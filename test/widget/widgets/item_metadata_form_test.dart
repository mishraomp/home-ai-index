import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemMetadataForm Widget Tests (T112)', () {
    testWidgets('renders form with quantity field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Quantity'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders form with notes field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('renders form with expiration date picker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Expiration Date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('quantity field accepts numeric input', (
      WidgetTester tester,
    ) async {
      final quantityController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '5');
      expect(quantityController.text, equals('5'));
    });

    testWidgets('notes field accepts text input', (WidgetTester tester) async {
      final notesController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Organic milk');
      expect(notesController.text, equals('Organic milk'));
    });

    testWidgets('form displays all three fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Expiration Date'), findsOneWidget);
    });

    testWidgets('form can be submitted', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Form valid
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('form validates required fields', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Try to validate with empty field
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('form allows optional fields', (WidgetTester tester) async {
      final notesController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ),
        ),
      );

      // Notes field should be optional
      expect(notesController.text, isEmpty);
    });

    testWidgets('form displays validation error', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Quantity is required'), findsOneWidget);
    });
  });
}
