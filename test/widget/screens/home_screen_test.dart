import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
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

  final testCategories = [
    Category(
      id: 'cat1',
      name: 'Electronics',
      iconCodePoint: Icons.devices.codePoint,
      isCustom: false,
    ),
    Category(
      id: 'cat2',
      name: 'Tools',
      iconCodePoint: Icons.build.codePoint,
      isCustom: false,
    ),
  ];

  final testLocations = [
    const Location(id: 'loc1', name: 'Garage'),
    const Location(id: 'loc2', name: 'Kitchen'),
  ];

  final testItems = [
    Item(
      id: 'item1',
      name: 'Laptop',
      quantity: 1,
      categoryId: 'cat1',
      locationId: 'loc1',
      addedAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    Item(
      id: 'item2',
      name: 'Hammer',
      quantity: 2,
      categoryId: 'cat2',
      locationId: 'loc2',
      addedAt: DateTime(2025, 1, 2),
      updatedAt: DateTime(2025, 1, 2),
    ),
  ];

  group('HomeScreen Widget Tests', () {
    testWidgets('displays app bar with title and actions', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(); // Trigger frame after setState

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('Home AI Index'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays loading indicator while loading data', (
      tester,
    ) async {
      // Use a completer to control when the future completes
      final completer = Completer<List<Item>>();
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) => completer.future);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump(); // Trigger frame after setState

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cleanup: complete the future
      completer.complete(testItems);
      await tester.pumpAndSettle();
    });

    testWidgets('displays items in list', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('Hammer'), findsOneWidget);
    });

    testWidgets('displays floating action button', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('taps FAB without crashing', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Just verify FAB exists and can be tapped
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Single pump, don't wait for settle (navigation)

      // If we got here, no crash occurred
    }, skip: true); // Skip: Navigation testing requires full app routing setup

    testWidgets('displays error message when loading fails', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenThrow(Exception('Failed to load'));
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Failed to load data: Exception: Failed to load'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull-to-refresh - drag on the ListView
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify repositories were called again
      verify(mockCategoryRepository.getCategories()).called(2);
      verify(mockItemRepository.getItems()).called(2);
      verify(mockItemRepository.getExpiringItems(any)).called(2);
    });

    testWidgets('displays empty state when no items exist', (tester) async {
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => []);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No items yet'), findsOneWidget);
      expect(
        find.text('Tap the + button to add your first item'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('displays expiring items section when items are expiring', (
      tester,
    ) async {
      final expiringItem = Item(
        id: 'item3',
        name: 'Milk',
        quantity: 1,
        categoryId: 'cat1',
        locationId: 'loc2',
        expirationDate: DateTime.now().add(const Duration(days: 3)),
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockItemRepository.getExpiringItems(any),
      ).thenAnswer((_) async => [expiringItem]);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Expiring Soon'), findsOneWidget);
      expect(find.byIcon(Icons.warning_outlined), findsOneWidget);
      expect(find.text('All Items'), findsOneWidget);
    });
  });
}
