import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository_impl.dart';

@GenerateMocks([Database])
import 'location_history_repository_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late LocationHistoryRepository repository;

  setUp(() {
    mockDatabase = MockDatabase();
    repository = LocationHistoryRepositoryImpl(database: mockDatabase);
  });

  group('LocationHistoryRepository', () {
    group('getHistoryForItem', () {
      test(
        'should return history entries sorted by date (newest first)',
        () async {
          // Arrange
          final mockData = [
            {
              'id': '1',
              'item_id': 'item1',
              'location_id': 'loc1',
              'timestamp': '2025-10-14T12:00:00.000Z',
            },
            {
              'id': '2',
              'item_id': 'item1',
              'location_id': 'loc2',
              'timestamp': '2025-10-14T11:00:00.000Z',
            },
          ];
          when(
            mockDatabase.query(
              'location_history',
              where: 'item_id = ?',
              whereArgs: ['item1'],
              orderBy: 'timestamp DESC',
              limit: 10,
            ),
          ).thenAnswer((_) async => mockData);

          // Act
          final result = await repository.getHistoryForItem('item1');

          // Assert
          expect(result, hasLength(2));
          expect(result[0].id, '1');
          expect(result[0].locationId, 'loc1');
          expect(result[1].id, '2');
          expect(result[1].locationId, 'loc2');
        },
      );

      test('should return limited number of entries', () async {
        // Arrange
        final mockData = [
          {
            'id': '1',
            'item_id': 'item1',
            'location_id': 'loc1',
            'timestamp': '2025-10-14T12:00:00.000Z',
          },
          {
            'id': '2',
            'item_id': 'item1',
            'location_id': 'loc2',
            'timestamp': '2025-10-14T11:00:00.000Z',
          },
          {
            'id': '3',
            'item_id': 'item1',
            'location_id': 'loc3',
            'timestamp': '2025-10-14T10:00:00.000Z',
          },
        ];
        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
            limit: 2,
          ),
        ).thenAnswer((_) async => mockData.take(2).toList());

        // Act
        final result = await repository.getHistoryForItem('item1', limit: 2);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[1].id, '2');
      });

      test('should return empty list when no history exists', () async {
        // Arrange
        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
            limit: 10,
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getHistoryForItem('item1');

        // Assert
        expect(result, isEmpty);
      });

      test('should throw DatabaseException on query error', () async {
        // Arrange
        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
            limit: 10,
          ),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getHistoryForItem('item1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('createHistoryEntry', () {
      test('should create history entry successfully', () async {
        // Arrange
        final entry = LocationHistory(
          id: '1',
          itemId: 'item1',
          locationId: 'loc1',
          timestamp: DateTime.parse('2025-10-14T12:00:00.000Z'),
        );
        when(
          mockDatabase.insert('location_history', entry.toDatabase()),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.createHistoryEntry(entry);

        // Assert
        expect(result, equals(entry));
        verify(
          mockDatabase.insert('location_history', entry.toDatabase()),
        ).called(1);
      });

      test('should throw ValidationException for empty itemId', () async {
        // Arrange
        final entry = LocationHistory(
          id: '1',
          itemId: '',
          locationId: 'loc1',
          timestamp: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.createHistoryEntry(entry),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for empty locationId', () async {
        // Arrange
        final entry = LocationHistory(
          id: '1',
          itemId: 'item1',
          locationId: '',
          timestamp: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => repository.createHistoryEntry(entry),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw DatabaseException on insert error', () async {
        // Arrange
        final entry = LocationHistory(
          id: '1',
          itemId: 'item1',
          locationId: 'loc1',
          timestamp: DateTime.now(),
        );
        when(
          mockDatabase.insert('location_history', entry.toDatabase()),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.createHistoryEntry(entry),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('pruneHistoryForItem', () {
      test('should delete old entries and keep recent ones', () async {
        // Arrange - Item has 15 history entries, keep last 10
        final allEntries = List.generate(
          15,
          (i) => {
            'id': 'entry$i',
            'item_id': 'item1',
            'location_id': 'loc$i',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: i))
                .toIso8601String(),
          },
        );

        // Mock getting all entries
        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
          ),
        ).thenAnswer((_) async => allEntries);

        // Mock deleting old entries (keep last 10, delete 5)
        final idsToDelete = allEntries.skip(10).map((e) => e['id']).toList();
        when(
          mockDatabase.delete(
            'location_history',
            where: 'id IN (${idsToDelete.map((_) => '?').join(', ')})',
            whereArgs: idsToDelete,
          ),
        ).thenAnswer((_) async => 5);

        // Act
        final result = await repository.pruneHistoryForItem(
          'item1',
        );

        // Assert
        expect(result, 5); // 5 entries deleted
      });

      test('should return 0 when no entries need pruning', () async {
        // Arrange - Item has 5 entries, keep last 10
        final entries = List.generate(
          5,
          (i) => {
            'id': 'entry$i',
            'item_id': 'item1',
            'location_id': 'loc$i',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: i))
                .toIso8601String(),
          },
        );

        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
          ),
        ).thenAnswer((_) async => entries);

        // Act
        final result = await repository.pruneHistoryForItem(
          'item1',
        );

        // Assert
        expect(result, 0); // No entries deleted
        verifyNever(mockDatabase.delete(any, where: anyNamed('where')));
      });

      test('should throw DatabaseException on error', () async {
        // Arrange
        when(
          mockDatabase.query(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
            orderBy: 'timestamp DESC',
          ),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.pruneHistoryForItem('item1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('deleteHistoryForItem', () {
      test('should delete all history entries for item', () async {
        // Arrange
        when(
          mockDatabase.delete(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
          ),
        ).thenAnswer((_) async => 5);

        // Act
        final result = await repository.deleteHistoryForItem('item1');

        // Assert
        expect(result, 5);
        verify(
          mockDatabase.delete(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
          ),
        ).called(1);
      });

      test('should return 0 when no history exists', () async {
        // Arrange
        when(
          mockDatabase.delete(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
          ),
        ).thenAnswer((_) async => 0);

        // Act
        final result = await repository.deleteHistoryForItem('item1');

        // Assert
        expect(result, 0);
      });

      test('should throw DatabaseException on delete error', () async {
        // Arrange
        when(
          mockDatabase.delete(
            'location_history',
            where: 'item_id = ?',
            whereArgs: ['item1'],
          ),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.deleteHistoryForItem('item1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}
