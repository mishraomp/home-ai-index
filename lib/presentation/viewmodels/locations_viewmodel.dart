import 'package:flutter/foundation.dart';

import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';

/// ViewModel for managing locations
class LocationsViewModel extends ChangeNotifier {
  LocationsViewModel({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;
  final LocationRepository _locationRepository;

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  List<Location> _locations = [];
  Location? _selectedLocation;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Location> get locations => _locations;
  Location? get selectedLocation => _selectedLocation;

  /// Load all locations or root locations only
  Future<void> loadLocations({bool rootOnly = false}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _locations = await _locationRepository.getLocations(rootOnly: rootOnly);

      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load locations: $e';
      _locations = [];
      _setLoading(false);
    }
  }

  /// Load child locations for a specific parent
  Future<void> loadChildLocations(String parentId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _locations = await _locationRepository.getChildLocations(parentId);

      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load child locations: $e';
      _setLoading(false);
    }
  }

  /// Create a new location
  Future<void> createLocation(String name, String? parentId) async {
    // Validate name before calling repository
    if (name.trim().isEmpty) {
      _errorMessage = 'Location name cannot be empty';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final newLocation = Location(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        parentId: parentId,
      );

      await _locationRepository.createLocation(newLocation);

      // Reload locations after creation
      await loadLocations();

      _setLoading(false);
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to create location: $e';
      _setLoading(false);
    }
  }

  /// Update an existing location's name
  Future<void> updateLocation(String id, String newName) async {
    // Validate name before calling repository
    if (newName.trim().isEmpty) {
      _errorMessage = 'Location name cannot be empty';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final updatedLocation = Location(id: id, name: newName.trim());

      await _locationRepository.updateLocation(updatedLocation);

      // Reload locations after update
      await loadLocations();

      _setLoading(false);
    } on LocationNotFoundException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to update location: $e';
      _setLoading(false);
    }
  }

  /// Delete a location
  Future<void> deleteLocation(String id, {required bool deleteItems}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _locationRepository.deleteLocation(id, deleteItems: deleteItems);

      // Reload locations after deletion
      await loadLocations();

      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to delete location: $e';
      _setLoading(false);
    }
  }

  /// Check if a location has items assigned to it
  Future<bool> checkLocationHasItems(String locationId) async {
    try {
      return await _locationRepository.hasItems(locationId);
    } catch (e) {
      _errorMessage = 'Failed to check location items: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get the full path for a location (from root to location)
  Future<List<Location>> getLocationPath(String locationId) async {
    return _locationRepository.getLocationPath(locationId);
  }

  /// Select a location
  void selectLocation(Location location) {
    _selectedLocation = location;
    notifyListeners();
  }

  /// Clear location selection
  void clearSelection() {
    _selectedLocation = null;
    notifyListeners();
  }

  /// Validate if a location can be moved to a new parent
  Future<bool> validateLocationMove(
    String locationId,
    String? newParentId,
  ) async {
    if (newParentId == null) {
      return true; // Moving to root is always valid
    }

    try {
      await _locationRepository.validateLocationMove(locationId, newParentId);
      return true;
    } on ValidationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to validate location move: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
