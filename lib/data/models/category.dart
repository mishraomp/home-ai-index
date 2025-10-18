import 'package:equatable/equatable.dart';

/// Represents a category for organizing inventory items
///
/// Categories can be default (pre-populated) or custom (user-created).
/// Each category has an icon represented by its Material Icons codePoint.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.isCustom,
  });

  /// Creates a Category from a JSON map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      isCustom: json['isCustom'] as bool,
    );
  }

  /// Creates a Category from a database map
  factory Category.fromDatabase(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['icon_code_point'] as int,
      isCustom: (map['is_custom'] as int) == 1,
    );
  }

  /// Unique identifier (UUID format for custom, predefined string for defaults)
  final String id;

  /// Display name of the category
  final String name;

  /// Material Icons codePoint for the category icon
  final int iconCodePoint;

  /// Whether this is a user-created custom category
  final bool isCustom;

  /// Converts this Category to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'isCustom': isCustom,
    };
  }

  /// Converts this Category to a database map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'icon_code_point': iconCodePoint,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  /// Creates a copy of this Category with some fields replaced
  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    bool? isCustom,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  List<Object?> get props => [id, name, iconCodePoint, isCustom];
}
