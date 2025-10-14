// Home AI Index - Widget Tests
// Basic smoke test for Phase 1 setup

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_ai_index/main.dart';

void main() {
  testWidgets('App launches and displays placeholder screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const HomeAIIndexApp());

    // Verify that the app title is displayed
    expect(find.text('Home AI Index'), findsWidgets);

    // Verify placeholder screen content
    expect(find.text('Smart Home Inventory Manager'), findsOneWidget);
    expect(find.text('Phase 1: Setup Complete'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
