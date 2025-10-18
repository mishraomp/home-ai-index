# Data Model: Home AI Index

**Feature**: Home AI Index - Smart Home Inventory Manager  
**Date**: 2025-10-13  
**Status**: Complete

## Overview

This document defines the data entities, relationships, and validation rules for the Home AI Index application. All entities are stored locally in SQLite and follow immutable patterns with `copyWith` methods.

---

## Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐
│  Category   │◄────────│     Item     │
│             │ 1     * │              │
│  - id       │         │  - id        │
│  - name     │         │  - name      │
│  - icon     │         │  - photo     │
│  - custom   │         │  - quantity  │
└─────────────┘         │  - notes     │
                        └──────┬───────┘
                               │ *
                               │
                               │ 1
                        ┌──────▼────────┐
                        │   Location    │
                        │               │◄──┐ parent
                        │  - id         │   │
                        │  - name       │   │ (self-ref)
                        │  - parent_id  │───┘
                        │  - full_path  │
                        └───────┬───────┘
                                │
                                │ *
                                │
                        ┌───────▼────────────┐
                        │ LocationHistory    │
                        │                    │
                        │  - id              │
                        │  - item_id         │
                        │  - location_id     │
                        │  - moved_at        │
                        └────────────────────┘
```

**Relationships**:
- **Category → Item**: One-to-Many (one category has many items)
- **Location → Item**: One-to-Many (one location contains many items)
- **Location → Location**: Self-referential (hierarchical locations)
- **Item → LocationHistory**: One-to-Many (track item movements)

---

## 1. Item Entity

### Description
Represents a physical object in the home inventory.

### Dart Model

```dart
import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final String? locationId;
  final String? photoPath;
  final int quantity;
  final String? notes;
  final DateTime? expirationDate;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Item({
    required this.id,
    required this.name,
    required this.categoryId,
    this.locationId,
    this.photoPath,
    this.quantity = 1,
    this.notes,
    this.expirationDate,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Immutable updates
  Item copyWith({
    String? name,
    String? categoryId,
    String? locationId,
    String? photoPath,
    int? quantity,
    String? notes,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      photoPath: photoPath ?? this.photoPath,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      expirationDate: expirationDate ?? this.expirationDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'location_id': locationId,
      'photo_path': photoPath,
      'quantity': quantity,
      'notes': notes,
      'expiration_date': expirationDate?.millisecondsSinceEpoch,
      'purchase_date': purchaseDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
      locationId: json['location_id'] as String?,
      photoPath: json['photo_path'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String?,
      expirationDate: json['expiration_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiration_date'] as int)
          : null,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['purchase_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        categoryId,
        locationId,
        photoPath,
        quantity,
        notes,
        expirationDate,
        purchaseDate,
        createdAt,
        updatedAt,
      ];
}
```

### Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| `id` | UUID v4 format | "Invalid item ID format" |
| `name` | 1-100 characters, not empty | "Item name must be between 1 and 100 characters" |
| `categoryId` | Must reference existing category | "Invalid category" |
| `locationId` | Must reference existing location (if provided) | "Invalid location" |
| `photoPath` | Valid file path (if provided) | "Invalid photo path" |
| `quantity` | ≥1 | "Quantity must be at least 1" |
| `notes` | ≤500 characters (if provided) | "Notes cannot exceed 500 characters" |
| `expirationDate` | Future date (if provided) | "Expiration date cannot be in the past" |
| `purchaseDate` | ≤ today (if provided) | "Purchase date cannot be in the future" |

### Business Rules

1. **Deletion**: When an item is deleted, its location history is also deleted (CASCADE)
2. **Photo Cleanup**: When an item with a photo is deleted, the photo file must be removed from storage
3. **Location Assignment**: Items can exist without a location (unlocated items)
4. **Expiration Warning**: Items expire within 7 days show warning badge
5. **Duplicate Names**: Allowed (differentiated by location and photo)

---

## 2. Category Entity

### Description
Classification for grouping similar items.

### Dart Model

```dart
class Category extends Equatable {
  final String id;
  final String name;
  final int iconCode; // Material Icons codePoint
  final bool isCustom;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    this.isCustom = false,
    required this.createdAt,
  });

  Category copyWith({
    String? name,
    int? iconCode,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      isCustom: isCustom,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['icon_code'] as int,
      isCustom: (json['is_custom'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  @override
  List<Object?> get props => [id, name, iconCode, isCustom, createdAt];
}
```

### Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| `id` | UUID v4 format | "Invalid category ID format" |
| `name` | 1-50 characters, unique | "Category name must be unique and between 1-50 characters" |
| `iconCode` | Valid Material Icons codePoint | "Invalid icon" |

### Default Categories

The following 12 categories are pre-populated on first app launch:

```dart
final defaultCategories = [
  Category(id: uuid(), name: 'Groceries', iconCode: Icons.shopping_basket.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Tools', iconCode: Icons.build.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Appliances', iconCode: Icons.kitchen.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Clothing', iconCode: Icons.checkroom.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Electronics', iconCode: Icons.devices.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Cleaning Supplies', iconCode: Icons.cleaning_services.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Furniture', iconCode: Icons.chair.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Sports Equipment', iconCode: Icons.sports_soccer.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Toys', iconCode: Icons.toys.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Books', iconCode: Icons.book.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Kitchen Items', iconCode: Icons.restaurant.codePoint, isCustom: false, createdAt: now),
  Category(id: uuid(), name: 'Bathroom Items', iconCode: Icons.bathroom.codePoint, isCustom: false, createdAt: now),
];
```

### Business Rules

1. **Default Categories**: Cannot be deleted, only custom categories can be removed
2. **Deletion Constraint**: Cannot delete category with assigned items (must reassign first)
3. **Name Uniqueness**: Category names must be unique (case-insensitive)

---

## 3. Location Entity

### Description
Physical storage place in the home where items are kept. Supports hierarchical organization.

### Dart Model

```dart
class Location extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final String fullPath; // e.g., "Master Bedroom > Closet > Top Shelf"
  final DateTime createdAt;

  const Location({
    required this.id,
    required this.name,
    this.parentId,
    required this.fullPath,
    required this.createdAt,
  });

  Location copyWith({
    String? name,
    String? parentId,
    String? fullPath,
  }) {
    return Location(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      fullPath: fullPath ?? this.fullPath,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'full_path': fullPath,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      fullPath: json['full_path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  @override
  List<Object?> get props => [id, name, parentId, fullPath, createdAt];
}
```

### Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| `id` | UUID v4 format | "Invalid location ID format" |
| `name` | 1-100 characters | "Location name must be between 1 and 100 characters" |
| `parentId` | Must reference existing location (if provided) | "Invalid parent location" |
| `fullPath` | Auto-generated, read-only | N/A |

### Business Rules

1. **Hierarchy**: Maximum 5 levels deep to prevent excessive nesting
2. **Full Path**: Auto-generated by concatenating parent names with " > " separator
3. **Deletion Options**:
   - **Remove location only**: Items become unlocated (location_id = NULL)
   - **Remove location and items**: Cascade delete all items
4. **Circular References**: Prevent location from being its own ancestor
5. **Root Locations**: Locations with `parentId = NULL` are top-level

### Example Hierarchies

```
Master Bedroom (root)
├── Closet
│   ├── Top Shelf
│   └── Bottom Drawer
└── Dresser

Kitchen (root)
├── Pantry
│   ├── Top Shelf
│   └── Bottom Shelf
└── Refrigerator
    ├── Top Shelf
    └── Crisper Drawer

Garage (root)
└── Tool Cabinet
    ├── Top Drawer
    └── Bottom Drawer
```

---

## 4. Location History Entity

### Description
Tracks historical location assignments for items to provide movement audit trail.

### Dart Model

```dart
class LocationHistory extends Equatable {
  final String id;
  final String itemId;
  final String locationId;
  final DateTime movedAt;

  const LocationHistory({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.movedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'location_id': locationId,
      'moved_at': movedAt.millisecondsSinceEpoch,
    };
  }

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      locationId: json['location_id'] as String,
      movedAt: DateTime.fromMillisecondsSinceEpoch(json['moved_at'] as int),
    );
  }

  @override
  List<Object?> get props => [id, itemId, locationId, movedAt];
}
```

### Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| `id` | UUID v4 format | "Invalid history ID format" |
| `itemId` | Must reference existing item | "Invalid item reference" |
| `locationId` | Must reference existing location | "Invalid location reference" |
| `movedAt` | Valid timestamp | "Invalid timestamp" |

### Business Rules

1. **Auto-Create**: New history entry created when item location changes
2. **History Limit**: Keep last 10 location changes per item (delete older entries)
3. **Cascade Delete**: When item is deleted, all history entries are deleted
4. **Read-Only**: History entries cannot be edited after creation

---

## 5. Image Recognition Result (Transient)

### Description
Temporary entity representing ML model output. Not persisted to database.

### Dart Model

```dart
class ImageRecognitionResult {
  final List<DetectedLabel> labels;
  final DateTime processedAt;
  final Duration processingTime;

  const ImageRecognitionResult({
    required this.labels,
    required this.processedAt,
    required this.processingTime,
  });
}

class DetectedLabel {
  final String label;
  final double confidence;
  final String? suggestedCategory;

  const DetectedLabel({
    required this.label,
    required this.confidence,
    this.suggestedCategory,
  });
}
```

### Business Rules

1. **Confidence Threshold**: Only show labels with confidence ≥ 0.3
2. **Top Results**: Return top 5 predictions sorted by confidence
3. **Category Mapping**: Map ImageNet labels to app categories (e.g., "banana" → "Groceries")
4. **Manual Fallback**: If top confidence < 0.5, prompt user for manual entry

---

## Database Indexes

For optimal query performance:

```sql
-- Item queries
CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_items_location ON items(location_id);
CREATE INDEX idx_items_name ON items(name COLLATE NOCASE); -- Case-insensitive search

-- Location queries
CREATE INDEX idx_locations_parent ON locations(parent_id);
CREATE INDEX idx_locations_path ON locations(full_path);

-- History queries
CREATE INDEX idx_location_history_item ON location_history(item_id);
CREATE INDEX idx_location_history_timestamp ON location_history(moved_at);
```

---

## State Transitions

### Item Lifecycle

```
┌──────────┐
│  Create  │
└────┬─────┘
     │
     ▼
┌──────────┐    Update    ┌──────────┐
│  Active  │◄────────────►│ Modified │
└────┬─────┘              └──────────┘
     │
     │ Delete
     ▼
┌──────────┐
│ Deleted  │ (permanent)
└──────────┘
```

### Location Assignment Transitions

```
┌────────────┐
│ Unlocated  │
└──────┬─────┘
       │ Assign location
       ▼
┌────────────┐
│  Located   │
└──────┬─────┘
       │
       ├─► Relocate (create history entry)
       │
       └─► Unassign (set location_id = NULL)
```

---

## Data Migration Plan

**Version 1.0** (MVP):
- Initial schema as defined above
- No migrations needed

**Future Versions**:
- Use sqflite migrations with version management
- Add `schema_version` table to track applied migrations
- Support backward-compatible schema changes

---

## Summary

✅ **Entities Defined**: 4 core entities + 1 transient  
✅ **Relationships**: Clear foreign key relationships  
✅ **Validation**: Comprehensive validation rules  
✅ **Immutability**: All models use `copyWith` pattern  
✅ **Serialization**: JSON serialization for SQLite storage  
✅ **Performance**: Proper indexing strategy  
✅ **Business Rules**: Clear data lifecycle management  

**Next Steps**: Generate API contracts (internal data access patterns)
