import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';

/// ViewModel for the Search Screen
///
/// Manages searching items with:
/// - Real-time search with debouncing
/// - Category/location filtering
/// - Search result ranking
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required ItemRepository itemRepository})
    : _itemRepository = itemRepository;

  final ItemRepository _itemRepository;

  List<Item> _searchResults = [];
  List<Item> _filteredResults = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedLocationId;
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  // Getters
  List<Item> get searchResults => _searchResults;
  List<Item> get filteredResults => _filteredResults;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedLocationId => _selectedLocationId;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  /// Search for items by name
  Future<void> search(String query) async {
    _searchQuery = query;
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        // For empty query, get all items
        _searchResults = await _itemRepository.getItems();
      } else {
        // For non-empty query, use search
        _searchResults = await _itemRepository.searchItems(query);
      }

      _applyFilters();
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search items: ${e.toString()}';
      _searchResults = [];
      _filteredResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Search with debouncing (300ms delay)
  void searchWithDebounce(String query) {
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Set up new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      search(query);
    });
  }

  /// Filter search results by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  /// Filter search results by location
  void filterByLocation(String? locationId) {
    _selectedLocationId = locationId;
    _applyFilters();
    notifyListeners();
  }

  /// Apply all active filters
  void _applyFilters() {
    // Start with all search results
    _filteredResults = List.from(_searchResults);

    // Apply category filter if set
    if (_selectedCategoryId != null) {
      _filteredResults = _filteredResults
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    // Apply location filter if set
    if (_selectedLocationId != null) {
      _filteredResults = _filteredResults
          .where((item) => item.locationId == _selectedLocationId)
          .toList();
    }
  }

  /// Clear search query and results
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _filteredResults = [];
    _selectedCategoryId = null;
    _selectedLocationId = null;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
