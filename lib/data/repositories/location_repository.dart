import 'package:home_ai_index/data/models/location.dart';

/// Repository interface for managing storage locations
abstract class LocationRepository {
  /// Retrieves all locations.
  ///
  /// [rootOnly]: If true, returns only top-level locations (parentId = null)
  ///
  /// Returns: List of locations
  /// Throws: DatabaseException on query error
  Future<List<Location>> getLocations({bool rootOnly = false});

  /// Retrieves a single location by ID.
  ///
  /// [id]: Location ID
  ///
  /// Returns: Location if found
  /// Throws: LocationNotFoundException if not found
  Future<Location> getLocationById(String id);

  /// Retrieves child locations of a parent.
  ///
  /// [parentId]: Parent location ID
  ///
  /// Returns: List of child locations
  /// Throws: DatabaseException on query error
  Future<List<Location>> getChildLocations(String parentId);

  /// Retrieves full path of location ancestors.
  ///
  /// [locationId]: Location ID
  ///
  /// Returns: List of locations from root to specified location
  /// Throws: LocationNotFoundException if not found
  /// Throws: DatabaseException on query error
  Future<List<Location>> getLocationPath(String locationId);

  /// Creates a new location.
  ///
  /// [location]: Location to create
  ///
  /// Returns: Created location
  /// Throws: ValidationException if data invalid or hierarchy too deep (>5 levels)
  /// Throws: DatabaseException on insert error
  Future<Location> createLocation(Location location);

  /// Updates an existing location.
  ///
  /// [location]: Location with updated fields
  ///
  /// Returns: Updated location
  /// Throws: LocationNotFoundException if not found
  /// Throws: ValidationException if data invalid or creates circular reference
  /// Throws: DatabaseException on update error
  Future<Location> updateLocation(Location location);

  /// Deletes a location.
  ///
  /// [id]: Location ID
  /// [deleteItems]: If true, delete items in location; if false, unassign items
  ///
  /// Returns: true if deleted successfully
  /// Throws: LocationNotFoundException if not found
  /// Throws: DatabaseException on delete error
  Future<bool> deleteLocation(String id, {bool deleteItems = false});

  /// Checks if location has any items.
  ///
  /// [locationId]: Location ID
  ///
  /// Returns: true if location has items
  /// Throws: DatabaseException on query error
  Future<bool> hasItems(String locationId);

  /// Validates that moving location doesn't create circular reference.
  ///
  /// [locationId]: Location being moved
  /// [newParentId]: New parent location ID
  ///
  /// Returns: true if move is valid
  /// Throws: ValidationException if would create circular reference
  Future<bool> validateLocationMove(String locationId, String newParentId);
}
