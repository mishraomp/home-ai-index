import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/presentation/viewmodels/add_item_viewmodel.dart';

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
      context.read<AddItemViewModel>().loadCategories();
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
            icon: const Icon(Icons.check),
            onPressed: _saveItem,
          ),
        ],
      ),
      body: Consumer<AddItemViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        viewModel.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
    final result = viewModel.recognitionResult;
    if (result == null) return const SizedBox.shrink();

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Recognition',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Detected: ${result.label}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
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
      value: viewModel.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(),
      ),
      items: viewModel.categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')),
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
    return TextFormField(
      initialValue: viewModel.selectedLocation,
      decoration: const InputDecoration(
        labelText: 'Location *',
        hintText: 'e.g., Kitchen, Bedroom',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Location is required';
        }
        return null;
      },
      onChanged: (value) => viewModel.setLocation(value),
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

  Future<void> _pickImage(ImageSource source, AddItemViewModel viewModel) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved successfully')),
      );
    }
  }
}
