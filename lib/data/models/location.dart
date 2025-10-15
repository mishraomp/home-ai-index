import 'package:equatable/equatable.dart';

/// Represents a storage location in the home
///
/// Locations form a hierarchical structure (up to 5 levels deep).
/// Example: Home > Kitchen > Pantry > Top Shelf > Left Side
class Location extends Equatable {

  const Location({required this.id, required this.name, this.parentId});

  /// Creates a Location from a JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
    );
  }

  /// Creates a Location from a database map
  factory Location.fromDatabase(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
    );
  }
  /// Unique identifier (UUID format)
  final String id;

  /// Display name of the location
  final String name;

  /// ID of the parent location (null for root locations)
  final String? parentId;

  /// Converts this Location to a JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parentId': parentId};
  }

  /// Converts this Location to a database map
  Map<String, dynamic> toDatabase() {
    return {'id': id, 'name': name, 'parent_id': parentId};
  }

  /// Creates a copy of this Location with some fields replaced
  Location copyWith({String? id, String? name, String? parentId}) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [id, name, parentId];
}
