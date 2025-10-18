# GitHub Actions Workflow Contracts

**Date**: 2025-10-17  
**Feature**: CI/CD Pipeline Implementation  
**Purpose**: Define the interface contracts for all GitHub Actions workflows and reusable actions

## Overview

This document specifies the exact interface for each workflow and reusable action, including inputs, outputs, triggers, secrets, and expected behavior. These contracts serve as the specification for implementation.

---

## Workflow: ci.yml (Continuous Integration)

**Purpose**: Run lint, tests, and debug builds on every push and pull request

### Triggers

```yaml
on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - main
      - develop
```

### Jobs

#### 1. Job: lint

**Runs On**: `ubuntu-latest`

**Purpose**: Enforce code quality standards with Flutter analyzer

**Steps**:
1. Checkout code
2. Setup Flutter
3. Get dependencies
4. Run analyzer: `flutter analyze --fatal-infos --fatal-warnings`

**Success Criteria**: Zero lint errors or warnings

**Timeout**: 5 minutes

**Outputs**: None

---

#### 2. Job: test

**Runs On**: `ubuntu-latest`

**Purpose**: Execute all tests and generate coverage report

**Dependencies**: None (runs in parallel with lint)

**Steps**:
1. Checkout code
2. Setup Flutter
3. Get dependencies
4. Run tests: `flutter test --coverage --reporter expanded`
5. Generate coverage summary
6. Check coverage threshold (≥80%)
7. Upload coverage artifact
8. Upload coverage to GitHub (comment on PR)

**Success Criteria**: 
- All tests pass
- Coverage ≥80%

**Timeout**: 10 minutes

**Artifacts**:
- `coverage-report`: Coverage HTML report
- `lcov.info`: Raw coverage data

**Outputs**:
- `coverage-percent`: Line coverage percentage (e.g., "85.3")

---

#### 3. Job: build-android

**Runs On**: `ubuntu-latest`

**Purpose**: Build Android debug APK to verify build succeeds

**Dependencies**: `[lint, test]` (only runs if lint and test pass)

**Steps**:
1. Checkout code
2. Setup Flutter
3. Setup Java (JDK 17)
4. Get dependencies
5. Build debug APK: `flutter build apk --debug`
6. Upload APK artifact

**Success Criteria**: Build completes without errors

**Timeout**: 15 minutes

**Artifacts**:
- `android-debug-apk`: Debug APK file

---

#### 4. Job: build-ios

**Runs On**: `macos-latest`

**Purpose**: Build iOS debug app to verify build succeeds

**Dependencies**: `[lint, test]` (only runs if lint and test pass)

**Conditional**: Only run if iOS files changed (path filter)

**Path Filter**:
```yaml
ios/**
lib/**
pubspec.yaml
```

**Steps**:
1. Checkout code
2. Setup Flutter
3. Setup Xcode (select Xcode version)
4. Get dependencies
5. Build iOS app: `flutter build ios --debug --no-codesign`
6. Archive Runner.app
7. Upload artifact

**Success Criteria**: Build completes without errors

**Timeout**: 20 minutes

**Artifacts**:
- `ios-debug-app`: Debug iOS app archive

---

### Environment Variables

```yaml
env:
  FLUTTER_VERSION: '3.16.5'
  JAVA_VERSION: '17'
```

### Secrets Required

