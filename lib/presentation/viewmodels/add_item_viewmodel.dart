import 'package:flutter/foundation.dart' hide Category;
import 'package:home_ai_index/core/exceptions.dart' as app_exceptions;
import 'package:home_ai_index/core/utils/validators.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/image_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/services/api_credentials_manager.dart';
import 'package:home_ai_index/data/services/api_quota_manager.dart';
import 'package:home_ai_index/data/services/recognition_service.dart';
import 'package:image_picker/image_picker.dart';

/// Recognition state for UI feedback
enum RecognitionState { idle, recognizing, success, error }

/// ViewModel for adding new items with image recognition
class AddItemViewModel extends ChangeNotifier {
  AddItemViewModel({
    required ItemRepository itemRepository,
    required CategoryRepository categoryRepository,
    required ImageRepository imageRepository,
    required RecognitionService recognitionService,
    APICredentialsManager? credentialsManager,
    APIQuotaManager? quotaManager,
    ImagePicker? imagePicker,
  }) : _itemRepository = itemRepository,
       _categoryRepository = categoryRepository,
       _imageRepository = imageRepository,
       _recognitionService = recognitionService,
       _credentialsManager = credentialsManager ?? APICredentialsManager(),
       _quotaManager = quotaManager,
       _imagePicker = imagePicker ?? ImagePicker() {
    _checkCredentials();
  }

  final ItemRepository _itemRepository;
  final CategoryRepository _categoryRepository;
  final ImageRepository _imageRepository;
  final RecognitionService _recognitionService;
  final APICredentialsManager _credentialsManager;
  final APIQuotaManager? _quotaManager;
  final ImagePicker _imagePicker;

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedImagePath;
  Uint8List? _currentImageBytes; // Store for retry
  RecognitionResult? _recognitionResult;
  List<Category> _categories = [];
  RecognitionState _recognitionState = RecognitionState.idle;
  bool _hasApiCredentials = false;
  bool _usedOnlineRecognition = false;
  QuotaWarning? _pendingQuotaWarning; // Quota warning to display to user

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
  RecognitionResult? get recognitionResult => _recognitionResult;
  List<Category> get categories => _categories;
  RecognitionState get recognitionState => _recognitionState;
  bool get hasApiCredentials => _hasApiCredentials;
  bool get usedOnlineRecognition => _usedOnlineRecognition;
  QuotaWarning? get pendingQuotaWarning => _pendingQuotaWarning;

  String get name => _name;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  int get quantity => _quantity;
  String get notes => _notes;

  String get suggestedName => _recognitionResult?.label ?? '';
  String? get suggestedCategory => _recognitionResult?.category;

  // New getters for enhanced UI
  double? get confidence => _recognitionResult?.confidence;
  List<String> get alternativeLabels =>
      _recognitionResult?.alternativeLabels ?? [];

  bool get isLowConfidence => (confidence ?? 0) < 0.7;
  String get recognitionSource =>
      _usedOnlineRecognition ? 'Cloud Vision' : 'Offline';

  Future<void> _checkCredentials() async {
    _hasApiCredentials = await _credentialsManager.hasValidCredentials();
    notifyListeners();
  }

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

