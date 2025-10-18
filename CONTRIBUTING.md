# Contributing to Home AI Index

Thank you for your interest in contributing to Home AI Index! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background or identity.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and help them get started
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling or insulting/derogatory remarks
- Personal or political attacks
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

## Getting Started

### Prerequisites

1. **Flutter SDK** (3.16.0+)
2. **Dart SDK** (3.2.0+)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Git** for version control

### Setup Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/home-ai-index.git
   cd home-ai-index
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/mishraomp/home-ai-index.git
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Generate mock files for testing:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. Verify setup by running tests:
   ```bash
   flutter test
   ```

## Development Workflow

### 1. Create a Feature Branch

Always work on a feature branch, never directly on `main` or `001-build-a-mobile`:

```bash
# Update your local repository
git fetch upstream
git checkout 001-build-a-mobile
git merge upstream/001-build-a-mobile

# Create a feature branch
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test improvements

### 2. Make Your Changes

Follow the [Coding Standards](#coding-standards) and write tests for your changes.

### 3. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "feat: add bulk delete functionality

- Implement BulkActionsViewModel with delete method
- Add DeleteConfirmationDialog widget
- Include unit and widget tests
- Update documentation
```

Commit message format:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `refactor:` - Code refactoring
- `style:` - Code formatting (no functional changes)
- `perf:` - Performance improvements

### 4. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/001-build-a-mobile
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### Dart/Flutter Code Style

#### 1. Follow Dart Style Guide

- Use `dart format` before committing:
  ```bash
  dart format .
  ```

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines

#### 2. Import Ordering

Sort imports in this order:
1. Dart core libraries (`dart:*`)
2. External packages (`package:flutter`, `package:provider`, etc.) - alphabetically
3. Blank line
4. Project imports (`package:home_ai_index/*`) - alphabetically

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/item.dart';
```

Use `dart fix --apply` to auto-fix import ordering.

#### 3. Constructor Placement

Constructors MUST come before field declarations:

```dart
class MyClass {
  // ✅ Good: Constructor first
  MyClass({required this.field1, this.field2});
  
  final String field1;
  final int? field2;
  
  void myMethod() { }
}
```

#### 4. Documentation

Add DartDoc comments to all public APIs:

```dart
/// Manages item inventory operations
///
/// Handles CRUD operations for items with automatic
/// location history tracking and validation.
class ItemRepository {
  /// Creates a new item in the database
  ///
  /// Throws [ValidationException] if item data is invalid.
  /// Throws [DatabaseException] if database operation fails.
  ///
  /// Returns the ID of the created item.
  Future<String> createItem(Item item) async {
    // Implementation
  }
}
```

#### 5. Null Safety

Always use null safety properly:

```dart
// ✅ Good
String? nullableString;
String nonNullableString = '';

if (nullableString != null) {
  print(nullableString.length);  // Safe
}

// ❌ Bad
print(nullableString!.length);  // Avoid ! operator unless certain
```

#### 6. Async/Await

Use async/await instead of `.then()`:

```dart
// ✅ Good
Future<List<Item>> loadItems() async {
  try {
    final items = await repository.getItems();
    return items;
  } catch (e) {
    throw AppException('Failed to load items: $e');
  }
}

// ❌ Bad
Future<List<Item>> loadItems() {
  return repository.getItems().then((items) => items);
}
```

### Widget Architecture

#### 1. Atomic Design

Organize widgets by complexity:
- **Atoms**: Basic components (badges, buttons)
- **Molecules**: Combinations of atoms (item card, category badge)
- **Organisms**: Complex components (item list, location tree)
- **Screens**: Full pages

#### 2. State Management

Use Provider with ChangeNotifier:

```dart
class MyViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    // Load data
    
    _isLoading = false;
    notifyListeners();
  }
}
```

#### 3. Widget Composition

Prefer composition over inheritance:

```dart
// ✅ Good
class ItemCard extends StatelessWidget {
  const ItemCard({required this.item, super.key});
  
  final Item item;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          ItemThumbnail(imagePath: item.imagePath),
          ItemDetails(item: item),
          CategoryBadge(category: item.categoryId),
        ],
      ),
    );
  }
}

