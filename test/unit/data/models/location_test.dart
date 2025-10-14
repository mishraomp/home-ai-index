import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/location.dart';

void main() {
  group('Location Model', () {
    const testLocation = Location(
      id: 'pantry',
      name: 'Pantry',
      parentId: 'kitchen',
    );

    const rootLocation = Location(id: 'home', name: 'Home', parentId: null);

    group('fromJson', () {
      test('should correctly deserialize from JSON map', () {
        final json = {'id': 'pantry', 'name': 'Pantry', 'parentId': 'kitchen'};

        final location = Location.fromJson(json);

        expect(location.id, 'pantry');
        expect(location.name, 'Pantry');
        expect(location.parentId, 'kitchen');
      });

      test('should handle null parentId for root locations', () {
        final json = {'id': 'home', 'name': 'Home', 'parentId': null};

        final location = Location.fromJson(json);

        expect(location.id, 'home');
        expect(location.name, 'Home');
        expect(location.parentId, isNull);
      });
    });

    group('fromDatabase', () {
      test('should correctly deserialize from database map', () {
        final map = {'id': 'pantry', 'name': 'Pantry', 'parent_id': 'kitchen'};

        final location = Location.fromDatabase(map);

        expect(location.id, 'pantry');
        expect(location.name, 'Pantry');
        expect(location.parentId, 'kitchen');
      });

      test('should handle null parent_id', () {
        final map = {'id': 'home', 'name': 'Home', 'parent_id': null};

        final location = Location.fromDatabase(map);

        expect(location.parentId, isNull);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON map', () {
        final json = testLocation.toJson();

        expect(json['id'], 'pantry');
        expect(json['name'], 'Pantry');
        expect(json['parentId'], 'kitchen');
      });

      test('should include null parentId', () {
        final json = rootLocation.toJson();

        expect(json['parentId'], isNull);
      });
    });

    group('toDatabase', () {
      test('should correctly serialize to database map with snake_case', () {
        final map = testLocation.toDatabase();

        expect(map['id'], 'pantry');
        expect(map['name'], 'Pantry');
        expect(map['parent_id'], 'kitchen');
      });

      test('should include null parent_id', () {
        final map = rootLocation.toDatabase();

        expect(map['parent_id'], isNull);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedLocation = testLocation.copyWith(
          name: 'Updated Pantry',
          parentId: 'storage-room',
        );

        expect(updatedLocation.id, testLocation.id);
        expect(updatedLocation.name, 'Updated Pantry');
        expect(updatedLocation.parentId, 'storage-room');
      });

      test('should keep original values for non-updated fields', () {
        final updatedLocation = testLocation.copyWith(name: 'New Name');

        expect(updatedLocation.parentId, testLocation.parentId);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields match', () {
        const location1 = Location(
          id: 'pantry',
          name: 'Pantry',
          parentId: 'kitchen',
        );

        const location2 = Location(
          id: 'pantry',
          name: 'Pantry',
          parentId: 'kitchen',
        );

        expect(location1, equals(location2));
        expect(location1.hashCode, equals(location2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const location1 = testLocation;
        final location2 = testLocation.copyWith(name: 'Different Name');

        expect(location1, isNot(equals(location2)));
        expect(location1.hashCode, isNot(equals(location2.hashCode)));
      });

      test('should handle equality with null parentId', () {
        const location1 = Location(id: 'home', name: 'Home', parentId: null);

        const location2 = Location(id: 'home', name: 'Home', parentId: null);

        expect(location1, equals(location2));
      });
    });
  });
}
