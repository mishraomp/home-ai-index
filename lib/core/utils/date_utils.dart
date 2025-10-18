/// Utility functions for date and expiration date calculations
class ExpirationDateUtils {
  /// Calculate days until expiration
  /// Returns null if expirationDate is null
  static int? daysUntilExpiration(DateTime? expirationDate) {
    if (expirationDate == null) {
      return null;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedExpiration = DateTime(
      expirationDate.year,
      expirationDate.month,
      expirationDate.day,
    );

    return normalizedExpiration.difference(normalizedToday).inDays;
  }

  /// Check if item is expired
  static bool isExpired(DateTime? expirationDate) {
    if (expirationDate == null) {
      return false;
    }

    final daysLeft = daysUntilExpiration(expirationDate);
    return daysLeft != null && daysLeft < 0;
  }

  /// Check if item is expiring soon (within specified days, default 7)
  static bool isExpiringSoon(DateTime? expirationDate, {int days = 7}) {
    if (expirationDate == null) {
      return false;
    }

    final daysLeft = daysUntilExpiration(expirationDate);
    if (daysLeft == null) {
      return false;
    }

    return daysLeft >= 0 && daysLeft <= days;
  }

  /// Get expiration status as a string
  static String getExpirationStatus(DateTime? expirationDate) {
    if (expirationDate == null) {
      return 'No expiration date';
    }

    if (isExpired(expirationDate)) {
      return 'Expired';
    }

    final daysLeft = daysUntilExpiration(expirationDate);
    if (daysLeft == null) {
      return 'Invalid date';
    }

    if (daysLeft == 0) {
      return 'Expires today';
    } else if (daysLeft == 1) {
      return 'Expires tomorrow';
    } else if (daysLeft < 7) {
      return 'Expires in $daysLeft days';
    } else {
      return 'Expires on ${_formatDate(expirationDate)}';
    }
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format date with month name (e.g., Oct 22, 2025)
  static String formatDateWithMonth(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get items expiring within specified days
  static List<DateTime> getExpiringWithinDays(List<DateTime> dates, int days) {
    return dates.where((date) => isExpiringSoon(date, days: days)).toList()
      ..sort();
  }
}
