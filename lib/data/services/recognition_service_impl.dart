import 'package:flutter/foundation.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/core/utils/label_mapper.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:home_ai_index/data/services/recognition_service.dart';

/// Implementation of RecognitionService using Google Cloud Vision API.
/// When Cloud Vision is unavailable, returns an error result prompting
/// the user to enter items manually (per User Story 2).
class RecognitionServiceImpl implements RecognitionService {
  RecognitionServiceImpl({
    required CloudVisionService cloudVisionService,
    LabelMapper? labelMapper,
  }) : _cloudVisionService = cloudVisionService,
       _labelMapper = labelMapper ?? LabelMapper();

  final CloudVisionService _cloudVisionService;
  final LabelMapper _labelMapper;

  APICredentials? _credentials;
  bool _offlineMode = false;

  @override
  Future<RecognitionResult> recognizeImage(Uint8List imageBytes) async {
    // Check if credentials are available and valid
    if (_credentials == null || !_credentials!.isValid()) {
      debugPrint('Cloud Vision API: No valid credentials available');
      return _createErrorResult(
        'Online recognition unavailable. Please configure API credentials in settings or enter items manually.',
      );
    }

    // If in offline mode, return error immediately
    if (_offlineMode) {
      debugPrint('Cloud Vision API: Offline mode enabled');
      return _createErrorResult(
        'Offline mode enabled. Online recognition is disabled.',
      );
    }

    // Try Cloud Vision API
    try {
      return await _recognizeWithCloudVision(imageBytes);
    } on AuthenticationException catch (e) {
      debugPrint('Cloud Vision auth failed: ${e.message}');
      return _createErrorResult(
        'Authentication failed. Please check your API credentials in settings.',
      );
    } on QuotaExceededException catch (e) {
      debugPrint('Cloud Vision quota exceeded: ${e.message}');
      return _createErrorResult(
        'API quota exceeded. Please try again later or enter items manually.',
      );
    } on NetworkException catch (e) {
      debugPrint('Network error: ${e.message}');
      return _createErrorResult(
        'No internet connection. Please check your connection or enter items manually.',
      );
    } on TimeoutException catch (e) {
      debugPrint('Cloud Vision timeout: ${e.message}');
      return _createErrorResult(
        'Request timed out. Please try again or enter items manually.',
      );
    } on AppException catch (e) {
      debugPrint('Cloud Vision error: ${e.message}');
      return _createErrorResult(
        'Recognition failed: ${e.message}. Please try again or enter items manually.',
      );
    } catch (e) {
      debugPrint('Unexpected error calling Cloud Vision: $e');
      return _createErrorResult(
        'An unexpected error occurred. Please enter items manually.',
      );
    }
  }

  /// Recognize image using Cloud Vision API
  Future<RecognitionResult> _recognizeWithCloudVision(
    Uint8List imageBytes,
  ) async {
    final request = CloudVisionRequest(imageBytes: imageBytes);

    final response = await _cloudVisionService.recognizeImage(
      request,
      _credentials!,
    );

    return RecognitionResult.fromCloudVision(response, _labelMapper);
  }

  /// Create an error result with a user-friendly message
  RecognitionResult _createErrorResult(String message) {
    return RecognitionResult.offline(
      label: message,
      category: 'other', // Use 'other' category which exists in database
      confidence: 0.0,
    );
  }

  @override
  void setCredentials(APICredentials? credentials) {
    _credentials = credentials;
  }

  @override
  APICredentials? getCredentials() {
    return _credentials;
  }

  @override
  void setOfflineMode(bool enabled) {
    _offlineMode = enabled;
  }

  @override
  bool isOfflineMode() {
    return _offlineMode;
  }

  @override
  void dispose() {
    // No resources to dispose since we removed offline service
  }
}
