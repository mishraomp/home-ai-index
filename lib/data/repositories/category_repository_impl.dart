import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';

/// Implementation of CategoryRepository using SQLite
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query('categories', orderBy: 'name ASC');

      return results.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get categories: $e');
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return null;
      }

      return Category.fromDatabase(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get category: $e');
    }
  }

  @override
  Future<String> createCategory(Category category) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('categories', category.toDatabase());
      return category.id;
    } catch (e) {
      throw DatabaseException('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final db = await _databaseHelper.database;
      final rowsAffected = await db.update(
        'categories',
        category.toDatabase(),
        where: 'id = ?',
        whereArgs: [category.id],
      );

      if (rowsAffected == 0) {
        throw CategoryNotFoundException(
          'Category with id ${category.id} not found',
        );
      }
    } catch (e) {
      if (e is CategoryNotFoundException) rethrow;
      throw DatabaseException('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final db = await _databaseHelper.database;
      final rowsAffected = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw CategoryNotFoundException('Category with id $id not found');
      }
    } catch (e) {
      if (e is CategoryNotFoundException) rethrow;
      throw DatabaseException('Failed to delete category: $e');
    }
  }
}
