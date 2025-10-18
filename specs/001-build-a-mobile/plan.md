# Implementation Plan: Home AI Index - Smart Home Inventory Manager

**Branch**: `001-build-a-mobile` | **Date**: 2025-10-13 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `C:\projects\personal\home-ai-index\specs\001-build-a-mobile\spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a Flutter mobile application that enables homeowners to manage their home inventory using on-device image recognition. Users photograph items (groceries, tools, appliances), which are automatically identified and categorized. Items are organized by physical storage locations (e.g., "Master Bedroom Closet", "Kitchen Pantry") with support for relocation tracking. The app operates fully offline with local SQLite storage, on-device ML image recognition, and no cloud dependencies.

**Technical Approach**: Flutter cross-platform app with on-device TensorFlow Lite model for image classification, sqflite for local database, and Material Design 3 UI following clean architecture patterns.

## Technical Context

**Language/Version**: Dart 3.2+ / Flutter 3.16+  
**Primary Dependencies**: 
- `sqflite` (^2.3.0) - Local SQLite database
- `path_provider` (^2.1.0) - File system paths
- `image_picker` (^1.0.5) - Camera and gallery access
- `tflite_flutter` (^0.10.4) - On-device ML inference
- `provider` (^6.1.0) - State management
- `flutter_lints` (^3.0.0) - Code quality enforcement

**Storage**: SQLite database (local device storage) via sqflite package. Photos stored in app's private directory as JPEG files (compressed to ≤2MB). No cloud storage or sync in MVP.

**Testing**: `flutter_test` package (unit/widget tests), `integration_test` package (e2e tests), `mockito` for mocking dependencies

**Target Platform**: 
- Android: API level 24+ (Android 7.0+)
- iOS: iOS 13.0+
- Primary target: Phone form factor, portrait orientation

**Project Type**: Mobile (Flutter app) - Single codebase for Android/iOS

**Performance Goals**: 
- 60 FPS during all UI interactions
- Cold start: <2 seconds
- Image recognition: <5 seconds per photo
- Search results: <300ms latency
- Support 500+ items with smooth scrolling

**Constraints**: 
- Fully offline - no internet connectivity required
- On-device ML only - no cloud AI APIs
- Photo storage: ≤2MB per image (JPEG compression)
- No user authentication (local device only)
- Portrait orientation only for MVP
- Minimal external dependencies

**Scale/Scope**: 
- Single-user app (no multi-user/sync)
- Target: 500+ items in inventory
- Estimated: 8-12 screens
- MVP timeline: 6-8 weeks
- Post-MVP: Cloud backup, multi-device sync

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Check (Before Phase 0)

**Code Quality & Maintainability**:
- [x] Linting configured (`flutter_lints` ^3.0.0 in pubspec.yaml)
- [x] DartDoc documentation plan for all public APIs (models, repositories, services, view models)
- [x] Strong typing enforced (strict null safety, minimal `dynamic` usage)
- [x] Code organization follows Effective Dart guidelines (clean architecture: data/domain/presentation layers)

**Test-First Development**:
- [x] Unit test strategy defined (≥80% coverage for repositories, services, view models)
- [x] Widget test plan for UI components (all screens and custom widgets)
- [x] Integration test scenarios identified (6 user stories from spec as integration tests)
- [x] Golden test approach for critical UI (item cards, location tiles, category badges)

**Widget Architecture**:
- [x] Widget composition strategy (atomic design: atoms→molecules→organisms→screens)
- [x] State management approach selected (Provider with ChangeNotifier for simplicity and testability)
- [x] Separation of UI and business logic defined (MVVM pattern: Views → ViewModels → Repositories)
- [x] `const` widget usage plan (all stateless UI components use `const` constructors)

**Performance Standards**:
- [x] Target frame rate identified (60 FPS minimum, profile with DevTools before release)
- [x] Profiling checkpoints defined (after image recognition, list scrolling, search implementation)
- [x] List rendering strategy (ListView.builder with lazy loading, thumbnail caching)
- [x] Image loading and caching strategy (local file system, Image.file with cacheWidth/cacheHeight)
- [x] Startup time optimization plan (async initialization, splash screen, deferred loading)

**UX Consistency**:
- [x] Design system selected (Material Design 3 with custom color scheme)
- [x] Theme support plan (ThemeData with light/dark ColorScheme, ThemeMode.system default)
- [x] Responsive layout strategy (phone-first, responsive breakpoints at 600dp for tablet)
- [x] Accessibility requirements documented (Semantics widgets, 4.5:1 contrast, 48dp touch targets)
- [x] Loading/error/empty state designs (CircularProgressIndicator, error snackbars, empty state illustrations)

**State Management**:
- [x] State management solution selected (Provider - lightweight, testable, Flutter recommended)
- [x] Immutable state pattern confirmed (copyWith methods on models, never mutate state directly)
- [x] Async operation handling strategy (FutureBuilder/StreamBuilder for UI, async methods in ViewModels)
- [x] Error handling approach defined (try-catch with custom exceptions, user-friendly error messages)

**✅ INITIAL GATE STATUS: PASSED** - All constitution requirements satisfied. Proceeding to Phase 0.

---

### Post-Design Check (After Phase 1)

**Code Quality & Maintainability**:
- [x] Data model uses strong typing (all entities with explicit types, Equatable for value equality)
- [x] Contracts define clear interfaces (6 repositories with documented method signatures, params, exceptions)
- [x] Immutable models with copyWith methods (Item, Category, Location, LocationHistory, ImageRecognitionResult)
- [x] Validation rules documented per field (see data-model.md tables)

**Test-First Development**:
- [x] Repository interfaces enable mocking (abstract classes for all repositories)
- [x] Exception hierarchy supports test assertions (AppException with typed subclasses)
- [x] Testable business rules documented (category constraints, location hierarchy validation)
- [x] Integration test scenarios map to contracts (6 repositories cover all 6 user stories)

**Widget Architecture**:
- [x] Clear data layer separation (repositories abstract database/file system/ML)
- [x] ViewModels will consume repositories (no direct database/service access in UI)
- [x] Models support UI rendering (JSON serialization, human-readable properties)
- [x] State changes atomic (each model update returns new instance via copyWith)

**Performance Standards**:
- [x] Database indexes planned (name, categoryId, locationId, createdAt)
- [x] Image compression strategy (≤2MB photos, 200×200px thumbnails)
- [x] ML model lazy-loaded (on first camera use, not app startup)
- [x] Query optimization (limit clauses, pagination support in contracts)
- [x] Thumbnail generation for fast rendering (separate thumbnail path methods)

**UX Consistency**:
- [x] Consistent error handling (exception hierarchy with user-friendly messages)
- [x] Loading state patterns (async methods return Future for FutureBuilder integration)
- [x] Empty state support (repositories return empty lists, not null)
- [x] Default categories provide consistent experience (12 pre-populated categories)

**State Management**:
- [x] Immutable state enforced (all models use Equatable, copyWith methods)
- [x] Async operations properly typed (all repo methods return Future)
- [x] Error propagation clear (typed exceptions with codes)
- [x] State transitions documented (see data-model.md state diagrams)

**✅ POST-DESIGN GATE STATUS: PASSED** - Design artifacts align with constitution. Phase 1 complete, ready for Phase 2 implementation.

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
home-ai-index/
├── lib/
│   ├── main.dart                          # App entry point with Provider setup
│   ├── app.dart                           # MaterialApp with theme and routing
│   │
│   ├── core/                              # Core utilities and constants
│   │   ├── constants/
│   │   │   ├── app_constants.dart        # App-wide constants
│   │   │   └── default_categories.dart   # Default item categories
│   │   ├── extensions/
│   │   │   └── string_extensions.dart    # String helper extensions
│   │   └── theme/
│   │       ├── app_theme.dart            # Light/dark theme definitions
│   │       └── app_colors.dart           # Custom color palette
│   │
│   ├── data/                              # Data layer
│   │   ├── models/
│   │   │   ├── item_model.dart           # Item entity with JSON serialization
│   │   │   ├── category_model.dart       # Category entity
│   │   │   ├── location_model.dart       # Storage location entity
│   │   │   └── location_history_model.dart # Location history entry
│   │   │
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── database_helper.dart  # SQLite database setup
│   │   │   │   ├── item_local_datasource.dart
│   │   │   │   ├── category_local_datasource.dart
│   │   │   │   └── location_local_datasource.dart
│   │   │   └── ml/
│   │   │       └── image_recognition_service.dart # TFLite integration
│   │   │
│   │   └── repositories/
│   │       ├── item_repository.dart      # Item CRUD operations
│   │       ├── category_repository.dart  # Category management
│   │       ├── location_repository.dart  # Location management
│   │       └── image_repository.dart     # Photo storage/retrieval
│   │
│   ├── presentation/                      # UI layer
│   │   ├── screens/
│   │   │   ├── home_screen.dart          # Main dashboard
│   │   │   ├── add_item_screen.dart      # Camera + recognition flow
│   │   │   ├── item_details_screen.dart  # Item details with edit
│   │   │   ├── items_list_screen.dart    # Browse by category/location
│   │   │   ├── search_screen.dart        # Search functionality
│   │   │   ├── locations_screen.dart     # Manage locations
│   │   │   └── settings_screen.dart      # App settings
│   │   │
│   │   ├── widgets/
│   │   │   ├── common/                   # Reusable components
│   │   │   │   ├── custom_app_bar.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   ├── error_message.dart
│   │   │   │   └── empty_state.dart
│   │   │   ├── item/
│   │   │   │   ├── item_card.dart        # Item list tile
│   │   │   │   ├── item_thumbnail.dart   # Image thumbnail
│   │   │   │   └── item_metadata.dart    # Metadata display
│   │   │   ├── location/
│   │   │   │   ├── location_tile.dart    # Location list item
│   │   │   │   └── location_picker.dart  # Location selector dialog
│   │   │   └── category/
│   │   │       ├── category_badge.dart   # Category chip
│   │   │       └── category_grid.dart    # Category grid view
│   │   │
│   │   └── viewmodels/
│   │       ├── home_viewmodel.dart       # Home screen logic
│   │       ├── add_item_viewmodel.dart   # Add item flow logic
│   │       ├── items_list_viewmodel.dart # Browse logic
│   │       ├── search_viewmodel.dart     # Search logic
│   │       └── locations_viewmodel.dart  # Location management
│   │
│   └── utils/
│       ├── image_processor.dart          # Image compression utilities
│       ├── file_helper.dart              # File system operations
│       └── validators.dart               # Input validators
│
├── test/
│   ├── unit/
│   │   ├── data/
│   │   │   ├── models/                   # Model tests (JSON, copyWith)
│   │   │   ├── datasources/              # Datasource tests (mocked SQLite)
│   │   │   └── repositories/             # Repository tests
│   │   └── presentation/
│   │       └── viewmodels/               # ViewModel unit tests
│   │
│   ├── widget/
│   │   ├── screens/                      # Screen widget tests
│   │   └── widgets/                      # Component widget tests
│   │
│   ├── integration/
│   │   ├── user_story_1_test.dart        # Add item via image recognition
│   │   ├── user_story_2_test.dart        # Organize by location
│   │   ├── user_story_3_test.dart        # Relocate items
│   │   ├── user_story_4_test.dart        # Browse and search
│   │   ├── user_story_5_test.dart        # Remove items/locations
│   │   └── user_story_6_test.dart        # Item metadata
│   │
│   └── fixtures/
│       ├── test_data.dart                # Mock data generators
│       └── test_images/                  # Sample images for testing
│
├── assets/
│   ├── ml_models/
│   │   └── mobilenet_v2.tflite          # Image classification model
│   ├── images/
│   │   ├── empty_state_illustrations/
│   │   └── category_icons/
│   └── fonts/                            # Custom fonts (if any)
│
├── android/                              # Android platform code
├── ios/                                  # iOS platform code
├── pubspec.yaml                          # Dependencies
├── analysis_options.yaml                 # Lint rules
└── README.md                             # Project documentation
```
└── widgets/               # Widgets (if UI package)

