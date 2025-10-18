# Repository Contracts: Home AI Index

**Feature**: Home AI Index - Smart Home Inventory Manager  
**Date**: 2025-10-13  
**Type**: Internal Data Access Interfaces

## Overview

This document defines the repository interface contracts for data access in the Home AI Index application. These are **internal interfaces**, not REST APIs, as this is an offline-first mobile app with no backend server.

All repositories follow the Repository Pattern to abstract data sources (SQLite, file system, ML model) from business logic and UI layers.

---

## 1. ItemRepository Interface

### Purpose
Manages CRUD operations for inventory items.

### Interface Definition

```dart
abstract class ItemRepository {
  /// Retrieves all items, optionally filtered by category and/or location.
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

  /// Retrieves a single item by ID.
  ///
  /// [id]: Unique item identifier
  ///
  /// Returns: Item if found
  /// Throws: ItemNotFoundException if item doesn't exist
  Future<Item> getItemById(String id);

  /// Searches items by name.
  ///
  /// [query]: Search term (case-insensitive, partial match)
  /// [limit]: Maximum number of results (default: 50)
  ///
  /// Returns: List of matching items sorted by relevance
  /// Throws: DatabaseException on query error
  Future<List<Item>> searchItems(String query, {int limit = 50});

  /// Creates a new item.
  ///
  /// [item]: Item to create
  ///
  /// Returns: Created item with generated ID and timestamps
  /// Throws: ValidationException if item data is invalid
  /// Throws: DatabaseException on insert error
  Future<Item> createItem(Item item);

  /// Updates an existing item.
  ///
  /// [item]: Item with updated fields
  ///
  /// Returns: Updated item with new updatedAt timestamp
  /// Throws: ItemNotFoundException if item doesn't exist
  /// Throws: ValidationException if updated data is invalid
  /// Throws: DatabaseException on update error
  Future<Item> updateItem(Item item);

  /// Deletes an item by ID.
  ///
  /// Also deletes associated photo file and location history.
  ///
  /// [id]: Item ID to delete
  ///
  /// Returns: true if deleted successfully
  /// Throws: ItemNotFoundException if item doesn't exist
  /// Throws: DatabaseException on delete error
  Future<bool> deleteItem(String id);

  /// Bulk deletes items by IDs.
  ///
  /// [ids]: List of item IDs to delete
  ///
  /// Returns: Number of items successfully deleted
  /// Throws: DatabaseException on delete error
  Future<int> deleteItems(List<String> ids);

  /// Gets count of items by category.
  ///
  /// Returns: Map of category ID to item count
  /// Throws: DatabaseException on query error
  Future<Map<String, int>> getItemCountByCategory();

  /// Gets count of items by location.
  ///
  /// Returns: Map of location ID to item count
  /// Throws: DatabaseException on query error
  Future<Map<String, int>> getItemCountByLocation();

  /// Gets items expiring within specified days.
  ///
  /// [days]: Number of days from now (default: 7)
  ///
  /// Returns: List of items with expiration dates within threshold
  /// Throws: DatabaseException on query error
  Future<List<Item>> getExpiringItems({int days = 7});
}
```

### Implementation Notes

- Use `sqflite` for database operations
- All dates stored as Unix timestamps (milliseconds since epoch)
- Search uses `LIKE` with `%query%` pattern (case-insensitive with `COLLATE NOCASE`)
- Deletion triggers photo file cleanup via `ImageRepository`
- Location history cascade delete handled by database foreign key

---

## 2. CategoryRepository Interface

### Purpose
Manages item categories (default and custom).

### Interface Definition

