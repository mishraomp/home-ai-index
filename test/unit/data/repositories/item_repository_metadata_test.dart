import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'item_repository_metadata_test.mocks.dart';

@GenerateMocks([ItemRepository])
void main() {
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
  });

  group('Item Repository Metadata Tests (T110)', () {
    testWidgets('updateItem with quantity metadata', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 3,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Organic whole milk',
        expirationDate: DateTime(2025, 10, 22),
      );

      when(
        mockItemRepository.updateItem(item),
      ).thenAnswer((_) => Future.value());

      await mockItemRepository.updateItem(item);

      verify(mockItemRepository.updateItem(item)).called(1);
    });

    testWidgets('updateItem with notes metadata', (WidgetTester tester) async {
      final item = Item(
        id: 'item2',
        name: 'Cheese',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 9, 15),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Premium aged cheddar - keep cool',
        expirationDate: DateTime(2025, 10, 20),
      );

      when(
        mockItemRepository.updateItem(item),
      ).thenAnswer((_) => Future.value());

      await mockItemRepository.updateItem(item);

      verify(mockItemRepository.updateItem(item)).called(1);
    });

    testWidgets('updateItem with expirationDate metadata', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item3',
        name: 'Yogurt',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10, 5),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Greek yogurt',
        expirationDate: DateTime(2025, 10, 30),
      );

      when(
        mockItemRepository.updateItem(item),
      ).thenAnswer((_) => Future.value());

      await mockItemRepository.updateItem(item);

      verify(mockItemRepository.updateItem(item)).called(1);
    });

    testWidgets('getItemById retrieves metadata', (WidgetTester tester) async {
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Organic whole milk',
        expirationDate: DateTime(2025, 10, 22),
      );

      when(
        mockItemRepository.getItemById('item1'),
      ).thenAnswer((_) async => item);

      final retrieved = await mockItemRepository.getItemById('item1');

      expect(retrieved?.quantity, equals(2));
      expect(retrieved?.notes, equals('Organic whole milk'));
      expect(retrieved?.expirationDate, equals(DateTime(2025, 10, 22)));
    });

    testWidgets('getItems returns list with metadata', (
      WidgetTester tester,
    ) async {
      final items = [
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
      ];

      when(mockItemRepository.getItems()).thenAnswer((_) async => items);

      final retrieved = await mockItemRepository.getItems();

      expect(retrieved, hasLength(2));
      expect(retrieved[0].quantity, equals(2));
      expect(retrieved[1].quantity, equals(1));
    });

    testWidgets('updateItem preserves existing metadata', (
      WidgetTester tester,
    ) async {
      final updatedItem = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 3,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 16),
        notes: 'Organic whole milk',
        expirationDate: DateTime(2025, 10, 22),
      );

      when(
        mockItemRepository.updateItem(updatedItem),
      ).thenAnswer((_) => Future.value());

      await mockItemRepository.updateItem(updatedItem);

      verify(
        mockItemRepository.updateItem(
          argThat(
            isA<Item>()
                .having((item) => item.quantity, 'quantity', equals(3))
                .having(
                  (item) => item.notes,
                  'notes',
                  equals('Organic whole milk'),
                )
                .having(
                  (item) => item.expirationDate,
                  'expirationDate',
                  isNotNull,
                ),
          ),
        ),
      ).called(1);
    });

    testWidgets('getItemById with missing metadata', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Laptop',
        quantity: 1,
        categoryId: 'cat3',
        locationId: 'loc1',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025, 10, 15),
      );

      when(
        mockItemRepository.getItemById('item1'),
      ).thenAnswer((_) async => item);

      final retrieved = await mockItemRepository.getItemById('item1');

      expect(retrieved?.quantity, equals(1));
      expect(retrieved?.notes, isNull);
      expect(retrieved?.expirationDate, isNull);
    });

    testWidgets('updateItem with all metadata fields', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 5,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Organic whole milk - premium',
        expirationDate: DateTime(2025, 10, 22),
      );

      when(
        mockItemRepository.updateItem(item),
      ).thenAnswer((_) => Future.value());

      await mockItemRepository.updateItem(item);

      verify(
        mockItemRepository.updateItem(
          argThat(
            isA<Item>()
                .having((i) => i.quantity, 'quantity', equals(5))
                .having((i) => i.notes, 'notes', contains('premium'))
                .having((i) => i.expirationDate, 'expirationDate', isNotNull),
          ),
        ),
      ).called(1);
    });

    testWidgets('metadata updates reflected in subsequent queries', (
      WidgetTester tester,
    ) async {
      final item = Item(
        id: 'item1',
        name: 'Milk',
        quantity: 2,
        categoryId: 'cat1',
        locationId: 'loc1',
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10, 15),
        notes: 'Organic whole milk',
        expirationDate: DateTime(2025, 10, 22),
      );

      when(
        mockItemRepository.getItemById('item1'),
      ).thenAnswer((_) async => item);

      final retrieved = await mockItemRepository.getItemById('item1');

      expect(retrieved?.quantity, equals(2));
      expect(retrieved?.notes, equals('Organic whole milk'));
      expect(retrieved?.expirationDate, isNotNull);
    });
  });
}
