import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/screens/add_item_screen.dart';
import 'package:home_ai_index/presentation/viewmodels/bulk_actions_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/item/item_card.dart';
import 'package:home_ai_index/presentation/widgets/location_picker_dialog.dart';
import 'package:provider/provider.dart';

/// Home screen displaying the inventory list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<dynamic> _items = [];
  Map<String, Category> _categoriesMap = {};
  String? _errorMessage;

  // Bulk selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _enterSelectionMode(String itemId) {
    setState(() {
      _isSelectionMode = true;
      _selectedItemIds.add(itemId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItemIds.clear();
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
        // Exit selection mode if no items selected
        if (_selectedItemIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedItemIds.addAll(_items.map((item) => item.id as String));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedItemIds.clear();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final itemRepo = context.read<ItemRepository>();
      final categoryRepo = context.read<CategoryRepository>();

      // Load categories first
      final categories = await categoryRepo.getCategories();
      _categoriesMap = {for (final c in categories) c.id: c};

      // Load items
      final items = await itemRepo.getItems();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: _buildBody(),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _navigateToAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
      bottomNavigationBar: _isSelectionMode ? _buildBulkActionsBar() : null,
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('Home AI Index'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text('${_selectedItemIds.length} selected'),
      actions: [
        if (_selectedItemIds.length < _items.length)
          TextButton(onPressed: _selectAll, child: const Text('Select All'))
        else
          TextButton(
            onPressed: _deselectAll,
            child: const Text('Deselect All'),
          ),
      ],
    );
  }

  Widget _buildBulkActionsBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _selectedItemIds.isEmpty
                    ? null
                    : _showBulkMoveDialog,
                icon: const Icon(Icons.drive_file_move),
                label: const Text('Move To...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBulkMoveDialog() async {
    // Create BulkActionsViewModel
    final bulkViewModel = BulkActionsViewModel(
      itemRepository: context.read<ItemRepository>(),
      locationRepository: context.read<LocationRepository>(),
      locationHistoryRepository: context.read<LocationHistoryRepository>(),
    );

    // Get all locations
    final locationRepo = context.read<LocationRepository>();
    final locations = await locationRepo.getLocations();

    if (!mounted) return;

    // Show location picker
    final selectedLocationId = await showDialog<String?>(
      context: context,
      builder: (context) =>
          LocationPickerDialog(locations: locations, selectedLocationId: null),
    );

    if (selectedLocationId == null && !mounted) return;

    // Perform bulk move
    if (mounted) {
      await bulkViewModel.moveSelectedItems(
        _selectedItemIds.toList(),
        selectedLocationId,
      );

      if (!mounted) return;

      // Check for errors
      if (bulkViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bulkViewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        // Success - show message and refresh
        final count = _selectedItemIds.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully moved $count item${count > 1 ? 's' : ''}',
            ),
          ),
        );

        // Exit selection mode and reload data
        _exitSelectionMode();
        _loadData();
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No items yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your first item',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final category = _categoriesMap[item.categoryId];
          final isSelected = _selectedItemIds.contains(item.id);

          return ItemCard(
            item: item,
            categoryName: category?.name ?? 'Unknown',
            categoryIcon: category != null
                ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
                : Icons.help_outline,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleItemSelection(item.id);
              } else {
                // TODO: Navigate to item details
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _enterSelectionMode(item.id);
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddItem() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );

    if (result == true) {
      // Reload items after adding
      _loadData();
    }
  }
}
