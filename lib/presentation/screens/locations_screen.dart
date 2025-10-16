import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/location/location_tile.dart';
import 'package:provider/provider.dart';

/// Screen for managing storage locations
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final List<Location> _breadcrumb = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationsViewModel>().loadLocations(rootOnly: true);
    });
  }

  Future<void> _navigateToChildren(Location location) async {
    final viewModel = context.read<LocationsViewModel>();
    await viewModel.loadChildLocations(location.id);

    setState(() {
      _breadcrumb.add(location);
    });
  }

  void _navigateBack() {
    if (_breadcrumb.isEmpty) return;

    final viewModel = context.read<LocationsViewModel>();

    setState(() {
      _breadcrumb.removeLast();
    });

    if (_breadcrumb.isEmpty) {
      viewModel.loadLocations(rootOnly: true);
    } else {
      viewModel.loadChildLocations(_breadcrumb.last.id);
    }
  }

  Future<void> _showCreateDialog({Location? parent}) async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parent == null ? 'Create Location' : 'Create Sublocation'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Location Name',
            hintText: 'e.g., Kitchen, Bedroom',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final viewModel = context.read<LocationsViewModel>();
      await viewModel.createLocation(nameController.text, parent?.id);

      if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }

  Future<void> _showEditDialog(Location location) async {
    final nameController = TextEditingController(text: location.name);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Location'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Location Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final viewModel = context.read<LocationsViewModel>();
      await viewModel.updateLocation(location.id, nameController.text);

      if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }

  Future<void> _showDeleteDialog(Location location) async {
    final viewModel = context.read<LocationsViewModel>();

    // Check if location has items
    final hasItems = await viewModel.checkLocationHasItems(location.id);

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${location.name}"?'),
            if (hasItems) ...[
              const SizedBox(height: 16),
              const Text(
                'This location has items. What would you like to do with them?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (hasItems)
            TextButton(
              onPressed: () => Navigator.pop(context, 'unassign'),
              child: const Text('Unassign Items'),
            ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, hasItems ? 'delete-all' : 'delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(hasItems ? 'Delete All' : 'Delete'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final deleteItems = result == 'delete-all';
      await viewModel.deleteLocation(location.id, deleteItems: deleteItems);

      if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      } else if (mounted) {
        // Show undo snackbar for 30 seconds
        final snackBar = SnackBar(
          content: const Text('Location deleted'),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await viewModel.restoreLocation();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location restored')),
                );
              }
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_breadcrumb.isEmpty ? 'Locations' : _breadcrumb.last.name),
        leading: _breadcrumb.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : null,
      ),
      body: Consumer<LocationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      if (_breadcrumb.isEmpty) {
                        viewModel.loadLocations(rootOnly: true);
                      } else {
                        viewModel.loadChildLocations(_breadcrumb.last.id);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No locations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first location to organize items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: viewModel.locations.length,
            itemBuilder: (context, index) {
              final location = viewModel.locations[index];

              return LocationTile(
                location: location,
                hasChildren: true, // We'd need to check this
                onTap: () => _navigateToChildren(location),
                onEdit: () => _showEditDialog(location),
                onDelete: () => _showDeleteDialog(location),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(
          parent: _breadcrumb.isEmpty ? null : _breadcrumb.last,
        ),
        icon: const Icon(Icons.add),
        label: Text(_breadcrumb.isEmpty ? 'Add Location' : 'Add Sublocation'),
      ),
    );
  }
}
