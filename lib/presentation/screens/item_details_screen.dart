import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/item_details_viewmodel.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({
    super.key,
    required this.itemId,
    required this.itemRepository,
    required this.locationHistoryRepository,
    required this.categoryRepository,
    required this.locationRepository,
  });

  final String itemId;
  final ItemRepository itemRepository;
  final LocationHistoryRepository locationHistoryRepository;
  final CategoryRepository categoryRepository;
  final LocationRepository locationRepository;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool _hasChanges = false;

  void _handleBack() {
    if (_hasChanges) {
      context.pop(true);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ItemDetailsViewModel(
              itemId: widget.itemId,
              itemRepository: widget.itemRepository,
              locationHistoryRepository: widget.locationHistoryRepository,
              categoryRepository: widget.categoryRepository,
              locationRepository: widget.locationRepository,
            )
            ..loadItem()
            ..loadLocationHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          actions: [
            // Edit button
            Consumer<ItemDetailsViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: viewModel.item != null
                      ? () => _showEditDialog(context, viewModel)
                      : null,
                  tooltip: 'Edit Item',
                );
              },
            ),
            // Delete button
            Consumer<ItemDetailsViewModel>(
              builder: (context, viewModel, _) {
                return IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: viewModel.item != null
                      ? () => _showDeleteDialog(context, viewModel)
                      : null,
                  tooltip: 'Delete Item',
                );
              },
            ),
          ],
        ),
        body: Consumer<ItemDetailsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.item == null) {
              return const Center(child: Text('Item not found'));
            }
            final item = viewModel.item!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  if (item.imagePath != null && item.imagePath!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(item.imagePath!),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (item.imagePath != null && item.imagePath!.isNotEmpty)
                    const SizedBox(height: 24),

                  // Item name
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Card
                  _buildInfoCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Quantity',
                    value: '${item.quantity}',
                  ),
                  const SizedBox(height: 12),

                  // Category Card
                  FutureBuilder(
                    future: Provider.of<CategoryRepository>(
                      context,
                      listen: false,
                    ).getCategoryById(item.categoryId),
                    builder: (context, snapshot) {
                      final categoryName = snapshot.data?.name ?? 'Unknown';
                      return _buildInfoCard(
                        context,
                        icon: Icons.category,
                        title: 'Category',
                        value: categoryName,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Location Card
                  if (item.locationId != null)
                    FutureBuilder(
                      future: Provider.of<LocationRepository>(
                        context,
                        listen: false,
                      ).getLocationById(item.locationId!),
                      builder: (context, snapshot) {
                        final locationName = snapshot.data?.name ?? 'Unknown';
                        return _buildInfoCard(
                          context,
                          icon: Icons.place,
                          title: 'Location',
                          value: locationName,
                        );
                      },
                    ),
                  if (item.locationId != null) const SizedBox(height: 12),

                  // Notes
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    _buildInfoCard(
                      context,
                      icon: Icons.notes,
                      title: 'Notes',
                      value: item.notes!,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Expiration Date
                  if (item.expirationDate != null) ...[
                    _buildInfoCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Expiration Date',
                      value: _formatDate(item.expirationDate!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Added date
                  _buildInfoCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Added',
                    value: _formatDate(item.addedAt),
                  ),

                  // Location History Section
                  if (viewModel.locationHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Location History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...viewModel.locationHistory.map((history) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FutureBuilder(
                          future: Provider.of<LocationRepository>(
                            context,
                            listen: false,
                          ).getLocationById(history.locationId),
                          builder: (context, snapshot) {
                            final locationName =
                                snapshot.data?.name ?? 'Unknown';
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(locationName),
                                subtitle: Text(
                                  'Moved: ${_formatDate(history.timestamp)}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Show edit dialog
  Future<void> _showEditDialog(
    BuildContext context,
    ItemDetailsViewModel viewModel,
  ) async {
    final item = viewModel.item;
    if (item == null) return;

    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final notesController = TextEditingController(text: item.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final name = nameController.text.trim();
      final quantity = int.tryParse(quantityController.text) ?? 1;
      final notes = notesController.text.trim();

      // Update item fields
      await viewModel.updateItemName(name);
      await viewModel.updateItemQuantity(quantity);
      await viewModel.updateItemNotes(notes.isEmpty ? null : notes);

      // Mark that changes were made
      _hasChanges = true;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
      }
    }

    nameController.dispose();
    quantityController.dispose();
    notesController.dispose();
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteDialog(
    BuildContext context,
    ItemDetailsViewModel viewModel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final success = await viewModel.deleteItem();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate back to home screen with result=true to trigger refresh
        context.pop(true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to delete item'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
