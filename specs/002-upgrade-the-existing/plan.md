# Implementation Plan: Upgrade to Google Cloud Vision API# Implementation Plan: [FEATURE]



**Branch**: `002-upgrade-the-existing` | **Date**: 2025-10-16 | **Spec**: [spec.md](spec.md)  **Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/002-upgrade-the-existing/spec.md`**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`



## Summary**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.



Replace the offline TensorFlow Lite MobileNetV2 model with Google Cloud Vision API for image recognition. This upgrade will improve recognition accuracy by 20%+ while adding cloud-based label detection capabilities. The implementation will maintain backward compatibility by gracefully degrading to manual entry when offline, ensuring app functionality is preserved even without internet connectivity.## Summary



**Primary Requirement**: Integrate Google Cloud Vision API Label Detection to classify household items from photos, replacing the existing on-device TensorFlow Lite model while maintaining offline fallback capability.[Extract from feature spec: primary requirement + technical approach from research]



**Technical Approach**: Implement a new `CloudVisionService` that wraps the Google Cloud Vision REST API, use secure credential storage for API keys, add network connectivity checks, implement retry logic with exponential backoff, and preserve the existing `ImageRecognitionService` interface for seamless integration.## Technical Context



## Technical Context<!--

  ACTION REQUIRED: Replace the content in this section with the technical details

**Language/Version**: Dart 3.2+, Flutter 3.16+    for the project. The structure here is presented in advisory capacity to guide

**Primary Dependencies**:   the iteration process.

- `http` ^1.1.0 (HTTP client for API calls)-->

- `flutter_secure_storage` ^9.0.0 (secure credential storage)

- `connectivity_plus` ^5.0.0 (network connectivity detection)**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  

- Existing: `provider` ^6.1.0, `image` ^4.0.17**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  

**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  

**Storage**: **Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  

- Secure storage for API credentials (flutter_secure_storage)**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]

- Existing SQLite database for items (unchanged)**Project Type**: [single/web/mobile - determines source structure]  

- Local image storage (unchanged)**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  

**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  

**Testing**: **Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

- `flutter_test` for unit and widget tests

- `mockito` ^5.4.3 for mocking HTTP client and API responses## Constitution Check

- `flutter_driver` for integration tests

- Golden tests for UI components*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*



**Target Platform**: **Code Quality & Maintainability**:

- Android 21+ (API level 21)- [ ] Linting configured (`flutter_lints` or stricter)

- iOS 12.0+- [ ] DartDoc documentation plan for all public APIs

- Target devices: Phones and tablets- [ ] Strong typing enforced (no unnecessary `dynamic`)

- [ ] Code organization follows Effective Dart guidelines

**Project Type**: Flutter mobile application (existing)

**Test-First Development**:

**Performance Goals**: - [ ] Unit test strategy defined (≥80% coverage target)

- API response time: <3 seconds for 95% of requests- [ ] Widget test plan for UI components

- Image preprocessing: <1 second- [ ] Integration test scenarios identified

- UI responsiveness: No blocking during API calls- [ ] Golden test approach for critical UI (if applicable)

- App startup: No increase >500ms

**Widget Architecture**:

**Constraints**: - [ ] Widget composition strategy (modular, reusable components)

- API timeout: 10 seconds maximum- [ ] State management approach selected and justified

- Image size limit: 20MB (Cloud Vision API limit)- [ ] Separation of UI and business logic defined

- Network required for AI features- [ ] `const` widget usage plan for performance

- Must support offline mode with manual entry

- API costs must be monitored**Performance Standards**:

- [ ] Target frame rate identified (60 FPS minimum)

**Scale/Scope**: - [ ] Profiling checkpoints defined

- Single-user mobile app- [ ] List rendering strategy for large datasets

- Expected API usage: 10-50 calls per user per day- [ ] Image loading and caching strategy

- Existing codebase: ~15k LOC- [ ] Startup time optimization plan

- New/modified files: ~15-20 files

**UX Consistency**:

## Constitution Check- [ ] Design system selected (Material 3 / Cupertino)

- [ ] Theme support plan (light/dark mode)

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*- [ ] Responsive layout strategy (phone/tablet/desktop)

- [ ] Accessibility requirements documented (WCAG 2.1 AA)

**Code Quality & Maintainability**:- [ ] Loading/error/empty state designs

- [x] Linting configured (`flutter_lints` ^6.0.0 already in pubspec.yaml)

- [x] DartDoc documentation plan: All public APIs in new `CloudVisionService`, `APICredentialsManager`, and modified `ImageRecognitionService` interface**State Management**:

- [x] Strong typing enforced: No `dynamic` types; use typed API response models- [ ] State management solution selected and justified

