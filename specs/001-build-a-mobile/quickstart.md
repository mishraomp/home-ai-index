# Quickstart Guide: Home AI Index

**Feature**: Home AI Index - Smart Home Inventory Manager  
**Last Updated**: 2025-10-13  
**Target Platforms**: Android 7.0+ (API 24), iOS 13.0+

## Overview

This quickstart guide helps you set up, build, and run the Home AI Index application. This is a Flutter mobile app with on-device image recognition for organizing home inventory items.

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher (bundled with Flutter)
- **IDE**: VS Code with Flutter/Dart extensions OR Android Studio
- **Android Studio**: For Android development (includes Android SDK)
- **Xcode**: For iOS development (macOS only, version 15.0+)

### Verify Installation

```powershell
# Check Flutter version
flutter --version

# Check Dart version
dart --version

# Run Flutter doctor to check setup
flutter doctor -v
```

**Expected Output**:
```
[✓] Flutter (Channel stable, 3.16.x, on Windows/macOS)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS (macOS only)
[✓] Connected device (X available)
```

---

## Project Setup

### 1. Clone Repository

```powershell
cd C:\projects\personal
git clone <repository-url> home-ai-index
cd home-ai-index
```

### 2. Switch to Feature Branch

```powershell
git checkout 001-build-a-mobile
```

### 3. Install Dependencies

```powershell
flutter pub get
```

This installs the following packages:
- `provider: ^6.1.0` - State management
- `sqflite: ^2.3.0` - SQLite database
- `tflite_flutter: ^0.10.4` - TensorFlow Lite ML
- `image_picker: ^1.0.5` - Camera/gallery access
- `path_provider: ^2.1.0` - File system paths
- `mockito: ^5.4.3` - Testing mocks

### 4. Add ML Model

Download MobileNet V2 TFLite model and place in assets:

```powershell
# Create assets directory
mkdir assets/ml_models -Force

# Download model (use browser or curl)
# Model URL: https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v2_1.0_224.tflite

# Place file at: assets/ml_models/mobilenet_v2.tflite
```

Verify `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/ml_models/mobilenet_v2.tflite
```

### 5. Update pubspec.yaml (if needed)

Run after adding model:

```powershell
flutter pub get
```

---

## Running the App

### Run on Android Emulator

1. Start Android emulator:
   ```powershell
   # List available emulators
   flutter emulators
   
   # Launch specific emulator
   flutter emulators --launch <emulator_id>
   ```

2. Run app:
   ```powershell
   flutter run
   ```

### Run on iOS Simulator (macOS only)

1. Start iOS simulator:
   ```powershell
   open -a Simulator
   ```

2. Run app:
   ```powershell
   flutter run
   ```

### Run on Physical Device

1. **Android**: Enable USB debugging on device, connect via USB
2. **iOS**: Connect device, trust computer, configure code signing in Xcode

3. Check device connection:
   ```powershell
   flutter devices
   ```

4. Run on specific device:
   ```powershell
   flutter run -d <device_id>
   ```

### Run with Hot Reload

The app supports hot reload during development:

- **Hot Reload**: `r` in terminal (preserves app state)
- **Hot Restart**: `R` in terminal (resets app state)
- **Quit**: `q` in terminal

---

## Testing

### Run All Tests

```powershell
flutter test
```

### Run Unit Tests Only

```powershell
flutter test test/unit
```

### Run Widget Tests Only

```powershell
flutter test test/widget
```

### Run Integration Tests

```powershell
# Run on connected device/emulator
flutter test integration_test
```

### Run with Coverage

```powershell
flutter test --coverage
```

View coverage report:

