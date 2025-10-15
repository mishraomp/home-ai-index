import 'package:home_ai_index/core/constants/app_constants.dart';
import 'package:home_ai_index/core/constants/default_categories.dart';
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for the Home AI Index app
///
/// Manages database creation, migrations, and provides the database instance.
/// Implements the singleton pattern to ensure a single database connection.
class DatabaseHelper {

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        'Failed to initialize database: $e',
      );
    }
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the database schema on first launch
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedDefaultCategories(db);
  }

  /// Handles database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
    // For now, this is a placeholder for when we need to update the schema
  }

  /// Creates all database tables
  Future<void> _createTables(Database db) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        FOREIGN KEY (parent_id) REFERENCES locations (id) ON DELETE CASCADE
      )
    ''');

    // Create index on parent_id for faster hierarchy queries
    await db.execute('''
      CREATE INDEX idx_locations_parent_id ON locations (parent_id)
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        notes TEXT,
        quantity INTEGER NOT NULL DEFAULT 1,
        category_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        expiration_date TEXT,
        image_path TEXT,
        ml_detected_label TEXT,
        ml_confidence_score REAL,
        added_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
        FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE RESTRICT
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_items_category_id ON items (category_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_items_location_id ON items (location_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_items_expiration_date ON items (expiration_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_items_name ON items (name)
    ''');

    // Location history table
    await db.execute('''
      CREATE TABLE location_history (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
        FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE RESTRICT
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_location_history_item_id ON location_history (item_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_location_history_timestamp ON location_history (timestamp)
    ''');
  }

  /// Seeds the database with default categories
  Future<void> _seedDefaultCategories(Database db) async {
    for (final category in defaultCategories) {
      // Convert boolean to integer for SQLite storage
      final dbCategory = Map<String, dynamic>.from(category);
      dbCategory['is_custom'] = (dbCategory['isCustom'] as bool) ? 1 : 0;
      dbCategory.remove('isCustom'); // Remove the boolean field

      // Rename keys to match database schema
      dbCategory['icon_code_point'] = dbCategory['iconCodePoint'];
      dbCategory.remove('iconCodePoint');

      await db.insert('categories', dbCategory);
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Deletes the database (for testing purposes)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
