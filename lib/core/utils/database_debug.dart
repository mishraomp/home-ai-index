import 'package:flutter/material.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Debug utility to inspect and clean database
///
/// Usage: Run this as a standalone script or integrate into app's debug menu
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Database Debug Utility ===\n');

  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;

  // Query all items
  print('--- All Items in Database ---');
  final items = await db.query('items');
  print('Total items: ${items.length}\n');

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    print('Item ${i + 1}:');
    print('  ID: ${item['id']}');
    print('  Name: ${item['name']}');
    print('  Category: ${item['category_id']}');
    print('  Location: ${item['location_id']}');
    print('  Quantity: ${item['quantity']}');
    print('  Added: ${item['added_at']}');
    print('');
  }

  // Check for items with invalid data
  print('--- Checking for Invalid Items ---');
  final invalidItems = items.where((item) {
    final id = item['id'] as String?;
    final name = item['name'] as String?;
    return id == null || id.isEmpty || name == null || name.isEmpty;
  }).toList();

  if (invalidItems.isEmpty) {
    print('✓ All items have valid IDs and names\n');
  } else {
    print('⚠ Found ${invalidItems.length} items with invalid data:');
    for (final item in invalidItems) {
      print('  - ID: "${item['id']}", Name: "${item['name']}"');
    }
    print('');
  }

  // Offer to clean up invalid items
  if (invalidItems.isNotEmpty) {
    print('Would you like to delete these invalid items? (y/n)');
    // In a real app, you'd use a button or confirmation dialog
    // For now, uncomment the next line to auto-delete:
    // await cleanupInvalidItems(db, invalidItems);
  }

  print('=== End of Database Debug ===');
}

/// Delete invalid items from database
Future<void> cleanupInvalidItems(
  Database db,
  List<Map<String, dynamic>> items,
) async {
  print('\nCleaning up invalid items...');
  int deleted = 0;

  for (final item in items) {
    final id = item['id'] as String?;
    if (id != null && id.isNotEmpty) {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
      deleted++;
      print('  ✓ Deleted item with ID: $id');
    }
  }

  print('Cleanup complete. Deleted $deleted items.\n');
}

/// Delete ALL items (use with caution!)
Future<void> deleteAllItems(Database db) async {
  print('\n⚠ WARNING: Deleting ALL items from database...');
  await db.delete('items');
  print('All items deleted.\n');
}

/// Delete specific item by ID
Future<void> deleteItemById(Database db, String id) async {
  print('\nDeleting item with ID: $id...');
  final count = await db.delete('items', where: 'id = ?', whereArgs: [id]);
  if (count > 0) {
    print('✓ Item deleted successfully.\n');
  } else {
    print('✗ No item found with that ID.\n');
  }
}
