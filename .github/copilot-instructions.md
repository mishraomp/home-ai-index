# home-ai-index Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-10-16

## Active Technologies
- Dart 3.2+ / Flutter 3.16+ (001-build-a-mobile)
- Google Cloud Vision API, http ^1.1.0, flutter_secure_storage ^9.0.0, connectivity_plus ^5.0.0 (002-upgrade-the-existing)
- Provider state management, image ^4.0.17, sqflite ^2.3.0 (existing)

## Project Structure
```
src/
tests/
```

## Commands
```bash
# Development
flutter run              # Run app in debug mode
flutter test             # Run unit/widget tests
flutter analyze          # Check for issues
dart fix --apply         # Auto-fix lint issues

# Cloud Vision API
flutter pub get          # Install dependencies
# See quickstart.md for API setup

# Build
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

## Code Style
Dart 3.2+ / Flutter 3.16+: Follow standard conventions

### Flutter Best Practices (CRITICAL)
**ALWAYS follow these rules - NO EXCEPTIONS:**

1. **Import Ordering** - Sort directive sections alphabetically:
   - Dart core libraries first (dart:*)
   - External package imports second (package:flutter, package:provider, etc.) - alphabetically sorted
   - Blank line separator
   - Project imports last (package:home_ai_index/*) - alphabetically sorted
   - Use `dart fix --apply` to auto-fix import ordering issues

2. **Constructor Placement** - Constructor declarations MUST be before non-constructor declarations:
   - Constructor comes FIRST in the class body
   - Then field declarations
   - Then methods
   - Never place fields before the constructor

3. **Quality Checks**:
   - Run `flutter analyze` before committing
   - Run `flutter test` to ensure all tests pass
   - Use `dart fix --apply` to automatically fix lint issues

4. **Code Generation**:
   - When creating new Flutter widgets or classes, ALWAYS place constructor first
   - When editing existing code, verify current structure before making changes
   - Follow Material Design 3 guidelines for UI components

## Recent Changes
- 002-upgrade-the-existing: Added Google Cloud Vision API integration (http, flutter_secure_storage, connectivity_plus)
- 001-build-a-mobile: Added Dart 3.2+ / Flutter 3.16+

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