// ❌ Bad - Too monolithic
class ItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          // 100+ lines of nested widgets
        ],
      ),
    );
  }
}
```

## Testing Guidelines

### Test Requirements

**ALL code changes MUST include tests.** We follow Test-Driven Development (TDD):

1. Write failing tests (Red)
2. Implement minimum code to pass (Green)
3. Refactor for quality (Refactor)

### Test Coverage

Maintain ≥80% test coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS/Linux
start coverage/html/index.html # Windows
```

### Test Types

#### 1. Unit Tests

Test business logic in isolation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ItemRepository])
void main() {
  group('AddItemViewModel', () {
    late AddItemViewModel viewModel;
    late MockItemRepository mockRepository;
    
    setUp(() {
      mockRepository = MockItemRepository();
      viewModel = AddItemViewModel(itemRepository: mockRepository);
    });
    
    test('saveItem creates item with valid data', () async {
      // Arrange
      viewModel.setName('Test Item');
      viewModel.setCategoryId('cat1');
      when(mockRepository.createItem(any))
          .thenAnswer((_) async => 'item-id');
      
      // Act
      await viewModel.saveItem();
      
      // Assert
      verify(mockRepository.createItem(any)).called(1);
      expect(viewModel.errorMessage, isNull);
    });
  });
}
```

#### 2. Widget Tests

Test UI components:

```dart
testWidgets('ItemCard displays item information', (tester) async {
  final item = Item(
    id: '1',
    name: 'Test Item',
    categoryId: 'cat1',
    // ... other fields
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ItemCard(
          item: item,
          categoryName: 'Kitchen',
          categoryIcon: Icons.kitchen,
        ),
      ),
    ),
  );
  
  expect(find.text('Test Item'), findsOneWidget);
  expect(find.text('Kitchen'), findsOneWidget);
  expect(find.byIcon(Icons.kitchen), findsOneWidget);
});
```

#### 3. Integration Tests

Test complete user flows:

```dart
testWidgets('User can add item with image', (tester) async {
  // Setup
  await tester.pumpWidget(const MyApp());
  
  // Navigate to add item screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Take photo
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();
  
  // Verify image recognition ran
  expect(find.text('Suggested:'), findsOneWidget);
  
  // Enter name and save
  await tester.enterText(find.byType(TextField), 'My Item');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  
  // Verify item appears in list
  expect(find.text('My Item'), findsOneWidget);
});
```

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/unit/presentation/viewmodels/add_item_viewmodel_test.dart

# With coverage
flutter test --coverage

# Watch mode (runs on file changes)
flutter test --watch
```

## Pull Request Process

### Before Submitting

- [ ] All tests pass: `flutter test`
- [ ] Code is formatted: `dart format .`
- [ ] No lint errors: `flutter analyze`
- [ ] Documentation is updated
- [ ] Commit messages follow conventions
- [ ] Branch is up to date with upstream

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issue
Fixes #<issue-number>

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Tests pass locally
```

### Review Process

1. Automated checks run (tests, linting)
2. Code review by maintainers
3. Address feedback with additional commits
4. Once approved, PR will be merged

### After Merge

1. Delete your feature branch
2. Update your local repository:
   ```bash
   git checkout 001-build-a-mobile
   git pull upstream 001-build-a-mobile
   ```

## Project Structure

```
home-ai-index/
├── lib/
│   ├── core/              # Shared utilities
│   ├── data/              # Data layer
│   │   ├── datasources/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── presentation/      # UI layer
│   │   ├── screens/
│   │   ├── viewmodels/
│   │   └── widgets/
│   └── main.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── assets/
│   ├── ml_models/
│   └── images/
├── docs/                  # Documentation
└── specs/                 # Feature specifications
```

## Getting Help

- 📖 Read the [documentation](docs/)
- 🐛 Report bugs via [GitHub Issues](https://github.com/mishraomp/home-ai-index/issues)
- 💬 Ask questions in [Discussions](https://github.com/mishraomp/home-ai-index/discussions)
- 📧 Email: [maintainer email]

## Recognition

Contributors will be recognized in:
- README.md Contributors section
- GitHub Insights
- Release notes for significant contributions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Home AI Index! 🎉
