import 'package:home_ai_index/data/models/item.dart';

/// Repository interface for Item data operations
abstract class ItemRepository {
  /// Creates a new item in the database
  Future<String> createItem(Item item);

  /// Retrieves an item by its ID
  Future<Item?> getItemById(String id);

  /// Retrieves all items
  Future<List<Item>> getItems();

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
