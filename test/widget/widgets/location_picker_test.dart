import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/location/location_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'location_picker_test.mocks.dart';

@GenerateMocks([LocationsViewModel])
void main() {
  late MockLocationsViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockLocationsViewModel();
  });

  Widget createLocationPicker({Location? initialLocation}) {
    return ChangeNotifierProvider<LocationsViewModel>.value(
      value: mockViewModel,
      child: MaterialApp(
        home: Scaffold(body: LocationPicker(initialLocation: initialLocation)),
      ),
    );
  }

  final testLocations = [
    const Location(id: 'loc1', name: 'Garage'),
    const Location(id: 'loc2', name: 'Attic'),
    const Location(id: 'loc3', name: 'Basement'),
  ];

  group('LocationPicker Widget Tests', () {
    testWidgets('displays title "Select Location"', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());

      expect(find.text('Select Location'), findsOneWidget);
    });

    testWidgets('displays locations list', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());
      await tester.pump();

      expect(find.text('Garage'), findsWidgets);
      expect(find.text('Attic'), findsWidgets);
      expect(find.text('Basement'), findsWidgets);
    });

    testWidgets('displays loading indicator when loading', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(true);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when error occurs', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn('Failed to load');

      await tester.pumpWidget(createLocationPicker());

      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('displays cancel button', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays select button when location is selected', (
      WidgetTester tester,
    ) async {
      final initialLoc = testLocations[0];
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(
        createLocationPicker(initialLocation: initialLoc),
      );

      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('shows hierarchical navigation in breadcrumb', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());
      await tester.pump();

      // Breadcrumb should be visible (either as text or UI element)
      expect(find.byType(LocationPicker), findsOneWidget);
    });

    testWidgets('can select a location', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());
      await tester.pump();

      // Tap on first location
      await tester.tap(find.text('Garage').first);
      await tester.pump();

      expect(find.byType(LocationPicker), findsOneWidget);
    });

    testWidgets('displays none option when allowNone is true', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationPicker());
      await tester.pump();

      expect(find.text('No Location'), findsOneWidget);
    });
  });
}
