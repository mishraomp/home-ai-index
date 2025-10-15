import 'package:flutter/foundation.dart';

import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';

/// ViewModel for item details screen
///
/// Manages item viewing, editing, deletion, and location history
class ItemDetailsViewModel extends ChangeNotifier {
  ItemDetailsViewModel({
    required String itemId,
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required LocationRepository locationRepository,
    required LocationHistoryRepository locationHistoryRepository,
  }) : _itemId = itemId,
       _itemRepository = itemRepository,
       _locationRepository = locationRepository,
       _locationHistoryRepository = locationHistoryRepository;

  final String _itemId;
  final ItemRepository _itemRepository;
  final LocationRepository _locationRepository;
  final LocationHistoryRepository _locationHistoryRepository;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  Item? _item;
  List<LocationHistory> _locationHistory = [];
  final Map<String, Location> _locationCache = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Item? get item => _item;
  List<LocationHistory> get locationHistory => _locationHistory;

  /// Loads the item details
  Future<void> loadItem() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _item = await _itemRepository.getItemById(_itemId);
      _errorMessage = null;
    } on ItemNotFoundException catch (e) {
      _errorMessage = 'Item not found: ${e.message}';
      _item = null;
    } catch (e) {
      _errorMessage = 'Failed to load item: $e';
      _item = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the location history for the item
  Future<void> loadLocationHistory() async {
    _errorMessage = null;

    try {
      _locationHistory = await _locationHistoryRepository.getHistoryForItem(
        _itemId,
      );

      // Preload locations for history entries
      for (final history in _locationHistory) {
        if (!_locationCache.containsKey(history.locationId)) {
          try {
            final location = await _locationRepository.getLocationById(
              history.locationId,
            );
            _locationCache[history.locationId] = location;
          } catch (e) {
            // Location might have been deleted, skip
            debugPrint('Failed to load location ${history.locationId}: $e');
          }
        }
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load location history: $e';
      _locationHistory = [];
    }

    notifyListeners();
  }

  /// Updates the item's name
  Future<void> updateItemName(String name) async {
    if (_item == null) return;

    if (name.trim().isEmpty) {
      _errorMessage = 'Name cannot be empty';
      notifyListeners();
      return;
    }

    try {
      final updatedItem = _item!.copyWith(
        name: name.trim(),
        updatedAt: DateTime.now(),
      );
      await _itemRepository.updateItem(updatedItem);
      _item = updatedItem;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update name: $e';
    }

    notifyListeners();
  }

  /// Updates the item's quantity
  Future<void> updateItemQuantity(int quantity) async {
    if (_item == null) return;

    if (quantity <= 0) {
      _errorMessage = 'Quantity must be greater than 0';
      notifyListeners();
      return;
    }

    try {
      final updatedItem = _item!.copyWith(
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
      await _itemRepository.updateItem(updatedItem);
      _item = updatedItem;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update quantity: $e';
    }

    notifyListeners();
  }

  /// Updates the item's notes
  Future<void> updateItemNotes(String? notes) async {
    if (_item == null) return;

    try {
      final updatedItem = _item!.copyWith(
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        updateNotes: true,
        updatedAt: DateTime.now(),
      );
      await _itemRepository.updateItem(updatedItem);
      _item = updatedItem;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update notes: $e';
    }

    notifyListeners();
  }

  /// Updates the item's location
  Future<void> updateItemLocation(String? newLocationId) async {
    if (_item == null) return;

    // Don't update if location is the same
    if (_item!.locationId == newLocationId) {
      return;
    }

    try {
      final updatedItem = _item!.copyWith(
        locationId: newLocationId,
        updateLocationId: true,
        updatedAt: DateTime.now(),
      );

      await _itemRepository.updateItem(updatedItem);

      // Create history entry
      final historyEntry = LocationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: _itemId,
        locationId: newLocationId ?? '',
        timestamp: DateTime.now(),
      );
      await _locationHistoryRepository.createHistoryEntry(historyEntry);

      _item = updatedItem;
      _errorMessage = null;

      // Reload history to show the new entry
      await loadLocationHistory();
    } catch (e) {
      _errorMessage = 'Failed to update location: $e';
      notifyListeners();
    }
  }

  /// Updates the item's category
  Future<void> updateItemCategory(String categoryId) async {
    if (_item == null) return;

    if (categoryId.trim().isEmpty) {
      _errorMessage = 'Category cannot be empty';
      notifyListeners();
      return;
    }

    try {
      final updatedItem = _item!.copyWith(
        categoryId: categoryId,
        updatedAt: DateTime.now(),
      );
      await _itemRepository.updateItem(updatedItem);
      _item = updatedItem;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
    }

    notifyListeners();
  }

  /// Deletes the item
  Future<bool> deleteItem() async {
    if (_item == null) return false;

    try {
      await _itemRepository.deleteItem(_itemId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gets the location name for a location ID (synchronous, uses cache)
  String getLocationName(String? locationId) {
    if (locationId == null) {
      return 'Unlocated';
    }

    // Check cache
    if (_locationCache.containsKey(locationId)) {
      return _locationCache[locationId]!.name;
    }

    return 'Unknown';
  }

  /// Clears the error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
