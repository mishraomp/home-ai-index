# home-ai-index Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-10-13

## Active Technologies
- Dart 3.2+ / Flutter 3.16+ (001-build-a-mobile)

## Project Structure
```
src/
tests/
```

## Commands
# Add commands for Dart 3.2+ / Flutter 3.16+

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
- 001-build-a-mobile: Added Dart 3.2+ / Flutter 3.16+

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->