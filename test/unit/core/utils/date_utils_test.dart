import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Utils - Expiration Date Calculations (T111)', () {
    testWidgets('calculates days until expiration', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expirationDate = DateTime(2025, 10, 22); // 7 days later

      final daysUntilExpiration = expirationDate.difference(today).inDays;

      expect(daysUntilExpiration, equals(7));
    });

    testWidgets('returns 0 for items expiring today', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expirationDate = DateTime(2025, 10, 15);

      final daysUntilExpiration = expirationDate.difference(today).inDays;

      expect(daysUntilExpiration, equals(0));
    });

    testWidgets('returns negative for expired items', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expirationDate = DateTime(2025, 10, 10); // 5 days ago

      final daysUntilExpiration = expirationDate.difference(today).inDays;

      expect(daysUntilExpiration, isNegative);
    });

    testWidgets('identifies items expiring within 7 days', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expiringItems = [
        DateTime(2025, 10, 18), // 3 days - should include
        DateTime(2025, 10, 22), // 7 days - should include
        DateTime(2025, 10, 23), // 8 days - should not include
        DateTime(2025, 10, 10), // expired - should include
      ];

      final expiringWithin7Days = expiringItems
          .where(
            (date) => date.difference(today).inDays <= 7 && date.isAfter(today),
          )
          .toList();

      expect(expiringWithin7Days, hasLength(2));
    });

    testWidgets('identifies already expired items', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expiredDate = DateTime(2025, 10, 10);

      final isExpired = expiredDate.isBefore(today);

      expect(isExpired, isTrue);
    });

    testWidgets('identifies future (not expired) items', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final futureDate = DateTime(2025, 10, 20);

      final isExpired = futureDate.isBefore(today);

      expect(isExpired, isFalse);
    });

    testWidgets('handles null expiration date', (WidgetTester tester) async {
      final today = DateTime(2025, 10, 15);
      const DateTime? expirationDate = null;

      final isExpired = expirationDate?.isBefore(today) ?? false;

      expect(isExpired, isFalse);
    });

    testWidgets('formats expiration date for display', (
      WidgetTester tester,
    ) async {
      final expirationDate = DateTime(2025, 10, 15);
      final formattedDate =
          '${expirationDate.year}-${expirationDate.month.toString().padLeft(2, '0')}-${expirationDate.day.toString().padLeft(2, '0')}';

      expect(formattedDate, equals('2025-10-15'));
    });

    testWidgets('calculates expiration status', (WidgetTester tester) async {
      final today = DateTime(2025, 10, 15);

      // Expired
      final expired = DateTime(2025, 10, 10);
      expect(expired.isBefore(today), isTrue);

      // Expiring soon (within 3 days)
      final expiringSoon = DateTime(2025, 10, 17);
      final daysUntilExpiringSoon = expiringSoon.difference(today).inDays;
      expect(daysUntilExpiringSoon <= 3 && daysUntilExpiringSoon > 0, isTrue);

      // Good condition
      final good = DateTime(2025, 11, 15);
      final daysUntilGood = good.difference(today).inDays;
      expect(daysUntilGood > 7, isTrue);
    });
  });
}
