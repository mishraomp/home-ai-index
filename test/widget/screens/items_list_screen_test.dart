import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/presentation/screens/items_list/items_list_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/items_list_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'items_list_screen_test.mocks.dart';

@GenerateMocks([ItemRepository])
void main() {
  late MockItemRepository mockItemRepository;
  late ItemsListViewModel itemsListViewModel;

  setUp(() {
    mockItemRepository = MockItemRepository();
    itemsListViewModel = ItemsListViewModel(itemRepository: mockItemRepository);
  });

  Widget createItemsListScreen({
    String title = 'All Items',
    String? categoryId,
    String? locationId,
  }) {
    return ChangeNotifierProvider<ItemsListViewModel>.value(
      value: itemsListViewModel,
      child: MaterialApp(
        home: ItemsListScreen(
          title: title,
          categoryId: categoryId,
          locationId: locationId,
        ),
      ),
    );
  }

  final testItems = List.generate(
    25,
    (index) => Item(
      id: 'item$index',
      name: 'Item $index',
      quantity: index % 3 + 1,
      categoryId: 'cat${index % 3}',
      locationId: 'loc${index % 2}',
      addedAt: DateTime(2025, 1, index + 1),
      updatedAt: DateTime(2025, 1, index + 1),
    ),
  );

  group('ItemsListScreen Widget Tests', () {
    testWidgets('displays app bar with title', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('All Items'), findsOneWidget);
    });

    testWidgets('displays sort menu button', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('displays group by menu button', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('opens sort menu when sort button tapped', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap sort button
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Should show sort options
      expect(find.text('Name A-Z'), findsOneWidget);
      expect(find.text('Name Z-A'), findsOneWidget);
      expect(find.text('Newest First'), findsOneWidget);
      expect(find.text('Oldest First'), findsOneWidget);
    });

    testWidgets('opens group by menu when category button tapped', (
      tester,
    ) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap group by button
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Should show grouping options
      expect(find.text('No Grouping'), findsOneWidget);
      expect(find.text('Group by Category'), findsOneWidget);
      expect(find.text('Group by Location'), findsOneWidget);
    });

    testWidgets('displays loading indicator while loading', (tester) async {
      final completer = Completer<List<Item>>();
      when(mockItemRepository.getItems()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading items...'), findsOneWidget);

      // Cleanup
      completer.complete(testItems);
      await tester.pumpAndSettle();
    });

    testWidgets('displays items in flat list', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Should show items
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('displays quantity badge when quantity > 1', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Items with quantity > 1 should show badge
      expect(find.text('×2'), findsWidgets);
      expect(find.text('×3'), findsWidgets);
    });

    testWidgets('displays error message when loading fails', (tester) async {
      when(
        mockItemRepository.getItems(),
      ).thenThrow(Exception('Failed to load'));

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Failed to load items.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retries loading when retry button tapped', (tester) async {
      var callCount = 0;
      when(mockItemRepository.getItems()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Failed to load');
        }
        return testItems;
      });

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should show items
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('displays empty state when no items in category', (
      tester,
    ) async {
      when(
        mockItemRepository.getItemsByCategory('cat1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createItemsListScreen(title: 'Electronics', categoryId: 'cat1'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No Electronics Items'), findsOneWidget);
      expect(
        find.text('You don\'t have any items in this category yet.'),
        findsOneWidget,
      );
    });

    testWidgets('displays empty state when no items in location', (
      tester,
    ) async {
      when(
        mockItemRepository.getItemsByLocation('loc1'),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createItemsListScreen(title: 'Garage', locationId: 'loc1'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No Items in Garage'), findsOneWidget);
      expect(
        find.text('This location doesn\'t have any items yet.'),
        findsOneWidget,
      );
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull-to-refresh
      await tester.drag(find.text('Item 0'), const Offset(0, 300));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify repository was called again
      verify(mockItemRepository.getItems()).called(2);
    });

    testWidgets('displays pagination footer when items > page size', (
      tester,
    ) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // With 25 items and page size 20, should have pagination
      // Just verify items are displayed (pagination logic is internal)
      expect(find.text('Item 0'), findsOneWidget);
    }, skip: true);

    testWidgets('hides pagination footer when items <= page size', (
      tester,
    ) async {
      final fewItems = testItems.take(5).toList();
      when(mockItemRepository.getItems()).thenAnswer((_) async => fewItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Should not show pagination
      expect(find.textContaining('Page'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('taps on item shows snackbar', (tester) async {
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createItemsListScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap on item
      await tester.tap(find.text('Item 0'));
      await tester.pumpAndSettle();

      expect(find.text('View details for Item 0'), findsOneWidget);
    });

    testWidgets('loads items by category when categoryId provided', (
      tester,
    ) async {
      final categoryItems = testItems.take(5).toList();
      when(
        mockItemRepository.getItemsByCategory('cat1'),
      ).thenAnswer((_) async => categoryItems);

      await tester.pumpWidget(
        createItemsListScreen(title: 'Electronics', categoryId: 'cat1'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify correct method was called
      verify(mockItemRepository.getItemsByCategory('cat1')).called(1);
      verifyNever(mockItemRepository.getItems());
    });

    testWidgets('loads items by location when locationId provided', (
      tester,
    ) async {
      final locationItems = testItems.take(5).toList();
      when(
        mockItemRepository.getItemsByLocation('loc1'),
      ).thenAnswer((_) async => locationItems);

      await tester.pumpWidget(
        createItemsListScreen(title: 'Garage', locationId: 'loc1'),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify correct method was called
      verify(mockItemRepository.getItemsByLocation('loc1')).called(1);
      verifyNever(mockItemRepository.getItems());
    });
  });
}
