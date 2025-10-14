/// Date formatting utilities for the Home AI Index app
///
/// Provides consistent date/time formatting across the application
/// for timestamps, expiration dates, and location history.
library;

import 'package:intl/intl.dart';

import 'package:home_ai_index/core/constants/app_constants.dart';

/// Formats a DateTime as a relative time string (e.g., "2 hours ago", "3 days ago")
///
/// Used for displaying when items were added or moved.
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
}

/// Formats a DateTime as a short date string (e.g., "Jan 15, 2024")
///
/// Used for displaying added dates and expiration dates.
String formatShortDate(DateTime dateTime) {
  return DateFormat('MMM d, y').format(dateTime);
}

/// Formats a DateTime as a long date string (e.g., "January 15, 2024")
///
/// Used for detailed views and reports.
String formatLongDate(DateTime dateTime) {
  return DateFormat('MMMM d, y').format(dateTime);
}

/// Formats a DateTime with time (e.g., "Jan 15, 2024 at 2:30 PM")
///
/// Used for location history and detailed timestamps.
String formatDateWithTime(DateTime dateTime) {
  return DateFormat('MMM d, y \'at\' h:mm a').format(dateTime);
}

/// Formats an expiration date with contextual information
///
/// Returns strings like:
/// - "Expires in 3 days" (future, within threshold)
/// - "Expires Jan 15, 2024" (future, beyond threshold)
/// - "Expired 2 days ago" (past, within 7 days)
/// - "Expired Jan 15, 2024" (past, beyond 7 days)
String formatExpirationDate(DateTime expirationDate) {
  final now = DateTime.now();
  final difference = expirationDate.difference(now);

  if (difference.isNegative) {
    // Already expired
    final daysSinceExpired = difference.inDays.abs();
    if (daysSinceExpired < 7) {
      return 'Expired ${daysSinceExpired == 0 ? 'today' : '$daysSinceExpired ${daysSinceExpired == 1 ? 'day' : 'days'} ago'}';
    } else {
      return 'Expired ${formatShortDate(expirationDate)}';
    }
  } else {
    // Not yet expired
    final daysUntilExpired = difference.inDays;
    if (daysUntilExpired <= expiringItemsThresholdDays) {
      return 'Expires in ${daysUntilExpired == 0 ? 'today' : '$daysUntilExpired ${daysUntilExpired == 1 ? 'day' : 'days'}'}';
    } else {
      return 'Expires ${formatShortDate(expirationDate)}';
    }
  }
}

/// Checks if an item is expiring soon (within threshold)
///
/// Used for filtering and highlighting items that need attention.
bool isExpiringSoon(DateTime expirationDate) {
  final now = DateTime.now();
  final difference = expirationDate.difference(now);

  return difference.inDays <= expiringItemsThresholdDays &&
      difference.inDays >= 0;
}

/// Checks if an item is expired
///
/// Used for filtering and highlighting expired items.
bool isExpired(DateTime expirationDate) {
  return expirationDate.isBefore(DateTime.now());
}

/// Formats a timestamp for database storage (ISO 8601)
///
/// Used for consistent timestamp storage in SQLite.
String formatTimestampForDatabase(DateTime dateTime) {
  return dateTime.toIso8601String();
}

/// Parses a timestamp from database storage (ISO 8601)
///
/// Used for reading timestamps from SQLite.
DateTime parseTimestampFromDatabase(String timestamp) {
  return DateTime.parse(timestamp);
}