```dart
abstract class CategoryRepository {
  /// Retrieves all categories.
  ///
  /// [includeCustomOnly]: If true, returns only custom categories
  ///
  /// Returns: List of all categories sorted alphabetically
  /// Throws: DatabaseException on query error
  Future<List<Category>> getCategories({bool includeCustomOnly = false});

  /// Retrieves a single category by ID.
  ///
  /// [id]: Category ID
  ///
  /// Returns: Category if found
  /// Throws: CategoryNotFoundException if not found
  Future<Category> getCategoryById(String id);

  /// Creates a new custom category.
  ///
  /// [category]: Category to create (isCustom must be true)
  ///
  /// Returns: Created category
  /// Throws: ValidationException if category data invalid or name not unique
  /// Throws: DatabaseException on insert error
  Future<Category> createCategory(Category category);

  /// Updates an existing category.
  ///
  /// Only custom categories can be updated.
  ///
  /// [category]: Category with updated fields
  ///
  /// Returns: Updated category
  /// Throws: CategoryNotFoundException if not found
  /// Throws: ValidationException if trying to update default category or name not unique
  /// Throws: DatabaseException on update error
  Future<Category> updateCategory(Category category);

  /// Deletes a custom category.
  ///
  /// Cannot delete default categories or categories with assigned items.
  ///
  /// [id]: Category ID
  ///
  /// Returns: true if deleted successfully
  /// Throws: CategoryNotFoundException if not found
  /// Throws: ValidationException if default category or has items
  /// Throws: DatabaseException on delete error
  Future<bool> deleteCategory(String id);

  /// Initializes default categories on first app launch.
  ///
  /// Returns: true if categories were created (first run)
  /// Throws: DatabaseException on insert error
  Future<bool> initializeDefaultCategories();

  /// Checks if category has any items.
  ///
  /// [categoryId]: Category ID to check
  ///
  /// Returns: true if category has items
  /// Throws: DatabaseException on query error
  Future<bool> hasItems(String categoryId);
}
```

### Implementation Notes

- Default categories pre-populated on first launch
- Category names must be unique (enforced by UNIQUE constraint)
- Icon stored as Material Icons `codePoint` (int)
- Cannot delete categories with items (check via `hasItems()` first)

---

## 3. LocationRepository Interface

### Purpose
Manages storage locations with hierarchical support.

### Interface Definition

```dart
abstract class LocationRepository {
  /// Retrieves all locations.
  ///
  /// [rootOnly]: If true, returns only top-level locations (parentId = null)
  ///
  /// Returns: List of locations
  /// Throws: DatabaseException on query error
  Future<List<Location>> getLocations({bool rootOnly = false});

  /// Retrieves a single location by ID.
  ///
  /// [id]: Location ID
  ///
  /// Returns: Location if found
  /// Throws: LocationNotFoundException if not found
  Future<Location> getLocationById(String id);

  /// Retrieves child locations of a parent.
  ///
  /// [parentId]: Parent location ID
  ///
  /// Returns: List of child locations
  /// Throws: DatabaseException on query error
  Future<List<Location>> getChildLocations(String parentId);

  /// Retrieves full path of location ancestors.
  ///
  /// [locationId]: Location ID
  ///
  /// Returns: List of locations from root to specified location
  /// Throws: LocationNotFoundException if not found
  /// Throws: DatabaseException on query error
  Future<List<Location>> getLocationPath(String locationId);

  /// Creates a new location.
  ///
  /// [location]: Location to create
  ///
  /// Returns: Created location with generated fullPath
  /// Throws: ValidationException if data invalid or hierarchy too deep (>5 levels)
  /// Throws: DatabaseException on insert error
  Future<Location> createLocation(Location location);

  /// Updates an existing location.
  ///
  /// [location]: Location with updated fields
  ///
  /// Returns: Updated location with regenerated fullPath
  /// Throws: LocationNotFoundException if not found
  /// Throws: ValidationException if data invalid or creates circular reference
  /// Throws: DatabaseException on update error
  Future<Location> updateLocation(Location location);

  /// Deletes a location.
  ///
  /// [id]: Location ID
  /// [deleteItems]: If true, delete items in location; if false, unassign items
  ///
  /// Returns: true if deleted successfully
  /// Throws: LocationNotFoundException if not found
  /// Throws: DatabaseException on delete error
  Future<bool> deleteLocation(String id, {bool deleteItems = false});

  /// Checks if location has any items.
  ///
  /// [locationId]: Location ID
  ///
  /// Returns: true if location has items
  /// Throws: DatabaseException on query error
  Future<bool> hasItems(String locationId);

  /// Validates that moving location doesn't create circular reference.
  ///
  /// [locationId]: Location being moved
  /// [newParentId]: New parent location ID
  ///
  /// Returns: true if move is valid
  /// Throws: ValidationException if would create circular reference
  Future<bool> validateLocationMove(String locationId, String newParentId);
}
```

