import 'package:flutter/foundation.dart' hide Category;
import 'package:home_ai_index/core/utils/cache_manager.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';

/// Sorting options for items
enum SortOption { nameAsc, nameDesc, dateNewest, dateOldest }

/// ViewModel for the Home Screen
///
/// Manages loading and displaying:
/// - Categories grid
/// - Recent items
/// - Locations list
/// - Filtering by category/location
/// - Sorting items
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required LocationRepository locationRepository,
    AppCache? cache,
  }) : _itemRepository = itemRepository,
       _categoryRepository = categoryRepository,
       _locationRepository = locationRepository,
       _cache = cache ?? AppCache();

  final ItemRepository _itemRepository;
  final CategoryRepository _categoryRepository;
  final LocationRepository _locationRepository;
  final AppCache _cache;

  List<Category> _categories = [];
  List<Location> _locations = [];
  List<Item> _recentItems = [];
  List<Item> _filteredItems = [];
  String? _selectedCategoryId;
  String? _selectedLocationId;
  SortOption _currentSortOption = SortOption.dateNewest;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Category> get categories => _categories;
  List<Location> get locations => _locations;
  List<Item> get recentItems => _recentItems;
  List<Item> get filteredItems => _filteredItems;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedLocationId => _selectedLocationId;
  SortOption get currentSortOption => _currentSortOption;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all data (categories, locations, recent items)
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to load from cache first
      final cachedCategories = _cache.getCachedCategories();
      final cachedRecentItems = _cache.getCachedRecentItems();

      if (cachedCategories != null && cachedRecentItems != null) {
        // Use cached data for instant display
        _categories = cachedCategories;
        _recentItems = cachedRecentItems;
        _isLoading = false;
        notifyListeners();
        // Still fetch fresh data in background
      }

      // Load all data in parallel
      final results = await Future.wait([
        _categoryRepository.getCategories(),
        _locationRepository.getLocations(),
        _itemRepository.getItems(),
      ]);

      _categories = results[0] as List<Category>;
      _locations = results[1] as List<Location>;
      final allItems = results[2] as List<Item>;

      // Sort by date and take last 10 items
      allItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _recentItems = allItems.take(10).toList();

      // Cache the results
      _cache.cacheCategories(_categories);
      _cache.cacheRecentItems(_recentItems);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter items by category
  Future<void> filterByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    _selectedLocationId = null; // Clear location filter
    _errorMessage = null;
    notifyListeners();

    try {
      if (categoryId == null) {
        _filteredItems = await _itemRepository.getItems();
      } else {
        _filteredItems = await _itemRepository.getItemsByCategory(categoryId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to filter items: ${e.toString()}';
      _filteredItems = [];
      notifyListeners();
    }
  }

  /// Filter items by location
  Future<void> filterByLocation(String? locationId) async {
    _selectedLocationId = locationId;
    _selectedCategoryId = null; // Clear category filter
    _errorMessage = null;
    notifyListeners();

    try {
      if (locationId == null) {
        _filteredItems = await _itemRepository.getItems();
      } else {
        _filteredItems = await _itemRepository.getItemsByLocation(locationId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to filter items: ${e.toString()}';
      _filteredItems = [];
      notifyListeners();
    }
  }

  /// Sort items by specified option
  void sortItems(SortOption option) {
    _currentSortOption = option;

    switch (option) {
      case SortOption.nameAsc:
        _filteredItems.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameDesc:
        _filteredItems.sort((a, b) => b.name.compareTo(a.name));
      case SortOption.dateNewest:
        _filteredItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SortOption.dateOldest:
        _filteredItems.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    }

    notifyListeners();
  }

  /// Get category by ID
  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get location by ID
  Location? getLocationById(String locationId) {
    try {
      return _locations.firstWhere((l) => l.id == locationId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadData();
  }

  /// Set filtered items (for testing)
  @visibleForTesting
  void setFilteredItems(List<Item> items) {
    _filteredItems = List.from(items);
    notifyListeners();
  }
}
