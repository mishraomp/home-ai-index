import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/presentation/screens/item_details_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/item_details_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'item_details_screen_test.mocks.dart';

@GenerateMocks([ItemDetailsViewModel])
void main() {
  late MockItemDetailsViewModel mockViewModel;
  late Item testItem;
  late List<LocationHistory> testHistory;
  late List<Category> testCategories;
  late List<Location> testLocations;

  setUp(() {
    mockViewModel = MockItemDetailsViewModel();

    testItem = Item(
      id: 'item-1',
      name: 'Test Item',
      notes: 'Test notes',
      quantity: 5,
      categoryId: 'cat-1',
      locationId: 'loc-1',
      addedAt: DateTime(2025, 1),
      updatedAt: DateTime(2025, 1, 2),
    );

    testHistory = [
      LocationHistory(
        id: 'hist-1',
        itemId: 'item-1',
        locationId: 'loc-1',
        timestamp: DateTime(2025, 1, 2),
      ),
      LocationHistory(
        id: 'hist-2',
        itemId: 'item-1',
        locationId: 'loc-2',
        timestamp: DateTime(2025, 1),
      ),
    ];

    testCategories = [
      const Category(
        id: 'cat-1',
        name: 'Kitchen',
        iconCodePoint: 0xe3ab,
        isCustom: false,
      ),
      const Category(
        id: 'cat-2',
        name: 'Bathroom',
        iconCodePoint: 0xe3ac,
        isCustom: false,
      ),
    ];

    testLocations = [
      const Location(id: 'loc-1', name: 'Kitchen Cabinet'),
      const Location(id: 'loc-2', name: 'Pantry'),
    ];

    // Default mock setup
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.errorMessage).thenReturn(null);
    when(mockViewModel.item).thenReturn(testItem);
    when(mockViewModel.locationHistory).thenReturn(testHistory);
    when(mockViewModel.getLocationName(any)).thenReturn('Kitchen Cabinet');
    when(mockViewModel.loadItem()).thenAnswer((_) async => Future.value());
    when(
      mockViewModel.loadLocationHistory(),
    ).thenAnswer((_) async => Future.value());
  });

  Widget createTestWidget({
    required ItemDetailsViewModel viewModel,
    required List<Category> categories,
    required List<Location> locations,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<ItemDetailsViewModel>.value(
        value: viewModel,
        child: ItemDetailsScreen(categories: categories, locations: locations),
      ),
    );
  }

  group('ItemDetailsScreen', () {
    group('Initial Loading', () {
      testWidgets('should display loading indicator when loading', (
        tester,
      ) async {
        when(mockViewModel.isLoading).thenReturn(true);
        when(mockViewModel.item).thenReturn(null);

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Test Item'), findsNothing);
      });

      testWidgets('should call loadItem on init', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        verify(mockViewModel.loadItem()).called(1);
        verify(mockViewModel.loadLocationHistory()).called(1);
      });

      testWidgets('should display error message when error occurs', (
        tester,
      ) async {
        when(mockViewModel.errorMessage).thenReturn('Failed to load item');
        when(mockViewModel.item).thenReturn(null);

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Failed to load item'), findsOneWidget);
        expect(find.text('Test Item'), findsNothing);
      });
    });

    group('Item Display', () {
      testWidgets('should display item name in app bar', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.widgetWithText(AppBar, 'Test Item'), findsOneWidget);
      });

      testWidgets('should display all item fields', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Test Item'), findsAtLeastNWidgets(1));
        expect(find.text('5'), findsOneWidget); // Quantity
        expect(find.text('Test notes'), findsOneWidget);
      });

      testWidgets('should display category name', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Kitchen'), findsOneWidget);
      });

      testWidgets('should display location name', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Kitchen Cabinet'), findsAtLeastNWidgets(1));
      });

      testWidgets('should display Unlocated when no location', (tester) async {
        when(mockViewModel.item).thenReturn(
          testItem.copyWith(updateLocationId: true),
        );
        when(mockViewModel.getLocationName(null)).thenReturn('Unlocated');

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Unlocated'), findsOneWidget);
      });
    });

    group('Edit Name', () {
      testWidgets('should allow editing item name', (tester) async {
        when(
          mockViewModel.updateItemName(any),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        // Find the name text field
        final nameField = find.widgetWithText(TextFormField, 'Test Item');
        expect(nameField, findsOneWidget);

        // Enter new name
        await tester.enterText(nameField, 'Updated Item');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verify(mockViewModel.updateItemName('Updated Item')).called(1);
      });

      testWidgets('should show validation error for empty name', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        final nameField = find.widgetWithText(TextFormField, 'Test Item');
        await tester.enterText(nameField, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verifyNever(mockViewModel.updateItemName(any));
      });
    });

    group('Edit Quantity', () {
      testWidgets('should allow editing quantity', (tester) async {
        when(
          mockViewModel.updateItemQuantity(any),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        final quantityField = find.widgetWithText(TextFormField, '5');
        expect(quantityField, findsOneWidget);

        await tester.enterText(quantityField, '10');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verify(mockViewModel.updateItemQuantity(10)).called(1);
      });
    });

    group('Edit Notes', () {
      testWidgets('should allow editing notes', (tester) async {
        when(
          mockViewModel.updateItemNotes(any),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        final notesField = find.widgetWithText(TextFormField, 'Test notes');
        expect(notesField, findsOneWidget);

        await tester.enterText(notesField, 'Updated notes');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        verify(mockViewModel.updateItemNotes('Updated notes')).called(1);
      });
    });

    group('Change Category', () {
      testWidgets('should display category dropdown', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(
          find.byType(DropdownButtonFormField<String>),
          findsAtLeastNWidgets(1),
        );
      });

      testWidgets('should update category when changed', (tester) async {
        when(
          mockViewModel.updateItemCategory(any),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        // Find and tap the category dropdown
        final categoryDropdown = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Kitchen',
        );
        await tester.tap(categoryDropdown);
        await tester.pumpAndSettle();

        // Select Bathroom
        await tester.tap(find.text('Bathroom').last);
        await tester.pumpAndSettle();

        verify(mockViewModel.updateItemCategory('cat-2')).called(1);
      });
    });

    group('Change Location', () {
      testWidgets('should display change location button', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(
          find.widgetWithText(ElevatedButton, 'Change Location'),
          findsOneWidget,
        );
      });

      testWidgets('should open LocationPicker dialog when button tapped', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Change Location'),
        );
        await tester.pumpAndSettle();

        // Dialog should be shown
        expect(find.text('Select Location'), findsOneWidget);
      });

      testWidgets('should update location when selected', (tester) async {
        when(
          mockViewModel.updateItemLocation(any),
        ).thenAnswer((_) async => Future.value());

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        // Open location picker
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Change Location'),
        );
        await tester.pumpAndSettle();

        // Select a location
        await tester.tap(find.text('Pantry'));
        await tester.pumpAndSettle();

        verify(mockViewModel.updateItemLocation('loc-2')).called(1);
      });
    });

    group('Location History', () {
      testWidgets('should display location history section', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Location History'), findsOneWidget);
      });

      testWidgets('should display history entries', (tester) async {
        when(
          mockViewModel.getLocationName('loc-1'),
        ).thenReturn('Kitchen Cabinet');
        when(mockViewModel.getLocationName('loc-2')).thenReturn('Pantry');

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('Kitchen Cabinet'), findsAtLeastNWidgets(1));
        expect(find.text('Pantry'), findsOneWidget);
      });

      testWidgets('should display empty state when no history', (tester) async {
        when(mockViewModel.locationHistory).thenReturn([]);

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.text('No location history'), findsOneWidget);
      });
    });

    group('Delete Item', () {
      testWidgets('should display delete button', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        expect(find.widgetWithIcon(IconButton, Icons.delete), findsOneWidget);
      });

      testWidgets('should show confirmation dialog when delete tapped', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        await tester.tap(find.widgetWithIcon(IconButton, Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Delete Item'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete this item?'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('should not delete when cancel tapped', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        await tester.tap(find.widgetWithIcon(IconButton, Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(mockViewModel.deleteItem());
      });

      testWidgets('should delete item when confirmed', (tester) async {
        when(mockViewModel.deleteItem()).thenAnswer((_) async => true);

        await tester.pumpWidget(
          createTestWidget(
            viewModel: mockViewModel,
            categories: testCategories,
            locations: testLocations,
          ),
        );

        await tester.tap(find.widgetWithIcon(IconButton, Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        verify(mockViewModel.deleteItem()).called(1);
      });
    });
  });
}
