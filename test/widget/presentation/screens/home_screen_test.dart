import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/screens/home/home_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([
  ItemRepository,
  CategoryRepository,
  LocationRepository,
  LocationHistoryRepository,
])
void main() {
  late MockItemRepository mockItemRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockLocationRepository mockLocationRepository;
  late MockLocationHistoryRepository mockLocationHistoryRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockLocationRepository = MockLocationRepository();
    mockLocationHistoryRepository = MockLocationHistoryRepository();
  });

  Widget createHomeScreen() {
    return MultiProvider(
      providers: [
        Provider<ItemRepository>.value(value: mockItemRepository),
        Provider<CategoryRepository>.value(value: mockCategoryRepository),
        Provider<LocationRepository>.value(value: mockLocationRepository),
        Provider<LocationHistoryRepository>.value(
          value: mockLocationHistoryRepository,
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  final testCategory = Category(
    id: 'cat-1',
    name: 'Electronics',
    iconCodePoint: Icons.phone_android.codePoint,
    isCustom: false,
  );

  final testItems = [
    Item(
      id: 'item-1',
      name: 'Test Item 1',
      categoryId: 'cat-1',
      quantity: 1,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'item-2',
      name: 'Test Item 2',
      categoryId: 'cat-1',
      quantity: 2,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'item-3',
      name: 'Test Item 3',
      categoryId: 'cat-1',
      quantity: 1,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  void setupMocks() {
    when(mockItemRepository.getExpiringItems(any)).thenAnswer((_) async => []);
  }

  group('HomeScreen Selection Mode', () {
    testWidgets('should show normal AppBar initially', (tester) async {
      setupMocks();
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Normal AppBar with "Home AI Index" title
      expect(find.text('Home AI Index'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Selection mode elements should not be visible
      expect(find.text('selected'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should show normal AppBar initially', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Long press on first item
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      // Selection mode AppBar should appear
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Select All'), findsOneWidget);

      // FAB should be hidden
      expect(find.byType(FloatingActionButton), findsNothing);

      // Bulk actions bar should appear
      expect(find.text('Move To...'), findsOneWidget);

      // Checkboxes should be visible
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('should toggle item selection on tap in selection mode', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);

      // Tap second item to select it
      await tester.tap(find.text('Test Item 2'));
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);

      // Tap second item again to deselect it
      await tester.tap(find.text('Test Item 2'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('should select all items when Select All is tapped', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);

      // Tap Select All
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);

      // Button should change to "Deselect All"
      expect(find.text('Deselect All'), findsOneWidget);
      expect(find.text('Select All'), findsNothing);
    });

    testWidgets('should deselect all items when Deselect All is tapped', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      // Select all
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);

      // Tap Deselect All
      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();

      expect(find.text('0 selected'), findsOneWidget);

      // Button should change back to "Select All"
      expect(find.text('Select All'), findsOneWidget);
      expect(find.text('Deselect All'), findsNothing);
    });

    testWidgets('should exit selection mode when close button is tapped', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Should return to normal mode
      expect(find.text('Home AI Index'), findsOneWidget);
      expect(find.text('selected'), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Move To...'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
    });

    testWidgets('should exit selection mode when last item is deselected', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);

      // Deselect the only selected item
      await tester.tap(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      // Should automatically exit selection mode
      expect(find.text('Home AI Index'), findsOneWidget);
      expect(find.text('selected'), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show bulk actions bar in selection mode', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Initially no bulk actions bar
      expect(find.text('Move To...'), findsNothing);

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      // Bulk actions bar should appear
      expect(find.text('Move To...'), findsOneWidget);
      expect(find.byIcon(Icons.drive_file_move), findsOneWidget);
    });

    testWidgets('should update selection count when items are selected', (
      tester,
    ) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [testCategory]);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);

      // Select second item
      await tester.tap(find.text('Test Item 2'));
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);

      // Select third item
      await tester.tap(find.text('Test Item 3'));
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets(
      'should not enter selection mode on long press if already in selection mode',
      (tester) async {
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => [testCategory]);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        when(
          mockItemRepository.getExpiringItems(any),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createHomeScreen());
        await tester.pumpAndSettle();

        // Enter selection mode
        await tester.longPress(find.text('Test Item 1'));
        await tester.pumpAndSettle();

        expect(find.text('1 selected'), findsOneWidget);

        // Long press another item (should not do anything special)
        await tester.longPress(find.text('Test Item 2'));
        await tester.pumpAndSettle();

        // Should still be in selection mode with 1 item selected
        // (long press doesn't toggle selection, only tap does)
        expect(find.text('1 selected'), findsOneWidget);
      },
    );
  });
}