```powershell
# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

### Test Watch Mode (VS Code)

Install Flutter extension and use:
- `Ctrl+Shift+P` → "Flutter: Run All Tests"
- `Ctrl+Shift+P` → "Flutter: Run Tests in Current File"

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── data/                        # Data layer (repositories)
│   ├── models/                  # Entity models
│   │   ├── item.dart
│   │   ├── category.dart
│   │   ├── location.dart
│   │   └── location_history.dart
│   ├── repositories/            # Repository implementations
│   │   ├── item_repository.dart
│   │   ├── category_repository.dart
│   │   ├── location_repository.dart
│   │   ├── location_history_repository.dart
│   │   └── image_repository.dart
│   ├── services/                # External services
│   │   └── image_recognition_service.dart
│   └── database/                # SQLite database
│       ├── database_helper.dart
│       └── schema.dart
├── presentation/                # Presentation layer (UI)
│   ├── screens/                 # Screen widgets
│   │   ├── home_screen.dart
│   │   ├── add_item_screen.dart
│   │   ├── item_detail_screen.dart
│   │   ├── categories_screen.dart
│   │   └── locations_screen.dart
│   ├── widgets/                 # Reusable widgets
│   │   ├── item_card.dart
│   │   ├── category_chip.dart
│   │   └── location_picker.dart
│   └── view_models/             # MVVM ViewModels with Provider
│       ├── item_view_model.dart
│       ├── category_view_model.dart
│       └── location_view_model.dart
├── core/                        # Shared utilities
│   ├── constants.dart           # App constants
│   ├── exceptions.dart          # Custom exceptions
│   ├── theme.dart               # Material Design 3 theme
│   └── utils/                   # Helper utilities
│       ├── date_formatter.dart
│       └── validators.dart
└── assets/                      # App assets
    └── ml_models/
        └── mobilenet_v2.tflite

test/
├── unit/                        # Unit tests
│   ├── models/
│   ├── repositories/
│   └── services/
├── widget/                      # Widget tests
│   ├── screens/
│   └── widgets/
└── integration_test/            # Integration tests
    └── app_test.dart
```

---

## Common Commands

### Build Commands

```powershell
# Build Android APK (debug)
flutter build apk --debug

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release
```

### Clean & Rebuild

```powershell
# Clean build artifacts
flutter clean

# Reinstall dependencies
flutter pub get

# Rebuild app
flutter run
```

### Analyze Code

```powershell
# Run Dart analyzer
flutter analyze

# Format code
dart format lib/ test/

# Check formatting without writing
dart format --output=none --set-exit-if-changed lib/ test/
```

### Debugging

```powershell
# Run in debug mode with DevTools
flutter run --debug

# Open DevTools in browser
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Profiling

```powershell
# Run in profile mode
flutter run --profile

# Run in release mode
flutter run --release
```

---

## Database Management

### Initialize Database

Database auto-initializes on first app launch:

1. Creates SQLite database at `/app_documents/home_ai_index.db`
2. Runs schema migrations from `lib/data/database/schema.dart`
3. Seeds 12 default categories

### Reset Database

Delete database file to reset:

```powershell
# On Android emulator/device
flutter run
adb shell
cd /data/data/<package_name>/app_flutter/
rm home_ai_index.db
exit

# On iOS simulator
flutter run
# Delete app from simulator and reinstall
```

### Inspect Database (Android)

```powershell
# Pull database from device
adb pull /data/data/<package_name>/app_flutter/home_ai_index.db .

# Open with SQLite browser
# Download: https://sqlitebrowser.org/
```

---

## Troubleshooting

### Issue: "Waiting for another flutter command to release the startup lock"

**Solution**:
```powershell
cd $env:LOCALAPPDATA\Pub\Cache
rm -Force .dart_tool\package_config.json
cd <project_root>
flutter pub get
```

### Issue: "Unable to load asset: assets/ml_models/mobilenet_v2.tflite"

**Solution**:
1. Verify model file exists at `assets/ml_models/mobilenet_v2.tflite`
2. Ensure `pubspec.yaml` lists asset under `flutter: assets:`
3. Run `flutter clean && flutter pub get`
4. Restart app

### Issue: "Camera permission denied"

**Solution**:
- **Android**: Check `android/app/src/main/AndroidManifest.xml` includes:
  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  ```
- **iOS**: Check `ios/Runner/Info.plist` includes:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>This app needs camera access to scan items</string>
  ```

### Issue: Tests failing with "MissingPluginException"

**Solution**:
```powershell
# Run tests with integration_test package
flutter test integration_test/

