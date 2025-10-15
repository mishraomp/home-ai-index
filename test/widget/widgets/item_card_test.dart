import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/presentation/widgets/item/item_card.dart';
import 'package:home_ai_index/presentation/widgets/item/item_thumbnail.dart';
import 'package:home_ai_index/presentation/widgets/category/category_badge.dart';

void main() {
  group('ItemCard Widget Tests', () {
    late Item testItem;

    setUp(() {
      testItem = Item(
        id: '1',
        name: 'Test Item',
        categoryId: 'cat1',
        locationId: 'loc1',
        quantity: 1,
        imagePath: '/test/path/image.jpg',
        notes: 'Test notes',
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Item item,
      String categoryName = 'Food',
      IconData categoryIcon = Icons.restaurant,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('displays item name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('displays item thumbnail', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.byType(ItemThumbnail), findsOneWidget);
    });

    testWidgets('displays category badge', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.byType(CategoryBadge), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('displays notes when available', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('hides notes when null', (WidgetTester tester) async {
      final itemWithoutNotes = Item(
        id: testItem.id,
        name: testItem.name,
        categoryId: testItem.categoryId,
        locationId: testItem.locationId,
        quantity: testItem.quantity,
        imagePath: testItem.imagePath,
        addedAt: testItem.addedAt,
        updatedAt: testItem.updatedAt,
      );

      await tester.pumpWidget(createTestWidget(item: itemWithoutNotes));

      expect(find.text('Test notes'), findsNothing);
    });

    testWidgets('displays quantity badge when quantity > 1', (
      WidgetTester tester,
    ) async {
      final itemWithQuantity = testItem.copyWith(quantity: 5);

      await tester.pumpWidget(createTestWidget(item: itemWithQuantity));

      expect(find.text('x5'), findsOneWidget);
    });

    testWidgets('hides quantity badge when quantity is 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.text('x1'), findsNothing);
    });

    testWidgets('displays chevron icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays as Card widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('has InkWell for tap interaction', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(item: testItem, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(ItemCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('works without onTap callback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(item: testItem));

      // Should render without error
      expect(find.byType(ItemCard), findsOneWidget);

      // Tapping should not throw an error
      await tester.tap(find.byType(ItemCard));
      await tester.pumpAndSettle();
    });

    testWidgets('truncates long item name', (WidgetTester tester) async {
      final longNameItem = testItem.copyWith(
        name: 'This is a very long item name that should be truncated',
      );

      await tester.pumpWidget(createTestWidget(item: longNameItem));

      // The text widget should use ellipsis
      final textWidget = tester.widget<Text>(find.text(longNameItem.name));
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('truncates long notes', (WidgetTester tester) async {
      final longNotesItem = testItem.copyWith(
        notes:
            'These are very long notes that should be truncated in the display',
      );

      await tester.pumpWidget(createTestWidget(item: longNotesItem));

      // Find the notes text widget
      final notesText = find.text(longNotesItem.notes!);
      expect(notesText, findsOneWidget);

      final textWidget = tester.widget<Text>(notesText);
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('uses correct category icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(item: testItem, categoryIcon: Icons.laptop),
      );

      expect(find.byType(CategoryBadge), findsOneWidget);
    });

    testWidgets('uses correct category name', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(item: testItem, categoryName: 'Electronics'),
      );

      expect(find.text('Electronics'), findsOneWidget);
    });
  });
}
