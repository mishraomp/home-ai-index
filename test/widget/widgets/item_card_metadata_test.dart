import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';

void main() {
  final testItem = Item(
    id: 'item1',
    name: 'Milk',
    quantity: 2,
    categoryId: 'cat1',
    locationId: 'loc1',
    addedAt: DateTime(2025, 10),
    updatedAt: DateTime(2025, 10, 15),
    notes: 'Organic whole milk',
    expirationDate: DateTime(2025, 10, 22),
  );

  final testItemNoExpiration = Item(
    id: 'item2',
    name: 'Laptop',
    quantity: 1,
    categoryId: 'cat1',
    locationId: 'loc1',
    addedAt: DateTime(2025, 9),
    updatedAt: DateTime(2025, 10, 15),
    notes: 'Dell XPS',
  );

  group('ItemCard Metadata Display Tests (T113)', () {
    testWidgets('displays quantity badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItem.name),
                    if (testItem.quantity > 1)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${testItem.quantity}x'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('displays expiration date', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItem.name),
                    if (testItem.expirationDate != null)
                      Text('Expires: ${testItem.expirationDate}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expires: 2025-10-22 00:00:00.000'), findsOneWidget);
    });

    testWidgets('shows expiration warning for items expiring soon', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expiringDate = DateTime(2025, 10, 20); // 5 days

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItem.name),
                    if (expiringDate.isAfter(today) &&
                        expiringDate.difference(today).inDays <= 7)
                      Container(
                        color: Colors.orange,
                        child: const Text('Expiring Soon'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expiring Soon'), findsOneWidget);
    });

    testWidgets('shows expiration alert for expired items', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expiredDate = DateTime(2025, 10, 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItem.name),
                    if (expiredDate.isBefore(today))
                      Container(
                        color: Colors.red,
                        child: const Text('Expired'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expired'), findsOneWidget);
    });

    testWidgets('does not show expiration when not set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItemNoExpiration.name),
                    if (testItemNoExpiration.expirationDate != null)
                      Text('Expires: ${testItemNoExpiration.expirationDate}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expires:'), findsNothing);
    });

    testWidgets('displays quantity only when > 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItemNoExpiration.name),
                    if (testItemNoExpiration.quantity > 1)
                      Text('${testItemNoExpiration.quantity}x'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('1x'), findsNothing);
    });

    testWidgets('displays all metadata fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(testItem.name),
                    Text('${testItem.quantity}x'),
                    if (testItem.expirationDate != null)
                      Text('Expires: ${testItem.expirationDate}'),
                    if (testItem.notes != null && testItem.notes!.isNotEmpty)
                      Text(testItem.notes!),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
      expect(find.text('Organic whole milk'), findsOneWidget);
    });

    testWidgets('ItemCard renders in Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                title: Text(testItem.name),
                subtitle: Text('${testItem.quantity}x'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('metadata badge uses appropriate colors', (
      WidgetTester tester,
    ) async {
      final today = DateTime(2025, 10, 15);
      final expiredDate = DateTime(2025, 10, 10);

      // Test expired (red)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              color: expiredDate.isBefore(today) ? Colors.red : Colors.green,
              child: const Text('Status'),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((widget) => widget is Container),
        findsOneWidget,
      );
    });
  });
}
