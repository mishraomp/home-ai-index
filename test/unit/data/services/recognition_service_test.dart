import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:home_ai_index/data/services/recognition_service_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recognition_service_test.mocks.dart';

@GenerateMocks([CloudVisionService])
void main() {
  group('RecognitionService', () {
    late MockCloudVisionService mockCloudVisionService;
    late RecognitionServiceImpl recognitionService;
    late APICredentials testCredentials;

    setUp(() {
      mockCloudVisionService = MockCloudVisionService();
      recognitionService = RecognitionServiceImpl(
        cloudVisionService: mockCloudVisionService,
      );
      testCredentials = const APICredentials(apiKey: 'test-api-key-1234567890');
    });

    group('Cloud Vision Recognition', () {
      test('should use Cloud Vision API when credentials are set', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(mockCloudVisionService.recognizeImage(any, any)).thenAnswer(
          (_) async => const CloudVisionResponse(
            labelAnnotations: [
              LabelAnnotation(
                description: 'Chair',
                score: 0.95,
                mid: '/m/chair',
              ),
            ],
          ),
        );

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.cloudVision));
        expect(result.label, equals('Chair'));
        expect(result.confidence, equals(0.95));
        verify(mockCloudVisionService.recognizeImage(any, any)).called(1);
      });
    });

    group('Error Handling - Returns Error Results', () {
      test('should return error when credentials not set', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        // Don't set credentials

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.confidence, equals(0.0));
        expect(result.label, contains('configure API credentials'));
        verifyNever(mockCloudVisionService.recognizeImage(any, any));
      });

      test('should return error when in offline mode', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);
        recognitionService.setOfflineMode(true);

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('Offline mode enabled'));
        verifyNever(mockCloudVisionService.recognizeImage(any, any));
      });

      test('should return error on authentication failure', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(
          mockCloudVisionService.recognizeImage(any, any),
        ).thenThrow(const AuthenticationException('Invalid API key'));

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('Authentication failed'));
        verify(mockCloudVisionService.recognizeImage(any, any)).called(1);
      });

      test('should return error on quota exceeded', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(
          mockCloudVisionService.recognizeImage(any, any),
        ).thenThrow(const QuotaExceededException('API quota exceeded'));

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('quota exceeded'));
      });

      test('should return error on network failure', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(
          mockCloudVisionService.recognizeImage(any, any),
        ).thenThrow(const NetworkException('No internet connection'));

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('No internet connection'));
      });

      test('should return error on timeout', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(
          mockCloudVisionService.recognizeImage(any, any),
        ).thenThrow(const TimeoutException('Request timed out'));

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('timed out'));
      });

      test('should return error on unexpected exception', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        recognitionService.setCredentials(testCredentials);

        when(
          mockCloudVisionService.recognizeImage(any, any),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await recognitionService.recognizeImage(imageBytes);

        // Assert
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.category, equals('other'));
        expect(result.label, contains('unexpected error'));
      });
    });

    group('Credentials Management', () {
      test('should store and retrieve credentials', () {
        // Act
        recognitionService.setCredentials(testCredentials);
        final retrieved = recognitionService.getCredentials();

        // Assert
        expect(retrieved, equals(testCredentials));
      });

      test('should allow clearing credentials', () {
        // Arrange
        recognitionService.setCredentials(testCredentials);

        // Act
        recognitionService.setCredentials(null);
        final retrieved = recognitionService.getCredentials();

        // Assert
        expect(retrieved, isNull);
      });
    });

    group('Offline Mode Toggle', () {
      test('should toggle offline mode', () {
        // Initial state
        expect(recognitionService.isOfflineMode(), isFalse);

        // Enable
        recognitionService.setOfflineMode(true);
        expect(recognitionService.isOfflineMode(), isTrue);

        // Disable
        recognitionService.setOfflineMode(false);
        expect(recognitionService.isOfflineMode(), isFalse);
      });
    });

    group('Resource Management', () {
      test('should dispose without errors', () {
        // Act & Assert - should not throw
        recognitionService.dispose();
      });
    });
  });
}
