import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/screens/home/home_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/home_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_golden_test.mocks.dart';

@GenerateMocks([ItemRepository, CategoryRepository, LocationRepository])
void main() {
  late MockItemRepository mockItemRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockLocationRepository mockLocationRepository;
  late HomeViewModel homeViewModel;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockLocationRepository = MockLocationRepository();

    homeViewModel = HomeViewModel(
      itemRepository: mockItemRepository,
      categoryRepository: mockCategoryRepository,
      locationRepository: mockLocationRepository,
    );
  });

  Widget createHomeScreen() {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: homeViewModel,
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

  group('HomeScreen Golden Tests', () {
    testWidgets('golden - loading state', (tester) async {
      // Setup loading state with completer
      final completer = Completer<List<Category>>();
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) => completer.future);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Compare with golden file
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_loading.png'),
      );

      // Cleanup
      completer.complete(testCategories);
      await tester.pumpAndSettle();
    });

    testWidgets('golden - success state with data', (tester) async {
      // Setup success state
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify data is loaded
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);

      // Compare with golden file
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_success.png'),
      );
    });

    testWidgets('golden - error state', (tester) async {
      // Setup error state
      when(
        mockCategoryRepository.getCategories(),
      ).thenThrow(Exception('Failed to load'));
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error is displayed
      expect(find.text('Failed to load home data.'), findsOneWidget);

      // Compare with golden file
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_error.png'),
      );
    });

    testWidgets('golden - empty state', (tester) async {
      // Setup empty state
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('No items yet'), findsOneWidget);

      // Compare with golden file
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_empty.png'),
      );
    });

    testWidgets('golden - filter sheet open', (tester) async {
      // Setup success state
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

      await tester.pumpWidget(createHomeScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Open filter sheet
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify sheet is open
      expect(find.text('Filter & Sort'), findsOneWidget);

      // Compare with golden file
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_screen_filter_sheet.png'),
      );
    });
  });
}
