import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/presentation/screens/add_item_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/add_item_viewmodel.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'add_item_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AddItemViewModel>(),
  MockSpec<LocationsViewModel>(),
])
void main() {
  late MockAddItemViewModel mockAddItemViewModel;
  late MockLocationsViewModel mockLocationsViewModel;

  setUp(() {
    mockAddItemViewModel = MockAddItemViewModel();
    mockLocationsViewModel = MockLocationsViewModel();

    // Default stubs - common behavior
    when(mockAddItemViewModel.isLoading).thenReturn(false);
    when(
      mockAddItemViewModel.recognitionState,
    ).thenReturn(RecognitionState.idle);
    when(mockAddItemViewModel.categories).thenReturn([]);
    when(mockAddItemViewModel.selectedImagePath).thenReturn(null);
    when(mockAddItemViewModel.hasApiCredentials).thenReturn(false);
    when(mockAddItemViewModel.errorMessage).thenReturn(null);
    when(mockAddItemViewModel.recognitionResult).thenReturn(null);
    when(mockAddItemViewModel.confidence).thenReturn(null);
    when(mockAddItemViewModel.usedOnlineRecognition).thenReturn(false);
    when(mockAddItemViewModel.recognitionSource).thenReturn('Offline');
    when(mockAddItemViewModel.isLowConfidence).thenReturn(false);
    when(mockAddItemViewModel.loadCategories()).thenAnswer((_) async {});
    when(
      mockAddItemViewModel.refreshCredentialsStatus(),
    ).thenAnswer((_) async {});

    when(mockLocationsViewModel.locations).thenReturn([]);
    when(mockLocationsViewModel.isLoading).thenReturn(false);
    when(mockLocationsViewModel.loadLocations()).thenAnswer((_) async {});
  });

  Widget createTestWidget({
    AddItemViewModel? addItemViewModel,
    LocationsViewModel? locationsViewModel,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AddItemViewModel>.value(
            value: addItemViewModel ?? mockAddItemViewModel,
          ),
          ChangeNotifierProvider<LocationsViewModel>.value(
            value: locationsViewModel ?? mockLocationsViewModel,
          ),
        ],
        child: const AddItemScreen(),
      ),
      routes: {
        '/settings': (context) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Settings Screen')),
        ),
      },
    );
  }

  group('AddItemScreen Widget Tests', () {
    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      // Arrange
      when(mockAddItemViewModel.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('shows form fields when not loading', (tester) async {
      // Arrange
      when(mockAddItemViewModel.isLoading).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Form), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('shows recognizing state during API call', (tester) async {
      // Arrange
      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.recognizing);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester
          .pump(); // Use pump() instead of pumpAndSettle() for ongoing animations

      // Assert
      expect(find.text('Recognizing image...'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CircularProgressIndicator && widget.strokeWidth == 2,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows success state with recognition results', (tester) async {
      // Arrange
      const recognitionResult = RecognitionResult(
        label: 'Apple',
        category: 'groceries',
        confidence: 0.95,
        source: RecognitionSource.cloudVision,
      );

      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.success);
      when(
        mockAddItemViewModel.recognitionResult,
      ).thenReturn(recognitionResult);
      when(mockAddItemViewModel.confidence).thenReturn(0.95);
      when(mockAddItemViewModel.usedOnlineRecognition).thenReturn(true);
      when(mockAddItemViewModel.recognitionSource).thenReturn('Cloud Vision');
      when(mockAddItemViewModel.isLowConfidence).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('AI Recognition'), findsOneWidget);
      expect(find.text('Detected: Apple'), findsOneWidget);
      expect(find.text('Cloud Vision'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('shows error state with error message', (tester) async {
      // Arrange
      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.error);
      when(
        mockAddItemViewModel.errorMessage,
      ).thenReturn('Network connection failed');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Recognition Failed'), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);
      expect(find.text('Retry Recognition'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows retry button in error state and triggers retry', (
      tester,
    ) async {
      // Arrange
      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.error);
      when(mockAddItemViewModel.errorMessage).thenReturn('API error');
      when(mockAddItemViewModel.retryRecognition()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the retry button by text
      final retryButton = find.text('Retry Recognition');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      // Assert
      verify(mockAddItemViewModel.retryRecognition()).called(1);
    });

    testWidgets('shows no API credentials warning when not configured', (
      tester,
    ) async {
      // Arrange
      when(mockAddItemViewModel.hasApiCredentials).thenReturn(false);
      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.idle);
      when(mockAddItemViewModel.selectedImagePath).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No API Key Configured'), findsOneWidget);
      expect(
        find.text(
          'Using offline recognition only. Add a Cloud Vision API key for better accuracy.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('navigates to settings when settings button tapped', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap settings button in AppBar
      final settingsButton = find
          .widgetWithIcon(IconButton, Icons.settings)
          .first;
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Assert - Settings screen should be visible
      expect(find.text('Settings Screen'), findsOneWidget);

      // Navigate back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verify refresh was called after navigation
        verify(mockAddItemViewModel.refreshCredentialsStatus()).called(1);
      }
    });

    testWidgets('shows offline recognition indicator for offline results', (
      tester,
    ) async {
      // Arrange
      const recognitionResult = RecognitionResult(
        label: 'Bottle',
        category: 'other',
        confidence: 0.75,
        source: RecognitionSource.offline,
      );

      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.success);
      when(
        mockAddItemViewModel.recognitionResult,
      ).thenReturn(recognitionResult);
      when(mockAddItemViewModel.confidence).thenReturn(0.75);
      when(mockAddItemViewModel.usedOnlineRecognition).thenReturn(false);
      when(mockAddItemViewModel.recognitionSource).thenReturn('Offline');
      when(mockAddItemViewModel.isLowConfidence).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('shows high confidence indicator for confident results', (
      tester,
    ) async {
      // Arrange
      const recognitionResult = RecognitionResult(
        label: 'Orange',
        category: 'groceries',
        confidence: 0.98,
        source: RecognitionSource.cloudVision,
      );

      when(
        mockAddItemViewModel.recognitionState,
      ).thenReturn(RecognitionState.success);
      when(
        mockAddItemViewModel.recognitionResult,
      ).thenReturn(recognitionResult);
      when(mockAddItemViewModel.confidence).thenReturn(0.98);
      when(mockAddItemViewModel.usedOnlineRecognition).thenReturn(true);
      when(mockAddItemViewModel.recognitionSource).thenReturn('Cloud Vision');
      when(mockAddItemViewModel.isLowConfidence).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('AddItemScreen Form Interaction Tests', () {
    testWidgets('name field can be edited', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Item');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('quantity field can be edited', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find quantity field (should have initial value '1')
      final quantityFields = find.byType(TextFormField);
      final quantityField = quantityFields.at(
        quantityFields.evaluate().length - 2,
      );

      await tester.enterText(quantityField, '5');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows category dropdown when categories loaded', (
      tester,
    ) async {
      // Arrange
      when(mockAddItemViewModel.categories).thenReturn([
        const Category(
          id: 'groceries',
          name: 'Groceries',
          iconCodePoint: 0xe57f,
          isCustom: false,
        ),
        const Category(
          id: 'electronics',
          name: 'Electronics',
          iconCodePoint: 0xe1b8,
          isCustom: false,
        ),
      ]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - dropdown should be present (uses String, not Category type)
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });
  });
}
