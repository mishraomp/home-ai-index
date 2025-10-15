import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/viewmodels/item_details_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/location_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Screen for viewing and editing item details
///
/// Displays comprehensive item information including:
/// - Basic details (name, quantity, category, location, notes)
/// - Location history timeline
/// - Edit capabilities for all fields
/// - Delete functionality with confirmation
class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({
    required this.categories,
    required this.locations,
    super.key,
  });

  final List<Category> categories;
  final List<Location> locations;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late ItemDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read<ItemDetailsViewModel>();

    // Initialize controllers
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();

    // Load data
    _viewModel.loadItem();
    _viewModel.loadLocationHistory();

    // Listen for item changes
    _viewModel.addListener(_updateControllers);

    // Initialize controllers with current values
    _updateControllers();
  }

  void _updateControllers() {
    final item = _viewModel.item;

    if (item != null) {
      if (_nameController.text != item.name) {
        _nameController.text = item.name;
      }
      if (_quantityController.text != item.quantity.toString()) {
        _quantityController.text = item.quantity.toString();
      }
      if (_notesController.text != (item.notes ?? '')) {
        _notesController.text = item.notes ?? '';
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateControllers);

    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleNameSubmit() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      return;
    }

    await _viewModel.updateItemName(newName);
  }

  Future<void> _handleQuantitySubmit() async {
    final quantityText = _quantityController.text.trim();
    final quantity = int.tryParse(quantityText);

    if (quantity == null || quantity <= 0) {
      return;
    }

    await _viewModel.updateItemQuantity(quantity);
  }

  Future<void> _handleNotesSubmit() async {
    final notes = _notesController.text.trim();

    await _viewModel.updateItemNotes(notes.isEmpty ? null : notes);
  }

  Future<void> _handleCategoryChange(String? categoryId) async {
    if (categoryId == null) return;

    await _viewModel.updateItemCategory(categoryId);
  }

  Future<void> _handleLocationChange() async {
    final currentLocationId = _viewModel.item?.locationId;

    final selectedLocationId = await showDialog<String>(
      context: context,
      builder: (context) => LocationPickerDialog(
        locations: widget.locations,
        selectedLocationId: currentLocationId,
      ),
    );

    if (selectedLocationId != null) {
      await _viewModel.updateItemLocation(selectedLocationId);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _viewModel.deleteItem();

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemDetailsViewModel>(
      builder: (context, viewModel, child) {
        // Show error snackbar
        if (viewModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: viewModel.clearError,
                  ),
                ),
              );
            }
          });
        }

        // Show loading indicator
        if (viewModel.isLoading || viewModel.item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Item Details')),
            body: viewModel.errorMessage != null
                ? Center(child: Text(viewModel.errorMessage!))
                : const Center(child: CircularProgressIndicator()),
          );
        }

        final item = viewModel.item!;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _handleDelete,
                tooltip: 'Delete Item',
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleNameSubmit(),
                  ),
                  const SizedBox(height: 16),

                  // Quantity field
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleQuantitySubmit(),
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: item.categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: _handleCategoryChange,
                  ),
                  const SizedBox(height: 16),

                  // Location section
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.getLocationName(item.locationId),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _handleLocationChange,
                        child: const Text('Change Location'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    onFieldSubmitted: (_) => _handleNotesSubmit(),
                  ),
                  const SizedBox(height: 24),

                  // Location History section
                  const Text(
                    'Location History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (viewModel.locationHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No location history',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.locationHistory.length,
                      itemBuilder: (context, index) {
                        final history = viewModel.locationHistory[index];
                        final locationName = viewModel.getLocationName(
                          history.locationId,
                        );
                        final formattedDate = DateFormat.yMMMd()
                            .add_jm()
                            .format(history.timestamp);

                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(locationName),
                          subtitle: Text(formattedDate),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
