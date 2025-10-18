import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';

void main() {
  group('Category Model', () {
    const testCategory = Category(
      id: 'groceries',
      name: 'Groceries',
      iconCodePoint: 0xe59c,
      isCustom: false,
    );

    group('fromJson', () {
      test('should correctly deserialize from JSON map', () {
        final json = {
          'id': 'groceries',
          'name': 'Groceries',
          'iconCodePoint': 0xe59c,
          'isCustom': false,
        };

        final category = Category.fromJson(json);

        expect(category.id, 'groceries');
        expect(category.name, 'Groceries');
        expect(category.iconCodePoint, 0xe59c);
        expect(category.isCustom, false);
      });

      test('should handle custom categories', () {
        final json = {
          'id': 'custom-id-1',
          'name': 'Custom Category',
          'iconCodePoint': 0xe3b2,
          'isCustom': true,
        };

        final category = Category.fromJson(json);

        expect(category.isCustom, true);
        expect(category.id, 'custom-id-1');
      });
    });

    group('fromDatabase', () {
      test('should correctly deserialize from database map', () {
        final map = {
          'id': 'groceries',
          'name': 'Groceries',
          'icon_code_point': 0xe59c,
          'is_custom': 0,
        };

        final category = Category.fromDatabase(map);

        expect(category.id, 'groceries');
        expect(category.name, 'Groceries');
        expect(category.iconCodePoint, 0xe59c);
        expect(category.isCustom, false);
      });

      test('should convert integer 1 to true for isCustom', () {
        final map = {
          'id': 'custom-id-1',
          'name': 'Custom Category',
          'icon_code_point': 0xe3b2,
          'is_custom': 1,
        };

        final category = Category.fromDatabase(map);

        expect(category.isCustom, true);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON map', () {
        final json = testCategory.toJson();

        expect(json['id'], 'groceries');
        expect(json['name'], 'Groceries');
        expect(json['iconCodePoint'], 0xe59c);
        expect(json['isCustom'], false);
      });
    });

    group('toDatabase', () {
      test('should correctly serialize to database map with snake_case', () {
        final map = testCategory.toDatabase();

        expect(map['id'], 'groceries');
        expect(map['name'], 'Groceries');
        expect(map['icon_code_point'], 0xe59c);
        expect(map['is_custom'], 0);
      });

      test('should convert true to integer 1 for isCustom', () {
        const customCategory = Category(
          id: 'custom-id-1',
          name: 'Custom Category',
          iconCodePoint: 0xe3b2,
          isCustom: true,
        );

        final map = customCategory.toDatabase();

        expect(map['is_custom'], 1);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedCategory = testCategory.copyWith(
          name: 'Updated Groceries',
          iconCodePoint: 0xe000,
        );

        expect(updatedCategory.id, testCategory.id);
        expect(updatedCategory.name, 'Updated Groceries');
        expect(updatedCategory.iconCodePoint, 0xe000);
        expect(updatedCategory.isCustom, testCategory.isCustom);
      });

      test('should keep original values for non-updated fields', () {
        final updatedCategory = testCategory.copyWith(name: 'New Name');

        expect(updatedCategory.iconCodePoint, testCategory.iconCodePoint);
        expect(updatedCategory.isCustom, testCategory.isCustom);
      });
    });

    group('Equatable', () {
      test('should be equal when all fields match', () {
        const category1 = Category(
          id: 'groceries',
          name: 'Groceries',
          iconCodePoint: 0xe59c,
          isCustom: false,
        );

        const category2 = Category(
          id: 'groceries',
          name: 'Groceries',
          iconCodePoint: 0xe59c,
          isCustom: false,
        );

        expect(category1, equals(category2));
        expect(category1.hashCode, equals(category2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const category1 = testCategory;
        final category2 = testCategory.copyWith(name: 'Different Name');

        expect(category1, isNot(equals(category2)));
        expect(category1.hashCode, isNot(equals(category2.hashCode)));
      });
    });
  });
}