- [x] Code organization: Follow existing structure in `lib/data/services/` and `lib/data/models/`- [ ] Immutable state pattern confirmed

- [ ] Async operation handling strategy

**Test-First Development**:- [ ] Error handling approach defined

- [x] Unit test strategy: ≥80% coverage for CloudVisionService, APICredentialsManager, retry logic, error handling

- [x] Widget test plan: Add item screen with API states (loading, success, error, offline), confidence score display## Project Structure

- [x] Integration test scenarios: End-to-end flow from camera to API to item creation; offline fallback; error recovery

- [x] Golden test approach: Not required (no new complex UI components)### Documentation (this feature)



**Widget Architecture**:```

- [x] Widget composition strategy: Reuse existing `AddItemScreen`, add loading/error state widgetsspecs/[###-feature]/

- [x] State management: Use existing `Provider` pattern with `AddItemViewModel`├── plan.md              # This file (/speckit.plan command output)

- [x] Separation of UI and business logic: Service layer (`CloudVisionService`) separate from ViewModel├── research.md          # Phase 0 output (/speckit.plan command)

- [x] `const` widget usage: Apply to all new stateless widgets (loading indicators, error messages)├── data-model.md        # Phase 1 output (/speckit.plan command)

├── quickstart.md        # Phase 1 output (/speckit.plan command)

**Performance Standards**:├── contracts/           # Phase 1 output (/speckit.plan command)

- [x] Target frame rate: 60 FPS (no impact from async API calls)└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)

- [x] Profiling checkpoints: Profile add item screen with API integration before/after changes```

- [x] List rendering strategy: N/A (no new lists)

- [x] Image loading and caching: Reuse existing image handling; no changes needed### Source Code (repository root)

- [x] Startup time optimization: Remove TensorFlow Lite initialization (~500ms savings expected)<!--

  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout

**UX Consistency**:  for this feature. Delete unused options and expand the chosen structure with

- [x] Design system: Material Design 3 (existing)  real paths (e.g., apps/admin, packages/something). The delivered plan must

- [x] Theme support: Support existing light/dark themes  not include Option labels.

- [x] Responsive layout: Maintain existing responsive behavior-->

- [x] Accessibility requirements: Add semantic labels for loading states, error messages, confidence scores

- [x] Loading/error/empty state designs: Add loading indicator during API calls, error dialogs with retry options, offline mode banner```

# [REMOVE IF UNUSED] Option 1: Flutter Application (DEFAULT for Flutter/Dart projects)

**State Management**:lib/

- [x] State management solution: Continue using `Provider` with ViewModel pattern├── main.dart              # App entry point

- [x] Immutable state pattern: Use immutable models for API responses and recognition results├── app.dart               # App widget with routing/theme

- [x] Async operation handling: Use `Future` with loading/error states in ViewModel├── core/                  # Core utilities, constants, extensions

- [x] Error handling approach: Typed exceptions (ApiException, NetworkException, AuthenticationException) with user-friendly messages├── data/                  # Data layer (repositories, data sources, models)

│   ├── models/           # Data models

**Constitution Check Result**: ✅ **PASSED** - No violations. All principles satisfied.│   ├── repositories/     # Repository implementations

│   └── datasources/      # API clients, local storage

## Project Structure├── domain/                # Business logic layer (optional for complex apps)

│   ├── entities/         # Business entities

### Documentation (this feature)│   ├── repositories/     # Repository interfaces

│   └── usecases/         # Business use cases

```├── presentation/          # UI layer

specs/002-upgrade-the-existing/│   ├── screens/          # Screen widgets

├── plan.md              # This file│   ├── widgets/          # Reusable widgets

├── research.md          # Phase 0 output (API patterns, error handling, security)│   └── [state]/          # State management (bloc, providers, viewmodels)

├── data-model.md        # Phase 1 output (API request/response models)└── utils/                 # Helper utilities

├── quickstart.md        # Phase 1 output (setup and usage guide)

├── contracts/           # Phase 1 output (API contract definitions)test/

└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)├── unit/                  # Unit tests for business logic

```├── widget/                # Widget tests for UI components

├── integration/           # Integration tests

### Source Code (repository root)└── fixtures/              # Test data and mocks



```# [REMOVE IF UNUSED] Option 2: Flutter Plugin (when creating a plugin)

lib/lib/

├── main.dart                    # [MODIFY] Remove TensorFlow Lite initialization├── [plugin_name].dart     # Main plugin file

├── core/├── src/                   # Implementation

│   ├── constants/└── platform/              # Platform-specific interfaces

