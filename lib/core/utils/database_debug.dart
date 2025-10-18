import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Debug utility to inspect and clean database
///
/// Usage: Run this as a standalone script or integrate into app's debug menu
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  developer.log('=== Database Debug Utility ===\n', name: 'DatabaseDebug');

  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;

  // Query all items
  developer.log('--- All Items in Database ---', name: 'DatabaseDebug');
  final items = await db.query('items');
  developer.log('Total items: ${items.length}\n', name: 'DatabaseDebug');

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    developer.log('Item ${i + 1}:', name: 'DatabaseDebug');
    developer.log('  ID: ${item['id']}', name: 'DatabaseDebug');
    developer.log('  Name: ${item['name']}', name: 'DatabaseDebug');
    developer.log('  Category: ${item['category_id']}', name: 'DatabaseDebug');
    developer.log('  Location: ${item['location_id']}', name: 'DatabaseDebug');
    developer.log('  Quantity: ${item['quantity']}', name: 'DatabaseDebug');
    developer.log('  Added: ${item['added_at']}', name: 'DatabaseDebug');
    developer.log('', name: 'DatabaseDebug');
  }

  // Check for items with invalid data
  developer.log('--- Checking for Invalid Items ---', name: 'DatabaseDebug');
  final invalidItems = items.where((item) {
    final id = item['id'] as String?;
    final name = item['name'] as String?;
    return id == null || id.isEmpty || name == null || name.isEmpty;
  }).toList();

  if (invalidItems.isEmpty) {
    developer.log('✓ All items have valid IDs and names\n',
        name: 'DatabaseDebug');
  } else {
    developer.log('⚠ Found ${invalidItems.length} items with invalid data:',
        name: 'DatabaseDebug');
    for (final item in invalidItems) {
      developer.log('  - ID: "${item['id']}", Name: "${item['name']}"',
          name: 'DatabaseDebug');
    }
    developer.log('', name: 'DatabaseDebug');
  }

  // Offer to clean up invalid items
  if (invalidItems.isNotEmpty) {
    developer.log('Would you like to delete these invalid items? (y/n)',
        name: 'DatabaseDebug');
    // In a real app, you'd use a button or confirmation dialog
    // For now, uncomment the next line to auto-delete:
    // await cleanupInvalidItems(db, invalidItems);
  }

  developer.log('=== End of Database Debug ===', name: 'DatabaseDebug');
}

/// Delete invalid items from database
Future<void> cleanupInvalidItems(
  Database db,
  List<Map<String, dynamic>> items,
) async {
  developer.log('\nCleaning up invalid items...', name: 'DatabaseDebug');
  int deleted = 0;

  for (final item in items) {
    final id = item['id'] as String?;
    if (id != null && id.isNotEmpty) {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
      deleted++;
      developer.log('  ✓ Deleted item with ID: $id', name: 'DatabaseDebug');
    }
  }

  developer.log('Cleanup complete. Deleted $deleted items.\n',
      name: 'DatabaseDebug');
}

/// Delete ALL items (use with caution!)
Future<void> deleteAllItems(Database db) async {
  developer.log('\n⚠ WARNING: Deleting ALL items from database...',
      name: 'DatabaseDebug');
  await db.delete('items');
  developer.log('All items deleted.\n', name: 'DatabaseDebug');
}

/// Delete specific item by ID
Future<void> deleteItemById(Database db, String id) async {
  developer.log('\nDeleting item with ID: $id...', name: 'DatabaseDebug');
  final count = await db.delete('items', where: 'id = ?', whereArgs: [id]);
  if (count > 0) {
    developer.log('✓ Item deleted successfully.\n', name: 'DatabaseDebug');
  } else {
    developer.log('✗ No item found with that ID.\n', name: 'DatabaseDebug');
  }
}