# Or mock platform channels in unit tests
```

### Issue: Slow image recognition

**Check**:
1. Running in release mode? (Debug is slower)
2. Model file correct size? (Should be ~14MB)
3. Device has sufficient RAM? (Minimum 2GB recommended)

---

## Development Workflow

### Feature Development Process

1. **Create Issue**: Document feature in GitHub Issues
2. **Spec Branch**: Create spec branch from `main`
3. **Run Spec Command**: Use `/speckit.specify` to create spec
4. **Review Spec**: Validate requirements pass checklist
5. **Create Plan**: Use `/speckit.plan` to generate implementation plan
6. **Implementation Branch**: Create feature branch (e.g., `001-build-a-mobile`)
7. **TDD Cycle**:
   - Write failing test
   - Implement feature
   - Refactor
   - Ensure tests pass
8. **Code Review**: Check constitution compliance
9. **Merge**: Merge to `main` after approval

### Testing Strategy

Follow **Test Pyramid**:

1. **Unit Tests (70%)**: Models, repositories, services
2. **Widget Tests (20%)**: Screen widgets, custom widgets
3. **Integration Tests (10%)**: End-to-end user flows

**Coverage Target**: ≥80% for all layers

---

## Performance Optimization

### Image Recognition

- Model loads lazily (first camera use, not app startup)
- Image preprocessed to 224×224 before inference
- Cache last 10 recognition results in memory

### Database Queries

- Indexes on frequently queried columns (`name`, `categoryId`, `locationId`)
- Limit search results to 50 items
- Use pagination for large lists

### UI Rendering

- Use `const` constructors where possible
- Lazy-load item images with thumbnails
- Implement virtual scrolling for long lists

---

## Architecture Patterns

### Repository Pattern

All data access goes through repository interfaces:

```dart
// Bad: Direct database access in UI
final items = await database.query('items');

// Good: Repository abstraction
final items = await itemRepository.getItems();
```

### MVVM with Provider

UI reacts to ViewModel state changes:

```dart
class ItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) return CircularProgressIndicator();
        return ListView.builder(
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) => ItemCard(viewModel.items[index]),
        );
      },
    );
  }
}
```

### Exception Handling

Use custom exceptions with user-friendly messages:

```dart
try {
  final item = await itemRepository.getItemById(id);
} on ItemNotFoundException catch (e) {
  // Show user-friendly error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Item not found')),
  );
} on DatabaseException catch (e) {
  // Log error and show generic message
  logger.error('Database error', e);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Something went wrong')),
  );
}
```

---

## Additional Resources

### Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [TensorFlow Lite Flutter](https://pub.dev/packages/tflite_flutter)

### Project Files

- **Specification**: `specs/001-build-a-mobile/spec.md`
- **Implementation Plan**: `specs/001-build-a-mobile/plan.md`
- **Data Model**: `specs/001-build-a-mobile/data-model.md`
- **API Contracts**: `specs/001-build-a-mobile/contracts/repository_contracts.md`
- **Constitution**: `.specify/memory/constitution.md`

### VS Code Extensions (Recommended)

- **Flutter**: Dart/Flutter language support
- **Flutter Widget Snippets**: Quick widget templates
- **Dart Data Class Generator**: Generate models with boilerplate
- **Error Lens**: Inline error highlighting
- **GitLens**: Git blame annotations

---

## Next Steps

1. ✅ Read project constitution: `.specify/memory/constitution.md`
2. ✅ Review feature spec: `specs/001-build-a-mobile/spec.md`
3. ✅ Understand data model: `specs/001-build-a-mobile/data-model.md`
4. ✅ Review API contracts: `specs/001-build-a-mobile/contracts/repository_contracts.md`
5. 🔲 Set up development environment (Flutter, Android Studio/Xcode)
6. 🔲 Clone repository and run `flutter pub get`
7. 🔲 Download and add MobileNet V2 model to assets
8. 🔲 Run app on emulator/device
9. 🔲 Run test suite to verify setup
10. 🔲 Start implementing Phase 2 (Core Data Layer)

---

**Questions?** Refer to the implementation plan (`specs/001-build-a-mobile/plan.md`) or consult the project constitution for development standards.

**Ready to Code?** 🚀 Start with Phase 2: Implement database schema and repository layer!
