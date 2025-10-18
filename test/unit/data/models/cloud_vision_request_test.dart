import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/cloud_vision_request.dart';

void main() {
  group('CloudVisionRequest', () {
    late Uint8List testImageBytes;

    setUp(() {
      // Create a small test image (100 bytes)
      testImageBytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
    });

    group('toJson', () {
      test('should create valid JSON structure', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['requests'], isA<List>());
        expect(json['requests'].length, equals(1));
      });

      test('should base64 encode image bytes', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act
        final json = request.toJson();
        final requestItem = json['requests'][0] as Map<String, dynamic>;
        final image = requestItem['image'] as Map<String, dynamic>;
        final content = image['content'] as String;

        // Assert
        expect(content, equals(base64Encode(testImageBytes)));
      });

      test('should include LABEL_DETECTION feature', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act
        final json = request.toJson();
        final requestItem = json['requests'][0] as Map<String, dynamic>;
        final features = requestItem['features'] as List;

        // Assert
        expect(features.length, equals(1));
        expect(features[0]['type'], equals('LABEL_DETECTION'));
      });

      test('should include maxResults in features', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 15,
        );

        // Act
        final json = request.toJson();
        final requestItem = json['requests'][0] as Map<String, dynamic>;
        final features = requestItem['features'] as List;

        // Assert
        expect(features[0]['maxResults'], equals(15));
      });

      test('should include language hints', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act
        final json = request.toJson();
        final requestItem = json['requests'][0] as Map<String, dynamic>;
        final imageContext =
            requestItem['imageContext'] as Map<String, dynamic>;

        // Assert
        expect(imageContext['languageHints'], equals(['en']));
      });

      test('should use default maxResults of 10', () {
        // Arrange
        final request = CloudVisionRequest(imageBytes: testImageBytes);

        // Act
        final json = request.toJson();
        final requestItem = json['requests'][0] as Map<String, dynamic>;
        final features = requestItem['features'] as List;

        // Assert
        expect(features[0]['maxResults'], equals(10));
      });
    });

    group('validate', () {
      test('should pass validation for valid request', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act & Assert
        expect(() => request.validate(), returnsNormally);
      });

      test('should throw ArgumentError for empty image bytes', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: Uint8List(0),
        );

        // Act & Assert
        expect(
          () => request.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot be empty'),
            ),
          ),
        );
      });

      test('should throw ArgumentError for image exceeding 20MB', () {
        // Arrange - Create 21MB image
        final largeImage = Uint8List(21 * 1024 * 1024);
        final request = CloudVisionRequest(
          imageBytes: largeImage,
        );

        // Act & Assert
        expect(
          () => request.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('exceeds maximum'),
            ),
          ),
        );
      });

      test('should throw ArgumentError for maxResults < 1', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 0,
        );

        // Act & Assert
        expect(
          () => request.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be between 1 and 50'),
            ),
          ),
        );
      });

      test('should throw ArgumentError for maxResults > 50', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 51,
        );

        // Act & Assert
        expect(
          () => request.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be between 1 and 50'),
            ),
          ),
        );
      });

      test('should pass validation for maxResults = 1', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 1,
        );

        // Act & Assert
        expect(() => request.validate(), returnsNormally);
      });

      test('should pass validation for maxResults = 50', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 50,
        );

        // Act & Assert
        expect(() => request.validate(), returnsNormally);
      });
    });

    group('toString', () {
      test('should include image size and maxResults', () {
        // Arrange
        final request = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act
        final result = request.toString();

        // Assert
        expect(result, contains('100 bytes'));
        expect(result, contains('maxResults: 10'));
      });
    });

    group('equality', () {
      test('should be equal for same image bytes and maxResults', () {
        // Arrange
        final request1 = CloudVisionRequest(
          imageBytes: testImageBytes,
        );
        final request2 = CloudVisionRequest(
          imageBytes: testImageBytes,
        );

        // Act & Assert
        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      test('should not be equal for different image bytes', () {
        // Arrange
        final differentBytes = Uint8List.fromList([1, 2, 3]);
        final request1 = CloudVisionRequest(
          imageBytes: testImageBytes,
        );
        final request2 = CloudVisionRequest(
          imageBytes: differentBytes,
        );

        // Act & Assert
        expect(request1, isNot(equals(request2)));
      });

      test('should not be equal for different maxResults', () {
        // Arrange
        final request1 = CloudVisionRequest(
          imageBytes: testImageBytes,
        );
        final request2 = CloudVisionRequest(
          imageBytes: testImageBytes,
          maxResults: 15,
        );

        // Act & Assert
        expect(request1, isNot(equals(request2)));
      });
    });
  });
}
