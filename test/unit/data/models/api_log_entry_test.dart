import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/api_log_entry.dart';

void main() {
  group('APILogEntry', () {
    const testId = 'log-123';
    const testEndpoint = 'https://vision.googleapis.com/v1/images:annotate';
    final testTimestamp = DateTime(2025, 10, 16, 14, 30);
    const testStatusCode = 200;
    const testLatency = Duration(milliseconds: 250);
    const testError = 'Network timeout';

    group('success factory', () {
      test('should create successful log entry with all fields', () {
        // Act
        final entry = APILogEntry.success(
          id: testId,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
        );

        // Assert
        expect(entry.id, testId);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, testStatusCode);
        expect(entry.latency, testLatency);
        expect(entry.success, isTrue);
        expect(entry.error, isNull);
        expect(entry.timestamp, isNotNull);
      });
    });

    group('failure factory', () {
      test('should create failed log entry with all fields', () {
        // Act
        final entry = APILogEntry.failure(
          id: testId,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          error: testError,
        );

        // Assert
        expect(entry.id, testId);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, testStatusCode);
        expect(entry.latency, testLatency);
        expect(entry.success, isFalse);
        expect(entry.error, testError);
        expect(entry.timestamp, isNotNull);
      });

      test('should create failed entry without status code or latency', () {
        // Act
        final entry = APILogEntry.failure(
          id: testId,
          endpoint: testEndpoint,
          error: testError,
        );

        // Assert
        expect(entry.id, testId);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, isNull);
        expect(entry.latency, isNull);
        expect(entry.success, isFalse);
        expect(entry.error, testError);
      });
    });

    group('toJson()', () {
      test('should serialize successful entry to JSON', () {
        // Arrange
        final entry = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          success: true,
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json, {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': testStatusCode,
          'latencyMs': 250,
          'error': null,
          'success': true,
        });
      });

      test('should serialize failed entry to JSON', () {
        // Arrange
        final entry = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          error: testError,
          success: false,
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json, {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': testStatusCode,
          'latencyMs': 250,
          'error': testError,
          'success': false,
        });
      });

      test('should serialize entry without optional fields', () {
        // Arrange
        final entry = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          success: false,
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json, {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': null,
          'latencyMs': null,
          'error': null,
          'success': false,
        });
      });
    });

    group('fromJson()', () {
      test('should deserialize successful entry from JSON', () {
        // Arrange
        final json = {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': testStatusCode,
          'latencyMs': 250,
          'error': null,
          'success': true,
        };

        // Act
        final entry = APILogEntry.fromJson(json);

        // Assert
        expect(entry.id, testId);
        expect(entry.timestamp, testTimestamp);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, testStatusCode);
        expect(entry.latency, const Duration(milliseconds: 250));
        expect(entry.error, isNull);
        expect(entry.success, isTrue);
      });

      test('should deserialize failed entry from JSON', () {
        // Arrange
        final json = {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': testStatusCode,
          'latencyMs': 250,
          'error': testError,
          'success': false,
        };

        // Act
        final entry = APILogEntry.fromJson(json);

        // Assert
        expect(entry.id, testId);
        expect(entry.timestamp, testTimestamp);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, testStatusCode);
        expect(entry.latency, const Duration(milliseconds: 250));
        expect(entry.error, testError);
        expect(entry.success, isFalse);
      });

      test('should deserialize entry without optional fields', () {
        // Arrange
        final json = {
          'id': testId,
          'timestamp': testTimestamp.toIso8601String(),
          'endpoint': testEndpoint,
          'statusCode': null,
          'latencyMs': null,
          'error': null,
          'success': false,
        };

        // Act
        final entry = APILogEntry.fromJson(json);

        // Assert
        expect(entry.id, testId);
        expect(entry.timestamp, testTimestamp);
        expect(entry.endpoint, testEndpoint);
        expect(entry.statusCode, isNull);
        expect(entry.latency, isNull);
        expect(entry.error, isNull);
        expect(entry.success, isFalse);
      });
    });

    group('round-trip serialization', () {
      test('should maintain data through toJson/fromJson cycle', () {
        // Arrange
        final original = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          error: testError,
          success: false,
        );

        // Act
        final json = original.toJson();
        final restored = APILogEntry.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.timestamp, original.timestamp);
        expect(restored.endpoint, original.endpoint);
        expect(restored.statusCode, original.statusCode);
        expect(restored.latency, original.latency);
        expect(restored.error, original.error);
        expect(restored.success, original.success);
      });
    });

    group('toString()', () {
      test('should include key information in string representation', () {
        // Arrange
        final entry = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          success: true,
        );

        // Act
        final result = entry.toString();

        // Assert
        expect(result, contains(testId));
        expect(result, contains(testEndpoint));
        expect(result, contains('200'));
        expect(result, contains('250ms'));
        expect(result, contains('HTTP'));
      });

      test('should show error for unsuccessful entries', () {
        // Arrange
        final entry = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          error: testError,
          success: false,
        );

        // Act
        final result = entry.toString();

        // Assert
        expect(result, contains('error:'));
        expect(result, contains(testError));
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final entry1 = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          success: true,
        );
        final entry2 = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          statusCode: testStatusCode,
          latency: testLatency,
          success: true,
        );

        // Act & Assert
        expect(entry1, equals(entry2));
        expect(entry1.hashCode, equals(entry2.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final entry1 = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          success: true,
        );
        final entry2 = APILogEntry(
          id: 'different-id',
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          success: true,
        );

        // Act & Assert
        expect(entry1, isNot(equals(entry2)));
      });

      test('should not be equal when success status differs', () {
        // Arrange
        final entry1 = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          success: true,
        );
        final entry2 = APILogEntry(
          id: testId,
          timestamp: testTimestamp,
          endpoint: testEndpoint,
          success: false,
        );

        // Act & Assert
        expect(entry1, isNot(equals(entry2)));
      });
    });
  });
}
