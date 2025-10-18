import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:provider/provider.dart';

/// Dialog widget for selecting a location
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.initialLocation,
    this.allowNone = true,
  });

  final Location? initialLocation;
  final bool allowNone;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  Location? _selectedLocation;
  final List<Location> _breadcrumb = [];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;

    // Load initial locations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LocationsViewModel>();
      viewModel.loadLocations(rootOnly: true);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                if (_breadcrumb.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _navigateBack,
                  ),
                Expanded(
                  child: Text(
                    _breadcrumb.isEmpty
                        ? 'Select Location'
                        : _breadcrumb.last.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Breadcrumb
            if (_breadcrumb.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < _breadcrumb.length; i++) ...[
                      if (i > 0) const Icon(Icons.chevron_right, size: 16),
                      TextButton(
                        onPressed: () {
                          // Navigate to this level
                          while (_breadcrumb.length > i + 1) {
                            _breadcrumb.removeLast();
                          }
                          if (_breadcrumb.isEmpty) {
                            context.read<LocationsViewModel>().loadLocations(
                              rootOnly: true,
                            );
                          } else {
                            context
                                .read<LocationsViewModel>()
                                .loadChildLocations(_breadcrumb.last.id);
                          }
                          setState(() {});
                        },
                        child: Text(_breadcrumb[i].name),
                      ),
                    ],
                  ],
                ),
              ),

            const Divider(),

            // "None" option
            if (widget.allowNone)
              ListTile(
                leading: Icon(
                  Icons.not_listed_location_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('No Location'),
                trailing: _selectedLocation == null
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedLocation = null);
                },
              ),

            const Divider(),

            // Location list
            Expanded(
              child: Consumer<LocationsViewModel>(
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
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_breadcrumb.isEmpty) {
                                viewModel.loadLocations(rootOnly: true);
                              } else {
                                viewModel.loadChildLocations(
                                  _breadcrumb.last.id,
                                );
                              }
                            },
                            child: const Text('Retry'),
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
                            Icons.folder_off_outlined,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No locations found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: viewModel.locations.length,
                    itemBuilder: (context, index) {
                      final location = viewModel.locations[index];
                      final isSelected = _selectedLocation?.id == location.id;

                      return ListTile(
                        leading: Icon(
                          Icons.place_outlined,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(location.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _navigateToChildren(location),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() => _selectedLocation = location);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _selectedLocation),
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
