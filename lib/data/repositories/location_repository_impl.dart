import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

/// Implementation of LocationRepository using SQLite
class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({required this.database});
  final Database database;

  @override
  Future<List<Location>> getLocations({bool rootOnly = false}) async {
    try {
      final List<Map<String, dynamic>> maps;
      if (rootOnly) {
        maps = await database.query(
          'locations',
          where: 'parent_id IS NULL',
          orderBy: 'name ASC',
        );
      } else {
        maps = await database.query('locations', orderBy: 'name ASC');
      }
      return maps.map((map) => Location.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get locations: $e');
    }
  }

  @override
  Future<Location> getLocationById(String id) async {
    try {
      final maps = await database.query(
        'locations',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        throw LocationNotFoundException('Location not found: $id');
      }
      return Location.fromDatabase(maps.first);
    } catch (e) {
      if (e is LocationNotFoundException) rethrow;
      throw DatabaseException('Failed to get location by id: $e');
    }
  }

  @override
  Future<List<Location>> getChildLocations(String parentId) async {
    try {
      final maps = await database.query(
        'locations',
        where: 'parent_id = ?',
        whereArgs: [parentId],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Location.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get child locations: $e');
    }
  }

  @override
  Future<List<Location>> getLocationPath(String locationId) async {
    try {
      final path = <Location>[];
      String? currentId = locationId;

      while (currentId != null) {
        final location = await getLocationById(currentId);
        path.insert(0, location); // Insert at beginning to build path from root
        currentId = location.parentId;
      }

      return path;
    } catch (e) {
      if (e is LocationNotFoundException) rethrow;
      throw DatabaseException('Failed to get location path: $e');
    }
  }

  @override
  Future<Location> createLocation(Location location) async {
    try {
      // Validate location name
      if (location.name.trim().isEmpty) {
        throw const ValidationException('Location name cannot be empty');
      }

      // Validate hierarchy depth (max 5 levels)
      if (location.parentId != null) {
        final path = await getLocationPath(location.parentId!);
        if (path.length >= 5) {
          throw const ValidationException(
            'Location hierarchy cannot exceed 5 levels',
          );
        }
      }

      await database.insert('locations', location.toDatabase());
      return location;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Failed to create location: $e');
    }
  }

  @override
  Future<Location> updateLocation(Location location) async {
    try {
      // Validate location name first (before DB operations)
      if (location.name.trim().isEmpty) {
        throw const ValidationException('Location name cannot be empty');
      }

      // Validate location exists
      await getLocationById(location.id);

      await database.update(
        'locations',
        location.toDatabase(),
        where: 'id = ?',
        whereArgs: [location.id],
      );
      return location;
    } catch (e) {
      if (e is LocationNotFoundException || e is ValidationException) rethrow;
      throw DatabaseException('Failed to update location: $e');
    }
  }

  @override
  Future<bool> deleteLocation(String id, {bool deleteItems = false}) async {
    try {
      // Check if location has items
      final items = await database.query(
        'items',
        where: 'location_id = ?',
        whereArgs: [id],
      );

      if (items.isNotEmpty) {
        if (deleteItems) {
          // Delete all items in this location
          await database.delete(
            'items',
            where: 'location_id = ?',
            whereArgs: [id],
          );
        } else {
          // Unassign items from this location
          await database.update(
            'items',
            {'location_id': null},
            where: 'location_id = ?',
            whereArgs: [id],
          );
        }
      }

      // Delete the location
      await database.delete('locations', where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      throw DatabaseException('Failed to delete location: $e');
    }
  }

  @override
  Future<bool> hasItems(String locationId) async {
    try {
      final items = await database.query(
        'items',
        where: 'location_id = ?',
        whereArgs: [locationId],
      );
      return items.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check if location has items: $e');
    }
  }

  @override
  Future<bool> validateLocationMove(
    String locationId,
    String newParentId,
  ) async {
    try {
      // Cannot move location to itself
      if (locationId == newParentId) {
        throw const ValidationException('Cannot move location to itself');
      }

      // Check if new parent is a descendant of the location being moved
      // This would create a circular reference
      final newParentPath = await getLocationPath(newParentId);
      for (final ancestor in newParentPath) {
        if (ancestor.id == locationId) {
          throw const ValidationException(
            'Cannot move location to its own descendant (circular reference)',
          );
        }
      }

      return true;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Failed to validate location move: $e');
    }
  }
}
