import 'dart:typed_data';

import 'package:flutter/foundation.dart' hide Category;
import 'package:image_picker/image_picker.dart';

import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/core/utils/validators.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/image_recognition_result.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/image_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/services/image_recognition_service.dart';

/// ViewModel for adding new items with image recognition
class AddItemViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  final CategoryRepository _categoryRepository;
  final ImageRepository _imageRepository;
  final ImageRecognitionService _recognitionService;
  final ImagePicker _imagePicker;

  AddItemViewModel({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required ImageRepository imageRepository,
    required ImageRecognitionService recognitionService,
    ImagePicker? imagePicker,
  })  : _itemRepository = itemRepository,
        _categoryRepository = categoryRepository,
        _imageRepository = imageRepository,
        _recognitionService = recognitionService,
        _imagePicker = imagePicker ?? ImagePicker();

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedImagePath;
  ImageRecognitionResult? _recognitionResult;
  List<Category> _categories = [];

  // Form fields
  String _name = '';
  String? _selectedCategory;
  String? _selectedLocation;
  int _quantity = 1;
  String _notes = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedImagePath => _selectedImagePath;
  ImageRecognitionResult? get recognitionResult => _recognitionResult;
  List<Category> get categories => _categories;
  
  String get name => _name;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  int get quantity => _quantity;
  String get notes => _notes;

  String get suggestedName => _recognitionResult?.label ?? '';
  String? get suggestedCategory => _recognitionResult?.suggestedCategory;

  /// Load available categories
  Future<void> loadCategories() async {
    try {
      _categories = await _categoryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  /// Pick an image from camera or gallery and recognize it
  Future<void> pickImage(ImageSource source) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) {
        _setLoading(false);
        return; // User canceled
      }

      // Read image bytes
      final imageBytes = await pickedFile.readAsBytes();

      // Generate a temporary ID for the image (will be replaced with actual item ID later)
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Save image
      final savedPath = await _imageRepository.saveImage(imageBytes, tempId);
      _selectedImagePath = savedPath;

      // Recognize image
      await recognizeImage(imageBytes);

      _setLoading(false);
    } on app_exceptions.ImageProcessingException catch (e) {
      _errorMessage = 'Failed to process image: ${e.message}';
      _selectedImagePath = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      _selectedImagePath = null;
      _setLoading(false);
    }
  }

  /// Recognize an image and update suggestions
  Future<void> recognizeImage(Uint8List imageBytes) async {
    try {
      final result = await _recognitionService.classifyImage(imageBytes);
      _recognitionResult = result;
      
      // Update suggestions
      if (_name.isEmpty) {
        _name = result.label;
      }
      if (_selectedCategory == null) {
        _selectedCategory = result.suggestedCategory;
      }
      
      notifyListeners();
    } on app_exceptions.ModelNotInitializedException catch (e) {
      _errorMessage = 'Recognition failed: ${e.message}';
      _recognitionResult = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Recognition failed: $e';
      _recognitionResult = null;
      notifyListeners();
    }
  }

  /// Save the item to the repository
  Future<bool> saveItem() async {
    try {
      _errorMessage = null;

      // Validate required fields
      final nameError = validateItemName(_name);
      if (nameError != null) {
        _errorMessage = nameError;
        notifyListeners();
        return false;
      }

      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        _errorMessage = 'Please select a category';
        notifyListeners();
        return false;
      }

      if (_selectedLocation == null || _selectedLocation!.isEmpty) {
        _errorMessage = 'Please select a location';
        notifyListeners();
        return false;
      }

      _setLoading(true);

      final now = DateTime.now();

      // Create item
      final item = Item(
        id: '', // Will be generated by repository
        name: _name.trim(),
        categoryId: _selectedCategory!,
        locationId: _selectedLocation!,
        quantity: _quantity,
        imagePath: _selectedImagePath,
        notes: _notes.isNotEmpty ? _notes : null,
        addedAt: now,
        updatedAt: now,
      );

      await _itemRepository.createItem(item);

      _setLoading(false);
      return true;
    } on app_exceptions.ValidationException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } on app_exceptions.DatabaseException catch (e) {
      _errorMessage = 'Failed to save item: ${e.message}';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Failed to save item: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Field setters
  void setName(String value) {
    _name = value;
    _clearError();
    notifyListeners();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    _clearError();
    notifyListeners();
  }

  void setLocation(String value) {
    _selectedLocation = value;
    _clearError();
    notifyListeners();
  }

  void setQuantity(int value) {
    _quantity = value;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  void setSelectedImagePath(String? value) {
    _selectedImagePath = value;
    notifyListeners();
  }

  void setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  /// Reset the form to initial state
  void reset() {
    _name = '';
    _selectedCategory = null;
    _selectedLocation = null;
    _quantity = 1;
    _notes = '';
    _selectedImagePath = null;
    _recognitionResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