None (debug builds don't require signing)

---

## Workflow: release.yml (Release Builds)

**Purpose**: Build signed release artifacts on merge to main

### Triggers

```yaml
on:
  push:
    branches:
      - main
```

### Jobs

#### 1. Job: release-android

**Runs On**: `ubuntu-latest`

**Purpose**: Build signed Android APK and AAB for release

**Steps**:
1. Checkout code
2. Setup Flutter
3. Setup Java (JDK 17)
4. Get dependencies
5. Decode keystore from secret
6. Create key.properties file
7. Increment build number (Git commit count)
8. Build release APK: `flutter build apk --release`
9. Build release AAB: `flutter build appbundle --release`
10. Generate build metadata JSON
11. Upload artifacts

**Success Criteria**: Signed builds created

**Timeout**: 20 minutes

**Secrets Required**:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

**Artifacts**:
- `android-release-apk`: Signed release APK
- `android-release-aab`: Signed release AAB
- `build-metadata`: Build info JSON

**Outputs**:
- `build-number`: Build number used
- `version`: App version from pubspec.yaml

---

#### 2. Job: release-ios

**Runs On**: `macos-latest`

**Purpose**: Build signed iOS IPA for release

**Steps**:
1. Checkout code
2. Setup Flutter
3. Setup Xcode
4. Install Fastlane
5. Get dependencies
6. Decode certificate and provisioning profile
7. Install certificate to keychain
8. Install provisioning profile
9. Increment build number
10. Build release IPA: `flutter build ipa --release`
11. Generate build metadata JSON
12. Upload artifacts

**Success Criteria**: Signed IPA created

**Timeout**: 25 minutes

**Secrets Required**:
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`

**Artifacts**:
- `ios-release-ipa`: Signed release IPA
- `build-metadata`: Build info JSON

**Outputs**:
- `build-number`: Build number used
- `version`: App version from pubspec.yaml

---

### Environment Variables

```yaml
env:
  FLUTTER_VERSION: '3.16.5'
  JAVA_VERSION: '17'
  RUBY_VERSION: '3.1'
```

---

## Workflow: deploy-beta.yml (Beta Deployment)

**Purpose**: Deploy signed builds to TestFlight and Google Play Internal Testing

### Triggers

```yaml
on:
  push:
    tags:
      - 'v*.*.*'  # Semantic version tags (e.g., v1.0.0)
```

### Jobs

#### 1. Job: deploy-android-beta

**Runs On**: `ubuntu-latest`

**Purpose**: Upload AAB to Google Play Internal Testing track

**Steps**:
1. Checkout code
2. Setup Ruby
3. Install Fastlane
4. Download release AAB artifact (from previous release workflow)
5. Setup Google Play service account
6. Upload to Internal Testing: `fastlane supply --track internal`
7. Notify team

**Success Criteria**: AAB uploaded successfully

**Timeout**: 15 minutes

**Secrets Required**:
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

**Artifacts**: None

---

#### 2. Job: deploy-ios-beta

**Runs On**: `macos-latest`

**Purpose**: Upload IPA to TestFlight for internal testing

**Steps**:
1. Checkout code
2. Setup Ruby
3. Install Fastlane
4. Download release IPA artifact (from previous release workflow)
5. Setup App Store Connect API key
6. Upload to TestFlight: `fastlane pilot upload`
7. Notify team

**Success Criteria**: IPA uploaded successfully

**Timeout**: 20 minutes

**Secrets Required**:
- `APP_STORE_CONNECT_API_KEY`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_ID`

**Artifacts**: None

---

### Environment Variables

```yaml
env:
  RUBY_VERSION: '3.1'
```

---

## Workflow: manual-build.yml (Manual Builds)

**Purpose**: Trigger builds manually for any branch

### Triggers

```yaml
on:
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to build'
        required: true
        type: choice
        options:
          - android
          - ios
          - both
        default: 'both'
      build-type:
        description: 'Build type'
        required: true
        type: choice
        options:
          - debug
          - release
        default: 'debug'
```

### Jobs

#### 1. Job: manual-build

**Runs On**: Matrix (ubuntu-latest for Android, macos-latest for iOS)

**Purpose**: Build requested platform(s) with specified build type

**Strategy**:
```yaml
matrix:
  include:
    - platform: android
      runner: ubuntu-latest
      enabled: ${{ inputs.platform == 'android' || inputs.platform == 'both' }}
    - platform: ios
      runner: macos-latest
      enabled: ${{ inputs.platform == 'ios' || inputs.platform == 'both' }}
```

**Steps**:
1. Checkout code
2. Setup Flutter
3. Platform-specific setup (Java for Android, Xcode for iOS)
4. Get dependencies
5. Build based on inputs
6. Upload artifact

**Success Criteria**: Build completes

**Timeout**: 25 minutes

**Artifacts**: Platform-specific build artifacts

---

## Reusable Action: setup-flutter

**Path**: `.github/actions/setup-flutter/action.yml`

**Purpose**: Setup Flutter SDK with dependency caching

### Inputs

```yaml
inputs:
  flutter-version:
    description: 'Flutter SDK version to install'
    required: false
    default: '3.16.5'
  cache-key:
    description: 'Additional cache key component'
    required: false
    default: 'flutter'
```

### Steps

1. Cache Flutter SDK
   ```yaml
   path: ${{ runner.tool_cache }}/flutter
   key: ${{ runner.os }}-flutter-${{ inputs.flutter-version }}
   ```

2. Install Flutter
   ```yaml
   uses: subosito/flutter-action@v2
   with:
     flutter-version: ${{ inputs.flutter-version }}
     cache: true
   ```

3. Cache pub dependencies
   ```yaml
   path: ~/.pub-cache
   key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
   ```

4. Run `flutter pub get`

5. Print Flutter version

### Outputs

```yaml
outputs:
  flutter-version:
    description: 'Installed Flutter version'
    value: ${{ steps.flutter-version.outputs.version }}
```

---

## Reusable Action: run-tests

**Path**: `.github/actions/run-tests/action.yml`

**Purpose**: Execute tests with coverage reporting

### Inputs

```yaml
inputs:
  coverage-threshold:
    description: 'Minimum coverage percentage required'
    required: false
    default: '80'
  upload-coverage:
    description: 'Upload coverage artifact'
    required: false
    default: 'true'
```

### Steps

1. Run tests with coverage
   ```bash
   flutter test --coverage --reporter expanded
   ```

2. Generate coverage summary
   ```bash
   lcov --summary coverage/lcov.info
   ```

3. Extract coverage percentage
   ```bash
   COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
   ```

4. Check threshold
   ```bash
   if (( $(echo "$COVERAGE < ${{ inputs.coverage-threshold }}" | bc -l) )); then
     echo "Coverage $COVERAGE% is below threshold ${{ inputs.coverage-threshold }}%"
     exit 1
   fi
   ```

5. Upload coverage artifact (if enabled)

### Outputs

```yaml
outputs:
  coverage-percent:
    description: 'Line coverage percentage'
    value: ${{ steps.coverage.outputs.percent }}
  tests-passed:
    description: 'Number of tests passed'
    value: ${{ steps.test.outputs.passed }}
  tests-failed:
    description: 'Number of tests failed'
    value: ${{ steps.test.outputs.failed }}
```

---

## Reusable Action: build-mobile

**Path**: `.github/actions/build-mobile/action.yml`

**Purpose**: Build Android or iOS application

### Inputs

```yaml
inputs:
  platform:
    description: 'Platform to build (android or ios)'
    required: true
  build-type:
    description: 'Build type (debug or release)'
    required: true
  upload-artifact:
    description: 'Upload build artifact'
    required: false
    default: 'true'
```

### Steps

**For Android**:
1. Setup Java JDK 17
2. Build APK or AAB based on type
   - Debug: `flutter build apk --debug`
   - Release: `flutter build apk --release` + `flutter build appbundle --release`
3. Upload artifact(s)

**For iOS**:
1. Select Xcode version
2. Build iOS app
   - Debug: `flutter build ios --debug --no-codesign`
   - Release: `flutter build ipa --release`
3. Upload artifact

### Outputs

```yaml
outputs:
  artifact-name:
    description: 'Name of uploaded artifact'
    value: ${{ steps.upload.outputs.artifact-name }}
  build-path:
    description: 'Path to built artifact'
    value: ${{ steps.build.outputs.path }}
```

---

## Helper Scripts Contracts

### Script: setup-android.sh

**Purpose**: Setup Android build environment

**Location**: `.github/scripts/setup-android.sh`

**Usage**: `./setup-android.sh`

**Actions**:
1. Decode keystore from base64 secret
2. Write keystore to file: `android/app/keystore.jks`
3. Create `android/key.properties` with credentials
4. Validate keystore integrity

**Required Environment Variables**:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

**Exit Codes**:
- `0`: Success
- `1`: Missing required environment variable
- `2`: Keystore decode failed
- `3`: Keystore validation failed

---

### Script: setup-ios.sh

**Purpose**: Setup iOS build environment with code signing

**Location**: `.github/scripts/setup-ios.sh`

**Usage**: `./setup-ios.sh`

**Actions**:
1. Decode certificate from base64 secret
2. Import certificate to keychain
3. Unlock keychain
4. Decode provisioning profile
5. Install provisioning profile
6. Validate setup

**Required Environment Variables**:
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`

**Exit Codes**:
- `0`: Success
- `1`: Missing required environment variable
- `2`: Certificate import failed
- `3`: Provisioning profile install failed

---

### Script: increment-build-number.sh

**Purpose**: Auto-increment build number based on Git history

**Location**: `.github/scripts/increment-build-number.sh`

**Usage**: `./increment-build-number.sh`

**Actions**:
1. Get commit count: `git rev-list --count HEAD`
2. Read current version from pubspec.yaml
3. Update pubspec.yaml with new build number
4. Update iOS Info.plist
5. Update Android build.gradle

**Outputs** (stdout):
```json
{
  "version": "1.0.0",
  "build_number": 42,
  "full_version": "1.0.0+42"
}
```

**Exit Codes**:
- `0`: Success
- `1`: Git command failed
- `2`: File update failed

---

### Script: verify-secrets.sh

**Purpose**: Validate all required secrets are configured

**Location**: `.github/scripts/verify-secrets.sh`

**Usage**: `./verify-secrets.sh [android|ios|all]`

**Actions**:
1. Check for required environment variables based on platform
2. Validate base64 encoding (attempt decode)
3. Report missing/invalid secrets

**Exit Codes**:
- `0`: All secrets valid
- `1`: Missing required secret
- `2`: Invalid secret format

---

### Script: upload-coverage.sh

**Purpose**: Upload coverage report and create PR comment

**Location**: `.github/scripts/upload-coverage.sh`

**Usage**: `./upload-coverage.sh <coverage-percent>`

**Actions**:
1. Generate coverage badge
2. Generate coverage summary markdown
3. Post as PR comment (if PR context)
4. Update workflow summary

**Required Environment Variables**:
- `GITHUB_TOKEN`
- `GITHUB_EVENT_PATH` (for PR number)

**Exit Codes**:
- `0`: Success
- `1`: Comment creation failed

---

## Error Handling Contracts

### Workflow Failures

**Behavior**: On job failure, workflow should:
1. Continue other independent jobs (`continue-on-error: false` by default)
2. Upload logs as artifact
3. Post failure comment on PR (if applicable)
4. Send GitHub notification to commit author

### Retry Logic

**Network Operations**: Retry up to 3 times with exponential backoff
```bash
for i in {1..3}; do
  flutter pub get && break || sleep $((2**i))
done
```

**Artifact Uploads**: Automatic retry by GitHub Actions (built-in)

### Timeout Handling

**Behavior**: If job exceeds timeout:
1. Cancel remaining steps
2. Mark job as failed
3. Upload partial logs
4. Send timeout notification

---

## Success Criteria

### Workflow Success

**ci.yml**: 
- ✅ All lint checks pass
- ✅ All tests pass
- ✅ Coverage ≥80%
- ✅ Debug builds succeed on both platforms

**release.yml**:
- ✅ Signed APK created
- ✅ Signed AAB created
- ✅ Signed IPA created
- ✅ Build metadata generated
- ✅ Artifacts uploaded

**deploy-beta.yml**:
- ✅ AAB uploaded to Google Play Internal Testing
- ✅ IPA uploaded to TestFlight
- ✅ Team notified

**manual-build.yml**:
- ✅ Requested platform(s) built
- ✅ Artifacts uploaded

---

## Versioning

All workflow files and reusable actions follow semantic versioning:
- **Major**: Breaking changes to inputs/outputs
- **Minor**: New features, backward-compatible
- **Patch**: Bug fixes, no interface changes

Current Version: `1.0.0`

---

## Conclusion

These contracts define the exact interface and behavior for all workflows and actions in the CI/CD pipeline. Implementation must adhere to these specifications to ensure consistency and reliability.
