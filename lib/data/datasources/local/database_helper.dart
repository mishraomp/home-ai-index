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
    await _seedDefaultLocations(db);
  }

  /// Handles database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1 -> 2: Add default location seed data
    if (oldVersion < 2) {
      await _seedDefaultLocations(db);
    }

    // Version 2 -> 3: Add API logs table
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE api_logs (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          endpoint TEXT NOT NULL,
          status_code INTEGER,
          latency_ms INTEGER,
          error TEXT,
          success INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_api_logs_timestamp ON api_logs (timestamp)
      ''');
      await db.execute('''
        CREATE INDEX idx_api_logs_success ON api_logs (success)
      ''');
    }
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

    // API logs table for Cloud Vision API usage tracking
    await db.execute('''
      CREATE TABLE api_logs (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        status_code INTEGER,
        latency_ms INTEGER,
        error TEXT,
        success INTEGER NOT NULL
      )
    ''');

    // Create indexes for faster queries on API logs
    await db.execute('''
      CREATE INDEX idx_api_logs_timestamp ON api_logs (timestamp)
    ''');
    await db.execute('''
      CREATE INDEX idx_api_logs_success ON api_logs (success)
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

  /// Seeds the database with default locations
  Future<void> _seedDefaultLocations(Database db) async {
    // Define some common default locations for a home
    final defaultLocations = [
      {'id': 'home', 'name': 'Home', 'parent_id': null},
      {'id': 'kitchen', 'name': 'Kitchen', 'parent_id': 'home'},
      {'id': 'bedroom', 'name': 'Bedroom', 'parent_id': 'home'},
      {'id': 'living-room', 'name': 'Living Room', 'parent_id': 'home'},
      {'id': 'bathroom', 'name': 'Bathroom', 'parent_id': 'home'},
      {'id': 'garage', 'name': 'Garage', 'parent_id': 'home'},
      {'id': 'storage', 'name': 'Storage', 'parent_id': 'home'},
      // Kitchen sub-locations
      {'id': 'pantry', 'name': 'Pantry', 'parent_id': 'kitchen'},
      {'id': 'fridge', 'name': 'Refrigerator', 'parent_id': 'kitchen'},
      {'id': 'cabinet', 'name': 'Cabinet', 'parent_id': 'kitchen'},
      // Bedroom sub-locations
      {'id': 'closet', 'name': 'Closet', 'parent_id': 'bedroom'},
      {'id': 'dresser', 'name': 'Dresser', 'parent_id': 'bedroom'},
    ];

    for (final location in defaultLocations) {
      await db.insert('locations', location);
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
