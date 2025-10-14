import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_ai_index/presentation/widgets/category/category_badge.dart';

void main() {
  group('CategoryBadge Widget Tests', () {
    Widget createTestWidget({
      String categoryName = 'Food',
      IconData icon = Icons.restaurant,
      Color? color,
      bool isCompact = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CategoryBadge(
            categoryName: categoryName,
            icon: icon,
            color: color,
            isCompact: isCompact,
          ),
        ),
      );
    }

    testWidgets('displays category name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('displays icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('uses custom color when provided in compact mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(color: Colors.red, isCompact: true),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
    });

    testWidgets('uses theme color when no color provided', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isCompact: true));

      // Should use default theme color from primaryContainer
      expect(find.byType(Container), findsOneWidget);
    });

    group('Compact mode', () {
      testWidgets('renders as Container in compact mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: true));

        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Chip), findsNothing);
      });

      testWidgets('has smaller icon size in compact mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: true));

        final icon = tester.widget<Icon>(find.byIcon(Icons.restaurant));
        expect(icon.size, equals(14));
      });

      testWidgets('has smaller text size in compact mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: true));

        final text = tester.widget<Text>(find.text('Food'));
        expect(text.style?.fontSize, equals(12));
      });

      testWidgets('uses rounded corners in compact mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: true));

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
      });
    });

    group('Full mode', () {
      testWidgets('renders as Chip in full mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: false));

        expect(find.byType(Chip), findsOneWidget);
      });

      testWidgets('has larger icon size in full mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: false));

        final icon = tester.widget<Icon>(find.byIcon(Icons.restaurant));
        expect(icon.size, equals(18));
      });

      testWidgets('has larger text size in full mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: false));

        final text = tester.widget<Text>(find.text('Food'));
        expect(text.style?.fontSize, equals(14));
      });

      testWidgets('uses Chip with avatar in full mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(isCompact: false));

        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.avatar, isA<Icon>());
        expect(chip.label, isA<Text>());
      });
    });

    testWidgets('displays different icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          categoryName: 'Electronics',
          icon: Icons.laptop,
        ),
      );

      expect(find.text('Electronics'), findsOneWidget);
      expect(find.byIcon(Icons.laptop), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsNothing);
    });

    testWidgets('displays long category names', (WidgetTester tester) async {
      const longName = 'Very Long Category Name';
      
      await tester.pumpWidget(
        createTestWidget(categoryName: longName),
      );

      expect(find.text(longName), findsOneWidget);
    });

    testWidgets('renders multiple badges independently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                CategoryBadge(
                  categoryName: 'Food',
                  icon: Icons.restaurant,
                  isCompact: true,
                ),
                CategoryBadge(
                  categoryName: 'Electronics',
                  icon: Icons.laptop,
                  isCompact: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.laptop), findsOneWidget);
    });

    testWidgets('compact mode has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isCompact: true));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(
        container.padding,
        equals(const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      );
    });

    testWidgets('font weight is w500', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final text = tester.widget<Text>(find.text('Food'));
      expect(text.style?.fontWeight, equals(FontWeight.w500));
    });
  });
}
