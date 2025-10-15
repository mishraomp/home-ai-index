import 'package:home_ai_index/core/exceptions.dart'
    show DatabaseException, ValidationException;
import 'package:home_ai_index/data/models/location_history.dart';

/// Repository interface for managing item location history.
/// Tracks the history of location changes for items.
abstract class LocationHistoryRepository {
  /// Gets the location history for a specific item.
  ///
  /// Returns entries sorted by timestamp in descending order (newest first).
  /// The [limit] parameter specifies the maximum number of entries to return (default: 10).
  /// Returns an empty list if no history exists for the item.
  ///
  /// Throws [DatabaseException] if the database operation fails.
  Future<List<LocationHistory>> getHistoryForItem(
    String itemId, {
    int limit = 10,
  });

  /// Creates a new location history entry.
  ///
  /// Returns the created LocationHistory entry.
  ///
  /// Throws [ValidationException] if:
  /// - itemId is empty
  /// - locationId is empty
  ///
  /// Throws [DatabaseException] if the database operation fails.
  Future<LocationHistory> createHistoryEntry(LocationHistory entry);

  /// Prunes old location history entries for an item, keeping only the most recent entries.
  ///
  /// The [keepLast] parameter specifies how many recent entries to keep (default: 10).
  /// Returns the number of entries deleted.
  ///
  /// Throws [DatabaseException] if the database operation fails.
  Future<int> pruneHistoryForItem(String itemId, {int keepLast = 10});

  /// Deletes all location history entries for a specific item.
  ///
  /// Returns the number of entries deleted.
  ///
  /// Throws [DatabaseException] if the database operation fails.
  Future<int> deleteHistoryForItem(String itemId);
}
