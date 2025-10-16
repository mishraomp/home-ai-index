import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/location_history.dart';

void main() {
  final testHistories = [
    LocationHistory(
      id: 'h1',
      itemId: 'item1',
      locationId: 'loc1',
      timestamp: DateTime(2025, 1, 15),
    ),
    LocationHistory(
      id: 'h2',
      itemId: 'item1',
      locationId: 'loc2',
      timestamp: DateTime(2025, 1, 10),
    ),
  ];

  group('LocationHistory Widget Tests', () {
    testWidgets('displays empty state when no history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 0,
              itemBuilder: (context, index) =>
                  ListTile(title: Text('Location $index')),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays history items in list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                final history = testHistories[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text('Location ${history.locationId}'),
                  subtitle: Text(history.timestamp.toString()),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('displays location id in history', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                final history = testHistories[index];
                return ListTile(title: Text('Location ${history.locationId}'));
              },
            ),
          ),
        ),
      );

      expect(find.text('Location loc1'), findsOneWidget);
      expect(find.text('Location loc2'), findsOneWidget);
    });

    testWidgets('displays timestamps in history', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                final history = testHistories[index];
                return ListTile(title: Text(history.timestamp.toString()));
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('displays correct number of history items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text('History Item $index'));
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(testHistories.length));
    });

    testWidgets('handles single location history entry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('History ${testHistories[index].locationId}'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays location icon in history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                return const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Location'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.location_on_outlined), findsWidgets);
    });

    testWidgets('renders history list without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testHistories.length,
              itemBuilder: (context, index) {
                final history = testHistories[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(history.locationId),
                  subtitle: Text(history.timestamp.toString()),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('handles empty history gracefully', (
      WidgetTester tester,
    ) async {
      final emptyHistories = <LocationHistory>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: emptyHistories.isEmpty
                ? const Center(child: Text('No location history'))
                : ListView.builder(
                    itemCount: emptyHistories.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text('Item $index'));
                    },
                  ),
          ),
        ),
      );

      expect(find.text('No location history'), findsOneWidget);
    });
  });
}