  /// Safely set category from recognition result, only if it exists in loaded categories
  void _setSuggestedCategory(String? categoryId) {
    if (categoryId == null || _selectedCategory != null) return;

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🏷️  CATEGORY VALIDATION');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('Suggested Category ID: "$categoryId"');
    debugPrint('Available Categories (${_categories.length}):');
    for (final cat in _categories) {
      debugPrint('  - ${cat.id}: ${cat.name}');
    }

    final categoryExists = _categories.any((cat) => cat.id == categoryId);
    debugPrint('Category Exists: $categoryExists');

    if (categoryExists) {
      _selectedCategory = categoryId;
      final categoryName = _categories
          .firstWhere((cat) => cat.id == categoryId)
          .name;
      debugPrint('✅ Category Set: "$categoryId" ($categoryName)');
    } else {
      debugPrint('❌ Category NOT Set: "$categoryId" not found in categories');
    }
    debugPrint('═══════════════════════════════════════════════════════\n');
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
      _currentImageBytes = imageBytes; // Store for retry

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
    _recognitionState = RecognitionState.recognizing;
    _errorMessage = null;
    _pendingQuotaWarning = null;
    notifyListeners();

    try {
      // Load API credentials
      final credentials = await _credentialsManager.load();

      // Check quota before making API call
      if (_quotaManager != null &&
          credentials != null &&
          credentials.isValid()) {
        final warning = await _quotaManager.shouldWarnUser();
        if (warning != null) {
          // Set pending warning and pause recognition
          _pendingQuotaWarning = warning;
          _recognitionState = RecognitionState.idle;
          notifyListeners();
          return; // Wait for user decision via confirmQuotaAndRecognize()
        }
      }

      // Set credentials in recognition service if available
      if (credentials != null && credentials.isValid()) {
        _recognitionService.setCredentials(credentials);
      }

      // Perform recognition
      final result = await _recognitionService.recognizeImage(imageBytes);
      _recognitionResult = result;

      // Track if we used online recognition
      _usedOnlineRecognition = result.source == RecognitionSource.cloudVision;
      _recognitionState = RecognitionState.success;

      // Update suggestions
      if (_name.isEmpty) {
        _name = result.label;
      }
      _setSuggestedCategory(result.category);

      notifyListeners();
    } on app_exceptions.AuthenticationException catch (e) {
      _errorMessage =
          'Authentication failed: ${e.message}. Please check your API key in Settings.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.QuotaExceededException catch (e) {
      _errorMessage =
          'API quota exceeded: ${e.message}. Using offline recognition.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.NetworkException catch (e) {
      _errorMessage = 'Network error: ${e.message}. Using offline recognition.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.ModelNotInitializedException catch (e) {
      _errorMessage = 'Recognition failed: ${e.message}';
      _recognitionState = RecognitionState.error;
      _recognitionResult = null;
      _usedOnlineRecognition = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Recognition failed: $e';
      _recognitionState = RecognitionState.error;
      _recognitionResult = null;
      _usedOnlineRecognition = false;
      notifyListeners();
    }
  }

  /// Retry recognition on the current image
  Future<void> retryRecognition() async {
    if (_currentImageBytes != null) {
      await recognizeImage(_currentImageBytes!);
    } else {
      _errorMessage = 'No image available to retry';
      notifyListeners();
    }
  }

  /// User confirmed to proceed with API call despite quota warning
  Future<void> confirmQuotaAndRecognize() async {
    if (_currentImageBytes == null) {
      _errorMessage = 'No image available to recognize';
      notifyListeners();
      return;
    }

    // Clear the warning and proceed with recognition
    _pendingQuotaWarning = null;
    _recognitionState = RecognitionState.recognizing;
    notifyListeners();

    try {
      // Load API credentials
      final credentials = await _credentialsManager.load();

      // Set credentials in recognition service if available
      if (credentials != null && credentials.isValid()) {
        _recognitionService.setCredentials(credentials);
      }

      // Perform recognition (skip quota check since user already confirmed)
      final result = await _recognitionService.recognizeImage(
        _currentImageBytes!,
      );
      _recognitionResult = result;

      // Track if we used online recognition
      _usedOnlineRecognition = result.source == RecognitionSource.cloudVision;
      _recognitionState = RecognitionState.success;

      // Update suggestions
      if (_name.isEmpty) {
        _name = result.label;
      }
      _setSuggestedCategory(result.category);

      notifyListeners();
    } on app_exceptions.AuthenticationException catch (e) {
      _errorMessage =
          'Authentication failed: ${e.message}. Please check your API key in Settings.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.QuotaExceededException catch (e) {
      _errorMessage =
          'API quota exceeded: ${e.message}. Using offline recognition.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.NetworkException catch (e) {
      _errorMessage = 'Network error: ${e.message}. Using offline recognition.';
      _recognitionState = RecognitionState.error;
      _usedOnlineRecognition = false;
      notifyListeners();
    } on app_exceptions.ModelNotInitializedException catch (e) {
      _errorMessage = 'Recognition failed: ${e.message}';
      _recognitionState = RecognitionState.error;
      _recognitionResult = null;
      _usedOnlineRecognition = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Recognition failed: $e';
      _recognitionState = RecognitionState.error;
      _recognitionResult = null;
      _usedOnlineRecognition = false;
      notifyListeners();
    }
  }

  /// User canceled the quota warning - skip online recognition
  void cancelQuotaWarning() {
    _pendingQuotaWarning = null;
    _errorMessage = 'Skipped online recognition to avoid API charges';
    _recognitionState = RecognitionState.idle;
    notifyListeners();
  }

  /// Refresh API credentials status
  Future<void> refreshCredentialsStatus() async {
    await _checkCredentials();
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

  void setLocation(String? value) {
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
    _currentImageBytes = null;
    _recognitionResult = null;
    _errorMessage = null;
    _recognitionState = RecognitionState.idle;
    _usedOnlineRecognition = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
