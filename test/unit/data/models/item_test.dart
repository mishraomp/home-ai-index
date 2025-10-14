import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';

void main() {
  group('Item Model', () {
    // Test data
    final now = DateTime.now();
    final expirationDate = DateTime.now().add(const Duration(days: 7));

    final testItem = Item(
      id: 'test-id-1',
      name: 'Test Item',
      notes: 'Test notes',
      quantity: 5,
      categoryId: 'groceries',
      locationId: 'pantry',
      expirationDate: expirationDate,
      imagePath: '/path/to/image.jpg',
      mlDetectedLabel: 'food',
      mlConfidenceScore: 0.95,
      addedAt: now,
      updatedAt: now,
    );

    group('fromJson', () {
      test('should correctly deserialize from JSON map', () {
        final json = {
          'id': 'test-id-1',
          'name': 'Test Item',
          'notes': 'Test notes',
          'quantity': 5,
          'categoryId': 'groceries',
          'locationId': 'pantry',
          'expirationDate': expirationDate.toIso8601String(),
          'imagePath': '/path/to/image.jpg',
          'mlDetectedLabel': 'food',
          'mlConfidenceScore': 0.95,
          'addedAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final item = Item.fromJson(json);

        expect(item.id, 'test-id-1');
        expect(item.name, 'Test Item');
        expect(item.notes, 'Test notes');
        expect(item.quantity, 5);
        expect(item.categoryId, 'groceries');
        expect(item.locationId, 'pantry');
        expect(item.expirationDate, expirationDate);
        expect(item.imagePath, '/path/to/image.jpg');
        expect(item.mlDetectedLabel, 'food');
        expect(item.mlConfidenceScore, 0.95);
        expect(item.addedAt, now);
        expect(item.updatedAt, now);
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'test-id-1',
          'name': 'Test Item',
          'notes': null,
          'quantity': 1,
          'categoryId': 'groceries',
          'locationId': 'pantry',
          'expirationDate': null,
          'imagePath': null,
          'mlDetectedLabel': null,
          'mlConfidenceScore': null,
          'addedAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final item = Item.fromJson(json);

        expect(item.notes, isNull);
        expect(item.expirationDate, isNull);
        expect(item.imagePath, isNull);
        expect(item.mlDetectedLabel, isNull);
        expect(item.mlConfidenceScore, isNull);
      });
    });

    group('fromDatabase', () {
      test('should correctly deserialize from database map', () {
        final map = {
          'id': 'test-id-1',
          'name': 'Test Item',
          'notes': 'Test notes',
          'quantity': 5,
          'category_id': 'groceries',
          'location_id': 'pantry',
          'expiration_date': expirationDate.toIso8601String(),
          'image_path': '/path/to/image.jpg',
          'ml_detected_label': 'food',
          'ml_confidence_score': 0.95,
          'added_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final item = Item.fromDatabase(map);

        expect(item.id, 'test-id-1');
        expect(item.name, 'Test Item');
        expect(item.categoryId, 'groceries');
        expect(item.locationId, 'pantry');
        expect(item.mlDetectedLabel, 'food');
        expect(item.mlConfidenceScore, 0.95);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON map', () {
        final json = testItem.toJson();

        expect(json['id'], 'test-id-1');
        expect(json['name'], 'Test Item');
        expect(json['notes'], 'Test notes');
        expect(json['quantity'], 5);
        expect(json['categoryId'], 'groceries');
        expect(json['locationId'], 'pantry');
        expect(json['expirationDate'], expirationDate.toIso8601String());
        expect(json['imagePath'], '/path/to/image.jpg');
        expect(json['mlDetectedLabel'], 'food');
        expect(json['mlConfidenceScore'], 0.95);
        expect(json['addedAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
      });
    });

    group('toDatabase', () {
      test('should correctly serialize to database map with snake_case', () {
        final map = testItem.toDatabase();

        expect(map['id'], 'test-id-1');
        expect(map['name'], 'Test Item');
        expect(map['category_id'], 'groceries');
        expect(map['location_id'], 'pantry');
        expect(map['expiration_date'], expirationDate.toIso8601String());
        expect(map['image_path'], '/path/to/image.jpg');
        expect(map['ml_detected_label'], 'food');
        expect(map['ml_confidence_score'], 0.95);
        expect(map['added_at'], now.toIso8601String());
        expect(map['updated_at'], now.toIso8601String());
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedItem = testItem.copyWith(
          name: 'Updated Name',
          quantity: 10,
        );

        expect(updatedItem.id, testItem.id);
        expect(updatedItem.name, 'Updated Name');
        expect(updatedItem.quantity, 10);
        expect(updatedItem.categoryId, testItem.categoryId);
        expect(updatedItem.locationId, testItem.locationId);
      });

      test('should keep original values for non-updated fields', () {
        final updatedItem = testItem.copyWith(name: 'New Name');

        expect(updatedItem.quantity, testItem.quantity);
        expect(updatedItem.notes, testItem.notes);
        expect(updatedItem.categoryId, testItem.categoryId);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields match', () {
        final item1 = Item(
          id: 'test-id-1',
          name: 'Test Item',
          notes: 'Test notes',
          quantity: 5,
          categoryId: 'groceries',
          locationId: 'pantry',
          expirationDate: expirationDate,
          imagePath: '/path/to/image.jpg',
          mlDetectedLabel: 'food',
          mlConfidenceScore: 0.95,
          addedAt: now,
          updatedAt: now,
        );

        final item2 = Item(
          id: 'test-id-1',
          name: 'Test Item',
          notes: 'Test notes',
          quantity: 5,
          categoryId: 'groceries',
          locationId: 'pantry',
          expirationDate: expirationDate,
          imagePath: '/path/to/image.jpg',
          mlDetectedLabel: 'food',
          mlConfidenceScore: 0.95,
          addedAt: now,
          updatedAt: now,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final item1 = testItem;
        final item2 = testItem.copyWith(name: 'Different Name');

        expect(item1, isNot(equals(item2)));
        expect(item1.hashCode, isNot(equals(item2.hashCode)));
      });
    });
  });
}
