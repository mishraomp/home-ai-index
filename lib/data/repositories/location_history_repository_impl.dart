import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// SQLite implementation of LocationHistoryRepository.
class LocationHistoryRepositoryImpl implements LocationHistoryRepository {
  LocationHistoryRepositoryImpl({required this.database});
  final Database database;

  @override
  Future<List<LocationHistory>> getHistoryForItem(
    String itemId, {
    int limit = 10,
  }) async {
    try {
      final results = await database.query(
        'location_history',
        where: 'item_id = ?',
        whereArgs: [itemId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results.map((map) => LocationHistory.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get location history for item: $e');
    }
  }

  @override
  Future<LocationHistory> createHistoryEntry(LocationHistory entry) async {
    // Validate input before DB operations
    if (entry.itemId.trim().isEmpty) {
      throw const ValidationException('Item ID cannot be empty');
    }
    if (entry.locationId.trim().isEmpty) {
      throw const ValidationException('Location ID cannot be empty');
    }

    try {
      await database.insert('location_history', entry.toDatabase());
      return entry;
    } catch (e) {
      throw DatabaseException('Failed to create location history entry: $e');
    }
  }

  @override
  Future<int> pruneHistoryForItem(String itemId, {int keepLast = 10}) async {
    try {
      // Get all entries for this item
      final allEntries = await database.query(
        'location_history',
        where: 'item_id = ?',
        whereArgs: [itemId],
        orderBy: 'timestamp DESC',
      );

      // If we have more than keepLast entries, delete the excess
      if (allEntries.length <= keepLast) {
        return 0; // Nothing to prune
      }

      // Get IDs of entries to delete (skip the newest keepLast entries)
      final entriesToDelete = allEntries.skip(keepLast).toList();
      final idsToDelete = entriesToDelete
          .map((e) => e['id'] as String)
          .toList();

      // Delete the old entries
      final deletedCount = await database.delete(
        'location_history',
        where: 'id IN (${idsToDelete.map((_) => '?').join(', ')})',
        whereArgs: idsToDelete,
      );

      return deletedCount;
    } catch (e) {
      throw DatabaseException('Failed to prune location history: $e');
    }
  }

  @override
  Future<int> deleteHistoryForItem(String itemId) async {
    try {
      return await database.delete(
        'location_history',
        where: 'item_id = ?',
        whereArgs: [itemId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete location history: $e');
    }
  }
}
