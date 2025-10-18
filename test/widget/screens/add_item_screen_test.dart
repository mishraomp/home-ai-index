import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/screens/add_item_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/add_item_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateMocks([AddItemViewModel, LocationRepository])
import 'add_item_screen_test.mocks.dart';

void main() {
  group('AddItemScreen Widget Tests', () {
    late MockAddItemViewModel mockViewModel;
    late MockLocationRepository mockLocationRepository;

    setUp(() {
      mockViewModel = MockAddItemViewModel();
      mockLocationRepository = MockLocationRepository();

      // Default mock behavior
      when(mockViewModel.isLoading).thenReturn(false);
      when(mockViewModel.errorMessage).thenReturn(null);
      when(mockViewModel.recognitionResult).thenReturn(null);
      when(mockViewModel.selectedImagePath).thenReturn(null);
      when(mockViewModel.name).thenReturn('');
      when(mockViewModel.selectedCategory).thenReturn(null);
      when(mockViewModel.selectedLocation).thenReturn(null);
      when(mockViewModel.quantity).thenReturn(1);
      when(mockViewModel.notes).thenReturn('');
      when(mockViewModel.categories).thenReturn([]);
      when(mockViewModel.suggestedName).thenReturn('');
      when(mockViewModel.suggestedCategory).thenReturn(null);
      when(mockViewModel.loadCategories()).thenAnswer((_) async => {});

      // New T027 properties
      when(mockViewModel.recognitionState).thenReturn(RecognitionState.idle);
      when(mockViewModel.hasApiCredentials).thenReturn(true);
      when(mockViewModel.usedOnlineRecognition).thenReturn(false);
      when(mockViewModel.confidence).thenReturn(null);
      when(mockViewModel.alternativeLabels).thenReturn([]);
      when(mockViewModel.isLowConfidence).thenReturn(false);
      when(mockViewModel.recognitionSource).thenReturn('Offline');
      when(mockViewModel.pendingQuotaWarning).thenReturn(null);
      when(
        mockViewModel.refreshCredentialsStatus(),
      ).thenAnswer((_) async => {});

      // Mock location repository
      when(mockLocationRepository.getLocations()).thenAnswer((_) async => []);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AddItemViewModel>.value(value: mockViewModel),
          Provider<LocationRepository>.value(value: mockLocationRepository),
        ],
        child: const MaterialApp(home: AddItemScreen()),
      );
    }

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays save button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('displays camera and gallery buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('displays loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides form when loading', (WidgetTester tester) async {
      when(mockViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Form should not be visible when loading
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Gallery'), findsNothing);
    });

    testWidgets('displays placeholder icon when no image', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.selectedImagePath).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('displays recognition result card when available', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.recognitionState).thenReturn(RecognitionState.success);
      when(mockViewModel.recognitionResult).thenReturn(
        const RecognitionResult(
          label: 'banana',
          confidence: 0.95,
          category: 'Food',
          source: RecognitionSource.cloudVision,
        ),
      );
      when(mockViewModel.confidence).thenReturn(0.95);
      when(mockViewModel.isLowConfidence).thenReturn(false);
      when(mockViewModel.usedOnlineRecognition).thenReturn(true);
      when(mockViewModel.recognitionSource).thenReturn('Cloud Vision');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('AI Recognition'), findsOneWidget);
      expect(find.textContaining('banana'), findsOneWidget);
      expect(find.textContaining('95% match'), findsOneWidget);
    });

    testWidgets('hides recognition result when null', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.recognitionResult).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('AI Recognition'), findsNothing);
    });

    testWidgets('displays form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Look for text form fields - they exist in the form
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('displays error message when present', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.recognitionState).thenReturn(RecognitionState.error);
      when(mockViewModel.errorMessage).thenReturn('Test error message');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry Recognition'), findsOneWidget);
    });

    testWidgets('calls pickImage when camera button tapped', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.pickImage(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find the button by text and tap it
      await tester.tap(find.text('Camera'));
      await tester.pump();

      verify(mockViewModel.pickImage(ImageSource.camera)).called(1);
    });

    testWidgets('calls pickImage when gallery button tapped', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.pickImage(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find the button by text and tap it
      await tester.tap(find.text('Gallery'));
      await tester.pump();

      verify(mockViewModel.pickImage(ImageSource.gallery)).called(1);
    });

    testWidgets('save icon button exists in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify the save icon button exists
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify it's clickable (it's an IconButton)
      final iconButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.check),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('loads categories on init', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // loadCategories should be called during initState
      verify(mockViewModel.loadCategories()).called(1);
    });

    testWidgets('displays categories in dropdown when available', (
      WidgetTester tester,
    ) async {
      when(mockViewModel.categories).thenReturn([
        const Category(
          id: '1',
          name: 'Food',
          iconCodePoint: 0xe8cc,
          isCustom: false,
        ),
        const Category(
          id: '2',
          name: 'Electronics',
          iconCodePoint: 0xe1b1,
          isCustom: false,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Dropdown should exist (part of form)
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });
  });
}