│   │   └── api_constants.dart   # [NEW] Cloud Vision API endpoints, timeouts, limits

│   ├── exceptions.dart          # [MODIFY] Add ApiException, NetworkException, AuthenticationExceptionexample/                   # Example app demonstrating plugin

│   └── utils/test/                      # Plugin tests

│       └── network_utils.dart   # [NEW] Connectivity checking, retry logic

├── data/android/                   # Android platform implementation

│   ├── models/ios/                       # iOS platform implementation

│   │   ├── cloud_vision_request.dart   # [NEW] Request model for Cloud Vision API

│   │   ├── cloud_vision_response.dart  # [NEW] Response model with labels and scores# [REMOVE IF UNUSED] Option 3: Flutter Package (when creating a reusable package)

│   │   ├── api_credentials.dart        # [NEW] Secure credential modellib/

│   │   └── image_recognition_result.dart # [MODIFY] Add confidence score field├── [package_name].dart    # Main export file

│   ├── services/├── src/                   # Package implementation

│   │   ├── image_recognition_service.dart      # [INTERFACE] Keep interface unchanged└── widgets/               # Widgets (if UI package)

│   │   ├── image_recognition_service_impl.dart # [REMOVE] Old TensorFlow Lite implementation

│   │   ├── cloud_vision_service.dart           # [NEW] Cloud Vision API implementationtest/                      # Package tests

│   │   └── api_credentials_manager.dart        # [NEW] Secure credential managementexample/                   # Example usage

│   └── repositories/

│       └── item_repository_impl.dart  # [MODIFY] Update to use new CloudVisionService# [REMOVE IF UNUSED] Option 4: Full-stack Flutter (Flutter + Backend API)

├── presentation/# Flutter app structure (as Option 1)

│   ├── screens/

│   │   └── add_item_screen.dart       # [MODIFY] Add loading states, error handlingbackend/

│   ├── viewmodels/├── src/

│   │   └── add_item_viewmodel.dart    # [MODIFY] Handle API states, errors│   ├── models/

│   └── widgets/│   ├── services/

│       ├── common/│   ├── api/

│       │   ├── api_loading_indicator.dart  # [NEW] Custom loading widget│   └── database/

│       │   ├── offline_banner.dart         # [NEW] Offline mode notification└── tests/

│       │   └── confidence_score_badge.dart # [NEW] Display recognition confidence```

│       └── dialogs/

│           └── api_error_dialog.dart       # [NEW] User-friendly error messages**Structure Decision**: [Document the selected structure and reference the real

└── utils/directories captured above]

    └── api_logger.dart                     # [NEW] API usage logging

## Complexity Tracking

test/

├── unit/*Fill ONLY if Constitution Check has violations that must be justified*

│   ├── data/

│   │   ├── services/| Violation | Why Needed | Simpler Alternative Rejected Because |

│   │   │   ├── cloud_vision_service_test.dart   # [NEW] Mock HTTP, test API calls|-----------|------------|-------------------------------------|

│   │   │   └── api_credentials_manager_test.dart # [NEW] Test secure storage| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |

│   │   └── models/| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

│   │       ├── cloud_vision_request_test.dart   # [NEW] Model serialization tests
│   │       └── cloud_vision_response_test.dart  # [NEW] Model parsing tests
│   └── core/
│       └── utils/
│           └── network_utils_test.dart          # [NEW] Test retry logic, connectivity
├── widget/
│   ├── screens/
│   │   └── add_item_screen_test.dart            # [MODIFY] Add API state tests
│   └── widgets/
│       ├── api_loading_indicator_test.dart      # [NEW]
│       ├── offline_banner_test.dart             # [NEW]
│       └── confidence_score_badge_test.dart     # [NEW]
└── integration/
    ├── cloud_vision_integration_test.dart        # [NEW] End-to-end API integration
    └── offline_fallback_test.dart                # [NEW] Test offline behavior

assets/
├── ml_models/                    # [REMOVE] Delete TensorFlow Lite model files
│   ├── mobilenet_v2.tflite      # [DELETE]
│   └── imagenet_labels.txt      # [DELETE]
└── images/                       # [UNCHANGED]

android/
└── app/
    └── src/main/AndroidManifest.xml  # [VERIFY] INTERNET permission exists

ios/
└── Runner/
    └── Info.plist                     # [VERIFY] NSAppTransportSecurity configured
```

**Structure Decision**: Using Flutter Application structure (Option 1). The feature integrates into the existing clean architecture with data/domain/presentation layers. New service layer components will be added under `lib/data/services/` following the repository pattern already established in the codebase.

## Complexity Tracking

*No Constitution violations - this section is empty.*

