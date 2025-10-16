import 'package:flutter/foundation.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/home_viewmodel.dart';

/// ViewModel for the Items List Screen
///
/// Manages displaying items with:
/// - Pagination support
/// - Category/location filtering
/// - Grouping by category or location
/// - Sorting options
class ItemsListViewModel extends ChangeNotifier {
  ItemsListViewModel({required ItemRepository itemRepository})
    : _itemRepository = itemRepository;

  final ItemRepository _itemRepository;

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  String? _filterCategoryId;
  String? _filterLocationId;
  SortOption _currentSortOption = SortOption.dateNewest;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Item> get items => _items;
  List<Item> get filteredItems => _filteredItems;
  String? get filterCategoryId => _filterCategoryId;
  String? get filterLocationId => _filterLocationId;
  SortOption get currentSortOption => _currentSortOption;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all items
  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _itemRepository.getItems();
      _filteredItems = List.from(_items);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: ${e.toString()}';
      _items = [];
      _filteredItems = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load items filtered by category
  Future<void> loadItemsByCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    _filterCategoryId = categoryId;
    _filterLocationId = null;
    notifyListeners();

    try {
      _items = await _itemRepository.getItemsByCategory(categoryId);
      _filteredItems = List.from(_items);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: ${e.toString()}';
      _items = [];
      _filteredItems = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load items filtered by location
  Future<void> loadItemsByLocation(String locationId) async {
    _isLoading = true;
    _errorMessage = null;
    _filterLocationId = locationId;
    _filterCategoryId = null;
    notifyListeners();

    try {
      _items = await _itemRepository.getItemsByLocation(locationId);
      _filteredItems = List.from(_items);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load items: ${e.toString()}';
      _items = [];
      _filteredItems = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a specific page of items
  List<Item> getPage(int pageIndex, {int pageSize = 20}) {
    final startIndex = pageIndex * pageSize;
    if (startIndex >= _filteredItems.length) {
      return [];
    }

    final endIndex = (startIndex + pageSize).clamp(0, _filteredItems.length);
    return _filteredItems.sublist(startIndex, endIndex);
  }

  /// Calculate total number of pages
  int getTotalPages({int pageSize = 20}) {
    if (_filteredItems.isEmpty) return 0;
    return (_filteredItems.length / pageSize).ceil();
  }

  /// Check if there's a next page
  bool hasNextPage(int currentPage, {int pageSize = 20}) {
    return currentPage < getTotalPages(pageSize: pageSize) - 1;
  }

  /// Group items by category
  Map<String, List<Item>> groupByCategory() {
    final Map<String, List<Item>> grouped = {};

    for (final item in _items) {
      grouped.putIfAbsent(item.categoryId, () => []).add(item);
    }

    return grouped;
  }

  /// Group items by location
  Map<String, List<Item>> groupByLocation() {
    final Map<String, List<Item>> grouped = {};

    for (final item in _items) {
      if (item.locationId != null) {
        grouped.putIfAbsent(item.locationId!, () => []).add(item);
      }
    }

    return grouped;
  }

  /// Sort items by specified option
  void sortBy(SortOption option) {
    _currentSortOption = option;

    switch (option) {
      case SortOption.nameAsc:
        _items.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameDesc:
        _items.sort((a, b) => b.name.compareTo(a.name));
      case SortOption.dateNewest:
        _items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SortOption.dateOldest:
        _items.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    }

    _filteredItems = List.from(_items);
    notifyListeners();
  }

  /// Apply filters to items
  void applyFilter({String? categoryId, String? locationId}) {
    _filterCategoryId = categoryId;
    _filterLocationId = locationId;

    _filteredItems = List.from(_items);

    if (categoryId != null) {
      _filteredItems = _filteredItems
          .where((item) => item.categoryId == categoryId)
          .toList();
    }

    if (locationId != null) {
      _filteredItems = _filteredItems
          .where((item) => item.locationId == locationId)
          .toList();
    }

    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filterCategoryId = null;
    _filterLocationId = null;
    _filteredItems = List.from(_items);
    notifyListeners();
  }

  /// Refresh items list
  Future<void> refresh() async {
    await loadItems();
  }

  /// Set items (for testing)
  @visibleForTesting
  void setItems(List<Item> items) {
    _items = List.from(items);
    _filteredItems = List.from(items);
    notifyListeners();
  }
}
