import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/search_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/common/empty_state.dart';
import 'package:home_ai_index/presentation/widgets/common/error_message.dart';
import 'package:home_ai_index/presentation/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

/// Search screen for finding items by name, category, and location
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Category? _selectedCategory;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to show/hide clear button
    });
    final viewModel = context.read<SearchViewModel>();
    viewModel.searchWithDebounce(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
            onPressed: () => _showFiltersSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchViewModel>().clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                context.read<SearchViewModel>().search(value);
              },
            ),
          ),

          // Active filters
          if (_selectedCategory != null || _selectedLocation != null)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedCategory!.name),
                        avatar: Icon(
                          IconData(
                            _selectedCategory!.iconCodePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 18,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                          context.read<SearchViewModel>().filterByCategory(
                            null,
                          );
                        },
                      ),
                    ),
                  if (_selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedLocation!.name),
                        avatar: const Icon(Icons.location_on, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedLocation = null;
                          });
                          context.read<SearchViewModel>().filterByLocation(
                            null,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isSearching) {
                  return const LoadingIndicator(message: 'Searching...');
                }

                if (viewModel.errorMessage != null) {
                  return ErrorMessages.loadFailed(
                    resource: 'search results',
                    onRetry: () => viewModel.search(_searchController.text),
                  );
                }

                // Always use filteredResults (includes both filtered and unfiltered results)
                final results = viewModel.filteredResults;

                if (results.isEmpty) {
                  return EmptyStates.noSearchResults(
                    query: _searchController.text.isEmpty
                        ? 'items'
                        : _searchController.text,
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return _buildSearchResultTile(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(BuildContext context, Item item) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: const Icon(Icons.inventory_2),
      ),
      title: Text(item.name),
      subtitle: Text(
        item.notes ?? 'No notes',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: item.quantity > 1
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '×${item.quantity}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        // TODO: Navigate to item details screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View details for ${item.name}')),
        );
      },
    );
  }

  void _showFiltersSheet(BuildContext context) {
    final viewModel = context.read<SearchViewModel>();

    showModalBottomSheet(
      context: context,
      builder: (context) => _FiltersSheet(
        viewModel: viewModel,
        selectedCategory: _selectedCategory,
        selectedLocation: _selectedLocation,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          viewModel.filterByCategory(category?.id);
        },
        onLocationSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          viewModel.filterByLocation(location?.id);
        },
      ),
    );
  }
}

/// Bottom sheet for search filters
class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.viewModel,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.onCategorySelected,
    required this.onLocationSelected,
  });

  final SearchViewModel viewModel;
  final Category? selectedCategory;
  final Location? selectedLocation;
  final ValueChanged<Category?> onCategorySelected;
  final ValueChanged<Location?> onLocationSelected;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  List<Category> _categories = [];
  List<Location> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final categoryRepo = context.read<CategoryRepository>();
      final locationRepo = context.read<LocationRepository>();

      final categories = await categoryRepo.getCategories();
      final locations = await locationRepo.getLocations();

      setState(() {
        _categories = categories;
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Filters', style: theme.textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () {
                  widget.onCategorySelected(null);
                  widget.onLocationSelected(null);
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category filter
          Text('Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: widget.selectedCategory == null,
                          onSelected: (_) {
                            widget.onCategorySelected(null);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ..._categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category.name),
                            avatar: Icon(
                              IconData(
                                category.iconCodePoint,
                                fontFamily: 'MaterialIcons',
                              ),
                              size: 18,
                            ),
                            selected:
                                widget.selectedCategory?.id == category.id,
                            onSelected: (_) {
                              widget.onCategorySelected(category);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // Location filter
          Text('Location', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: widget.selectedLocation == null,
                          onSelected: (_) {
                            widget.onLocationSelected(null);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ..._locations.map((location) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(location.name),
                            avatar: const Icon(Icons.location_on, size: 18),
                            selected:
                                widget.selectedLocation?.id == location.id,
                            onSelected: (_) {
                              widget.onLocationSelected(location);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
