import 'package:flutter/material.dart';

/// Default categories for home inventory items
///
/// These 12 categories are pre-populated on first app launch.
final List<Map<String, dynamic>> defaultCategories = [
  {
    'id': 'groceries',
    'name': 'Groceries',
    'iconCodePoint': Icons.shopping_basket.codePoint,
    'isCustom': false,
  },
  {
    'id': 'tools',
    'name': 'Tools',
    'iconCodePoint': Icons.hardware.codePoint,
    'isCustom': false,
  },
  {
    'id': 'appliances',
    'name': 'Appliances',
    'iconCodePoint': Icons.kitchen.codePoint,
    'isCustom': false,
  },
  {
    'id': 'electronics',
    'name': 'Electronics',
    'iconCodePoint': Icons.devices.codePoint,
    'isCustom': false,
  },
  {
    'id': 'clothing',
    'name': 'Clothing',
    'iconCodePoint': Icons.checkroom.codePoint,
    'isCustom': false,
  },
  {
    'id': 'books',
    'name': 'Books',
    'iconCodePoint': Icons.menu_book.codePoint,
    'isCustom': false,
  },
  {
    'id': 'toys',
    'name': 'Toys',
    'iconCodePoint': Icons.toys.codePoint,
    'isCustom': false,
  },
  {
    'id': 'sports',
    'name': 'Sports',
    'iconCodePoint': Icons.sports_soccer.codePoint,
    'isCustom': false,
  },
  {
    'id': 'furniture',
    'name': 'Furniture',
    'iconCodePoint': Icons.weekend.codePoint,
    'isCustom': false,
  },
  {
    'id': 'decor',
    'name': 'Decor',
    'iconCodePoint': Icons.palette.codePoint,
    'isCustom': false,
  },
  {
    'id': 'cleaning',
    'name': 'Cleaning',
    'iconCodePoint': Icons.cleaning_services.codePoint,
    'isCustom': false,
  },
  {
    'id': 'other',
    'name': 'Other',
    'iconCodePoint': Icons.category.codePoint,
    'isCustom': false,
  },
];
