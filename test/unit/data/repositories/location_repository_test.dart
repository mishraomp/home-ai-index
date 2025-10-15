import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseException;

import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository_impl.dart';

@GenerateMocks([Database])
import 'location_repository_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late LocationRepository repository;

  setUp(() {
    mockDatabase = MockDatabase();
    repository = LocationRepositoryImpl(database: mockDatabase);
  });

  group('LocationRepository', () {
    group('getLocations', () {
      test('should return all locations when rootOnly is false', () async {
        // Arrange
        final mockData = [
          {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          {'id': '2', 'name': 'Pantry', 'parent_id': '1'},
          {'id': '3', 'name': 'Living Room', 'parent_id': null},
        ];
        when(
          mockDatabase.query('locations', orderBy: 'name ASC'),
        ).thenAnswer((_) async => mockData);

        // Act
        final result = await repository.getLocations();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].id, '1');
        expect(result[0].name, 'Kitchen');
        expect(result[1].id, '2');
        expect(result[2].id, '3');
        verify(mockDatabase.query('locations', orderBy: 'name ASC')).called(1);
      });

      test('should return only root locations when rootOnly is true', () async {
        // Arrange
        final mockData = [
          {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          {'id': '3', 'name': 'Living Room', 'parent_id': null},
        ];
        when(
          mockDatabase.query(
            'locations',
            where: 'parent_id IS NULL',
            orderBy: 'name ASC',
          ),
        ).thenAnswer((_) async => mockData);

        // Act
        final result = await repository.getLocations(rootOnly: true);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].parentId, isNull);
        expect(result[1].parentId, isNull);
        verify(
          mockDatabase.query(
            'locations',
            where: 'parent_id IS NULL',
            orderBy: 'name ASC',
          ),
        ).called(1);
      });

      test('should return empty list when no locations exist', () async {
        // Arrange
        when(
          mockDatabase.query('locations', orderBy: 'name ASC'),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getLocations();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw DatabaseException on query error', () async {
        // Arrange
        when(
          mockDatabase.query('locations', orderBy: 'name ASC'),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getLocations(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getLocationById', () {
      test('should return location when found', () async {
        // Arrange
        final mockData = [
          {'id': '1', 'name': 'Kitchen', 'parent_id': null},
        ];
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer((_) async => mockData);

        // Act
        final result = await repository.getLocationById('1');

        // Assert
        expect(result.id, '1');
        expect(result.name, 'Kitchen');
        expect(result.parentId, isNull);
      });

      test('should throw LocationNotFoundException when not found', () async {
        // Arrange
        when(
          mockDatabase.query(
            'locations',
            where: 'id = ?',
            whereArgs: ['nonexistent'],
          ),
        ).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => repository.getLocationById('nonexistent'),
          throwsA(isA<LocationNotFoundException>()),
        );
      });

      test('should throw DatabaseException on query error', () async {
        // Arrange
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getLocationById('1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getChildLocations', () {
      test('should return child locations of parent', () async {
        // Arrange
        final mockData = [
          {'id': '2', 'name': 'Pantry', 'parent_id': '1'},
          {'id': '3', 'name': 'Cabinet A', 'parent_id': '1'},
        ];
        when(
          mockDatabase.query(
            'locations',
            where: 'parent_id = ?',
            whereArgs: ['1'],
            orderBy: 'name ASC',
          ),
        ).thenAnswer((_) async => mockData);

        // Act
        final result = await repository.getChildLocations('1');

        // Assert
        expect(result, hasLength(2));
        expect(result[0].parentId, '1');
        expect(result[1].parentId, '1');
      });

      test('should return empty list when no children exist', () async {
        // Arrange
        when(
          mockDatabase.query(
            'locations',
            where: 'parent_id = ?',
            whereArgs: ['1'],
            orderBy: 'name ASC',
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getChildLocations('1');

        // Assert
        expect(result, isEmpty);
      });

      test('should throw DatabaseException on query error', () async {
        // Arrange
        when(
          mockDatabase.query(
            'locations',
            where: 'parent_id = ?',
            whereArgs: ['1'],
            orderBy: 'name ASC',
          ),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getChildLocations('1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getLocationPath', () {
      test('should return path from root to location', () async {
        // Arrange - Kitchen > Pantry > Top Shelf
        when(
          mockDatabase.query(
            'locations',
            where: 'id = ?',
            whereArgs: ['3'], // Top Shelf
          ),
        ).thenAnswer(
          (_) async => [
            {'id': '3', 'name': 'Top Shelf', 'parent_id': '2'},
          ],
        );

        when(
          mockDatabase.query(
            'locations',
            where: 'id = ?',
            whereArgs: ['2'], // Pantry
          ),
        ).thenAnswer(
          (_) async => [
            {'id': '2', 'name': 'Pantry', 'parent_id': '1'},
          ],
        );

        when(
          mockDatabase.query(
            'locations',
            where: 'id = ?',
            whereArgs: ['1'], // Kitchen
          ),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        // Act
        final result = await repository.getLocationPath('3');

        // Assert
        expect(result, hasLength(3));
        expect(result[0].name, 'Kitchen'); // Root first
        expect(result[1].name, 'Pantry');
        expect(result[2].name, 'Top Shelf');
      });

      test('should return single location for root location', () async {
        // Arrange
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        // Act
        final result = await repository.getLocationPath('1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].name, 'Kitchen');
      });

      test(
        'should throw LocationNotFoundException when location not found',
        () async {
          // Arrange
          when(
            mockDatabase.query(
              'locations',
              where: 'id = ?',
              whereArgs: ['nonexistent'],
            ),
          ).thenAnswer((_) async => []);

          // Act & Assert
          expect(
            () => repository.getLocationPath('nonexistent'),
            throwsA(isA<LocationNotFoundException>()),
          );
        },
      );
    });

    group('createLocation', () {
      test('should create root location successfully', () async {
        // Arrange
        final location = Location(id: '1', name: 'Kitchen', parentId: null);
        when(
          mockDatabase.insert('locations', location.toDatabase()),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.createLocation(location);

        // Assert
        expect(result.id, '1');
        expect(result.name, 'Kitchen');
        expect(result.parentId, isNull);
        verify(
          mockDatabase.insert('locations', location.toDatabase()),
        ).called(1);
      });

      test('should create child location successfully', () async {
        // Arrange
        final location = Location(id: '2', name: 'Pantry', parentId: '1');

        // Mock parent location exists
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        when(
          mockDatabase.insert('locations', location.toDatabase()),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.createLocation(location);

        // Assert
        expect(result.id, '2');
        expect(result.name, 'Pantry');
        expect(result.parentId, '1');
      });

      test('should throw ValidationException for empty name', () async {
        // Arrange
        final location = Location(id: '1', name: '', parentId: null);

        // Act & Assert
        expect(
          () => repository.createLocation(location),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'should throw ValidationException when hierarchy too deep',
        () async {
          // Arrange - Trying to create 6th level
          final location = Location(id: '6', name: 'Level 6', parentId: '5');

          // Mock 5 levels already exist
          when(
            mockDatabase.query('locations', where: 'id = ?', whereArgs: ['5']),
          ).thenAnswer(
            (_) async => [
              {'id': '5', 'name': 'Level 5', 'parent_id': '4'},
            ],
          );
          when(
            mockDatabase.query('locations', where: 'id = ?', whereArgs: ['4']),
          ).thenAnswer(
            (_) async => [
              {'id': '4', 'name': 'Level 4', 'parent_id': '3'},
            ],
          );
          when(
            mockDatabase.query('locations', where: 'id = ?', whereArgs: ['3']),
          ).thenAnswer(
            (_) async => [
              {'id': '3', 'name': 'Level 3', 'parent_id': '2'},
            ],
          );
          when(
            mockDatabase.query('locations', where: 'id = ?', whereArgs: ['2']),
          ).thenAnswer(
            (_) async => [
              {'id': '2', 'name': 'Level 2', 'parent_id': '1'},
            ],
          );
          when(
            mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
          ).thenAnswer(
            (_) async => [
              {'id': '1', 'name': 'Level 1', 'parent_id': null},
            ],
          );

          // Act & Assert
          expect(
            () => repository.createLocation(location),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('should throw DatabaseException on insert error', () async {
        // Arrange
        final location = Location(id: '1', name: 'Kitchen', parentId: null);
        when(
          mockDatabase.insert('locations', location.toDatabase()),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.createLocation(location),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('updateLocation', () {
      test('should update location successfully', () async {
        // Arrange
        final location = Location(
          id: '1',
          name: 'Updated Kitchen',
          parentId: null,
        );

        // Mock location exists
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        when(
          mockDatabase.update(
            'locations',
            location.toDatabase(),
            where: 'id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.updateLocation(location);

        // Assert
        expect(result.name, 'Updated Kitchen');
        verify(
          mockDatabase.update(
            'locations',
            location.toDatabase(),
            where: 'id = ?',
            whereArgs: ['1'],
          ),
        ).called(1);
      });

      test('should throw LocationNotFoundException when not found', () async {
        // Arrange
        final location = Location(
          id: 'nonexistent',
          name: 'Test',
          parentId: null,
        );
        when(
          mockDatabase.query(
            'locations',
            where: 'id = ?',
            whereArgs: ['nonexistent'],
          ),
        ).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => repository.updateLocation(location),
          throwsA(isA<LocationNotFoundException>()),
        );
      });

      test('should throw ValidationException for empty name', () async {
        // Arrange
        final location = Location(id: '1', name: '', parentId: null);

        // Act & Assert
        expect(
          () => repository.updateLocation(location),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('deleteLocation', () {
      test('should delete location when no items assigned', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => []); // No items

        when(
          mockDatabase.delete('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deleteLocation('1');

        // Assert
        expect(result, isTrue);
        verify(
          mockDatabase.delete('locations', where: 'id = ?', whereArgs: ['1']),
        ).called(1);
      });

      test('should unassign items when deleteItems is false', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer(
          (_) async => [
            {'id': 'item1'},
            {'id': 'item2'},
          ],
        );

        when(
          mockDatabase.update(
            'items',
            {'location_id': null},
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => 2);

        when(
          mockDatabase.delete('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deleteLocation('1', deleteItems: false);

        // Assert
        expect(result, isTrue);
        verify(
          mockDatabase.update(
            'items',
            {'location_id': null},
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).called(1);
      });

      test('should delete items when deleteItems is true', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer(
          (_) async => [
            {'id': 'item1'},
            {'id': 'item2'},
          ],
        );

        when(
          mockDatabase.delete(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => 2);

        when(
          mockDatabase.delete('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deleteLocation('1', deleteItems: true);

        // Assert
        expect(result, isTrue);
        verify(
          mockDatabase.delete(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).called(1);
      });

      test('should throw DatabaseException on delete error', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => []);

        when(
          mockDatabase.delete('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.deleteLocation('1'),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('hasItems', () {
      test('should return true when location has items', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer(
          (_) async => [
            {'id': 'item1'},
          ],
        );

        // Act
        final result = await repository.hasItems('1');

        // Assert
        expect(result, isTrue);
      });

      test('should return false when location has no items', () async {
        // Arrange
        when(
          mockDatabase.query(
            'items',
            where: 'location_id = ?',
            whereArgs: ['1'],
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.hasItems('1');

        // Assert
        expect(result, isFalse);
      });
    });

    group('validateLocationMove', () {
      test('should return true for valid move', () async {
        // Arrange - Moving location 3 to be child of location 2
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['2']),
        ).thenAnswer(
          (_) async => [
            {'id': '2', 'name': 'Pantry', 'parent_id': '1'},
          ],
        );

        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        // Act
        final result = await repository.validateLocationMove('3', '2');

        // Assert
        expect(result, isTrue);
      });

      test('should throw ValidationException for circular reference', () async {
        // Arrange - Trying to move location 1 to be child of location 3 (which is child of 1)
        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['3']),
        ).thenAnswer(
          (_) async => [
            {'id': '3', 'name': 'Top Shelf', 'parent_id': '2'},
          ],
        );

        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['2']),
        ).thenAnswer(
          (_) async => [
            {'id': '2', 'name': 'Pantry', 'parent_id': '1'},
          ],
        );

        when(
          mockDatabase.query('locations', where: 'id = ?', whereArgs: ['1']),
        ).thenAnswer(
          (_) async => [
            {'id': '1', 'name': 'Kitchen', 'parent_id': null},
          ],
        );

        // Act & Assert - Moving '1' to be child of '3' creates circular ref
        expect(
          () => repository.validateLocationMove('1', '3'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when moving to self', () async {
        // Act & Assert
        expect(
          () => repository.validateLocationMove('1', '1'),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
