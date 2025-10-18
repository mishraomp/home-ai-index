import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/repositories/category_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([DatabaseHelper, Database])
import 'category_repository_test.mocks.dart';

void main() {
  group('CategoryRepository', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late MockDatabase mockDatabase;
    late CategoryRepositoryImpl repository;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
      repository = CategoryRepositoryImpl(mockDatabaseHelper);

      when(mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
    });

    const testCategory = Category(
      id: 'groceries',
      name: 'Groceries',
      iconCodePoint: 0xe59c,
      isCustom: false,
    );

    group('getCategories', () {
      test('should return all categories', () async {
        when(mockDatabase.query('categories', orderBy: anyNamed('orderBy')))
            .thenAnswer((_) async => [
                  testCategory.toDatabase(),
                  testCategory.copyWith(id: 'tools', name: 'Tools').toDatabase(),
                ]);

        final result = await repository.getCategories();

        expect(result, hasLength(2));
        expect(result[0].id, 'groceries');
        expect(result[1].id, 'tools');
        verify(mockDatabase.query('categories', orderBy: 'name ASC')).called(1);
      });

      test('should return empty list when no categories', () async {
        when(mockDatabase.query('categories', orderBy: anyNamed('orderBy')))
            .thenAnswer((_) async => []);

        final result = await repository.getCategories();

        expect(result, isEmpty);
      });

      test('should throw DatabaseException on query failure', () async {
        when(mockDatabase.query('categories', orderBy: anyNamed('orderBy')))
            .thenThrow(Exception('Query failed'));

        expect(
          () => repository.getCategories(),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('getCategoryById', () {
      test('should return category when found', () async {
        when(mockDatabase.query(
          'categories',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => [testCategory.toDatabase()]);

        final result = await repository.getCategoryById('groceries');

        expect(result, isNotNull);
        expect(result!.id, 'groceries');
        expect(result.name, 'Groceries');
        verify(mockDatabase.query(
          'categories',
          where: 'id = ?',
          whereArgs: ['groceries'],
        )).called(1);
      });

      test('should return null when category not found', () async {
        when(mockDatabase.query(
          'categories',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => []);

        final result = await repository.getCategoryById('nonexistent');

        expect(result, isNull);
      });

      test('should throw DatabaseException on query failure', () async {
        when(mockDatabase.query(
          'categories',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenThrow(Exception('Query failed'));

        expect(
          () => repository.getCategoryById('groceries'),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('createCategory', () {
      test('should insert custom category into database', () async {
        const customCategory = Category(
          id: 'custom-1',
          name: 'My Custom Category',
          iconCodePoint: 0xe000,
          isCustom: true,
        );

        when(mockDatabase.insert('categories', any))
            .thenAnswer((_) async => 1);

        final result = await repository.createCategory(customCategory);

        expect(result, customCategory.id);
        verify(mockDatabase.insert('categories', customCategory.toDatabase()))
            .called(1);
      });

      test('should throw DatabaseException on insert failure', () async {
        const customCategory = Category(
          id: 'custom-1',
          name: 'My Custom Category',
          iconCodePoint: 0xe000,
          isCustom: true,
        );

        when(mockDatabase.insert('categories', any))
            .thenThrow(Exception('Insert failed'));

        expect(
          () => repository.createCategory(customCategory),
          throwsA(isA<app_exceptions.DatabaseException>()),
        );
      });
    });

    group('updateCategory', () {
      test('should update custom category in database', () async {
        const customCategory = Category(
          id: 'custom-1',
          name: 'Updated Category',
          iconCodePoint: 0xe000,
          isCustom: true,
        );

        when(mockDatabase.update(
          'categories',
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 1);

        await repository.updateCategory(customCategory);

        verify(mockDatabase.update(
          'categories',
          customCategory.toDatabase(),
          where: 'id = ?',
          whereArgs: [customCategory.id],
        )).called(1);
      });

      test('should throw CategoryNotFoundException when category not found',
          () async {
        const customCategory = Category(
          id: 'custom-1',
          name: 'Updated Category',
          iconCodePoint: 0xe000,
          isCustom: true,
        );

        when(mockDatabase.update(
          'categories',
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 0);

        expect(
          () => repository.updateCategory(customCategory),
          throwsA(isA<app_exceptions.CategoryNotFoundException>()),
        );
      });
    });

    group('deleteCategory', () {
      test('should delete custom category from database', () async {
        when(mockDatabase.delete(
          'categories',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 1);

        await repository.deleteCategory('custom-1');

        verify(mockDatabase.delete(
          'categories',
          where: 'id = ?',
          whereArgs: ['custom-1'],
        )).called(1);
      });

      test('should throw CategoryNotFoundException when category not found',
          () async {
        when(mockDatabase.delete(
          'categories',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 0);

        expect(
          () => repository.deleteCategory('custom-1'),
          throwsA(isA<app_exceptions.CategoryNotFoundException>()),
        );
      });
    });
  });
}
