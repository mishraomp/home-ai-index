import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

// Generate mocks
@GenerateMocks([DatabaseHelper, Database])
import 'item_repository_test.mocks.dart';

void main() {
  group('ItemRepository', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late MockDatabase mockDatabase;
    late ItemRepositoryImpl repository;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
      repository = ItemRepositoryImpl(mockDatabaseHelper);

      // Setup default database mock behavior
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
    });

    final now = DateTime.now();
    final testItem = Item(
      id: 'item-1',
      name: 'Test Item',
      notes: 'Test notes',
      quantity: 5,
      categoryId: 'groceries',
      locationId: 'pantry',
      expirationDate: now.add(const Duration(days: 7)),
      imagePath: '/path/to/image.jpg',
      mlDetectedLabel: 'food',
      mlConfidenceScore: 0.95,
      addedAt: now,
      updatedAt: now,
    );

    group('createItem', () {
      test('should insert item into database and return id', () async {
        when(mockDatabase.insert('items', any)).thenAnswer((_) async => 1);

        final result = await repository.createItem(testItem);

        expect(result, testItem.id);
        verify(mockDatabase.insert('items', testItem.toDatabase())).called(1);
      });

      test('should throw DatabaseException on insert failure', () async {
        when(
          mockDatabase.insert('items', any),
        ).thenThrow(Exception('Insert failed'));

        expect(
          () => repository.createItem(testItem),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('getItemById', () {
      test('should return item when found', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItemById('item-1');

        expect(result, isNotNull);
        expect(result!.id, 'item-1');
        expect(result.name, 'Test Item');
        verify(
          mockDatabase.query('items', where: 'id = ?', whereArgs: ['item-1']),
        ).called(1);
      });

      test('should return null when item not found', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.getItemById('nonexistent');

        expect(result, isNull);
      });

      test('should throw DatabaseException on query failure', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenThrow(Exception('Query failed'));

        expect(
          () => repository.getItemById('item-1'),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('getItems', () {
      test('should return all items', () async {
        when(
          mockDatabase.query('items', orderBy: anyNamed('orderBy')),
        ).thenAnswer(
          (_) async => [
            testItem.toDatabase(),
            testItem.copyWith(id: 'item-2').toDatabase(),
          ],
        );

        final result = await repository.getItems();

        expect(result, hasLength(2));
        expect(result[0].id, 'item-1');
        expect(result[1].id, 'item-2');
        verify(mockDatabase.query('items', orderBy: 'added_at DESC')).called(1);
      });

      test('should return empty list when no items', () async {
        when(
          mockDatabase.query('items', orderBy: anyNamed('orderBy')),
        ).thenAnswer((_) async => []);

        final result = await repository.getItems();

        expect(result, isEmpty);
      });

      test('should filter by categoryId when provided', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItems(categoryId: 'groceries');

        expect(result, hasLength(1));
        expect(result[0].categoryId, 'groceries');
        verify(
          mockDatabase.query(
            'items',
            where: 'category_id = ?',
            whereArgs: ['groceries'],
            orderBy: 'added_at DESC',
          ),
        ).called(1);
      });

      test('should filter by locationId when provided', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItems(locationId: 'pantry');

        expect(result, hasLength(1));
        expect(result[0].locationId, 'pantry');
        verify(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['pantry'],
            orderBy: 'added_at DESC',
          ),
        ).called(1);
      });

      test('should filter by both categoryId and locationId', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItems(
          categoryId: 'groceries',
          locationId: 'pantry',
        );

        expect(result, hasLength(1));
        verify(
          mockDatabase.query(
            'items',
            where: 'category_id = ? AND location_id = ?',
            whereArgs: ['groceries', 'pantry'],
            orderBy: 'added_at DESC',
          ),
        ).called(1);
      });

      test(
        'should include unlocated items when includeUnlocated is true',
        () async {
          final unlocatedItem = Item(
            id: 'item-3',
            name: 'Unlocated Item',
            notes: '',
            quantity: 1,
            categoryId: 'groceries',
            addedAt: now,
            updatedAt: now,
          );
          when(
            mockDatabase.query(
              'items',
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
              orderBy: anyNamed('orderBy'),
            ),
          ).thenAnswer(
            (_) async => [testItem.toDatabase(), unlocatedItem.toDatabase()],
          );

          final result = await repository.getItems(
            locationId: 'pantry',
            includeUnlocated: true,
          );

          expect(result, hasLength(2));
          verify(
            mockDatabase.query(
              'items',
              where: '(location_id = ? OR location_id IS NULL)',
              whereArgs: ['pantry'],
              orderBy: 'added_at DESC',
            ),
          ).called(1);
        },
      );

      test(
        'should not include unlocated items when includeUnlocated is false',
        () async {
          when(
            mockDatabase.query(
              'items',
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
              orderBy: anyNamed('orderBy'),
            ),
          ).thenAnswer((_) async => [testItem.toDatabase()]);

          final result = await repository.getItems(locationId: 'pantry');

          expect(result, hasLength(1));
          verify(
            mockDatabase.query(
              'items',
              where: 'location_id = ?',
              whereArgs: ['pantry'],
              orderBy: 'added_at DESC',
            ),
          ).called(1);
        },
      );

      test(
        'should return only unlocated items when locationId is null and includeUnlocated is true',
        () async {
          final unlocatedItem1 = Item(
            id: 'item-3',
            name: 'Unlocated Item 1',
            notes: '',
            quantity: 1,
            categoryId: 'groceries',
            addedAt: now,
            updatedAt: now,
          );
          final unlocatedItem2 = Item(
            id: 'item-4',
            name: 'Unlocated Item 2',
            notes: '',
            quantity: 1,
            categoryId: 'groceries',
            addedAt: now,
            updatedAt: now,
          );
          when(
            mockDatabase.query(
              'items',
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
              orderBy: anyNamed('orderBy'),
            ),
          ).thenAnswer(
            (_) async => [
              unlocatedItem1.toDatabase(),
              unlocatedItem2.toDatabase(),
            ],
          );

          final result = await repository.getItems(includeUnlocated: true);

          expect(result, hasLength(2));
          // Check that all items have null locationId
          for (final item in result) {
            expect(item.locationId, isNull);
          }
          verify(
            mockDatabase.query(
              'items',
              where: 'location_id IS NULL',
              orderBy: 'added_at DESC',
            ),
          ).called(1);
        },
      );
    });

    group('getItemsByCategory', () {
      test('should return items filtered by category', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItemsByCategory('groceries');

        expect(result, hasLength(1));
        expect(result[0].categoryId, 'groceries');
        verify(
          mockDatabase.query(
            'items',
            where: 'category_id = ?',
            whereArgs: ['groceries'],
            orderBy: 'added_at DESC',
          ),
        ).called(1);
      });
    });

    group('getItemsByLocation', () {
      test('should return items filtered by location', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getItemsByLocation('pantry');

        expect(result, hasLength(1));
        expect(result[0].locationId, 'pantry');
        verify(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['pantry'],
            orderBy: 'added_at DESC',
          ),
        ).called(1);
      });

      test('should return empty list when no items at location', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.getItemsByLocation('garage');

        expect(result, isEmpty);
      });

      test('should throw DatabaseException on query failure', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenThrow(Exception('Query failed'));

        expect(
          () => repository.getItemsByLocation('pantry'),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('searchItems', () {
      test('should return items matching search query', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.searchItems('test');

        expect(result, hasLength(1));
        verify(
          mockDatabase.query(
            'items',
            where: 'name LIKE ?',
            whereArgs: ['%test%'],
            orderBy: 'added_at DESC',
            limit: 50,
          ),
        ).called(1);
      });

      test('should apply search result limit', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => []);

        await repository.searchItems('test');

        verify(
          mockDatabase.query(
            'items',
            where: 'name LIKE ?',
            whereArgs: ['%test%'],
            orderBy: 'added_at DESC',
            limit: 50,
          ),
        ).called(1);
      });
    });

    group('updateItem', () {
      test('should update item in database', () async {
        when(
          mockDatabase.update(
            'items',
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => 1);

        await repository.updateItem(testItem);

        verify(
          mockDatabase.update(
            'items',
            testItem.toDatabase(),
            where: 'id = ?',
            whereArgs: [testItem.id],
          ),
        ).called(1);
      });

      test('should throw ItemNotFoundException when item not found', () async {
        when(
          mockDatabase.update(
            'items',
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => 0);

        expect(
          () => repository.updateItem(testItem),
          throwsA(isA<app_exceptions.ItemNotFoundException>()),
        );
      });
    });

    group('deleteItem', () {
      test('should delete item from database', () async {
        when(
          mockDatabase.delete(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => 1);

        await repository.deleteItem('item-1');

        verify(
          mockDatabase.delete('items', where: 'id = ?', whereArgs: ['item-1']),
        ).called(1);
      });

      test('should throw ItemNotFoundException when item not found', () async {
        when(
          mockDatabase.delete(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => 0);

        expect(
          () => repository.deleteItem('item-1'),
          throwsA(isA<app_exceptions.ItemNotFoundException>()),
        );
      });
    });

    group('getExpiringItems', () {
      test('should return items expiring within threshold', () async {
        when(
          mockDatabase.query(
            'items',
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            orderBy: anyNamed('orderBy'),
          ),
        ).thenAnswer((_) async => [testItem.toDatabase()]);

        final result = await repository.getExpiringItems(7);

        expect(result, hasLength(1));
        verify(
          mockDatabase.query(
            'items',
            where: 'expiration_date IS NOT NULL AND expiration_date <= ?',
            whereArgs: anyNamed('whereArgs'),
            orderBy: 'expiration_date ASC',
          ),
        ).called(1);
      });
    });
  });
}
