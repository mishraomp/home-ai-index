# Research Document: Home AI Index - Technical Decisions

**Feature**: Home AI Index - Smart Home Inventory Manager  
**Date**: 2025-10-13  
**Status**: Complete

## Overview

This document captures research findings and technical decisions for implementing the Home AI Index mobile application using Flutter with on-device machine learning and offline-first architecture.

---

## 1. On-Device Image Recognition

### Decision: TensorFlow Lite with MobileNet V2

**Chosen Solution**: `tflite_flutter` package (^0.10.4) with pre-trained MobileNet V2 model

**Rationale**:
- **Offline Capability**: Runs entirely on-device, no internet required
- **Performance**: MobileNet V2 optimized for mobile (3.4M parameters, ~14MB model size)
- **Accuracy**: Achieves ~70%+ accuracy on ImageNet dataset (1000 classes)
- **Flutter Integration**: Official TFLite plugin with good community support
- **Cross-Platform**: Works on both Android and iOS
- **Inference Speed**: <100ms on modern devices

**Alternatives Considered**:
- **ML Kit (Google)**: Cloud-dependent for image labeling API; offline object detection doesn't provide item names
- **CoreML (iOS only)**: Platform-specific, would require separate Android solution
- **Custom trained model**: Too time-consuming for MVP; can be added later for household-specific items

**Implementation Details**:
- Model: MobileNet V2 (ImageNet 1000 classes)
- Input: 224x224 RGB images
- Output: Top 5 predictions with confidence scores
- Fallback: If confidence <0.5, prompt user for manual entry
- Model location: `assets/ml_models/mobilenet_v2.tflite`

**References**:
- TFLite Flutter: https://pub.dev/packages/tflite_flutter
- MobileNet V2: https://arxiv.org/abs/1801.04381

---

## 2. Local Database - SQLite

### Decision: sqflite package (^2.3.0)

**Chosen Solution**: SQLite database via `sqflite` package with custom database helper

**Rationale**:
- **Mature & Stable**: Most popular Flutter database plugin (5000+ pub points)
- **Offline-First**: All data persists locally without cloud dependency
- **Performance**: Fast queries for 500+ items with proper indexing
- **Relational Data**: Supports foreign keys for item-location relationships
- **Cross-Platform**: Works on Android, iOS, and desktop platforms
- **No Setup**: Embedded database, no server configuration needed

**Alternatives Considered**:
- **Hive**: Faster but NoSQL (harder to maintain relationships between items/locations)
- **Isar**: Modern and fast but newer (less mature ecosystem)
- **ObjectBox**: Fast but commercial license for advanced features
- **Drift (formerly Moor)**: Type-safe queries but adds complexity for MVP

**Database Schema**:

```sql
-- Items table
CREATE TABLE items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category_id TEXT NOT NULL,
  location_id TEXT,
  photo_path TEXT,
  quantity INTEGER DEFAULT 1,
  notes TEXT,
  expiration_date INTEGER,
  purchase_date INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Categories table
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  icon_code INTEGER NOT NULL,
  is_custom INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- Locations table
CREATE TABLE locations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id TEXT,
  full_path TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (parent_id) REFERENCES locations(id)
);

-- Location history table
CREATE TABLE location_history (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  moved_at INTEGER NOT NULL,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
  FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Indexes for performance
CREATE INDEX idx_items_category ON items(category_id);
CREATE INDEX idx_items_location ON items(location_id);
CREATE INDEX idx_items_name ON items(name);
CREATE INDEX idx_locations_parent ON locations(parent_id);
CREATE INDEX idx_location_history_item ON location_history(item_id);
```

**References**:
- sqflite: https://pub.dev/packages/sqflite
- SQLite best practices: https://www.sqlite.org/bestpractice.html

---

## 3. State Management - Provider

### Decision: Provider package (^6.1.0) with ChangeNotifier

**Chosen Solution**: Provider pattern with ViewModel classes extending ChangeNotifier

**Rationale**:
- **Simplicity**: Easy to understand and implement for MVP scope
- **Flutter Recommended**: Officially recommended by Flutter team
- **Testability**: ViewModels can be unit tested independently of UI
- **Performance**: Efficient rebuilds with granular listeners
- **Learning Curve**: Minimal for team members familiar with Flutter
- **Scalability**: Sufficient for 8-12 screens and 500+ items

**Alternatives Considered**:
- **BLoC**: Overcomplicated for this MVP; better for complex state machines
- **Riverpod**: Modern but more boilerplate; Provider is simpler for this use case
- **GetX**: Too opinionated; violates Flutter conventions
- **setState**: Insufficient for cross-screen state sharing

**Architecture Pattern**: MVVM (Model-View-ViewModel)