### Implementation Notes

- `fullPath` auto-generated by traversing parent hierarchy
- Maximum hierarchy depth: 5 levels
- Circular reference validation before updates
- Cascade delete option for items in location

---

## 4. LocationHistoryRepository Interface

### Purpose
Tracks historical location assignments for items.

### Interface Definition

```dart
abstract class LocationHistoryRepository {
  /// Retrieves location history for an item.
  ///
  /// [itemId]: Item ID
  /// [limit]: Maximum number of entries (default: 10)
  ///
  /// Returns: List of history entries sorted by date (newest first)
  /// Throws: DatabaseException on query error
  Future<List<LocationHistory>> getHistoryForItem(String itemId, {int limit = 10});

  /// Creates a new history entry when item location changes.
  ///
  /// [entry]: History entry to create
  ///
  /// Returns: Created history entry
  /// Throws: ValidationException if data invalid
  /// Throws: DatabaseException on insert error
  Future<LocationHistory> createHistoryEntry(LocationHistory entry);

  /// Deletes old history entries for an item (keeps last N entries).
  ///
  /// [itemId]: Item ID
  /// [keepLast]: Number of recent entries to keep (default: 10)
  ///
  /// Returns: Number of deleted entries
  /// Throws: DatabaseException on delete error
  Future<int> pruneHistoryForItem(String itemId, {int keepLast = 10});

  /// Deletes all history for an item (called when item is deleted).
  ///
  /// [itemId]: Item ID
  ///
  /// Returns: Number of deleted entries
  /// Throws: DatabaseException on delete error
  Future<int> deleteHistoryForItem(String itemId);
}
```

### Implementation Notes

- Auto-created when `ItemRepository.updateItem()` changes location
- Limited to last 10 entries per item (older pruned automatically)
- Cascade deleted when item is removed

---

## 5. ImageRepository Interface

### Purpose
Manages photo storage and retrieval on device file system.

### Interface Definition

```dart
abstract class ImageRepository {
  /// Saves an image file to app's private storage.
  ///
  /// [imagePath]: Path to source image (from camera/gallery)
  /// [itemId]: Unique identifier for the item
  ///
  /// Returns: Path to saved image file
  /// Throws: ImageProcessingException if compression fails
  /// Throws: FileSystemException if save fails
  Future<String> saveImage(String imagePath, String itemId);

  /// Generates a thumbnail for an image.
  ///
  /// [imagePath]: Path to source image
  /// [itemId]: Unique identifier for the item
  ///
  /// Returns: Path to thumbnail file
  /// Throws: ImageProcessingException if thumbnail generation fails
  Future<String> generateThumbnail(String imagePath, String itemId);

  /// Retrieves the file path for an item's photo.
  ///
  /// [itemId]: Item ID
  ///
  /// Returns: Path to image file
  /// Throws: FileNotFoundException if image doesn't exist
  Future<String> getImagePath(String itemId);

  /// Retrieves the file path for an item's thumbnail.
  ///
  /// [itemId]: Item ID
  ///
  /// Returns: Path to thumbnail file
  /// Throws: FileNotFoundException if thumbnail doesn't exist
  Future<String> getThumbnailPath(String itemId);

  /// Deletes an item's photo and thumbnail.
  ///
  /// [itemId]: Item ID
  ///
  /// Returns: true if files deleted successfully
  /// Throws: FileSystemException on delete error
  Future<bool> deleteImage(String itemId);

  /// Gets total storage used by photos.
  ///
  /// Returns: Storage size in bytes
  /// Throws: FileSystemException on error
  Future<int> getTotalStorageUsed();

  /// Compresses an image to target size.
  ///
  /// [imagePath]: Path to source image
  /// [maxSizeBytes]: Maximum file size in bytes (default: 2MB)
  /// [quality]: JPEG quality 0-100 (default: 85)
  ///
  /// Returns: Path to compressed image
  /// Throws: ImageProcessingException if compression fails
  Future<String> compressImage(
    String imagePath, {
    int maxSizeBytes = 2 * 1024 * 1024,
    int quality = 85,
  });
}
```

### Implementation Notes

