<!--
SYNC IMPACT REPORT
==================
Version: 0.0.0 → 1.0.0
Date: 2025-10-13

Changes:
- Initial constitution created from template
- Added 6 core principles focused on Flutter best practices
- Principles cover: Code Quality, Testing Standards, Widget Architecture, Performance, UX Consistency, State Management
- Added Performance Standards section
- Added Development Workflow section
- Defined governance rules and versioning policy

Templates Status:
- ✅ plan-template.md: Constitution Check section compatible
- ✅ spec-template.md: Requirements align with quality principles
- ✅ tasks-template.md: Task categories support test-first approach

Follow-up Actions: None
-->

# Home AI Index Constitution

## Core Principles

### I. Code Quality & Maintainability (NON-NEGOTIABLE)

All code MUST adhere to Flutter/Dart best practices with strict linting enforcement. Code quality is non-negotiable and enforced through automated tools.

**Rules**:
- MUST use `flutter_lints` or stricter (e.g., `very_good_analysis`) with zero violations
- MUST document all public APIs with DartDoc comments including parameters, return values, and examples
- MUST eliminate dead code and unused imports before PR submission
- MUST use strong typing; avoid `dynamic` except when interfacing with untyped APIs
- MUST follow Effective Dart style guide for naming conventions and code organization
- MUST keep functions focused and small (prefer <50 lines, max 100 lines per function)
- MUST use immutable data structures where possible (`@immutable`, `const` constructors)

**Rationale**: Clean, well-documented code reduces technical debt, improves maintainability, and enables team collaboration. Strict linting catches bugs early and enforces consistency.

---

### II. Test-First Development (NON-NEGOTIABLE)

Testing is mandatory and follows a strict test-first discipline. Tests MUST be written before implementation.

**Rules**:
- MUST write tests BEFORE implementation (Red-Green-Refactor cycle)
- MUST achieve minimum 80% code coverage for all business logic
- MUST include all three test types:
  * **Unit Tests**: Test individual functions/classes in isolation with mocked dependencies
  * **Widget Tests**: Test UI components, user interactions, and widget behavior
  * **Integration Tests**: Test complete user journeys and feature interactions
- MUST use golden tests for critical UI components to prevent visual regressions
- MUST mock external dependencies (network, storage, platform channels) in unit/widget tests
- MUST run all tests successfully before committing code
- MUST write tests that are deterministic, independent, and fast

**Rationale**: Test-first development ensures features work as specified, prevents regressions, and creates living documentation. Flutter's comprehensive testing framework (`flutter_test`, `integration_test`) makes this achievable without significant overhead.

---

### III. Widget Architecture & Composition

Widgets MUST be modular, reusable, and follow Flutter's composition patterns.

**Rules**:
- MUST break complex widgets into smaller, single-responsibility widgets
- MUST use `const` constructors wherever possible for performance optimization
- MUST extract reusable UI components into shared widget library
- MUST separate presentation widgets from business logic (use ViewModel/BLoC/Provider pattern)
- MUST keep widget build methods pure (no side effects, no async operations)
- MUST use appropriate widget types: `StatelessWidget` for pure UI, `StatefulWidget` only when local state needed
- MUST leverage Flutter's built-in widgets before creating custom implementations
- MUST document complex widget trees with explanatory comments

**Rationale**: Modular widget architecture improves code reusability, testing, and performance. `const` widgets reduce rebuilds and memory allocation. Separation of concerns enables independent testing and modification.

---

### IV. Performance Standards (NON-NEGOTIABLE)

Applications MUST meet performance benchmarks for smooth user experience.

**Rules**:
- MUST maintain 60 FPS (16ms frame budget) on target devices; 120 FPS on capable devices
- MUST keep app startup time under 2 seconds (cold start) and 500ms (warm start)
- MUST profile with Flutter DevTools Performance view before releasing features
- MUST avoid expensive operations in build methods (use `compute()` for heavy computation)
- MUST optimize list rendering with `ListView.builder`, pagination, or lazy loading for large datasets
- MUST minimize `saveLayer()` calls and avoid unnecessary `Opacity`, `ClipPath`, or `BackdropFilter`
- MUST use `RepaintBoundary` strategically to isolate expensive repaints
- MUST implement proper image caching and lazy loading for network images
- MUST measure and optimize app size (target: <50MB for base APK/IPA)

**Rationale**: Performance directly impacts user satisfaction and retention. Flutter provides excellent performance by default, but poor practices can introduce jank and sluggishness. Proactive profiling prevents performance regressions.

---

### V. User Experience Consistency

UI/UX MUST be consistent, accessible, and follow platform conventions.

