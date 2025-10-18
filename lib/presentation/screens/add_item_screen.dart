import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/presentation/viewmodels/add_item_viewmodel.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:home_ai_index/presentation/widgets/location/location_picker.dart';
import 'package:home_ai_index/presentation/widgets/quota_warning_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Screen for adding new items with image recognition
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AddItemViewModel>();
      // Reset form to clear any previous state
      viewModel.reset();
      // Load fresh categories from database
      viewModel.loadCategories();
      // Clear text controllers
      _nameController.clear();
      _notesController.clear();
      _quantityController.text = '1';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Settings',
            onPressed: () async {
              final viewModel = context.read<AddItemViewModel>();
              await context.push('/settings');

              if (mounted) {
                // Reload fresh data from database when returning
                viewModel.reset();
                unawaited(viewModel.loadCategories());
                unawaited(viewModel.refreshCredentialsStatus());

                // Clear text controllers
                _nameController.clear();
                _notesController.clear();
                _quantityController.text = '1';
              }
            },
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveItem),
        ],
      ),
      body: Consumer<AddItemViewModel>(
        builder: (context, viewModel, child) {
          // Show quota warning dialog if pending
          if (viewModel.pendingQuotaWarning != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final warning = viewModel.pendingQuotaWarning;
              if (warning != null) {
                final shouldProceed = await QuotaWarningDialog.show(
                  context,
                  warning,
                );

                if (mounted) {
                  if (shouldProceed) {
                    unawaited(viewModel.confirmQuotaAndRecognize());
                  } else {
                    viewModel.cancelQuotaWarning();
                  }
                }
              }
            });
          }

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(viewModel),
                  const SizedBox(height: 24),
                  _buildRecognitionResult(viewModel),
                  const SizedBox(height: 24),
                  _buildNameField(viewModel),
                  const SizedBox(height: 16),
                  _buildCategoryField(viewModel),
                  const SizedBox(height: 16),
                  _buildLocationField(viewModel),
                  const SizedBox(height: 16),
                  _buildQuantityField(viewModel),
                  const SizedBox(height: 16),
                  _buildNotesField(viewModel),
                  const SizedBox(height: 24),
                  _buildSaveButton(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(AddItemViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.selectedImagePath != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(viewModel.selectedImagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, viewModel),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, viewModel),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecognitionResult(AddItemViewModel viewModel) {
    return Column(
      children: [
        // Loading indicator during recognition
        if (viewModel.recognitionState == RecognitionState.recognizing)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Recognizing image...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

        // No API credentials warning
        if (!viewModel.hasApiCredentials &&
            viewModel.recognitionState == RecognitionState.idle &&
            viewModel.selectedImagePath == null)
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No API Key Configured',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Using offline recognition only. Add a Cloud Vision API key for better accuracy.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.orange[900]),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings').then((_) {
                          // Refresh credentials status after returning
                          viewModel.refreshCredentialsStatus();
                        });
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Error state with retry button
        if (viewModel.recognitionState == RecognitionState.error)
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Recognition Failed',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.red[900]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.retryRecognition,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Recognition'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Success state with results
        if (viewModel.recognitionState == RecognitionState.success &&
            viewModel.recognitionResult != null)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with recognition source badge
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Recognition',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      // Recognition source badge
                      Chip(
                        avatar: Icon(
                          viewModel.usedOnlineRecognition
                              ? Icons.cloud_done
                              : Icons.offline_bolt,
                          size: 16,
                        ),
                        label: Text(
                          viewModel.recognitionSource,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: viewModel.usedOnlineRecognition
                            ? Colors.blue[50]
                            : Colors.grey[200],
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Detected label
                  Text(
                    'Detected: ${viewModel.recognitionResult!.label}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confidence badge with color coding
                  if (viewModel.confidence != null)
                    Chip(
                      avatar: Icon(
                        viewModel.isLowConfidence
                            ? Icons.warning_amber
                            : Icons.check_circle,
                        color: viewModel.isLowConfidence
                            ? Colors.orange
                            : Colors.green,
                        size: 18,
                      ),
                      label: Text(
                        '${(viewModel.confidence! * 100).toInt()}% match',
                        style: TextStyle(
                          color: viewModel.isLowConfidence
                              ? Colors.orange[900]
                              : Colors.green[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: viewModel.isLowConfidence
                          ? Colors.orange[50]
                          : Colors.green[50],
                    ),

                  // Alternative labels for low confidence
                  if (viewModel.isLowConfidence &&
                      viewModel.alternativeLabels.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Did you mean:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: viewModel.alternativeLabels
                          .take(5)
                          .map(
                            (label) => ActionChip(
                              label: Text(label),
                              onPressed: () {
                                viewModel.setName(label);
                              },
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameField(AddItemViewModel viewModel) {
    // Sync controller with viewModel
    if (_nameController.text != viewModel.name) {
      _nameController.text = viewModel.name;
    }

    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Item Name *',
        hintText: 'Enter item name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Item name is required';
        }
        return null;
      },
      onChanged: (value) => viewModel.setName(value),
    );
  }

  Widget _buildCategoryField(AddItemViewModel viewModel) {
    return DropdownButtonFormField<String>(
      initialValue: viewModel.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(),
      ),
      items: viewModel.categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Icon(
                IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              ),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Category is required';
        }
        return null;
      },
      onChanged: (value) {
        if (value != null) {
          viewModel.setCategory(value);
        }
      },
    );
  }

  Widget _buildLocationField(AddItemViewModel viewModel) {
    return InkWell(
      onTap: () async {
        final selectedLocation = await showDialog<Location?>(
          context: context,
          builder: (context) => ChangeNotifierProvider(
            create: (_) =>
                LocationsViewModel(locationRepository: context.read())
                  ..loadLocations(),
            child: const LocationPicker(),
          ),
        );
        if (selectedLocation != null) {
          viewModel.setLocation(selectedLocation.id);
        } else {
          // User selected "No location"
          viewModel.setLocation(null);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Location',
          hintText: 'Tap to select location',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.place_outlined),
        ),
        child: Text(
          viewModel.selectedLocation ?? 'No location selected',
          style: TextStyle(
            color: viewModel.selectedLocation == null
                ? Theme.of(context).hintColor
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityField(AddItemViewModel viewModel) {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Quantity is required';
        }
        final quantity = int.tryParse(value);
        if (quantity == null || quantity < 1) {
          return 'Quantity must be at least 1';
        }
        return null;
      },
      onChanged: (value) {
        final quantity = int.tryParse(value);
        if (quantity != null) {
          viewModel.setQuantity(quantity);
        }
      },
    );
  }

  Widget _buildNotesField(AddItemViewModel viewModel) {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => viewModel.setNotes(value),
    );
  }

  Widget _buildSaveButton(AddItemViewModel viewModel) {
    return FilledButton.icon(
      onPressed: viewModel.isLoading ? null : _saveItem,
      icon: const Icon(Icons.save),
      label: const Text('Save Item'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    AddItemViewModel viewModel,
  ) async {
    await viewModel.pickImage(source);
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<AddItemViewModel>();
    final success = await viewModel.saveItem();

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item saved successfully')));
    }
  }
}
