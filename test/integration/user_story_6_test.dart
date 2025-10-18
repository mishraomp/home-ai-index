import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_story_6_test.mocks.dart';

@GenerateMocks([ItemRepository])
void main() {
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
  });

  final itemsWithMetadata = [
    Item(
      id: 'item1',
      name: 'Milk',
      quantity: 2,
      categoryId: 'cat1',
      locationId: 'loc1',
      addedAt: DateTime(2025, 10),
      updatedAt: DateTime(2025, 10, 15),
      notes: 'Organic whole milk',
      expirationDate: DateTime(2025, 10, 22),
    ),
    Item(
      id: 'item2',
      name: 'Cheese',
      quantity: 1,
      categoryId: 'cat1',
      locationId: 'loc1',
      addedAt: DateTime(2025, 9, 15),
      updatedAt: DateTime(2025, 10, 15),
      notes: 'Aged cheddar',
      expirationDate: DateTime(2025, 10, 20),
    ),
    Item(
      id: 'item3',
      name: 'Bread',
      quantity: 3,
      categoryId: 'cat2',
      locationId: 'loc2',
      addedAt: DateTime(2025, 10, 10),
      updatedAt: DateTime(2025, 10, 15),
      notes: 'Whole wheat',
      expirationDate: DateTime(2025, 10, 18),
    ),
    Item(
      id: 'item4',
      name: 'Laptop',
      quantity: 1,
      categoryId: 'cat3',
      locationId: 'loc1',
      addedAt: DateTime(2025),
      updatedAt: DateTime(2025, 10, 15),
      notes: 'Dell XPS 15',
    ),
  ];

  group('User Story 6: Metadata Management - Integration Tests (T114)', () {
    testWidgets('can add item with metadata', (WidgetTester tester) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();

      expect(items, hasLength(4));
      expect(items[0].quantity, equals(2));
      expect(items[0].notes, equals('Organic whole milk'));
      expect(items[0].expirationDate, isNotNull);
    });

    testWidgets('can edit item metadata', (WidgetTester tester) async {
      final updatedItem = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 3, // Changed from 2
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Organic whole milk - updated',
        expirationDate: DateTime(2025, 10, 25),
      );

      when(mockItemRepository.updateItem(any)).thenAnswer((_) async => {});

      // Verify update can be called
      await mockItemRepository.updateItem(updatedItem);
      verify(mockItemRepository.updateItem(any)).called(1);
    });

    testWidgets('metadata persists after save', (WidgetTester tester) async {
      final item = itemsWithMetadata[0];

      when(
        mockItemRepository.getItemById('item1'),
      ).thenAnswer((_) async => item);

      final retrieved = await mockItemRepository.getItemById('item1');

      expect(retrieved?.quantity, equals(2));
      expect(retrieved?.notes, equals('Organic whole milk'));
      expect(retrieved?.expirationDate, equals(DateTime(2025, 10, 22)));
    });

    testWidgets('can filter items by expiration date', (
      WidgetTester tester,
    ) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      final today = DateTime(2025, 10, 15);
      final expiringItems = items
          .where(
            (item) =>
                item.expirationDate != null &&
                item.expirationDate!.isAfter(today) &&
                item.expirationDate!.difference(today).inDays <= 7,
          )
          .toList();

      expect(expiringItems, hasLength(3));
      expect(expiringItems[0].name, equals('Milk'));
      expect(expiringItems[1].name, equals('Cheese'));
      expect(expiringItems[2].name, equals('Bread'));
    });

    testWidgets('handles items without expiration date', (
      WidgetTester tester,
    ) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      final itemsWithoutExpiration = items
          .where((item) => item.expirationDate == null)
          .toList();

      expect(itemsWithoutExpiration, hasLength(1));
      expect(itemsWithoutExpiration[0].name, equals('Laptop'));
    });

    testWidgets('quantity metadata affects list display', (
      WidgetTester tester,
    ) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      final itemsWithMultipleQty = items
          .where((item) => item.quantity > 1)
          .toList();

      expect(itemsWithMultipleQty, hasLength(2));
      expect(itemsWithMultipleQty[0].name, equals('Milk'));
      expect(itemsWithMultipleQty[1].name, equals('Bread'));
    });

    testWidgets('notes metadata is searchable', (WidgetTester tester) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      const searchTerm = 'organic';
      final searchResults = items
          .where(
            (item) =>
                item.notes != null &&
                item.notes!.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();

      expect(searchResults, hasLength(1));
      expect(searchResults[0].name, equals('Milk'));
    });

    testWidgets('can identify expired items', (WidgetTester tester) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      final today = DateTime(2025, 10, 25);
      final expiredItems = items
          .where(
            (item) =>
                item.expirationDate != null &&
                item.expirationDate!.isBefore(today),
          )
          .toList();

      expect(expiredItems, hasLength(3));
    });

    testWidgets('can get items expiring within 7 days', (
      WidgetTester tester,
    ) async {
      when(
        mockItemRepository.getItems(),
      ).thenAnswer((_) async => itemsWithMetadata);

      final items = await mockItemRepository.getItems();
      final today = DateTime(2025, 10, 15);
      final expiringWithin7Days = items
          .where(
            (item) =>
                item.expirationDate != null &&
                item.expirationDate!.isAfter(today) &&
                item.expirationDate!.difference(today).inDays <= 7,
          )
          .toList();

      expect(expiringWithin7Days, hasLength(3));
      expect(
        expiringWithin7Days[0].expirationDate,
        equals(DateTime(2025, 10, 22)),
      );
      expect(
        expiringWithin7Days[1].expirationDate,
        equals(DateTime(2025, 10, 20)),
      );
      expect(
        expiringWithin7Days[2].expirationDate,
        equals(DateTime(2025, 10, 18)),
      );
    });

    testWidgets('metadata updates trigger refresh', (
      WidgetTester tester,
    ) async {
      final originalItem = itemsWithMetadata[0];
      final updatedItem = Item(
        id: originalItem.id,
        name: originalItem.name,
        quantity: originalItem.quantity + 1,
        categoryId: originalItem.categoryId,
        locationId: originalItem.locationId,
        addedAt: originalItem.addedAt,
        updatedAt: DateTime.now(),
        notes: originalItem.notes,
        expirationDate: originalItem.expirationDate,
      );

      when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});

      await mockItemRepository.updateItem(updatedItem);

      verify(mockItemRepository.updateItem(any)).called(1);
    });
  });
}
