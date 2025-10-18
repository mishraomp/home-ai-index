import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/widgets/location/location_tile.dart';

void main() {
  group('LocationTile Widget Tests', () {
    late Location testLocation;

    setUp(() {
      testLocation = const Location(id: '1', name: 'Garage');
    });

    Widget createTestWidget({
      required Location location,
      int? itemCount,
      bool hasChildren = false,
      VoidCallback? onTap,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LocationTile(
            location: location,
            itemCount: itemCount,
            hasChildren: hasChildren,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      );
    }

    testWidgets('displays location name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.text('Garage'), findsOneWidget);
    });

    testWidgets('displays location icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    });

    testWidgets('displays item count when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(location: testLocation, itemCount: 5),
      );

      expect(find.text('5 items'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('displays singular item text when count is 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(location: testLocation, itemCount: 1),
      );

      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('hides item count when null', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
      expect(find.textContaining('item'), findsNothing);
    });

    testWidgets(
      'displays "Has sublocations" indicator when hasChildren is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(location: testLocation, hasChildren: true),
        );

        expect(find.text('Has sublocations'), findsOneWidget);
        expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      },
    );

    testWidgets('hides sublocation indicator when hasChildren is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.text('Has sublocations'), findsNothing);
    });

    testWidgets('displays chevron icon when onTap is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(location: testLocation, onTap: () {}),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('hides chevron icon when onTap is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(location: testLocation, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays popup menu when onEdit or onDelete is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          location: testLocation,
          onEdit: () {},
          onDelete: () {},
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets(
      'hides popup menu when neither onEdit nor onDelete is provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(location: testLocation));

        expect(find.byType(PopupMenuButton<String>), findsNothing);
      },
    );

    testWidgets('popup menu contains Edit option when onEdit is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(location: testLocation, onEdit: () {}),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('popup menu contains Delete option when onDelete is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(location: testLocation, onDelete: () {}),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('calls onEdit when Edit menu item is tapped', (
      WidgetTester tester,
    ) async {
      bool edited = false;

      await tester.pumpWidget(
        createTestWidget(location: testLocation, onEdit: () => edited = true),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Edit option
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(edited, isTrue);
    });

    testWidgets('calls onDelete when Delete menu item is tapped', (
      WidgetTester tester,
    ) async {
      bool deleted = false;

      await tester.pumpWidget(
        createTestWidget(
          location: testLocation,
          onDelete: () => deleted = true,
        ),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('displays both item count and sublocation indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          location: testLocation,
          itemCount: 3,
          hasChildren: true,
        ),
      );

      expect(find.text('3 items'), findsOneWidget);
      expect(find.text('Has sublocations'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('is wrapped in a Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('uses Material Design 3 color scheme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(location: testLocation));

      // Verify the icon container uses primaryContainer color
      final BuildContext context = tester.element(find.byType(LocationTile));
      final colorScheme = Theme.of(context).colorScheme;

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LocationTile),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(colorScheme.primaryContainer));
    });
  });
}