```dart
// Example ViewModel structure
class ItemsListViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadItems({String? categoryId, String? locationId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _items = await _itemRepository.getItems(
        categoryId: categoryId,
        locationId: locationId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**References**:
- Provider: https://pub.dev/packages/provider
- Flutter state management guide: https://docs.flutter.dev/data-and-backend/state-mgmt

---

## 4. Image Handling & Storage

### Decision: Local file system with image compression

**Chosen Solution**: Store compressed JPEG images in app's private directory using `path_provider`

**Rationale**:
- **Privacy**: Photos never leave the device
- **Performance**: Local file access is instant (no network latency)
- **Storage Efficiency**: Compress to 2MB max with 85% JPEG quality
- **Simplicity**: No cloud storage setup or authentication required
- **Offline**: Works without internet connection

**Implementation Strategy**:

```dart
// Image processing pipeline
1. Capture photo (image_picker package)
2. Compress image:
   - Resize to max 1920x1080 (maintain aspect ratio)
   - Convert to JPEG with quality=85
   - Target: ≤2MB file size
3. Generate thumbnail (200x200px) for list views
4. Save to app's documents directory:
   - Original: /app_documents/photos/{item_id}.jpg
   - Thumbnail: /app_documents/thumbnails/{item_id}_thumb.jpg
5. Store file path in SQLite (not the image itself)
```

**Storage Estimates**:
- 500 items × 2MB average = ~1GB storage
- 500 thumbnails × 20KB = ~10MB storage
- Database: ~5MB for metadata
- Total: ~1GB for 500-item inventory

**Alternatives Considered**:
- **Cloud Storage (Firebase/AWS S3)**: Requires internet; MVP is offline-first
- **SQLite BLOB**: Poor performance for large images; increases database size
- **Uncompressed images**: Would consume too much storage (5-10MB per photo)

**References**:
- path_provider: https://pub.dev/packages/path_provider
- image_picker: https://pub.dev/packages/image_picker
- Flutter image optimization: https://docs.flutter.dev/perf/rendering-performance#images

---

## 5. UI/UX Design System

### Decision: Material Design 3 with custom theme

**Chosen Solution**: Material 3 (Material You) design system with light/dark themes

**Rationale**:
- **Constitution Compliance**: Material Design 3 specified in requirements
- **Modern UI**: Latest design language with better accessibility
- **Cross-Platform**: Consistent look on Android and iOS
- **Theme Support**: Built-in light/dark mode with dynamic color
- **Accessibility**: WCAG 2.1 AA compliant out-of-the-box
- **Component Library**: Rich set of pre-built widgets

**Theme Configuration**:

```dart
// Light theme
ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4), // Primary purple
  brightness: Brightness.light,
);

// Dark theme
ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF6750A4),
  brightness: Brightness.dark,
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  cardTheme: CardTheme(elevation: 2),
  appBarTheme: AppBarTheme(centerTitle: true),
);
```

**Accessibility Requirements**:
- Minimum touch target: 48×48 logical pixels
- Color contrast: 4.5:1 for text (WCAG AA)
- Semantic labels for all interactive elements
- Support system font scaling (up to 2x)

**Alternatives Considered**:
- **Cupertino**: iOS-specific; spec requires cross-platform consistency
- **Custom design system**: Too time-consuming for MVP
- **Material 2**: Outdated; Material 3 is current standard

**References**:
- Material Design 3: https://m3.material.io
- Flutter theming: https://docs.flutter.dev/cookbook/design/themes

---

## 6. Camera Integration

### Decision: image_picker package (^1.0.5)

**Chosen Solution**: Official `image_picker` plugin for camera and gallery access

**Rationale**:
- **Official Plugin**: Maintained by Flutter team
- **Cross-Platform**: Works on Android, iOS, and web
- **Simple API**: Single method call for camera/gallery
- **Permission Handling**: Automatic permission requests with rationale
- **Image Quality Control**: Can specify image quality and size

**Implementation**:

```dart
final ImagePicker _picker = ImagePicker();

// Capture from camera
XFile? photo = await _picker.pickImage(
  source: ImageSource.camera,
  imageQuality: 85,
  maxWidth: 1920,
  maxHeight: 1080,
);

