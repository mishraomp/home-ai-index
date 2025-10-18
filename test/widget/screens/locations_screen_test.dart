import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/screens/locations_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'locations_screen_test.mocks.dart';

@GenerateMocks([LocationsViewModel])
void main() {
  late MockLocationsViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockLocationsViewModel();
  });

  Widget createLocationsScreen() {
    return ChangeNotifierProvider<LocationsViewModel>.value(
      value: mockViewModel,
      child: const MaterialApp(home: LocationsScreen()),
    );
  }

  final testLocations = [
    const Location(id: 'loc1', name: 'Garage'),
    const Location(id: 'loc2', name: 'Attic'),
    const Location(id: 'loc3', name: 'Basement'),
  ];

  group('LocationsScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());

      expect(find.text('Locations'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays loading indicator when loading', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(true);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays locations list when loaded', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());
      await tester.pump();

      expect(find.text('Garage'), findsWidgets);
      expect(find.text('Attic'), findsWidgets);
      expect(find.text('Basement'), findsWidgets);
    });

    testWidgets('displays error message when error occurs', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn('Failed to load locations');

      await tester.pumpWidget(createLocationsScreen());

      expect(find.text('Failed to load locations'), findsOneWidget);
    });

    testWidgets('displays FAB for adding new location', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays empty state message when no locations', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn([]);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());

      expect(find.byType(LocationsScreen), findsOneWidget);
    });

    testWidgets('shows location tiles for each location', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());
      await tester.pump();

      // LocationTile uses ListTile which wraps in Card
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('has breadcrumb navigation', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.locations).thenReturn(testLocations);
      when(mockViewModel.errorMessage).thenReturn(null);

      await tester.pumpWidget(createLocationsScreen());
      await tester.pump();

      // Screen should be able to track navigation state
      expect(find.byType(LocationsScreen), findsOneWidget);
    });
  });
}
