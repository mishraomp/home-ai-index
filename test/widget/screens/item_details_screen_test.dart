import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/screens/item_details_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/item_details_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'item_details_screen_test.mocks.dart';

@GenerateMocks([ItemDetailsViewModel])
void main() {
  late MockItemDetailsViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockItemDetailsViewModel();
  });

  Widget createItemDetailsScreen({
    required List<Category> categories,
    required List<Location> locations,
  }) {
    return ChangeNotifierProvider<ItemDetailsViewModel>.value(
      value: mockViewModel,
      child: MaterialApp(
        home: ItemDetailsContent(categories: categories, locations: locations),
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      ),
    );
  }

  final testItem = Item(
    id: 'item1',
    name: 'Laptop',
    quantity: 1,
    categoryId: 'cat1',
    locationId: 'loc1',
    addedAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  const testCategory = Category(
    id: 'cat1',
    name: 'Electronics',
    iconCodePoint: 0xe0b1,
    isCustom: false,
  );
  final testLocations = [const Location(id: 'loc1', name: 'Garage')];
  final testCategories = [testCategory];

  group('ItemDetailsScreen Widget Tests', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(ItemDetailsScreen), findsOneWidget);
    });

    testWidgets('displays title when item exists', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading when isLoading is true', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(true);
      when(mockViewModel.item).thenReturn(null);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error exists', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(null);
      when(mockViewModel.errorMessage).thenReturn('Test error');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders form when item is loaded', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('has dropdown for category selection', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays location history title', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.text('Location History'), findsOneWidget);
    });

    testWidgets('shows empty history message when no history', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.text('No location history'), findsOneWidget);
    });

    testWidgets('has buttons for item actions', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.item).thenReturn(testItem);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.locationHistory).thenReturn([]);
      when(mockViewModel.getLocationName(any)).thenReturn('Garage');

      await tester.pumpWidget(
        createItemDetailsScreen(
          categories: testCategories,
          locations: testLocations,
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