// Select from gallery
XFile? photo = await _picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 85,
);
```

**Permission Requirements**:
- Android: `CAMERA`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`
- iOS: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`

**Alternatives Considered**:
- **camera plugin**: Lower-level; requires more code for basic use cases
- **Platform channels**: Too much custom code; reinventing the wheel

**References**:
- image_picker: https://pub.dev/packages/image_picker

---

## 7. Testing Strategy

### Decision: Three-tier testing with mocks

**Chosen Solution**: Unit tests, widget tests, and integration tests with mockito for mocking

**Test Coverage Goals**:
- **Unit Tests**: 80%+ coverage for ViewModels, Repositories, Services
- **Widget Tests**: All screens and reusable widgets
- **Integration Tests**: 6 user stories from spec
- **Golden Tests**: Item cards, location tiles, category badges

**Testing Stack**:
- `flutter_test` - Built-in testing framework
- `integration_test` - End-to-end testing
- `mockito` - Mock dependencies
- `golden_toolkit` - Golden file testing

**Example Test Structure**:

```dart
// Unit test example
void main() {
  late ItemRepository itemRepository;
  late MockItemLocalDataSource mockDataSource;
  
  setUp(() {
    mockDataSource = MockItemLocalDataSource();
    itemRepository = ItemRepository(mockDataSource);
  });
  
  test('getItems returns list of items from datasource', () async {
    // Arrange
    when(mockDataSource.getAll()).thenAnswer((_) async => [testItem]);
    
    // Act
    final result = await itemRepository.getItems();
    
    // Assert
    expect(result, [testItem]);
    verify(mockDataSource.getAll()).called(1);
  });
}
```

**CI/CD Testing**:
- Run on every commit
- Block merge if tests fail
- Coverage reports required

**References**:
- Flutter testing guide: https://docs.flutter.dev/testing
- mockito: https://pub.dev/packages/mockito

---

## 8. Performance Optimization

### Decision: Lazy loading with caching strategies

**Chosen Solution**: ListView.builder with image caching and pagination

**Optimization Strategies**:

1. **List Rendering**:
   - Use `ListView.builder` for virtualized scrolling
   - Load items in batches of 50
   - Implement pull-to-refresh

2. **Image Loading**:
   - Use `Image.file` with `cacheWidth` and `cacheHeight`
   - Generate 200×200px thumbnails for list views
   - Load full-resolution only on detail screen

3. **Database Queries**:
   - Indexed queries on category_id, location_id, name
   - LIMIT and OFFSET for pagination
   - Avoid SELECT *; query only needed columns

4. **Search Optimization**:
   - Debounce search input (300ms delay)
   - Use SQLite FTS (Full-Text Search) for name queries
   - Cancel previous search queries when new input arrives

5. **Startup Optimization**:
   - Lazy-load ML model (only when camera opens)
   - Pre-populate default categories in splash screen
   - Use async initialization with FutureBuilder

**Performance Targets**:
- 60 FPS scrolling (16ms frame budget)
- <2 second cold start
- <5 second image recognition
- <300ms search results

**Profiling Plan**:
- Use Flutter DevTools Performance view
- Profile before each release
- Check for jank, memory leaks, excessive rebuilds

**References**:
- Flutter performance best practices: https://docs.flutter.dev/perf/best-practices

---

## 9. Error Handling & Logging

### Decision: Custom exceptions with user-friendly messages

**Chosen Solution**: Typed exceptions with try-catch blocks and SnackBar notifications

**Error Handling Strategy**:

```dart
// Custom exceptions
class ItemNotFoundException implements Exception {
  final String message;
  ItemNotFoundException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}

// ViewModel error handling
Future<void> deleteItem(String id) async {
  try {
    await _itemRepository.deleteItem(id);
    _showSuccess('Item deleted successfully');
  } on ItemNotFoundException catch (e) {
    _showError('Item not found');
  } on DatabaseException catch (e) {
    _showError('Failed to delete item. Please try again.');
  } catch (e) {
    _showError('An unexpected error occurred');
  }
}
```

**User Feedback**:
- Success: Green SnackBar with checkmark icon
- Error: Red SnackBar with error icon + retry option
- Loading: CircularProgressIndicator with descriptive text
- Empty states: Illustration + helpful message

**Logging** (Debug mode only):
- Use `debugPrint` for development
- Log errors with stack traces
- No PII (personally identifiable information) in logs

**References**:
- Dart exception handling: https://dart.dev/guides/language/language-tour#exceptions

---

## 10. Dependency Management

### Decision: Minimal, well-maintained packages

**Core Dependencies** (6 packages):

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State management
  provider: ^6.1.0
  
  # Local storage
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # Image handling
  image_picker: ^1.0.5
  
  # Machine learning
  tflite_flutter: ^0.10.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code quality
  flutter_lints: ^3.0.0
  
  # Testing
  mockito: ^5.4.3
  build_runner: ^2.4.6
  integration_test:
    sdk: flutter
```

**Rationale**:
- All packages have 100+ pub points (quality score)
- Active maintenance (updated within last 6 months)
- Large community (1000+ likes on pub.dev)
- Cross-platform support
- Minimal transitive dependencies

**Package Selection Criteria**:
1. Official or well-maintained by reputable organizations
2. Active development and issue resolution
3. Good documentation and examples
4. Null-safe and up-to-date
5. No known security vulnerabilities

**References**:
- pub.dev package quality: https://pub.dev/help/scoring

---

## Summary

All technical decisions align with the project requirements:

✅ **Offline-First**: SQLite + TFLite + local file storage  
✅ **Cross-Platform**: Flutter for Android & iOS  
✅ **No Cloud Dependencies**: Everything runs on-device  
✅ **Performance**: Optimized for 60 FPS and fast startup  
✅ **Testability**: Clean architecture enables comprehensive testing  
✅ **Maintainability**: Minimal dependencies, clean code structure  
✅ **Constitution Compliant**: Follows all 6 core principles  

**Next Steps**: Proceed to Phase 1 (Design & Contracts)
