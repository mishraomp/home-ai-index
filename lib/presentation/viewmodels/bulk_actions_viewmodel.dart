import 'package:flutter/foundation.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';

/// ViewModel for bulk actions on multiple items
class BulkActionsViewModel extends ChangeNotifier {
  BulkActionsViewModel({
    required ItemRepository itemRepository,
    required LocationRepository locationRepository,
    required LocationHistoryRepository locationHistoryRepository,
  }) : _itemRepository = itemRepository,
       _locationRepository = locationRepository,
       _locationHistoryRepository = locationHistoryRepository;

  final ItemRepository _itemRepository;
  final LocationRepository _locationRepository;
  final LocationHistoryRepository _locationHistoryRepository;

  bool _isLoading = false;
  String? _errorMessage;

  /// Whether a bulk operation is in progress
  bool get isLoading => _isLoading;

  /// Error message if the last operation failed
  String? get errorMessage => _errorMessage;

  /// Move multiple items to a new location
  ///
  /// Creates location history entries for each item whose location changed.
  /// If [newLocationId] is null, items will be marked as "Unlocated".
  /// Continues processing remaining items even if some fail.
  Future<void> moveSelectedItems(
    List<String> itemIds,
    String? newLocationId,
  ) async {
    if (itemIds.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verify location exists (if not null)
      if (newLocationId != null) {
        await _locationRepository.getLocationById(newLocationId);
      }

      // Process each item
      bool hasErrors = false;
      for (final itemId in itemIds) {
        try {
          // Get current item
          final item = await _itemRepository.getItemById(itemId);

          // Only update if location changed
          if (item?.locationId != newLocationId) {
            // Update item location
            final updatedItem = item!.copyWith(
              locationId: newLocationId,
              updateLocationId: true,
              updatedAt: DateTime.now(),
            );
            await _itemRepository.updateItem(updatedItem);

            // Create location history entry
            final history = LocationHistory(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              itemId: itemId,
              locationId: newLocationId ?? '',
              timestamp: DateTime.now(),
            );
            await _locationHistoryRepository.createHistoryEntry(history);
          }
        } catch (e) {
          hasErrors = true;
          // Continue processing other items
        }
      }

      if (hasErrors) {
        _errorMessage = 'Failed to move items: Some items could not be moved';
      }
    } catch (e) {
      _errorMessage = 'Failed to move items: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
