import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/location.dart';

/// Dialog for selecting a location from a hierarchical list
///
/// Displays locations in a tree structure and allows user to:
/// - Select a location
/// - Clear location (set to null)
/// - Cancel selection
class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({
    required this.locations,
    this.selectedLocationId,
    super.key,
  });

  final List<Location> locations;
  final String? selectedLocationId;

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _selectedLocationId = widget.selectedLocationId;
  }

  void _handleLocationTap(String? locationId) {
    setState(() {
      _selectedLocationId = locationId;
    });
    Navigator.of(context).pop(locationId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Unlocated option
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Unlocated'),
              trailing: _selectedLocationId == null
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _handleLocationTap(null),
            ),
            const Divider(),
            // Locations list
            ...widget.locations.map((location) {
              final isSelected = _selectedLocationId == location.id;
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => _handleLocationTap(location.id),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
