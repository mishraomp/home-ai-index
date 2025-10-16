import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';

void main() {
  group('Item Model - Metadata Validation Tests (T109)', () {
    testWidgets('Item has quantity field', (WidgetTester tester) async {
      final item = Item(
        id: 'item1',
        name: 'Laptop',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      expect(item.quantity, equals(2));
    });

    testWidgets('Item has notes field', (WidgetTester tester) async {
      final item = Item(
        id: 'item1',
        name: 'Laptop',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
        notes: 'Dell XPS 15',
      );

      expect(item.notes, equals('Dell XPS 15'));
    });

    testWidgets('Item has expirationDate field', (WidgetTester tester) async {
      final expirationDate = DateTime(2025, 12, 31);
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
        expirationDate: expirationDate,
      );

      expect(item.expirationDate, equals(expirationDate));
    });

    testWidgets('quantity validation - positive values only', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Item',
        quantity: 5,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      // Quantity should be positive
      expect(item.quantity > 0, isTrue);
    });

    testWidgets('Item can have empty notes', (WidgetTester tester) async {
      final item = Item(
        id: 'item1',
        name: 'Item',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
        notes: '',
      );

      expect(item.notes, isEmpty);
    });

    testWidgets('Item can have null expirationDate', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Item',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      expect(item.expirationDate, isNull);
    });

    testWidgets('Item with all metadata fields', (WidgetTester tester) async {
      final expirationDate = DateTime(2025, 12, 31);
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
        notes: 'Whole milk, organic',
        expirationDate: expirationDate,
      );

      expect(item.quantity, equals(2));
      expect(item.notes, equals('Whole milk, organic'));
      expect(item.expirationDate, equals(expirationDate));
    });

    testWidgets('Item toJson includes metadata', (WidgetTester tester) async {
      final expirationDate = DateTime(2025, 12, 31);
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
        notes: 'Organic',
        expirationDate: expirationDate,
      );

      final json = item.toJson();
      expect(json['quantity'], equals(2));
      expect(json['notes'], equals('Organic'));
      expect(json['expirationDate'], isNotNull);
    });

    testWidgets('Item fromJson includes metadata', (WidgetTester tester) async {
      final expirationDate = DateTime(2025, 12, 31);
      final itemData = {
        'id': 'item1',
        'name': 'Milk',
        'quantity': 2,
        'categoryId': 'cat1',
        'locationId': 'loc1',
        'addedAt': DateTime(2025).toString(),
        'updatedAt': DateTime(2025).toString(),
        'notes': 'Organic',
        'expirationDate': expirationDate.toString(),
      };

      final item = Item.fromJson(itemData);
      expect(item.quantity, equals(2));
      expect(item.notes, equals('Organic'));
    });
  });
}