- Images stored in app's documents directory: `/app_documents/photos/`
- Thumbnails stored in: `/app_documents/thumbnails/`
- Filename format: `{itemId}.jpg` and `{itemId}_thumb.jpg`
- Compression: Max 2MB, JPEG quality 85%, max dimensions 1920×1080
- Thumbnails: 200×200px, JPEG quality 70%

---

## 6. ImageRecognitionService Interface

### Purpose
Performs on-device image classification using TensorFlow Lite.

### Interface Definition

```dart
abstract class ImageRecognitionService {
  /// Initializes the TensorFlow Lite model.
  ///
  /// Should be called once during app initialization.
  ///
  /// Returns: true if model loaded successfully
  /// Throws: ModelLoadException if model file not found or invalid
  Future<bool> initializeModel();

  /// Classifies an image and returns detected labels.
  ///
  /// [imagePath]: Path to image file
  ///
  /// Returns: List of detected labels with confidence scores
  /// Throws: ImageProcessingException if image can't be processed
  /// Throws: ModelNotInitializedException if model not loaded
  Future<ImageRecognitionResult> classifyImage(String imagePath);

  /// Maps ImageNet label to app category.
  ///
  /// [label]: Label from ML model (e.g., "banana", "screwdriver")
  ///
  /// Returns: Suggested category name or null if no mapping
  String? mapLabelToCategory(String label);

  /// Releases model resources.
  ///
  /// Should be called when app is disposed.
  ///
  /// Returns: true if cleanup successful
  Future<bool> dispose();
}
```

### Implementation Notes

- Model file: `assets/ml_models/mobilenet_v2.tflite`
- Input: 224×224 RGB image
- Output: Top 5 predictions with confidence scores
- Lazy-loaded when camera is first opened (not on app startup)
- Label-to-category mapping based on ImageNet classes

**Example Label Mappings**:
```dart
const labelCategoryMap = {
  // Groceries
  'banana': 'Groceries',
  'orange': 'Groceries',
  'apple': 'Groceries',
  'milk': 'Groceries',
  
  // Tools
  'hammer': 'Tools',
  'screwdriver': 'Tools',
  'wrench': 'Tools',
  
  // Electronics
  'laptop': 'Electronics',
  'phone': 'Electronics',
  'remote control': 'Electronics',
  
  // ... (full mapping in implementation)
};
```

---

## Exception Hierarchy

All custom exceptions extend `AppException`:

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
}

// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(String message) : super(message, 'DB_ERROR');
}

// Entity not found exceptions
class ItemNotFoundException extends AppException {
  const ItemNotFoundException(String id) 
    : super('Item not found: $id', 'ITEM_NOT_FOUND');
}

class CategoryNotFoundException extends AppException {
  const CategoryNotFoundException(String id) 
    : super('Category not found: $id', 'CATEGORY_NOT_FOUND');
}

class LocationNotFoundException extends AppException {
  const LocationNotFoundException(String id) 
    : super('Location not found: $id', 'LOCATION_NOT_FOUND');
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(String message) 
    : super(message, 'VALIDATION_ERROR');
}

// File system exceptions
class FileSystemException extends AppException {
  const FileSystemException(String message) 
    : super(message, 'FILE_ERROR');
}

class FileNotFoundException extends FileSystemException {
  const FileNotFoundException(String path) 
    : super('File not found: $path');
}

// Image processing exceptions
class ImageProcessingException extends AppException {
  const ImageProcessingException(String message) 
    : super(message, 'IMAGE_ERROR');
}

// ML model exceptions
class ModelLoadException extends AppException {
  const ModelLoadException(String message) 
    : super(message, 'MODEL_LOAD_ERROR');
}

class ModelNotInitializedException extends AppException {
  const ModelNotInitializedException() 
    : super('ML model not initialized', 'MODEL_NOT_INITIALIZED');
}
```

---

## Summary

✅ **6 Repository Interfaces**: Items, Categories, Locations, History, Images, ML  
✅ **Clear Contracts**: All methods documented with params, returns, exceptions  
✅ **Testable**: Interfaces enable easy mocking for unit tests  
✅ **Consistent**: All repos follow same pattern and error handling  
✅ **Type-Safe**: Strong typing with custom exceptions  

**Next Steps**: Create quickstart guide for developers
