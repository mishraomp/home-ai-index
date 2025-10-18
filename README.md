# Home AI Index 🏠📦

<div align="center">

![CI](https://github.com/mishraomp/home-ai-index/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Tests](https://img.shields.io/badge/tests-530%20passing-success)
![Coverage](https://img.shields.io/badge/coverage-80%25+-brightgreen)

**A smart mobile app for intelligent home inventory management**

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

Home AI Index is a Flutter mobile application that helps you effortlessly track and organize your home inventory using **AI-powered image recognition**. Simply photograph an item, and the app automatically identifies and categorizes it for you.

### Why Home AI Index?

- 🤖 **AI-Powered**: On-device ML model (MobileNet V2) identifies items from photos
- 📍 **Location Tracking**: Organize items by room, shelf, box - up to 5 levels deep
- 🔍 **Smart Search**: Find items instantly with real-time search
- 🎨 **Beautiful UI**: Material Design 3 with light/dark themes
- 🔒 **Privacy First**: All data stored locally - no cloud, no tracking
- ⚡ **Fast & Smooth**: 60 FPS scrolling, <2s startup, <5s image recognition

### Screenshots

> 📸 *Screenshots coming soon*

## ✨ Features

### Core Features

✅ **Item Management**
- Add items with photos using camera or gallery
- AI-powered automatic item recognition (85%+ accuracy)
- Track quantities, notes, and expiration dates
- Edit and delete items with undo support (30-second window)

✅ **Location Tracking**
- Create hierarchical location structure (Home → Room → Shelf → Box → Drawer)
- Relocate items with automatic history tracking
- View location breadcrumbs and navigation
- Bulk item relocation

✅ **Smart Organization**
- 12 pre-defined categories (Kitchen, Electronics, Tools, etc.)
- Custom categories with icons
- Search and filter by category or location
- Sort by name, date, or location

✅ **User Experience**
- Material Design 3 UI components
- Dark/light theme with dynamic colors
- Accessibility: Screen reader support, WCAG AA contrast
- Performance optimized: Lazy loading, image caching, in-memory cache

### Advanced Features

- 📊 **"Expiring Soon" Dashboard**: Track items expiring within 7 days
- 🗄️ **Location History**: View timeline of where items have been moved
- 🔄 **Bulk Operations**: Select and manage multiple items at once
- 💾 **Auto-Backup**: Database with corruption recovery

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **MVVM** pattern for maintainability and testability:

```
lib/
├── core/                          # Shared utilities and constants
│   ├── constants/                 # App-wide constants
│   ├── exceptions.dart            # Custom exceptions
│   ├── theme/                     # App theming
│   └── utils/                     # Helper utilities
│
├── data/                          # Data layer
│   ├── datasources/               # Data sources (local, remote, ML)
│   │   └── local/                 # SQLite database
│   ├── models/                    # Data models
│   │   ├── item.dart
│   │   ├── category.dart
│   │   ├── location.dart
│   │   └── location_history.dart
│   ├── repositories/              # Repository implementations
│   └── services/                  # Business services (image recognition)
│
└── presentation/                  # Presentation layer
    ├── screens/                   # UI screens
    │   ├── home_screen.dart       # Main inventory list
    │   ├── add_item_screen.dart   # Add/capture items
    │   ├── item_details_screen.dart # View/edit item details
    │   └── locations_screen.dart  # Manage locations
    ├── viewmodels/                # State management (ChangeNotifier)
    │   ├── add_item_viewmodel.dart
    │   ├── item_details_viewmodel.dart
    │   ├── bulk_actions_viewmodel.dart
    │   └── locations_viewmodel.dart
    └── widgets/                   # Reusable UI components
```

## 🧪 Testing

Comprehensive test coverage with **372 passing tests**:

- **Unit Tests**: 185 tests
  - Repository tests (ItemRepository, LocationRepository, LocationHistoryRepository)
  - ViewModel tests (AddItemViewModel, ItemDetailsViewModel, BulkActionsViewModel)
  - Service tests (ImageRecognitionService)

- **Widget Tests**: 184 tests
  - Screen tests (HomeScreen, AddItemScreen, ItemDetailsScreen)
  - Component tests (ItemCard, CategoryBadge, LocationTile)

- **Integration Tests**: 3 tests
  - End-to-end feature validation

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/presentation/viewmodels/item_details_viewmodel_test.dart

# Run with coverage
flutter test --coverage
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.35.0 or higher
- Dart SDK 3.9.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Quick Deploy to Your Phone 📱

**The fastest way to run on your phone:**

1. **Enable USB Debugging** on your Android phone:
   - Go to Settings → About Phone
   - Tap "Build number" 7 times
   - Go to Settings → System → Developer Options
   - Enable "USB Debugging"

2. **Connect your phone** via USB cable

3. **Run the deployment script** (Windows):
   ```powershell
   .\deploy.ps1
   ```
   
   Or use Flutter directly:
   ```bash
   flutter run --release
   ```

That's it! The app will install and launch on your phone. ✨

📖 **For detailed deployment instructions**, see [DEPLOYMENT.md](DEPLOYMENT.md)

### Installation for Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/mishraomp/home-ai-index.git
   cd home-ai-index
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate mock files (for testing)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # List available devices
   flutter devices

   # Run on specific device
   flutter run -d <device-id>

   # Run in debug mode
   flutter run

   # Run in release mode
   flutter run --release
   ```

## 📚 Documentation

Comprehensive guides are available in the `docs/` directory:

- **[CI_CD_SETUP.md](docs/CI_CD_SETUP.md)** - CI/CD pipeline setup and deployment
- **[PERFORMANCE.md](docs/PERFORMANCE.md)** - Performance optimizations and profiling
- **[ACCESSIBILITY.md](docs/ACCESSIBILITY.md)** - Accessibility standards and testing
- **[ERROR_HANDLING.md](docs/ERROR_HANDLING.md)** - Error handling strategies
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[APP_ICON_GUIDE.md](docs/APP_ICON_GUIDE.md)** - App icon setup guide

### API Documentation

Generate DartDoc API documentation:

```bash
dart doc
```

View generated docs in `doc/api/index.html`

## 📚 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2              # State management
  sqflite: ^2.4.0               # Local SQLite database
  path: ^1.9.0                  # Path utilities
  path_provider: ^2.1.4         # App directories
  image_picker: ^1.1.2          # Camera/gallery access
  image: ^4.2.0                 # Image processing
  tflite_flutter: ^0.11.0       # TensorFlow Lite
  equatable: ^2.0.7             # Value equality
  intl: ^0.19.0                 # Date formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4               # Mocking framework
  build_runner: ^2.4.13         # Code generation
  flutter_lints: ^5.0.0         # Linting rules
  sqflite_common_ffi: ^2.3.4    # SQLite testing support
```



## 🗄️ Database Schema

### Items Table
```sql
CREATE TABLE items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  notes TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  category_id TEXT NOT NULL,
  location_id TEXT,
  expiration_date INTEGER,
  image_path TEXT,
  ml_detected_label TEXT,
  ml_confidence_score REAL,
  added_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### Locations Table
```sql
CREATE TABLE locations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id TEXT,
  created_at INTEGER NOT NULL
);
```

### Location History Table
```sql
CREATE TABLE location_history (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);
```

## 🛠️ Development

### Code Generation

```bash
# Generate mock files for testing
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch
```

### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Formatting

```bash
# Format all Dart files
dart format .
```

## 📝 Project Structure Notes

- **MVVM Pattern**: ViewModels use `ChangeNotifier` for state management
- **Repository Pattern**: Abstract repositories with concrete implementations
- **Dependency Injection**: Using `Provider` for DI
- **Test Doubles**: Generated mocks using `mockito` and `build_runner`
- **Clean Architecture**: Separation of concerns across layers


### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Adding or updating tests
- `refactor:` Code refactoring
- `style:` Code style changes
- `chore:` Maintenance tasks

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

