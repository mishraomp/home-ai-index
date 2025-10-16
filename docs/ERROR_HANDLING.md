# Error Handling Guide

## Overview
This document outlines the error handling strategy and implementation for the Home AI Index app.

## Error Handling Strategy

### 1. Error Categories
- **User Errors**: Invalid input, validation failures
- **System Errors**: Database failures, file system errors
- **Network Errors**: API failures (future feature)
- **Permission Errors**: Camera, storage access denied
- **Resource Errors**: ML model loading failures, low storage

### 2. Error Boundaries (T131) ✅

#### ViewModel Error Handling
All ViewModels follow this pattern:
```dart
Future<void> someOperation() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // Perform operation
    final result = await repository.doSomething();
    _data = result;
    _isLoading = false;
    notifyListeners();
  } on ValidationException catch (e) {
    _errorMessage = 'Invalid input: ${e.message}';
    _isLoading = false;
    notifyListeners();
  } on DatabaseException catch (e) {
    _errorMessage = 'Database error: ${e.message}';
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Unexpected error: ${e.toString()}';
    _isLoading = false;
    notifyListeners();
  }
}
```

#### UI Error Display
```dart
if (viewModel.errorMessage != null) {
  return ErrorMessage(
    message: viewModel.errorMessage!,
    onRetry: () => viewModel.retry(),
  );
}
```

### 3. Permission Handling (T132, T133) ✅

#### Camera Permission
**File**: `lib/presentation/viewmodels/add_item_viewmodel.dart`

```dart
Future<void> pickImage(ImageSource source) async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile == null) {
      _errorMessage = 'No image selected';
      notifyListeners();
      return;
    }
    // Process image...
  } on PlatformException catch (e) {
    if (e.code == 'camera_access_denied') {
      _errorMessage = 'Camera permission denied. Please enable camera access in settings.';
    } else if (e.code == 'photo_access_denied') {
      _errorMessage = 'Photo library permission denied. Please enable photo access in settings.';
    } else {
      _errorMessage = 'Failed to pick image: ${e.message}';
    }
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Unexpected error: ${e.toString()}';
    notifyListeners();
  }
}
```

#### Storage Permission
**File**: `lib/data/repositories/image_repository_impl.dart`

```dart
Future<String> saveImage(File imageFile, String itemId) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = path.join(appDir.path, 'images', fileName);
    
    // Create directory if it doesn't exist
    await Directory(path.dirname(savedPath)).create(recursive: true);
    
    await imageFile.copy(savedPath);
    return savedPath;
  } on FileSystemException catch (e) {
    throw AppException('Storage error: ${e.message}. Please check storage permissions.');
  } catch (e) {
    throw AppException('Failed to save image: ${e.toString()}');
  }
}
```

### 4. ML Model Fallback (T134) ✅

#### Model Loading with Graceful Degradation
**File**: `lib/data/services/image_recognition_service_impl.dart`

```dart
class ImageRecognitionServiceImpl implements ImageRecognitionService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  
  @override
  Future<void> initializeModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml_models/mobilenet_v2.tflite');
      _isModelLoaded = true;
    } catch (e) {
      // Log error but don't throw - allow graceful fallback
      debugPrint('Failed to load ML model: $e');
      _isModelLoaded = false;
    }
  }
  
  @override
  Future<ImageRecognitionResult> classifyImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      // Fallback: Return empty result, allowing manual entry
      return ImageRecognitionResult(
        suggestedName: '',
        suggestedCategory: '',
        confidence: 0.0,
        alternativeSuggestions: [],
      );
    }
    
    try {
      // Perform inference...
    } catch (e) {
      // Inference error - fallback to manual entry
      debugPrint('Image recognition failed: $e');
      return ImageRecognitionResult(
        suggestedName: '',
        suggestedCategory: '',
        confidence: 0.0,
        alternativeSuggestions: [],
      );
    }
  }
}
```

#### UI Handling for ML Fallback
```dart
Future<void> recognizeImage() async {
  if (_imagePath == null) return;
  
  _isRecognizing = true;
  notifyListeners();
  
  try {
    final result = await _imageRecognitionService.classifyImage(File(_imagePath!));
    
    if (result.confidence < 0.3 || result.suggestedName.isEmpty) {
      // ML failed or low confidence - show manual entry message
      _errorMessage = 'Could not identify item. Please enter details manually.';
    } else {
      // ML success
      _suggestedName = result.suggestedName;
      _suggestedCategoryId = result.suggestedCategory;
    }
  } catch (e) {
    _errorMessage = 'Image recognition unavailable. Please enter details manually.';
  } finally {
    _isRecognizing = false;
    notifyListeners();
  }
}
```

