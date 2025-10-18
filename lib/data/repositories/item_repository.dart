import 'package:home_ai_index/data/models/item.dart';

/// Repository interface for Item data operations
abstract class ItemRepository {
  /// Creates a new item in the database
  Future<String> createItem(Item item);

  /// Retrieves an item by its ID
  Future<Item?> getItemById(String id);

  /// Retrieves all items, optionally filtered by category and/or location
  ///
  /// [categoryId]: Filter items by category (optional)
  /// [locationId]: Filter items by location (optional)
  /// [includeUnlocated]: Include items without location when filtering by location
  ///
  /// Returns: List of items matching filters
  /// Throws: DatabaseException on query error
  Future<List<Item>> getItems({
    String? categoryId,
    String? locationId,
    bool includeUnlocated = false,
  });

  /// Retrieves items filtered by category
  Future<List<Item>> getItemsByCategory(String categoryId);

  /// Retrieves items filtered by location
  Future<List<Item>> getItemsByLocation(String locationId);

  /// Searches items by name
  Future<List<Item>> searchItems(String query);

  /// Updates an existing item
  Future<void> updateItem(Item item);

  /// Deletes an item by its ID
  Future<void> deleteItem(String id);

  /// Retrieves items expiring within the specified number of days
  Future<List<Item>> getExpiringItems(int daysThreshold);
}