test/                      # Package tests
example/                   # Example usage

# [REMOVE IF UNUSED] Option 4: Full-stack Flutter (Flutter + Backend API)
# Flutter app structure (as Option 1)

backend/
├── src/
│   ├── models/
│   ├── services/
│   ├── api/
│   └── database/
└── tests/
```

**Structure Decision**: Flutter Application (Option 1) - Clean Architecture with MVVM pattern

The structure follows Flutter best practices with clear separation of concerns:
- **Data Layer** (`lib/data/`): Models, datasources (SQLite, TFLite), and repositories
- **Presentation Layer** (`lib/presentation/`): Screens, widgets, and ViewModels using Provider
- **Core** (`lib/core/`): Shared utilities, theme, constants
- **Tests** (`test/`): Organized by test type (unit, widget, integration) matching source structure

This architecture enables:
- Independent testing of each layer
- Easy mocking for unit tests
- Clear dependency flow (Presentation → Data)
- Scalability for future features

## Complexity Tracking

*No violations - Constitution Check passed completely.*

All architectural decisions align with Flutter/Dart best practices and constitution requirements:
- Clean architecture with Repository pattern is standard for testable Flutter apps
- Provider state management is lightweight and Flutter-recommended
- MVVM pattern ensures UI/logic separation (Constitution Principle III)
- Three-layer testing strategy meets test-first requirements (Constitution Principle II)