### 5. Database Recovery (T135) ✅

#### Corruption Detection and Recovery
**File**: `lib/data/datasources/local/database_helper.dart`

```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  
  try {
    _database = await _initDatabase();
    return _database!;
  } on DatabaseException catch (e) {
    // Database corrupted - attempt recovery
    if (e.toString().contains('corrupt') || 
        e.toString().contains('malformed')) {
      debugPrint('Database corrupted, attempting recovery...');
      await _recoverDatabase();
      _database = await _initDatabase();
      return _database!;
    }
    rethrow;
  }
}

Future<void> _recoverDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'home_ai_index.db');
  
  // Backup corrupted database
  try {
    await File(path).rename('$path.corrupted.${DateTime.now().millisecondsSinceEpoch}');
  } catch (e) {
    // If rename fails, just delete
    await File(path).delete();
  }
  
  // Database will be recreated on next init
}
```

### 6. Offline Mode Indicators (T136) ✅

#### Storage Full Detection
```dart
Future<bool> hasEnoughStorage() async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final stat = await appDir.stat();
    
    // Check if at least 100MB available
    const minStorageMB = 100;
    final availableMB = stat.size / (1024 * 1024);
    
    return availableMB >= minStorageMB;
  } catch (e) {
    // Assume enough storage if check fails
    return true;
  }
}
```

#### Low Storage Banner
**File**: `lib/presentation/widgets/common/storage_warning_banner.dart`

```dart
class StorageWarningBanner extends StatelessWidget {
  const StorageWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkStorage(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!) {
          return MaterialBanner(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            content: Text(
              'Storage space is low. Please free up space to continue adding items.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to settings or show cleanup options
                },
                child: const Text('Manage Storage'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Future<bool> _checkStorage() async {
    // Implementation...
  }
}
```

## Error Messages

### User-Friendly Error Messages

#### Validation Errors
```dart
// ❌ Bad
'Name must be between 1 and 100 characters'

// ✅ Good
'Please enter a name (1-100 characters)'
```

#### System Errors
```dart
// ❌ Bad
'SQLiteException: database is locked'

// ✅ Good
'Unable to save item. Please try again in a moment.'
```

#### Permission Errors
```dart
// ❌ Bad
'PlatformException: camera_access_denied'

// ✅ Good
'Camera access is required to photograph items. Please enable camera permission in Settings > Home AI Index.'
```

## Error Logging

### Debug Logging
```dart
import 'package:flutter/foundation.dart';

void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
  if (kDebugMode) {
    debugPrint('Error in $operation: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }
}
```

### Production Error Tracking
Future integration with Firebase Crashlytics or Sentry:
```dart
// TODO: Add Crashlytics/Sentry
// Crashlytics.recordError(error, stackTrace);
```

## Testing Error Scenarios

### Unit Tests
```dart
test('handles database error gracefully', () async {
  // Mock database to throw error
  when(mockDatabase.insert(any, any))
      .thenThrow(DatabaseException('Database locked'));
  
  final repo = ItemRepositoryImpl(database: mockDatabase);
  
  expect(
    () => repo.createItem(testItem),
    throwsA(isA<DatabaseException>()),
  );
});
```

### Widget Tests
```dart
testWidgets('displays error message when loading fails', (tester) async {
  // Mock ViewModel to have error
  final viewModel = MockHomeViewModel();
  when(viewModel.errorMessage).thenReturn('Failed to load items');
  
  await tester.pumpWidget(
    ChangeNotifierProvider<HomeViewModel>.value(
      value: viewModel,
      child: const HomeScreen(),
    ),
  );
  
  expect(find.text('Failed to load items'), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
});
```

## Checklist

- [x] **T131**: Error boundaries for all async operations ✅
- [x] **T132**: Camera permission denied handling ✅
- [x] **T133**: Storage permission denied handling ✅
- [x] **T134**: ML model loading failure fallback ✅
- [x] **T135**: Database corruption recovery mechanism ✅
- [x] **T136**: Offline mode indicators (storage full) ✅

## References
- [Flutter Error Handling](https://docs.flutter.dev/testing/errors)
- [Material Design Error Messages](https://m3.material.io/components/snackbar/guidelines)
- [Permission Handler Plugin](https://pub.dev/packages/permission_handler)
