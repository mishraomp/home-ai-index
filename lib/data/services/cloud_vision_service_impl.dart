import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_ai_index/core/constants/api_constants.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';
import 'package:home_ai_index/data/services/api_usage_logger.dart';
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:http/http.dart' as http;

/// Implementation of Cloud Vision API service
class CloudVisionServiceImpl implements CloudVisionService {
  CloudVisionServiceImpl({http.Client? client, APIUsageLogger? logger})
    : _client = client ?? http.Client(),
      _logger = logger ?? APIUsageLogger();

  final http.Client _client;
  final APIUsageLogger _logger;

  @override
  Future<CloudVisionResponse> recognizeImage(
    CloudVisionRequest request,
    APICredentials credentials,
  ) async {
    // Validate request
    try {
      request.validate();
    } catch (e) {
      throw ArgumentError('Invalid request: $e');
    }

    // Validate credentials
    if (!credentials.isValid()) {
      throw ArgumentError('Invalid API credentials');
    }

    // Build URL with API key as query parameter
    // API endpoint: https://vision.googleapis.com/v1/images:annotate
    final url = Uri.https('vision.googleapis.com', '/v1/images:annotate', {
      'key': credentials.apiKey,
    });

    // Retry logic
    var attempt = 0;
    const maxAttempts = ApiConstants.maxRetries + 1; // Initial + retries

    while (attempt < maxAttempts) {
      final requestStart = DateTime.now();

      try {
        // Make API call with timeout
        final response = await _client
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(request.toJson()),
            )
            .timeout(ApiConstants.timeout);

        final latency = DateTime.now().difference(requestStart);

        // Handle response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success - log it
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
          final parsedResponse = CloudVisionResponse.fromJson(responseBody);

          // Debug logging - print full response (only in debug mode)
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('🔍 CLOUD VISION API RESPONSE - SUCCESS');
          debugPrint('═══════════════════════════════════════════════════════');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Latency: ${latency.inMilliseconds}ms');
          debugPrint('Image Size: ${request.imageBytes.length} bytes');
          debugPrint(
            'Labels Returned: ${parsedResponse.labelAnnotations.length}',
          );
          debugPrint(
            '-----------------------------------------------------------',
          );
          debugPrint('📋 All Labels:');
          for (var i = 0; i < parsedResponse.labelAnnotations.length; i++) {
            final label = parsedResponse.labelAnnotations[i];
            debugPrint(
              '  ${i + 1}. ${label.description} (${(label.score * 100).toStringAsFixed(1)}%)',
            );
          }
          if (parsedResponse.labelAnnotations.isNotEmpty) {
            debugPrint(
              '-----------------------------------------------------------',
            );
            debugPrint(
              '⭐ Top Label: ${parsedResponse.topLabel?.description} (${(parsedResponse.topLabel!.score * 100).toStringAsFixed(1)}%)',
            );
          }
          debugPrint(
            '-----------------------------------------------------------',
          );
          debugPrint('📄 Raw JSON Response:');
          debugPrint(const JsonEncoder.withIndent('  ').convert(responseBody));
          debugPrint(
            '═══════════════════════════════════════════════════════\n',
          );

          // Log successful API call
          await _logger.logSuccess(
            endpoint: 'images:annotate',
            statusCode: response.statusCode,
            latency: latency,
            imageSize: request.imageBytes.length,
            labelsReturned: parsedResponse.labelAnnotations.length,
          );

          return parsedResponse;
        }

        // Error response - parse error details
        final isRetryable = _isRetryableStatusCode(response.statusCode);

        String errorMessage =
            'API request failed with status ${response.statusCode}';
        Map<String, dynamic>? errorDetails;

        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          if (errorBody.containsKey('error')) {
            final error = errorBody['error'] as Map<String, dynamic>;
            errorMessage = error['message'] as String? ?? errorMessage;
            errorDetails = error;
          }
        } catch (_) {
          // Failed to parse error, use default message
        }

        // Log error
        await _logger.logFailure(
          endpoint: 'images:annotate',
          statusCode: response.statusCode,
          latency: DateTime.now().difference(requestStart),
          error: errorMessage,
        );

        // For retryable errors, continue retry loop
        if (isRetryable && attempt < maxAttempts - 1) {
          attempt++;
          await _delayBeforeRetry(attempt);
          continue;
        }

        // Throw specific exception based on status code
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw AuthenticationException(errorMessage, details: errorDetails);
        } else if (response.statusCode == 429) {
          throw QuotaExceededException(errorMessage, details: errorDetails);
        } else {
          // Non-retryable error or max retries reached
          throw ApiException(
            errorMessage,
            statusCode: response.statusCode,
            details: errorDetails,
            canRetry: isRetryable,
          );
        }
      } on SocketException catch (e) {
        // Log network error
        await _logger.logFailure(
          endpoint: 'images:annotate',
          latency: DateTime.now().difference(requestStart),
          error: 'Network connection failed: ${e.message}',
        );
        throw NetworkException('Network connection failed: ${e.message}');
      } on async.TimeoutException catch (_) {
        // Log timeout
        await _logger.logFailure(
          endpoint: 'images:annotate',
          latency: DateTime.now().difference(requestStart),
          error: 'Request timeout',
        );
        throw const TimeoutException('Request timeout');
      } on http.ClientException catch (e) {
        // Log HTTP error
        await _logger.logFailure(
          endpoint: 'images:annotate',
          latency: DateTime.now().difference(requestStart),
          error: 'HTTP client error: $e',
        );
        throw NetworkException('HTTP client error: $e');
      } catch (e) {
        // Re-throw our custom exceptions
        if (e is AppException) {
          rethrow;
        }
        // Log and wrap unknown exceptions
        await _logger.logFailure(
          endpoint: 'images:annotate',
          latency: DateTime.now().difference(requestStart),
          error: 'Unexpected error: $e',
        );
        throw ApiException('Unexpected error: $e');
      }
    }

    // Should not reach here
    throw const ApiException('Max retries exceeded');
  }

  /// Check if status code is retryable (server errors)
  bool _isRetryableStatusCode(int statusCode) {
    return statusCode == 500 || statusCode == 503 || statusCode == 504;
  }

  /// Exponential backoff delay before retry
  Future<void> _delayBeforeRetry(int attempt) async {
    if (attempt <= 0 || attempt > ApiConstants.retryDelays.length) {
      return;
    }
    final delay = ApiConstants.retryDelays[attempt - 1];
    await Future.delayed(delay);
  }
}
