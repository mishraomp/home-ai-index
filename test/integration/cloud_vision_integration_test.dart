import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/core/utils/label_mapper.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/data/services/api_usage_logger.dart';
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cloud_vision_integration_test.mocks.dart';

@GenerateMocks([http.Client, APIUsageLogger])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cloud Vision Integration Tests', () {
    late MockClient mockHttpClient;
    late MockAPIUsageLogger mockLogger;
    late CloudVisionService cloudVisionService;
    late APICredentials testCredentials;
    final labelMapper = LabelMapper();

    setUp(() {
      mockHttpClient = MockClient();
      mockLogger = MockAPIUsageLogger();
      cloudVisionService = CloudVisionServiceImpl(
        client: mockHttpClient,
        logger: mockLogger,
      );
      testCredentials = const APICredentials(apiKey: 'test-api-key-1234567890');
    });

    group('End-to-End Image Recognition', () {
      test(
        'should complete full recognition flow with category mapping',
        () async {
          // Arrange - Simulate a chair image
          final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
          final request = CloudVisionRequest(imageBytes: imageBytes);

          // Mock successful API response
          when(
            mockHttpClient.post(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).thenAnswer(
            (_) async => http.Response('''
              {
                "responses": [
                  {
                    "labelAnnotations": [
                      {
                        "mid": "/m/012345",
                        "description": "Dining Chair",
                        "score": 0.95,
                        "topicality": 0.95
                      },
                      {
                        "mid": "/m/067890",
                        "description": "Furniture",
                        "score": 0.90,
                        "topicality": 0.90
                      },
                      {
                        "mid": "/m/054321",
                        "description": "Wood",
                        "score": 0.85,
                        "topicality": 0.85
                      }
                    ]
                  }
                ]
              }
              ''', 200),
          );

          // Act
          final response = await cloudVisionService.recognizeImage(
            request,
            testCredentials,
          );

          // Convert to RecognitionResult
          final result = RecognitionResult.fromCloudVision(
            response,
            labelMapper,
          );

          // Assert
          expect(result.category, equals('furniture'));
          expect(result.confidence, greaterThanOrEqualTo(0.85));
          expect(result.label, equals('Dining Chair'));
          expect(result.alternativeLabels, contains('Furniture'));
          expect(result.source, equals(RecognitionSource.cloudVision));
        },
      );

      test('should handle electronics category', () async {
        // Arrange - Simulate a laptop image
        final imageBytes = Uint8List.fromList([10, 20, 30]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        // Mock API response for electronics
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('''
              {
                "responses": [
                  {
                    "labelAnnotations": [
                      {
                        "mid": "/m/laptop",
                        "description": "Laptop",
                        "score": 0.92,
                        "topicality": 0.92
                      },
                      {
                        "mid": "/m/computer",
                        "description": "Computer",
                        "score": 0.88,
                        "topicality": 0.88
                      }
                    ]
                  }
                ]
              }
              ''', 200),
        );

        // Act
        final response = await cloudVisionService.recognizeImage(
          request,
          testCredentials,
        );
        final result = RecognitionResult.fromCloudVision(response, labelMapper);

        // Assert
        expect(result.category, equals('electronics'));
        expect(result.confidence, greaterThanOrEqualTo(0.88));
      });

      test('should fallback to miscellaneous for unknown items', () async {
        // Arrange - Simulate an unusual item
        final imageBytes = Uint8List.fromList([100, 200]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        // Mock API response with unknown labels
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('''
              {
                "responses": [
                  {
                    "labelAnnotations": [
                      {
                        "mid": "/m/unknown",
                        "description": "Rare Artifact",
                        "score": 0.75,
                        "topicality": 0.75
                      }
                    ]
                  }
                ]
              }
              ''', 200),
        );

        // Act
        final response = await cloudVisionService.recognizeImage(
          request,
          testCredentials,
        );
        final result = RecognitionResult.fromCloudVision(response, labelMapper);

        // Assert
        expect(result.category, equals('other'));
        expect(result.label, equals('Rare Artifact'));
      });
    });

    group('Error Handling Integration', () {
      test('should handle authentication errors gracefully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        // Mock 401 Unauthorized response
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('''
              {
                "error": {
                  "code": 401,
                  "message": "API key not valid",
                  "status": "UNAUTHENTICATED"
                }
              }
              ''', 401),
        );

        // Act & Assert
        expect(
          () => cloudVisionService.recognizeImage(request, testCredentials),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should handle quota exceeded', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        // Mock 429 response
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('''
              {
                "error": {
                  "code": 429,
                  "message": "Quota exceeded",
                  "status": "RESOURCE_EXHAUSTED"
                }
              }
              ''', 429),
        );

        // Act & Assert
        expect(
          () => cloudVisionService.recognizeImage(request, testCredentials),
          throwsA(isA<QuotaExceededException>()),
        );
      });

      test('should retry on server errors and eventually succeed', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        var callCount = 0;
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount <= 2) {
            // First two calls fail with 503
            return http.Response(
              '{"error": {"code": 503, "message": "Service Unavailable"}}',
              503,
            );
          }
          // Third call succeeds
          return http.Response('''
            {
              "responses": [
                {
                  "labelAnnotations": [
                    {
                      "mid": "/m/book",
                      "description": "Book",
                      "score": 0.90,
                      "topicality": 0.90
                    }
                  ]
                }
              ]
            }
            ''', 200);
        });

        // Act
        final response = await cloudVisionService.recognizeImage(
          request,
          testCredentials,
        );
        final result = RecognitionResult.fromCloudVision(response, labelMapper);

        // Assert
        expect(result.category, equals('books'));
        expect(callCount, equals(3)); // Should have retried twice
      });
    });

    group('Performance and Validation', () {
      test('should validate image size before making API call', () async {
        // Arrange - Create image larger than 20MB
        final largeImageBytes = Uint8List(21 * 1024 * 1024);
        final request = CloudVisionRequest(imageBytes: largeImageBytes);

        // Act & Assert - validate() should throw
        expect(() => request.validate(), throwsArgumentError);
      });

      test('should validate maxResults range', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);

        // Act & Assert - maxResults too low
        var request = CloudVisionRequest(imageBytes: imageBytes, maxResults: 0);
        expect(() => request.validate(), throwsArgumentError);

        // maxResults too high
        request = CloudVisionRequest(imageBytes: imageBytes, maxResults: 51);
        expect(() => request.validate(), throwsArgumentError);
      });

      test('should handle empty API response gracefully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        final request = CloudVisionRequest(imageBytes: imageBytes);

        // Mock response with no labels
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('''
              {
                "responses": [
                  {
                    "labelAnnotations": []
                  }
                ]
              }
              ''', 200),
        );

        // Act & Assert - Should throw because no labels
        expect(
          () => cloudVisionService
              .recognizeImage(request, testCredentials)
              .then(
                (response) =>
                    RecognitionResult.fromCloudVision(response, labelMapper),
              ),
          throwsArgumentError,
        );
      });
    });
  });
}
