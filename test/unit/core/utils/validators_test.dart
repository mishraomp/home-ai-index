import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/utils/validators.dart';
import 'package:home_ai_index/core/constants/app_constants.dart';

void main() {
  group('Validators', () {
    group('validateItemName', () {
      test('should return null for valid item names', () {
        expect(validateItemName('Apple'), isNull);
        expect(validateItemName('Screwdriver Set'), isNull);
        expect(validateItemName('A'), isNull); // 1 character minimum
        expect(validateItemName('a' * 100), isNull); // 100 characters maximum
      });

      test('should return error for null or empty names', () {
        expect(validateItemName(null), 'Item name is required');
        expect(validateItemName(''), 'Item name is required');
        expect(validateItemName('   '), 'Item name is required');
      });

      test('should return error for names exceeding 100 characters', () {
        expect(
          validateItemName('a' * 101),
          'Item name must be 100 characters or less',
        );
      });
    });

    group('validateCategoryName', () {
      test('should return null for valid category names', () {
        expect(validateCategoryName('Groceries'), isNull);
        expect(validateCategoryName('Tools'), isNull);
        expect(validateCategoryName('A'), isNull);
        expect(validateCategoryName('a' * 50), isNull);
      });

      test('should return error for null or empty names', () {
        expect(validateCategoryName(null), 'Category name is required');
        expect(validateCategoryName(''), 'Category name is required');
        expect(validateCategoryName('   '), 'Category name is required');
      });

      test('should return error for names exceeding 50 characters', () {
        expect(
          validateCategoryName('a' * 51),
          'Category name must be 50 characters or less',
        );
      });
    });

    group('validateLocationName', () {
      test('should return null for valid location names', () {
        expect(validateLocationName('Kitchen'), isNull);
        expect(validateLocationName('Pantry'), isNull);
        expect(validateLocationName('A'), isNull);
        expect(validateLocationName('a' * 100), isNull);
      });

      test('should return error for null or empty names', () {
        expect(validateLocationName(null), 'Location name is required');
        expect(validateLocationName(''), 'Location name is required');
        expect(validateLocationName('   '), 'Location name is required');
      });

      test('should return error for names exceeding 100 characters', () {
        expect(
          validateLocationName('a' * 101),
          'Location name must be 100 characters or less',
        );
      });
    });

    group('validateLocationHierarchyDepth', () {
      test('should return null for valid depths', () {
        expect(validateLocationHierarchyDepth(1), isNull);
        expect(validateLocationHierarchyDepth(3), isNull);
        expect(
          validateLocationHierarchyDepth(maxLocationHierarchyDepth),
          isNull,
        );
      });

      test('should return error for depths exceeding maximum', () {
        expect(
          validateLocationHierarchyDepth(maxLocationHierarchyDepth + 1),
          'Location hierarchy cannot exceed $maxLocationHierarchyDepth levels',
        );
        expect(
          validateLocationHierarchyDepth(10),
          'Location hierarchy cannot exceed $maxLocationHierarchyDepth levels',
        );
      });
    });

    group('validateQuantity', () {
      test('should return null for valid quantities', () {
        expect(validateQuantity('0'), isNull);
        expect(validateQuantity('1'), isNull);
        expect(validateQuantity('100'), isNull);
        expect(validateQuantity('  5  '), isNull); // trimmed
      });

      test('should return error for null or empty values', () {
        expect(validateQuantity(null), 'Quantity is required');
        expect(validateQuantity(''), 'Quantity is required');
        expect(validateQuantity('   '), 'Quantity is required');
      });

      test('should return error for non-numeric values', () {
        expect(validateQuantity('abc'), 'Quantity must be a valid number');
        expect(validateQuantity('1.5'), 'Quantity must be a valid number');
        expect(validateQuantity('1a'), 'Quantity must be a valid number');
      });

      test('should return error for negative quantities', () {
        expect(validateQuantity('-1'), 'Quantity cannot be negative');
        expect(validateQuantity('-100'), 'Quantity cannot be negative');
      });
    });

    group('validateExpirationDate', () {
      test('should return null for any date (optional field)', () {
        expect(validateExpirationDate(null), isNull);
        expect(validateExpirationDate(DateTime.now()), isNull);
        expect(
          validateExpirationDate(DateTime.now().add(const Duration(days: 30))),
          isNull,
        );
        expect(
          validateExpirationDate(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
          isNull,
        );
      });
    });

    group('validateNotes', () {
      test('should return null for valid notes', () {
        expect(validateNotes(null), isNull);
        expect(validateNotes(''), isNull);
        expect(validateNotes('Short note'), isNull);
        expect(validateNotes('a' * 500), isNull);
      });

      test('should return error for notes exceeding 500 characters', () {
        expect(
          validateNotes('a' * 501),
          'Notes must be 500 characters or less',
        );
      });
    });

    group('validateImagePath', () {
      test('should return null for valid image paths', () {
        expect(validateImagePath(null), isNull);
        expect(validateImagePath('/path/to/image.jpg'), isNull);
        expect(validateImagePath('relative/path.png'), isNull);
      });

      test('should return error for empty image paths', () {
        expect(validateImagePath(''), 'Image path cannot be empty');
        expect(validateImagePath('   '), 'Image path cannot be empty');
      });
    });

    group('validateConfidenceScore', () {
      test('should return null for valid confidence scores', () {
        expect(validateConfidenceScore(0.0), isNull);
        expect(validateConfidenceScore(0.5), isNull);
        expect(validateConfidenceScore(1.0), isNull);
      });

      test('should return error for null scores', () {
        expect(validateConfidenceScore(null), 'Confidence score is required');
      });

      test('should return error for scores outside 0.0-1.0 range', () {
        expect(
          validateConfidenceScore(-0.1),
          'Confidence score must be between 0.0 and 1.0',
        );
        expect(
          validateConfidenceScore(1.1),
          'Confidence score must be between 0.0 and 1.0',
        );
        expect(
          validateConfidenceScore(-5.0),
          'Confidence score must be between 0.0 and 1.0',
        );
        expect(
          validateConfidenceScore(2.0),
          'Confidence score must be between 0.0 and 1.0',
        );
      });
    });

    group('validateSearchQuery', () {
      test('should return null for valid search queries', () {
        expect(validateSearchQuery('apple'), isNull);
        expect(validateSearchQuery('Screwdriver'), isNull);
        expect(validateSearchQuery('a'), isNull);
        expect(validateSearchQuery('  query  '), isNull); // trimmed
      });

      test('should return error for null or empty queries', () {
        expect(validateSearchQuery(null), 'Search query cannot be empty');
        expect(validateSearchQuery(''), 'Search query cannot be empty');
        expect(validateSearchQuery('   '), 'Search query cannot be empty');
      });
    });
  });
}
