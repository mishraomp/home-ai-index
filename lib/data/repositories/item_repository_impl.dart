import 'package:home_ai_index/core/constants/app_constants.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';

/// Implementation of ItemRepository using SQLite
class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  @override
  Future<String> createItem(Item item) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('items', item.toDatabase());
      return item.id;
    } catch (e) {
      throw DatabaseException('Failed to create item: $e');
    }
  }

  @override
  Future<Item?> getItemById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query('items', where: 'id = ?', whereArgs: [id]);

      if (results.isEmpty) {
        return null;
      }

      return Item.fromDatabase(results.first);
    } catch (e) {
      throw DatabaseException('Failed to get item: $e');
    }
  }

  @override
  Future<List<Item>> getItems({
    String? categoryId,
    String? locationId,
    bool includeUnlocated = false,
  }) async {
    try {
      final db = await _databaseHelper.database;

      // Build WHERE clause based on filters
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (categoryId != null) {
        whereClauses.add('category_id = ?');
        whereArgs.add(categoryId);
      }

      if (locationId != null) {
        if (includeUnlocated) {
          whereClauses.add('(location_id = ? OR location_id IS NULL)');
        } else {
          whereClauses.add('location_id = ?');
        }
        whereArgs.add(locationId);
      } else if (includeUnlocated && locationId == null) {
        // Special case: get only unlocated items
        whereClauses.add('location_id IS NULL');
      }

      final results = await db.query(
        'items',
        where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'added_at DESC',
      );

      return results.map((map) => Item.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get items: $e');
    }
  }

  @override
  Future<List<Item>> getItemsByCategory(String categoryId) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'items',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'added_at DESC',
      );

      return results.map((map) => Item.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get items by category: $e');
    }
  }

  @override
  Future<List<Item>> getItemsByLocation(String locationId) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'items',
        where: 'location_id = ?',
        whereArgs: [locationId],
        orderBy: 'added_at DESC',
      );

      return results.map((map) => Item.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get items by location: $e');
    }
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'items',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'added_at DESC',
        limit: searchResultsLimit,
      );

      return results.map((map) => Item.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to search items: $e');
    }
  }

  @override
  Future<void> updateItem(Item item) async {
    try {
      final db = await _databaseHelper.database;
      final rowsAffected = await db.update(
        'items',
        item.toDatabase(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      if (rowsAffected == 0) {
        throw ItemNotFoundException('Item with id ${item.id} not found');
      }
    } catch (e) {
      if (e is ItemNotFoundException) rethrow;
      throw DatabaseException('Failed to update item: $e');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final db = await _databaseHelper.database;
      final rowsAffected = await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw ItemNotFoundException('Item with id $id not found');
      }
    } catch (e) {
      if (e is ItemNotFoundException) rethrow;
      throw DatabaseException('Failed to delete item: $e');
    }
  }

  @override
  Future<List<Item>> getExpiringItems(int daysThreshold) async {
    try {
      final db = await _databaseHelper.database;
      final thresholdDate = DateTime.now()
          .add(Duration(days: daysThreshold))
          .toIso8601String();

      final results = await db.query(
        'items',
        where: 'expiration_date IS NOT NULL AND expiration_date <= ?',
        whereArgs: [thresholdDate],
        orderBy: 'expiration_date ASC',
      );

      return results.map((map) => Item.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get expiring items: $e');
    }
  }
}
