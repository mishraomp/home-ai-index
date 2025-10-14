import 'package:equatable/equatable.dart';

/// Represents a historical record of an item's location
///
/// Tracks where an item was located at specific points in time.
/// Limited to the most recent 10 entries per item.
class LocationHistory extends Equatable {
  /// Unique identifier (UUID format)
  final String id;

  /// ID of the item this history entry belongs to
  final String itemId;

  /// ID of the location where the item was
  final String locationId;

  /// Timestamp when the item was moved to this location
  final DateTime timestamp;

  const LocationHistory({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.timestamp,
  });

  /// Creates a LocationHistory from a JSON map
  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      locationId: json['locationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Creates a LocationHistory from a database map
  factory LocationHistory.fromDatabase(Map<String, dynamic> map) {
    return LocationHistory(
      id: map['id'] as String,
      itemId: map['item_id'] as String,
      locationId: map['location_id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Converts this LocationHistory to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'locationId': locationId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Converts this LocationHistory to a database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'item_id': itemId,
      'location_id': locationId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of this LocationHistory with some fields replaced
  LocationHistory copyWith({
    String? id,
    String? itemId,
    String? locationId,
    DateTime? timestamp,
  }) {
    return LocationHistory(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [id, itemId, locationId, timestamp];
}
