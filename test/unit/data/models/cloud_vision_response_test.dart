import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/cloud_vision_response.dart';

void main() {
  group('CloudVisionResponse', () {
    group('fromJson - success response', () {
      test('should parse valid response with labels', () {
        // Arrange
        final json = {
          'responses': [
            {
              'labelAnnotations': [
                {
                  'description': 'Apple',
                  'score': 0.98,
                  'topicality': 0.97,
                  'mid': '/m/014j1m',
                },
                {
                  'description': 'Fruit',
                  'score': 0.95,
                  'topicality': 0.94,
                  'mid': '/m/0cyhg',
                },
              ],
            },
          ],
        };

        // Act
        final response = CloudVisionResponse.fromJson(json);

        // Assert
        expect(response.labelAnnotations.length, equals(2));
        expect(response.hasLabels, isTrue);
        expect(response.hasError, isFalse);
        expect(response.error, isNull);
      });

      test('should parse topLabel correctly', () {
        // Arrange
        final json = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Apple', 'score': 0.98},
                {'description': 'Fruit', 'score': 0.95},
              ],
            },
          ],
        };

        // Act
        final response = CloudVisionResponse.fromJson(json);

        // Assert
        expect(response.topLabel, isNotNull);
        expect(response.topLabel!.description, equals('Apple'));
        expect(response.topLabel!.score, equals(0.98));
      });

      test('should handle response with no labels', () {
        // Arrange
        final json = {
          'responses': [
            {'labelAnnotations': []},
          ],
        };

        // Act
        final response = CloudVisionResponse.fromJson(json);

        // Assert
        expect(response.labelAnnotations, isEmpty);
        expect(response.hasLabels, isFalse);
        expect(response.topLabel, isNull);
      });

      test('should handle missing labelAnnotations field', () {
        // Arrange
        final json = {
          'responses': [{}],
        };

        // Act
        final response = CloudVisionResponse.fromJson(json);

        // Assert
        expect(response.labelAnnotations, isEmpty);
        expect(response.hasLabels, isFalse);
      });
    });

    group('fromJson - error response', () {
      test('should parse error response', () {
        // Arrange
        final json = {
          'responses': [
            {
              'error': {
                'code': 403,
                'message': 'Invalid API key',
                'status': 'PERMISSION_DENIED',
              },
            },
          ],
        };

        // Act
        final response = CloudVisionResponse.fromJson(json);

        // Assert
        expect(response.hasError, isTrue);
        expect(response.hasLabels, isFalse);
        expect(response.error, isNotNull);
        expect(response.error!.code, equals(403));
        expect(response.error!.status, equals('PERMISSION_DENIED'));
      });

      test('should throw ApiException for empty responses array', () {
        // Arrange
        final json = {'responses': []};

        // Act & Assert
        expect(
          () => CloudVisionResponse.fromJson(json),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              contains('Empty response'),
            ),
          ),
        );
      });

      test('should throw ApiException for missing responses field', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act & Assert
        expect(
          () => CloudVisionResponse.fromJson(json),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('toString', () {
      test('should show label count for success response', () {
        // Arrange
        final json = {
          'responses': [
            {
              'labelAnnotations': [
                {'description': 'Apple', 'score': 0.98},
                {'description': 'Fruit', 'score': 0.95},
              ],
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(json);

        // Act
        final result = response.toString();

        // Assert
        expect(result, contains('labels: 2'));
      });

      test('should show error for error response', () {
        // Arrange
        final json = {
          'responses': [
            {
              'error': {
                'code': 403,
                'message': 'Invalid API key',
                'status': 'PERMISSION_DENIED',
              },
            },
          ],
        };
        final response = CloudVisionResponse.fromJson(json);

        // Act
        final result = response.toString();

        // Assert
        expect(result, contains('error:'));
      });
    });
  });

  group('LabelAnnotation', () {
    group('fromJson', () {
      test('should parse complete label annotation', () {
        // Arrange
        final json = {
          'description': 'Apple',
          'score': 0.98,
          'topicality': 0.97,
          'mid': '/m/014j1m',
        };

        // Act
        final label = LabelAnnotation.fromJson(json);

        // Assert
        expect(label.description, equals('Apple'));
        expect(label.score, equals(0.98));
        expect(label.topicality, equals(0.97));
        expect(label.mid, equals('/m/014j1m'));
      });

      test('should parse minimal label annotation', () {
        // Arrange
        final json = {'description': 'Fruit', 'score': 0.95};

        // Act
        final label = LabelAnnotation.fromJson(json);

        // Assert
        expect(label.description, equals('Fruit'));
        expect(label.score, equals(0.95));
        expect(label.topicality, isNull);
        expect(label.mid, isNull);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        // Arrange
        const label = LabelAnnotation(
          description: 'Apple',
          score: 0.98,
          topicality: 0.97,
          mid: '/m/014j1m',
        );

        // Act
        final json = label.toJson();

        // Assert
        expect(json['description'], equals('Apple'));
        expect(json['score'], equals(0.98));
        expect(json['topicality'], equals(0.97));
        expect(json['mid'], equals('/m/014j1m'));
      });

      test('should omit null optional fields', () {
        // Arrange
        const label = LabelAnnotation(description: 'Fruit', score: 0.95);

        // Act
        final json = label.toJson();

        // Assert
        expect(json.containsKey('topicality'), isFalse);
        expect(json.containsKey('mid'), isFalse);
      });
    });

    group('confidence levels', () {
      test('should identify high confidence (>90%)', () {
        // Arrange
        const label = LabelAnnotation(description: 'Apple', score: 0.95);

        // Act & Assert
        expect(label.isHighConfidence, isTrue);
        expect(label.isMediumConfidence, isFalse);
        expect(label.isLowConfidence, isFalse);
      });

      test('should identify medium confidence (70-90%)', () {
        // Arrange
        const label = LabelAnnotation(description: 'Fruit', score: 0.85);

        // Act & Assert
        expect(label.isHighConfidence, isFalse);
        expect(label.isMediumConfidence, isTrue);
        expect(label.isLowConfidence, isFalse);
      });

      test('should identify low confidence (<70%)', () {
        // Arrange
        const label = LabelAnnotation(description: 'Food', score: 0.65);

        // Act & Assert
        expect(label.isHighConfidence, isFalse);
        expect(label.isMediumConfidence, isFalse);
        expect(label.isLowConfidence, isTrue);
      });

      test('should handle boundary at 90%', () {
        // Arrange
        const label = LabelAnnotation(description: 'Item', score: 0.9);

        // Act & Assert
        expect(label.isHighConfidence, isFalse);
        expect(label.isMediumConfidence, isTrue);
      });

      test('should handle boundary at 70%', () {
        // Arrange
        const label = LabelAnnotation(description: 'Item', score: 0.7);

        // Act & Assert
        expect(label.isMediumConfidence, isTrue);
        expect(label.isLowConfidence, isFalse);
      });
    });

    group('toString', () {
      test('should format score as percentage', () {
        // Arrange
        const label = LabelAnnotation(description: 'Apple', score: 0.9876);

        // Act
        final result = label.toString();

        // Assert
        expect(result, contains('Apple'));
        expect(result, contains('98.8%'));
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        const label1 = LabelAnnotation(
          description: 'Apple',
          score: 0.98,
          mid: '/m/014j1m',
        );
        const label2 = LabelAnnotation(
          description: 'Apple',
          score: 0.98,
          mid: '/m/014j1m',
        );

        // Act & Assert
        expect(label1, equals(label2));
        expect(label1.hashCode, equals(label2.hashCode));
      });
    });
  });

  group('ErrorInfo', () {
    group('fromJson', () {
      test('should parse error info', () {
        // Arrange
        final json = {
          'code': 403,
          'message': 'Invalid API key',
          'status': 'PERMISSION_DENIED',
        };

        // Act
        final error = ErrorInfo.fromJson(json);

        // Assert
        expect(error.code, equals(403));
        expect(error.message, equals('Invalid API key'));
        expect(error.status, equals('PERMISSION_DENIED'));
      });
    });

    group('toJson', () {
      test('should convert to JSON', () {
        // Arrange
        const error = ErrorInfo(
          code: 429,
          message: 'Quota exceeded',
          status: 'RESOURCE_EXHAUSTED',
        );

        // Act
        final json = error.toJson();

        // Assert
        expect(json['code'], equals(429));
        expect(json['message'], equals('Quota exceeded'));
        expect(json['status'], equals('RESOURCE_EXHAUSTED'));
      });
    });

    group('toString', () {
      test('should include all error details', () {
        // Arrange
        const error = ErrorInfo(
          code: 500,
          message: 'Internal server error',
          status: 'INTERNAL',
        );

        // Act
        final result = error.toString();

        // Assert
        expect(result, contains('500'));
        expect(result, contains('INTERNAL'));
        expect(result, contains('Internal server error'));
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        // Arrange
        const error1 = ErrorInfo(
          code: 403,
          message: 'Forbidden',
          status: 'PERMISSION_DENIED',
        );
        const error2 = ErrorInfo(
          code: 403,
          message: 'Forbidden',
          status: 'PERMISSION_DENIED',
        );

        // Act & Assert
        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });
    });
  });
}
