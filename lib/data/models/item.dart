import 'package:equatable/equatable.dart';

/// Represents an inventory item in the home
///
/// This is the core domain model representing physical items tracked in the app.
/// Items belong to categories and locations, and can have expiration dates,
/// images, and ML-detected labels.
class Item extends Equatable {
  /// Unique identifier (UUID format)
  final String id;

  /// Display name of the item
  final String name;

  /// Optional notes or description
  final String? notes;

  /// Quantity of this item (default 1)
  final int quantity;

  /// ID of the category this item belongs to
  final String categoryId;

  /// ID of the current location
  final String locationId;

  /// Optional expiration date (for perishables)
  final DateTime? expirationDate;

  /// Path to the item's image file (if captured)
  final String? imagePath;

  /// ML-detected label from image recognition
  final String? mlDetectedLabel;

  /// Confidence score of ML detection (0.0 to 1.0)
  final double? mlConfidenceScore;

  /// Timestamp when item was added to inventory
  final DateTime addedAt;

  /// Timestamp of last update
  final DateTime updatedAt;

  const Item({
    required this.id,
    required this.name,
    this.notes,
    required this.quantity,
    required this.categoryId,
    required this.locationId,
    this.expirationDate,
    this.imagePath,
    this.mlDetectedLabel,
    this.mlConfidenceScore,
    required this.addedAt,
    required this.updatedAt,
  });

  /// Creates an Item from a JSON map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      quantity: json['quantity'] as int,
      categoryId: json['categoryId'] as String,
      locationId: json['locationId'] as String,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      mlDetectedLabel: json['mlDetectedLabel'] as String?,
      mlConfidenceScore: json['mlConfidenceScore'] as double?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Creates an Item from a database map
  factory Item.fromDatabase(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      notes: map['notes'] as String?,
      quantity: map['quantity'] as int,
      categoryId: map['category_id'] as String,
      locationId: map['location_id'] as String,
      expirationDate: map['expiration_date'] != null
          ? DateTime.parse(map['expiration_date'] as String)
          : null,
      imagePath: map['image_path'] as String?,
      mlDetectedLabel: map['ml_detected_label'] as String?,
      mlConfidenceScore: map['ml_confidence_score'] as double?,
      addedAt: DateTime.parse(map['added_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts this Item to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'quantity': quantity,
      'categoryId': categoryId,
      'locationId': locationId,
      'expirationDate': expirationDate?.toIso8601String(),
      'imagePath': imagePath,
      'mlDetectedLabel': mlDetectedLabel,
      'mlConfidenceScore': mlConfidenceScore,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts this Item to a database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'quantity': quantity,
      'category_id': categoryId,
      'location_id': locationId,
      'expiration_date': expirationDate?.toIso8601String(),
      'image_path': imagePath,
      'ml_detected_label': mlDetectedLabel,
      'ml_confidence_score': mlConfidenceScore,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this Item with some fields replaced
  Item copyWith({
    String? id,
    String? name,
    String? notes,
    int? quantity,
    String? categoryId,
    String? locationId,
    DateTime? expirationDate,
    String? imagePath,
    String? mlDetectedLabel,
    double? mlConfidenceScore,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      expirationDate: expirationDate ?? this.expirationDate,
      imagePath: imagePath ?? this.imagePath,
      mlDetectedLabel: mlDetectedLabel ?? this.mlDetectedLabel,
      mlConfidenceScore: mlConfidenceScore ?? this.mlConfidenceScore,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    notes,
    quantity,
    categoryId,
    locationId,
    expirationDate,
    imagePath,
    mlDetectedLabel,
    mlConfidenceScore,
    addedAt,
    updatedAt,
  ];
}
