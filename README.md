# Home AI Index

A Flutter mobile application for intelligent home inventory management with AI-powered item recognition and organization.

## 📱 Overview

Home AI Index helps you keep track of items in your home by organizing them into categories and locations. The app features AI-powered image recognition to automatically identify and categorize items, making inventory management effortless.

### Key Features

✅ **Item Management**
- Add items with photos using camera or gallery
- AI-powered automatic item recognition and categorization
- Track item quantities and notes
- Search and filter items by category or location

✅ **Location Tracking**
- Create hierarchical location structure (up to 5 levels)
- Relocate individual items or bulk move multiple items
- Location history tracking with timestamps
- Visual location timeline for each item

✅ **Smart Organization**
- Pre-defined categories with custom icons
- Create custom categories for specific needs
- Bulk selection mode for managing multiple items
- Category badges and visual indicators

✅ **User Experience**
- Material Design 3 UI
- Dark/light theme support
- Intuitive gestures (long-press for selection)
- Real-time search and filtering

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **MVVM** pattern:

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

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

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

## 📚 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2              # State management
  sqflite: ^2.4.0               # Local database
  path: ^1.9.0                  # Path utilities
  image_picker: ^1.1.2          # Camera/gallery access
  equatable: ^2.0.7             # Value equality
  intl: ^0.19.0                 # Internationalization

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

