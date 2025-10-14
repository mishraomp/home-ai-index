/// Input validation utilities for the Home AI Index app
///
/// Provides validation functions for item names, location hierarchies,
/// quantities, dates, and other user inputs per data-model.md rules.
library;

import 'package:home_ai_index/core/constants/app_constants.dart';

/// Validates an item name
///
/// Rules:
/// - Required (non-empty after trimming)
/// - Must be between 1 and 100 characters
///
/// Returns error message if invalid, null if valid
String? validateItemName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Item name is required';
  }

  final trimmed = value.trim();
  if (trimmed.length > 100) {
    return 'Item name must be 100 characters or less';
  }

  return null;
}

/// Validates a category name
///
/// Rules:
/// - Required (non-empty after trimming)
/// - Must be between 1 and 50 characters
///
/// Returns error message if invalid, null if valid
String? validateCategoryName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Category name is required';
  }

  final trimmed = value.trim();
  if (trimmed.length > 50) {
    return 'Category name must be 50 characters or less';
  }

  return null;
}

/// Validates a location name
///
/// Rules:
/// - Required (non-empty after trimming)
/// - Must be between 1 and 100 characters
///
/// Returns error message if invalid, null if valid
String? validateLocationName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Location name is required';
  }

  final trimmed = value.trim();
  if (trimmed.length > 100) {
    return 'Location name must be 100 characters or less';
  }

  return null;
}

/// Validates location hierarchy depth
///
/// Rules:
/// - Must not exceed maxLocationHierarchyDepth (5 levels)
///
/// Returns error message if invalid, null if valid
String? validateLocationHierarchyDepth(int depth) {
  if (depth > maxLocationHierarchyDepth) {
    return 'Location hierarchy cannot exceed $maxLocationHierarchyDepth levels';
  }

  return null;
}

/// Validates item quantity
///
/// Rules:
/// - Must be non-negative (>= 0)
/// - Must be a valid integer
///
/// Returns error message if invalid, null if valid
String? validateQuantity(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Quantity is required';
  }

  final quantity = int.tryParse(value.trim());
  if (quantity == null) {
    return 'Quantity must be a valid number';
  }

  if (quantity < 0) {
    return 'Quantity cannot be negative';
  }

  return null;
}

/// Validates an expiration date
///
/// Rules:
/// - Optional (null is valid)
/// - If provided, must be a valid DateTime
/// - Can be in the past (for already expired items)
///
/// Returns error message if invalid, null if valid
String? validateExpirationDate(DateTime? date) {
  // Expiration date is optional, null is valid
  return null;
}

/// Validates notes/description text
///
/// Rules:
/// - Optional
/// - If provided, must be 500 characters or less
///
/// Returns error message if invalid, null if valid
String? validateNotes(String? value) {
  if (value != null && value.length > 500) {
    return 'Notes must be 500 characters or less';
  }

  return null;
}

/// Validates an image file path
///
/// Rules:
/// - Optional (null is valid for items without images)
/// - If provided, must not be empty
///
/// Returns error message if invalid, null if valid
String? validateImagePath(String? value) {
  if (value != null && value.trim().isEmpty) {
    return 'Image path cannot be empty';
  }

  return null;
}

/// Validates ML confidence score
///
/// Rules:
/// - Must be between 0.0 and 1.0 inclusive
///
/// Returns error message if invalid, null if valid
String? validateConfidenceScore(double? score) {
  if (score == null) {
    return 'Confidence score is required';
  }

  if (score < 0.0 || score > 1.0) {
    return 'Confidence score must be between 0.0 and 1.0';
  }

  return null;
}

/// Validates a search query
///
/// Rules:
/// - Required (non-empty after trimming)
/// - Must be at least 1 character
///
/// Returns error message if invalid, null if valid
String? validateSearchQuery(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Search query cannot be empty';
  }

  return null;
}
