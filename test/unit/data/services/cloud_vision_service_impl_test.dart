import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';
import 'package:home_ai_index/data/services/api_usage_logger.dart';
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cloud_vision_service_impl_test.mocks.dart';

@GenerateMocks([http.Client, DatabaseHelper, APIUsageLogger])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudVisionServiceImpl', () {
    late MockClient mockClient;
    late MockAPIUsageLogger mockLogger;
    late CloudVisionService service;
    late APICredentials credentials;

    setUp(() {
      mockClient = MockClient();
      mockLogger = MockAPIUsageLogger();
      service = CloudVisionServiceImpl(client: mockClient, logger: mockLogger);
      credentials = const APICredentials(apiKey: 'test-api-key-1234567890');
    });

    group('recognizeImage - success', () {
      test('should make successful API call and parse response', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3, 4]),
        );

        final responseBody = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Apple', 'score': 0.95},
                {'description': 'Fruit', 'score': 0.92},
              ],
            },
          ],
        };

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        // Act
        final result = await service.recognizeImage(request, credentials);

        // Assert
        expect(result.labelAnnotations, hasLength(2));
        expect(result.topLabel?.description, equals('Apple'));
        verify(
          mockClient.post(
            Uri.https('vision.googleapis.com', '/v1/images:annotate', {
              'key': 'test-api-key-1234567890',
            }),
            headers: {'Content-Type': 'application/json'},
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('should include correct request body', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        final request = CloudVisionRequest(
          imageBytes: imageBytes,
          maxResults: 5,
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'responses': [
                {
                  'labelAnnotations': [
                    {'description': 'Test', 'score': 0.9},
                  ],
                },
              ],
            }),
            200,
          ),
        );

        // Act
        await service.recognizeImage(request, credentials);

        // Assert
        final captured =
            verify(
                  mockClient.post(
                    any,
                    headers: anyNamed('headers'),
                    body: captureAnyNamed('body'),
                  ),
                ).captured.single
                as String;

        final requestBody = jsonDecode(captured);
        expect(requestBody['requests'], isList);
        expect(requestBody['requests'][0]['image']['content'], isNotNull);
        expect(
          requestBody['requests'][0]['features'][0]['type'],
          equals('LABEL_DETECTION'),
        );
        expect(
          requestBody['requests'][0]['features'][0]['maxResults'],
          equals(5),
        );
      });
    });

    group('recognizeImage - error handling', () {
      test('should throw AuthenticationException for 401', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 401,
                'message': 'Invalid API key',
                'status': 'UNAUTHENTICATED',
              },
            }),
            401,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(
            isA<AuthenticationException>().having(
              (e) => e.message,
              'message',
              contains('Invalid API key'),
            ),
          ),
        );
      });

      test('should throw AuthenticationException for 403', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 403,
                'message': 'Permission denied',
                'status': 'PERMISSION_DENIED',
              },
            }),
            403,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should throw QuotaExceededException for 429', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 429,
                'message': 'Quota exceeded',
                'status': 'RESOURCE_EXHAUSTED',
              },
            }),
            429,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(
            isA<QuotaExceededException>().having(
              (e) => e.message,
              'message',
              contains('Quota exceeded'),
            ),
          ),
        );
      });

      test('should throw ApiException for 400 bad request', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 400,
                'message': 'Invalid image format',
                'status': 'INVALID_ARGUMENT',
              },
            }),
            400,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              equals(400),
            ),
          ),
        );
      });

      test('should throw ApiException for 500 server error', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Internal server error', 500));

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              equals(500),
            ),
          ),
        );
      });

      test('should throw NetworkException on network failure', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(const SocketException('No internet connection'));

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('No internet connection'),
            ),
          ),
        );
      });

      test('should throw TimeoutException on timeout', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(const TimeoutException('Request timeout'));

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<TimeoutException>()),
        );
      });
    });

    group('recognizeImage - retry logic', () {
      test('should retry on retryable errors (503)', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        var callCount = 0;
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount < 3) {
            return http.Response('Service unavailable', 503);
          }
          return http.Response(
            jsonEncode({
              'responses': [
                {
                  'labelAnnotations': [
                    {'description': 'Success', 'score': 0.9},
                  ],
                },
              ],
            }),
            200,
          );
        });

        // Act
        final result = await service.recognizeImage(request, credentials);

        // Assert
        expect(result.topLabel?.description, equals('Success'));
        expect(callCount, equals(3)); // Initial + 2 retries
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(3);
      });

      test('should retry on retryable errors (504)', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        var callCount = 0;
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount < 2) {
            return http.Response('Gateway timeout', 504);
          }
          return http.Response(
            jsonEncode({
              'responses': [
                {
                  'labelAnnotations': [
                    {'description': 'Success', 'score': 0.9},
                  ],
                },
              ],
            }),
            200,
          );
        });

        // Act
        final result = await service.recognizeImage(request, credentials);

        // Assert
        expect(result.topLabel?.description, equals('Success'));
        expect(callCount, equals(2));
      });

      test('should NOT retry on non-retryable errors (400)', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 400,
                'message': 'Invalid request',
                'status': 'INVALID_ARGUMENT',
              },
            }),
            400,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<ApiException>()),
        );

        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1); // Should NOT retry
      });

      test('should NOT retry on authentication errors (401)', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 401,
                'message': 'Unauthorized',
                'status': 'UNAUTHENTICATED',
              },
            }),
            401,
          ),
        );

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<AuthenticationException>()),
        );

        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1); // Should NOT retry
      });

      test('should throw after max retries exceeded', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Service unavailable', 503));

        // Act & Assert
        await expectLater(
          service.recognizeImage(request, credentials),
          throwsA(isA<ApiException>()),
        );

        // Initial call + 2 retries = 3 total
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(3);
      });
    });

    group('recognizeImage - request validation', () {
      test('should validate request before sending', () async {
        // Arrange - Create invalid request (empty bytes)
        final request = CloudVisionRequest(imageBytes: Uint8List.fromList([]));

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<ArgumentError>()),
        );

        // Should not make HTTP call
        verifyNever(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        );
      });

      test('should validate credentials before sending', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );
        const invalidCredentials = APICredentials(apiKey: '');

        // Act & Assert
        expect(
          () => service.recognizeImage(request, invalidCredentials),
          throwsA(isA<ArgumentError>()),
        );

        // Should not make HTTP call
        verifyNever(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        );
      });
    });

    group('recognizeImage - timeout handling', () {
      test('should use configured timeout', () async {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List.fromList([1, 2, 3]),
        );

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(
            const Duration(seconds: 15),
          ); // Longer than timeout
          return http.Response('Too late', 200);
        });

        // Act & Assert
        expect(
          () => service.recognizeImage(request, credentials),
          throwsA(isA<TimeoutException>()),
        );
      });
    });
  });
}
