import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/services/api_credentials_manager.dart';
import 'package:home_ai_index/presentation/screens/settings_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/settings_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'settings_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<APICredentialsManager>()])
void main() {
  group('SettingsScreen Widget Tests (T045)', () {
    late MockAPICredentialsManager mockCredentialsManager;

    setUp(() {
      mockCredentialsManager = MockAPICredentialsManager();
    });

    Widget createSettingsScreen({SettingsViewModel? viewModel}) {
      return MaterialApp(
        home: viewModel != null
            ? ChangeNotifierProvider<SettingsViewModel>.value(
                value: viewModel,
                child: const Scaffold(body: SettingsScreenContent()),
              )
            : const SettingsScreen(),
      );
    }

    testWidgets('displays app bar with Settings title', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays header and description', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Google Cloud Vision API'), findsOneWidget);
      expect(
        find.text(
          'Enter your API credentials to enable image recognition with Google Cloud Vision.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays API Key input field', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find the API Key field
      final apiKeyField = find.widgetWithText(TextFormField, 'API Key *');
      expect(apiKeyField, findsOneWidget);

      // Check placeholder text
      expect(
        find.text('Enter your Google Cloud Vision API key'),
        findsOneWidget,
      );

      // Check visibility toggle exists
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('displays Project ID input field', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      final projectIdField = find.widgetWithText(
        TextFormField,
        'Project ID (Optional)',
      );
      expect(projectIdField, findsOneWidget);

      expect(find.text('Enter your Google Cloud project ID'), findsOneWidget);
    });

    testWidgets('displays Save Credentials button', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Save Credentials'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('toggles API key visibility when icon tapped', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Enter some text to verify obscuring
      final apiKeyField = find.widgetWithText(TextFormField, 'API Key *');
      await tester.enterText(apiKeyField, 'test-api-key-12345');
      await tester.pumpAndSettle();

      // Initially should show visibility icon (key is obscured)
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      // Should now show visibility_off icon (key is visible)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap again to toggle back
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Should show visibility icon again
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('displays help section with setup steps', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Scroll to bottom to see help section
      await tester.dragUntilVisible(
        find.text('How to get an API key'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      expect(find.text('How to get an API key'), findsOneWidget);
      expect(find.text('Go to Google Cloud Console'), findsOneWidget);
      expect(find.text('Create or select a project'), findsOneWidget);
      expect(find.text('Enable Cloud Vision API'), findsOneWidget);
      expect(find.text('Create API key'), findsOneWidget);
      expect(find.text('Secure your key'), findsOneWidget);
    });

    testWidgets('shows warning when no credentials configured', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(
        find.text(
          'No API credentials configured. Image recognition will use offline mode only.',
        ),
        findsOneWidget,
      );
    });
  });

  group('SettingsScreen Validation Tests (T046)', () {
    late MockAPICredentialsManager mockCredentialsManager;

    setUp(() {
      mockCredentialsManager = MockAPICredentialsManager();
    });

    Widget createSettingsScreen() {
      return const MaterialApp(home: SettingsScreen());
    }

    testWidgets('validates empty API key', (tester) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Leave API key empty and tap Save
      await tester.tap(find.text('Save Credentials'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter an API key'), findsOneWidget);
    });

    testWidgets('validates short API key (less than 20 characters)', (
      tester,
    ) async {
      when(
        mockCredentialsManager.hasValidCredentials(),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Enter short API key
      final apiKeyField = find.widgetWithText(TextFormField, 'API Key *');
      await tester.enterText(apiKeyField, 'short-key');
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save Credentials'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('API key appears to be too short'), findsOneWidget);
    });
  });
}

/// Helper widget to test SettingsScreen content without the provider wrapper
class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Return the inner content that uses Provider
    return const SettingsScreen();
  }
}
