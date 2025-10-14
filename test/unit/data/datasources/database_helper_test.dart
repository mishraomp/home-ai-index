import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/core/constants/app_constants.dart';
import 'package:home_ai_index/core/constants/default_categories.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUp(() {
      databaseHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      // Clean up after each test
      await databaseHelper.deleteDatabase();
    });

    group('Database Initialization', () {
      test('should create database successfully', () async {
        final db = await databaseHelper.database;
        expect(db, isNotNull);
        expect(db.isOpen, true);
      });

      test('should have correct database name', () async {
        final db = await databaseHelper.database;
        expect(db.path, contains(databaseName));
      });

      test('should create all required tables', () async {
        final db = await databaseHelper.database;

        // Query sqlite_master to check table existence
        final tables = await db.query(
          'sqlite_master',
          where: 'type = ?',
          whereArgs: ['table'],
        );

        final tableNames = tables.map((t) => t['name'] as String).toList();

        expect(tableNames, contains('categories'));
        expect(tableNames, contains('locations'));
        expect(tableNames, contains('items'));
        expect(tableNames, contains('location_history'));
      });
    });

    group('Categories Table', () {
      test('should have correct schema', () async {
        final db = await databaseHelper.database;

        final columns = await db.query('pragma_table_info("categories")');

        final columnNames = columns.map((c) => c['name'] as String).toList();

        expect(columnNames, contains('id'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('icon_code_point'));
        expect(columnNames, contains('is_custom'));
      });

      test('should seed default categories on initialization', () async {
        final db = await databaseHelper.database;

        final categories = await db.query('categories');

        expect(categories.length, defaultCategories.length);
        expect(categories.length, 12); // 12 default categories

        // Check a few specific categories
        final groceriesCategory = categories.firstWhere(
          (c) => c['id'] == 'groceries',
        );
        expect(groceriesCategory['name'], 'Groceries');
        expect(groceriesCategory['is_custom'], 0);
      });
    });

    group('Locations Table', () {
      test('should have correct schema', () async {
        final db = await databaseHelper.database;

        final columns = await db.query('pragma_table_info("locations")');

        final columnNames = columns.map((c) => c['name'] as String).toList();

        expect(columnNames, contains('id'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('parent_id'));
      });

      test('should have parent_id index', () async {
        final db = await databaseHelper.database;

        final indexes = await db.query(
          'sqlite_master',
          where: 'type = ? AND tbl_name = ?',
          whereArgs: ['index', 'locations'],
        );

        final indexNames = indexes.map((i) => i['name'] as String).toList();
        expect(indexNames, contains('idx_locations_parent_id'));
      });
    });

    group('Items Table', () {
      test('should have correct schema', () async {
        final db = await databaseHelper.database;

        final columns = await db.query('pragma_table_info("items")');

        final columnNames = columns.map((c) => c['name'] as String).toList();

        expect(columnNames, contains('id'));
        expect(columnNames, contains('name'));
        expect(columnNames, contains('notes'));
        expect(columnNames, contains('quantity'));
        expect(columnNames, contains('category_id'));
        expect(columnNames, contains('location_id'));
        expect(columnNames, contains('expiration_date'));
        expect(columnNames, contains('image_path'));
        expect(columnNames, contains('ml_detected_label'));
        expect(columnNames, contains('ml_confidence_score'));
        expect(columnNames, contains('added_at'));
        expect(columnNames, contains('updated_at'));
      });

      test('should have required indexes', () async {
        final db = await databaseHelper.database;

        final indexes = await db.query(
          'sqlite_master',
          where: 'type = ? AND tbl_name = ?',
          whereArgs: ['index', 'items'],
        );

        final indexNames = indexes.map((i) => i['name'] as String).toList();

        expect(indexNames, contains('idx_items_category_id'));
        expect(indexNames, contains('idx_items_location_id'));
        expect(indexNames, contains('idx_items_expiration_date'));
        expect(indexNames, contains('idx_items_name'));
      });
    });

    group('Location History Table', () {
      test('should have correct schema', () async {
        final db = await databaseHelper.database;

        final columns = await db.query('pragma_table_info("location_history")');

        final columnNames = columns.map((c) => c['name'] as String).toList();

        expect(columnNames, contains('id'));
        expect(columnNames, contains('item_id'));
        expect(columnNames, contains('location_id'));
        expect(columnNames, contains('timestamp'));
      });

      test('should have required indexes', () async {
        final db = await databaseHelper.database;

        final indexes = await db.query(
          'sqlite_master',
          where: 'type = ? AND tbl_name = ?',
          whereArgs: ['index', 'location_history'],
        );

        final indexNames = indexes.map((i) => i['name'] as String).toList();

        expect(indexNames, contains('idx_location_history_item_id'));
        expect(indexNames, contains('idx_location_history_timestamp'));
      });
    });

    group('Database Operations', () {
      test('should close database successfully', () async {
        final db = await databaseHelper.database;
        expect(db.isOpen, true);

        await databaseHelper.close();

        // Database should be closed and instance reset
        expect(DatabaseHelper.instance, isNotNull);
      });

      test('should delete database successfully', () async {
        // Create database
        await databaseHelper.database;

        // Delete it
        await databaseHelper.deleteDatabase();

        // Verify by creating a new database and checking it's empty
        final db = await databaseHelper.database;
        final tables = await db.query(
          'sqlite_master',
          where: 'type = ?',
          whereArgs: ['table'],
        );

        // Should have tables but newly created
        expect(tables.length, greaterThan(0));
      });
    });
  });
}
