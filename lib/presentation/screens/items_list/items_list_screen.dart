import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/presentation/viewmodels/home_viewmodel.dart';
import 'package:home_ai_index/presentation/viewmodels/items_list_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/common/empty_state.dart';
import 'package:home_ai_index/presentation/widgets/common/error_message.dart';
import 'package:home_ai_index/presentation/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

/// Items list screen showing filtered and grouped items
class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({
    required this.title,
    this.categoryId,
    this.locationId,
    super.key,
  });

  final String title;
  final String? categoryId;
  final String? locationId;

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  bool _isGrouped = false;
  GroupBy _groupBy = GroupBy.none;
  int _currentPage = 0;
  static const int _pageSize = 50; // Increased from 20 for better performance
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ItemsListViewModel>();
      if (widget.categoryId != null) {
        viewModel.loadItemsByCategory(widget.categoryId!);
      } else if (widget.locationId != null) {
        viewModel.loadItemsByLocation(widget.locationId!);
      } else {
        viewModel.loadItems();
      }
    });

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
      final viewModel = context.read<ItemsListViewModel>();
      if (viewModel.hasNextPage(_currentPage, pageSize: _pageSize)) {
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (option) {
              context.read<ItemsListViewModel>().sortBy(option);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Name A-Z'),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Text('Name Z-A'),
              ),
              const PopupMenuItem(
                value: SortOption.dateNewest,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: SortOption.dateOldest,
                child: Text('Oldest First'),
              ),
            ],
          ),
          PopupMenuButton<GroupBy>(
            icon: const Icon(Icons.category),
            tooltip: 'Group By',
            onSelected: (groupBy) {
              setState(() {
                _groupBy = groupBy;
                _isGrouped = groupBy != GroupBy.none;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GroupBy.none,
                child: Text('No Grouping'),
              ),
              const PopupMenuItem(
                value: GroupBy.category,
                child: Text('Group by Category'),
              ),
              const PopupMenuItem(
                value: GroupBy.location,
                child: Text('Group by Location'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ItemsListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingIndicator(message: 'Loading items...');
          }

          if (viewModel.errorMessage != null) {
            return ErrorMessages.loadFailed(
              resource: 'items',
              onRetry: () {
                if (widget.categoryId != null) {
                  viewModel.loadItemsByCategory(widget.categoryId!);
                } else if (widget.locationId != null) {
                  viewModel.loadItemsByLocation(widget.locationId!);
                } else {
                  viewModel.loadItems();
                }
              },
            );
          }

          if (viewModel.items.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: _isGrouped
                ? _buildGroupedList(context, viewModel)
                : _buildFlatList(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (widget.categoryId != null) {
      return EmptyStates.noCategoryItems(categoryName: widget.title);
    } else if (widget.locationId != null) {
      return EmptyStates.noLocationItems(locationName: widget.title);
    } else {
      return EmptyStates.noItems(
        onAddItem: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add item feature coming soon!')),
          );
        },
      );
    }
  }

  Widget _buildFlatList(BuildContext context, ItemsListViewModel viewModel) {
    // Use lazy loading with scroll controller
    final displayItems = viewModel.getPage(_currentPage, pageSize: _pageSize);

    return ListView.builder(
      controller: _scrollController,
      itemCount: displayItems.length + 1, // +1 for pagination info
      // Performance: Use item extent for better scrolling
      itemExtent: 72.0, // Standard ListTile height
      itemBuilder: (context, index) {
        if (index == displayItems.length) {
          return _buildPaginationFooter(viewModel);
        }
        final item = displayItems[index];
        return _buildItemTile(context, item);
      },
    );
  }

  Widget _buildGroupedList(BuildContext context, ItemsListViewModel viewModel) {
    Map<String, List<Item>> groups;
    if (_groupBy == GroupBy.category) {
      groups = viewModel.groupByCategory();
    } else {
      groups = viewModel.groupByLocation();
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupKey = groups.keys.elementAt(index);
        final items = groups[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    groupKey,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      items.length.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Group items
            ...items.map((item) => _buildItemTile(context, item)),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.inventory_2,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(item.name),
      subtitle: item.notes != null
          ? Text(item.notes!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
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

  Widget _buildPaginationFooter(ItemsListViewModel viewModel) {
    final totalPages = viewModel.getTotalPages();
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          if (_currentPage > 0)
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _currentPage--;
                });
              },
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
          const SizedBox(width: 8),
          if (viewModel.hasNextPage(_currentPage))
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _currentPage++;
                });
              },
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
            ),
        ],
      ),
    );
  }
}

/// Grouping options
enum GroupBy { none, category, location }
