import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/location_history.dart';

void main() {
  group('LocationHistory Model', () {
    final timestamp = DateTime.now();

    final testHistory = LocationHistory(
      id: 'history-id-1',
      itemId: 'item-id-1',
      locationId: 'pantry',
      timestamp: timestamp,
    );

    group('fromJson', () {
      test('should correctly deserialize from JSON map', () {
        final json = {
          'id': 'history-id-1',
          'itemId': 'item-id-1',
          'locationId': 'pantry',
          'timestamp': timestamp.toIso8601String(),
        };

        final history = LocationHistory.fromJson(json);

        expect(history.id, 'history-id-1');
        expect(history.itemId, 'item-id-1');
        expect(history.locationId, 'pantry');
        expect(history.timestamp, timestamp);
      });
    });

    group('fromDatabase', () {
      test('should correctly deserialize from database map', () {
        final map = {
          'id': 'history-id-1',
          'item_id': 'item-id-1',
          'location_id': 'pantry',
          'timestamp': timestamp.toIso8601String(),
        };

        final history = LocationHistory.fromDatabase(map);

        expect(history.id, 'history-id-1');
        expect(history.itemId, 'item-id-1');
        expect(history.locationId, 'pantry');
        expect(history.timestamp, timestamp);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON map', () {
        final json = testHistory.toJson();

        expect(json['id'], 'history-id-1');
        expect(json['itemId'], 'item-id-1');
        expect(json['locationId'], 'pantry');
        expect(json['timestamp'], timestamp.toIso8601String());
      });
    });

    group('toDatabase', () {
      test('should correctly serialize to database map with snake_case', () {
        final map = testHistory.toDatabase();

        expect(map['id'], 'history-id-1');
        expect(map['item_id'], 'item-id-1');
        expect(map['location_id'], 'pantry');
        expect(map['timestamp'], timestamp.toIso8601String());
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final newTimestamp = DateTime.now().add(const Duration(days: 1));
        final updatedHistory = testHistory.copyWith(
          locationId: 'fridge',
          timestamp: newTimestamp,
        );

        expect(updatedHistory.id, testHistory.id);
        expect(updatedHistory.itemId, testHistory.itemId);
        expect(updatedHistory.locationId, 'fridge');
        expect(updatedHistory.timestamp, newTimestamp);
      });

      test('should keep original values for non-updated fields', () {
        final updatedHistory = testHistory.copyWith(locationId: 'fridge');

        expect(updatedHistory.timestamp, testHistory.timestamp);
        expect(updatedHistory.itemId, testHistory.itemId);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields match', () {
        final history1 = LocationHistory(
          id: 'history-id-1',
          itemId: 'item-id-1',
          locationId: 'pantry',
          timestamp: timestamp,
        );

        final history2 = LocationHistory(
          id: 'history-id-1',
          itemId: 'item-id-1',
          locationId: 'pantry',
          timestamp: timestamp,
        );

        expect(history1, equals(history2));
        expect(history1.hashCode, equals(history2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final history1 = testHistory;
        final history2 = testHistory.copyWith(locationId: 'fridge');

        expect(history1, isNot(equals(history2)));
        expect(history1.hashCode, isNot(equals(history2.hashCode)));
      });
    });
  });
}
