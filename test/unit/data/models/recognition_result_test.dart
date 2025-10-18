import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/utils/label_mapper.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';

void main() {
  group('RecognitionResult', () {
    late LabelMapper mapper;

    setUp(() {
      mapper = LabelMapper();
    });

    group('fromCloudVision factory', () {
      test('should create result from Cloud Vision response with topLabel', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Apple', 'score': 0.95},
                {'description': 'Fruit', 'score': 0.92},
                {'description': 'Food', 'score': 0.88},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.label, equals('Apple'));
        expect(result.category, equals('groceries'));
        expect(result.confidence, equals(0.95));
        expect(result.source, equals(RecognitionSource.cloudVision));
      });

      test('should extract top 3 alternative labels skipping first', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Apple', 'score': 0.95},
                {'description': 'Fruit', 'score': 0.92},
                {'description': 'Food', 'score': 0.88},
                {'description': 'Red apple', 'score': 0.85},
                {'description': 'Produce', 'score': 0.80},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.alternativeLabels, hasLength(3));
        expect(result.alternativeLabels, ['Fruit', 'Food', 'Red apple']);
      });

      test('should handle fewer than 3 alternatives', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Laptop', 'score': 0.98},
                {'description': 'Computer', 'score': 0.95},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.alternativeLabels, hasLength(1));
        expect(result.alternativeLabels, ['Computer']);
      });

      test('should handle single label with no alternatives', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Chair', 'score': 0.90},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.alternativeLabels, isEmpty);
      });

      test('should map label to correct category via LabelMapper', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Smartphone', 'score': 0.96},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.category, equals('electronics'));
      });

      test('should handle unmapped labels with miscellaneous category', () {
        // Arrange
        final responseJson = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Unknown item xyz', 'score': 0.70},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act
        final result = RecognitionResult.fromCloudVision(response, mapper);

        // Assert
        expect(result.category, equals('other'));
      });

      test('should throw ArgumentError when response has no labels', () {
        // Arrange
        final responseJson = {
          'responses': [
            {'labelAnnotations': []},
          ],
        };
        final response = CloudVisionResponse.fromJson(responseJson);

        // Act & Assert
        expect(
          () => RecognitionResult.fromCloudVision(response, mapper),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('No labels detected'),
            ),
          ),
        );
      });
    });

    group('manual factory', () {
      test('should create result with manual source', () {
        // Act
        final result = RecognitionResult.manual(
          'My Custom Item',
          'electronics',
        );

        // Assert
        expect(result.label, equals('My Custom Item'));
        expect(result.category, equals('electronics'));
        expect(result.confidence, equals(1.0));
        expect(result.source, equals(RecognitionSource.manual));
        expect(result.alternativeLabels, isEmpty);
      });
    });

    group('offline factory', () {
      test('should create result with offline source', () {
        // Act
        final result = RecognitionResult.offline(
          label: 'Detected Item',
          category: 'groceries',
          confidence: 0.87,
        );

        // Assert
        expect(result.label, equals('Detected Item'));
        expect(result.category, equals('groceries'));
        expect(result.confidence, equals(0.87));
        expect(result.source, equals(RecognitionSource.offline));
        expect(result.alternativeLabels, isEmpty);
      });
    });

    group('confidence helpers', () {
      test('should identify high confidence (>90%)', () {
        // Arrange
        final result = RecognitionResult.manual(
          'Test',
          'other',
        ).copyWith(confidence: 0.95);

        // Act & Assert
        expect(result.isHighConfidence, isTrue);
        expect(result.isMediumConfidence, isFalse);
        expect(result.isLowConfidence, isFalse);
      });

      test('should identify medium confidence (70-90%)', () {
        // Arrange
        final result = RecognitionResult.manual(
          'Test',
          'other',
        ).copyWith(confidence: 0.85);

        // Act & Assert
        expect(result.isHighConfidence, isFalse);
        expect(result.isMediumConfidence, isTrue);
        expect(result.isLowConfidence, isFalse);
      });

      test('should identify low confidence (<70%)', () {
        // Arrange
        final result = RecognitionResult.manual(
          'Test',
          'other',
        ).copyWith(confidence: 0.60);

        // Act & Assert
        expect(result.isHighConfidence, isFalse);
        expect(result.isMediumConfidence, isFalse);
        expect(result.isLowConfidence, isTrue);
      });

      test('should handle boundary at 90%', () {
        // Arrange
        final result = RecognitionResult.manual(
          'Test',
          'other',
        ).copyWith(confidence: 0.9);

        // Act & Assert
        expect(result.isHighConfidence, isFalse);
        expect(result.isMediumConfidence, isTrue);
      });

      test('should handle boundary at 70%', () {
        // Arrange
        final result = RecognitionResult.manual(
          'Test',
          'other',
        ).copyWith(confidence: 0.7);

        // Act & Assert
        expect(result.isMediumConfidence, isTrue);
        expect(result.isLowConfidence, isFalse);
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON', () {
        // Arrange
        final result = RecognitionResult.offline(
          label: 'Test Item',
          category: 'electronics',
          confidence: 0.88,
        );

        // Act
        final json = result.toJson();

        // Assert
        expect(json['label'], equals('Test Item'));
        expect(json['category'], equals('electronics'));
        expect(json['confidence'], equals(0.88));
        expect(json['source'], equals('offline'));
      });

      test('should parse from JSON', () {
        // Arrange
        final json = {
          'label': 'Parsed Item',
          'category': 'groceries',
          'confidence': 0.92,
          'alternativeLabels': ['Alt A', 'Alt B', 'Alt C'],
          'source': 'cloudVision',
        };

        // Act
        final result = RecognitionResult.fromJson(json);

        // Assert
        expect(result.label, equals('Parsed Item'));
        expect(result.category, equals('groceries'));
        expect(result.confidence, equals(0.92));
        expect(result.alternativeLabels, equals(['Alt A', 'Alt B', 'Alt C']));
        expect(result.source, equals(RecognitionSource.cloudVision));
      });

      test('should handle empty alternativeLabels in JSON', () {
        // Arrange
        final json = {
          'label': 'Item',
          'category': 'furniture',
          'confidence': 0.75,
          'alternativeLabels': <String>[],
          'source': 'manual',
        };

        // Act
        final result = RecognitionResult.fromJson(json);

        // Assert
        expect(result.alternativeLabels, isEmpty);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        // Arrange
        final original = RecognitionResult.manual('Original', 'electronics');

        // Act
        final updated = original.copyWith(label: 'Updated', confidence: 0.80);

        // Assert
        expect(updated.label, equals('Updated'));
        expect(updated.confidence, equals(0.80));
        expect(updated.category, equals('electronics')); // Unchanged
        expect(updated.source, equals(RecognitionSource.manual)); // Unchanged
      });

      test('should keep original values if not specified', () {
        // Arrange
        final original = RecognitionResult.offline(
          label: 'Test',
          category: 'groceries',
          confidence: 0.88,
        );

        // Act
        final updated = original.copyWith(confidence: 0.92);

        // Assert
        expect(updated.label, equals('Test'));
        expect(updated.category, equals('groceries'));
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        final result1 = RecognitionResult.manual('Item', 'tools');
        final result2 = RecognitionResult.manual('Item', 'tools');

        // Act & Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different labels', () {
        // Arrange
        final result1 = RecognitionResult.manual('Item A', 'tools');
        final result2 = RecognitionResult.manual('Item B', 'tools');

        // Act & Assert
        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal for different sources', () {
        // Arrange
        final result1 = RecognitionResult.manual('Item', 'tools');
        final result2 = RecognitionResult.offline(
          label: 'Item',
          category: 'tools',
          confidence: 1.0,
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('should format with label and confidence', () {
        // Arrange
        final result = RecognitionResult.offline(
          label: 'Apple',
          category: 'groceries',
          confidence: 0.9234,
        );

        // Act
        final string = result.toString();

        // Assert
        expect(string, contains('Apple'));
        expect(string, contains('groceries'));
        expect(string, contains('92.3%'));
      });

      test('should include source', () {
        // Arrange
        final result = RecognitionResult.manual('Item', 'other');

        // Act
        final string = result.toString();

        // Assert
        expect(string, contains('manual'));
      });
    });
  });

  group('RecognitionSource', () {
    test('should have correct string values', () {
      expect(
        RecognitionSource.cloudVision.toString(),
        equals('RecognitionSource.cloudVision'),
      );
      expect(
        RecognitionSource.offline.toString(),
        equals('RecognitionSource.offline'),
      );
      expect(
        RecognitionSource.manual.toString(),
        equals('RecognitionSource.manual'),
      );
    });
  });
}