**Rules**:
- MUST follow Material Design 3 guidelines for Android/cross-platform or Cupertino for iOS-specific apps
- MUST support both light and dark themes consistently
- MUST implement proper responsive layouts supporting multiple screen sizes (phone, tablet, desktop)
- MUST achieve WCAG 2.1 Level AA accessibility standards minimum:
  * Semantic labels for screen readers
  * Sufficient color contrast ratios (4.5:1 for text)
  * Touch targets minimum 48x48 logical pixels
  * Support for platform accessibility features (TalkBack, VoiceOver, font scaling)
- MUST provide appropriate loading states, error messages, and empty states
- MUST use animations judiciously: enhance UX without causing distraction (200-300ms typical duration)
- MUST test on physical devices representing target user base (not just simulators)
- MUST handle orientation changes gracefully (portrait/landscape)

**Rationale**: Consistent UX reduces user confusion and learning curve. Accessibility is both ethical and legally required in many jurisdictions. Responsive design future-proofs apps across device types.

---

### VI. State Management & Architecture

State management MUST be predictable, testable, and scalable.

**Rules**:
- MUST select appropriate state management for app complexity:
  * Simple apps: `setState`, `InheritedWidget`, or `Provider`
  * Medium apps: `Riverpod`, `Bloc`, or `GetX`
  * Complex apps: `Bloc` with clean architecture layers
- MUST separate business logic from UI (ViewModel, Cubit, or equivalent)
- MUST make state immutable; use `copyWith()` for state updates
- MUST avoid global mutable state; pass dependencies explicitly or via dependency injection
- MUST handle async operations properly with loading/error states
- MUST implement proper error handling with typed exceptions
- MUST use streams or reactive patterns for real-time data
- MUST document state transitions and side effects

**Rationale**: Predictable state management reduces bugs and simplifies testing. Immutable state prevents subtle bugs from shared mutable references. Layered architecture enables independent testing of business logic.

---

## Performance Standards

### Benchmarks & Monitoring

- **Frame Rate**: Maintain 60 FPS minimum; profile with `flutter run --profile` and DevTools
- **Build Time**: Widget build methods MUST complete in <16ms
- **Memory**: Monitor with DevTools Memory view; fix memory leaks immediately
- **Network**: Implement request timeouts (10s default), retries with exponential backoff, and caching
- **Startup Time**: Measure with `flutter run --trace-startup` and optimize to <2s cold start

### Profiling Requirements

- MUST profile performance before merging features that:
  * Add new screens or complex widgets
  * Modify list rendering or scrolling behavior
  * Introduce animations or visual effects
  * Process large datasets or perform computations
- MUST use `Timeline.startSync()`/`Timeline.finishSync()` for custom performance traces
- MUST write performance tests for critical user paths (e.g., scrolling performance)

---

## Development Workflow

### Code Review Gates

All pull requests MUST pass these gates:

1. **Linting**: Zero linting errors (`flutter analyze`)
2. **Tests**: All tests pass (`flutter test`) with ≥80% coverage
3. **Build**: Clean builds on all target platforms
4. **Performance**: No performance regressions (frame drops, increased startup time)
5. **Accessibility**: Passes basic accessibility audit

### Pre-Commit Checklist

Before committing, developers MUST verify:

- [ ] All tests pass locally
- [ ] No linting errors
- [ ] Code is formatted (`dart format .`)
- [ ] Public APIs are documented
- [ ] Manual testing completed on real device
- [ ] No `print()` statements (use `debugPrint()` or logging package)
- [ ] Assets optimized (images compressed, unused assets removed)

### Breaking Changes

When introducing breaking changes:

1. MUST document in CHANGELOG with migration guide
2. MUST increment MAJOR version per semantic versioning
3. MUST provide deprecation warnings for at least one minor version before removal
4. MUST update all dependent code in the same PR

---

## Governance

This constitution establishes the foundation for all development practices in the Home AI Index project. It supersedes conflicting guidance and applies to all contributors.

**Amendment Process**:
- Amendments require documented justification with concrete examples
- Major changes (new principles, removed principles) require team consensus
- Minor clarifications can be made by project leads with notification
- All amendments MUST update version number and propagate changes to dependent templates

**Versioning Policy**:
- **MAJOR** version: Backward incompatible changes (principle removal/redefinition)
- **MINOR** version: New principles or materially expanded guidance
- **PATCH** version: Clarifications, typo fixes, non-semantic improvements

**Compliance Review**:
- All PRs MUST verify compliance with constitution principles
- Violations MUST be justified with documented rationale before merge
- Repeated violations trigger architecture review and potential refactoring
- Technical debt from violations MUST be tracked and prioritized for resolution

**Guidance Files**:
- Implementation details and agent-specific workflows documented in `.specify/templates/` directory
- This constitution provides high-level principles; templates provide execution details

---

**Version**: 1.0.0 | **Ratified**: 2025-10-13 | **Last Amended**: 2025-10-13