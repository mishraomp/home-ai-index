/// Maps Google Cloud Vision API labels to application categories
///
/// This utility helps categorize detected items from Cloud Vision
/// into the app's predefined categories like groceries, electronics, etc.
class LabelMapper {
  /// Map of common labels to categories
  static const Map<String, String> _labelToCategoryMap = {
    // Groceries & Food
    'food': 'groceries',
    'fruit': 'groceries',
    'vegetable': 'groceries',
    'apple': 'groceries',
    'banana': 'groceries',
    'orange': 'groceries',
    'tomato': 'groceries',
    'potato': 'groceries',
    'bread': 'groceries',
    'milk': 'groceries',
    'cheese': 'groceries',
    'meat': 'groceries',
    'fish': 'groceries',
    'beverage': 'groceries',
    'drink': 'groceries',
    'snack': 'groceries',
    'ingredient': 'groceries',
    'produce': 'groceries',

    // Electronics
    'electronics': 'electronics',
    'electronic': 'electronics',
    'computer': 'electronics',
    'laptop': 'electronics',
    'phone': 'electronics',
    'smartphone': 'electronics',
    'tablet': 'electronics',
    'camera': 'electronics',
    'television': 'electronics',
    'monitor': 'electronics',
    'keyboard': 'electronics',
    'mouse': 'electronics',
    'headphones': 'electronics',
    'speaker': 'electronics',
    'charger': 'electronics',
    'cable': 'electronics',
    'gadget': 'electronics',

    // Furniture
    'furniture': 'furniture',
    'chair': 'furniture',
    'table': 'furniture',
    'desk': 'furniture',
    'bed': 'furniture',
    'sofa': 'furniture',
    'couch': 'furniture',
    'shelf': 'furniture',
    'bookshelf': 'furniture',
    'cabinet': 'furniture',
    'drawer': 'furniture',

    // Clothing
    'clothing': 'clothing',
    'apparel': 'clothing',
    'shirt': 'clothing',
    'pants': 'clothing',
    'dress': 'clothing',
    'shoes': 'clothing',
    'jacket': 'clothing',
    'coat': 'clothing',
    'hat': 'clothing',
    'socks': 'clothing',
    'underwear': 'clothing',
    'jeans': 'clothing',
    'sweater': 'clothing',

    // Books & Media
    'book': 'books',
    'novel': 'books',
    'magazine': 'books',
    'newspaper': 'books',
    'publication': 'books',
    'textbook': 'books',
    'dvd': 'media',
    'cd': 'media',
    'blu-ray': 'media',
    'vinyl': 'media',
    'game': 'media',
    'video game': 'media',

    // Tools & Hardware
    'tool': 'tools',
    'hammer': 'tools',
    'screwdriver': 'tools',
    'wrench': 'tools',
    'drill': 'tools',
    'saw': 'tools',
    'hardware': 'tools',

    // Kitchen & Appliances
    'kitchenware': 'kitchen',
    'fork': 'kitchen',
    'appliance': 'appliances',
    'microwave': 'appliances',
    'refrigerator': 'appliances',
    'dishwasher': 'appliances',
    'washing machine': 'appliances',
    'oven': 'appliances',
    'blender': 'appliances',
    'toaster': 'appliances',
    'pot': 'kitchen',
    'pan': 'kitchen',
    'plate': 'kitchen',
    'bowl': 'kitchen',
    'cup': 'kitchen',
    'glass': 'kitchen',
    'utensil': 'kitchen',

    // Toys & Games
    'toy': 'toys',
    'lego': 'toys',
    'doll': 'toys',
    'action figure': 'toys',
    'board game': 'toys',
    'puzzle': 'toys',

    // Sports & Outdoor
    'sports equipment': 'sports',
    'basketball': 'sports',
    'soccer ball': 'sports',
    'tennis racket': 'sports',
    'ball': 'sports',
    'bicycle': 'sports',
    'bike': 'sports',
    'camping': 'outdoor',
    'camping chair': 'outdoor',
    'tent': 'outdoor',
    'sleeping bag': 'outdoor',
    'backpack': 'outdoor',

    // Personal Care
    'cosmetics': 'personal care',
    'shampoo': 'personal care',
    'deodorant': 'personal care',
    'soap': 'personal care',
    'toothbrush': 'personal care',
    'towel': 'personal care',

    // Office Supplies
    'stationery': 'office',
    'pen': 'office',
    'pencil': 'office',
    'notebook': 'office',
    'paper': 'office',
    'stapler': 'office',
  };

  /// Map a Cloud Vision label to an application category
  ///
  /// Returns the category if found, null if no mapping exists.
  /// Label matching is case-insensitive and uses partial matching.
  String? mapLabelToCategory(String label) {
    final normalizedLabel = label.toLowerCase().trim();

    // Empty label returns null
    if (normalizedLabel.isEmpty) {
      return null;
    }

    // Direct match
    if (_labelToCategoryMap.containsKey(normalizedLabel)) {
      return _labelToCategoryMap[normalizedLabel];
    }

    // Partial match - check if label contains any mapped keyword
    for (final entry in _labelToCategoryMap.entries) {
      if (normalizedLabel.contains(entry.key) ||
          entry.key.contains(normalizedLabel)) {
        return entry.value;
      }
    }

    // No match found
    return null;
  }

  /// Get all supported categories
  static Set<String> get supportedCategories {
    return {..._labelToCategoryMap.values, 'other'};
  }

  /// Check if a label can be mapped to a category
  bool canMap(String label) {
    return mapLabelToCategory(label) != null;
  }

  /// Get category with fallback to 'other'
  String mapLabelToCategoryWithFallback(String label) {
    return mapLabelToCategory(label) ?? 'other';
  }
}
