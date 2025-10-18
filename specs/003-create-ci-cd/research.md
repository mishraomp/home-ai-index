# Research: CI/CD Pipeline for Home AI Index Mobile App

**Date**: 2025-10-17  
**Feature**: CI/CD Pipeline Implementation  
**Phase**: 0 - Research & Decision Making

## Overview

This document consolidates research findings for implementing a comprehensive CI/CD pipeline for the Home AI Index Flutter mobile application using GitHub Actions, Fastlane, and bash scripting.

## Key Technology Decisions

### 1. CI/CD Platform: GitHub Actions

**Decision**: Use GitHub Actions as the primary CI/CD platform

**Rationale**:
- **Native Integration**: Seamlessly integrates with GitHub repository (already in use)
- **Cost-Effective**: Free for public repositories, 2000 minutes/month for private repos
- **Flutter Support**: Excellent Flutter ecosystem support with official and community actions
- **Matrix Builds**: Native support for parallel Android/iOS builds
- **Secret Management**: Built-in encrypted secrets for signing keys and credentials
- **Artifact Storage**: Integrated artifact storage with configurable retention
- **Active Community**: Large ecosystem of reusable actions and extensive documentation

**Alternatives Considered**:
- **GitLab CI/CD**: Requires GitLab hosting, migration overhead
- **CircleCI**: Additional service to manage, limited free tier
- **Jenkins**: Self-hosted infrastructure overhead, maintenance burden
- **Azure DevOps**: Good mobile support but introduces Microsoft dependency
- **Bitrise**: Mobile-specific but paid service, vendor lock-in

**Why GitHub Actions Won**: Already using GitHub, zero additional cost for public repos, native integration eliminates authentication complexity, excellent Flutter community support.

---

### 2. iOS Build Automation: Fastlane

**Decision**: Use Fastlane for iOS build signing, provisioning, and deployment automation

**Rationale**:
- **Industry Standard**: De facto standard for iOS/Android mobile app automation
- **Code Signing**: Simplifies complex iOS code signing and provisioning profile management
- **TestFlight Integration**: Native support for beta distribution via TestFlight
- **Match**: Code signing certificate management for teams
- **Gym**: Reliable IPA building with extensive configuration options
- **Pilot**: Automated TestFlight uploads with metadata management
- **Ruby-Based**: Well-documented, mature, extensive plugin ecosystem

**Alternatives Considered**:
- **Manual Xcode Build**: Complex code signing, error-prone, not automatable
- **Xcodebuild Direct**: Requires manual certificate/provisioning management
- **Bitrise**: Proprietary solution, vendor lock-in
- **Codemagic**: Good but paid service for advanced features

**Why Fastlane Won**: Eliminates iOS signing complexity, battle-tested in production at scale, open-source, free, extensive documentation, active community.

---

### 3. Android Build Signing: Gradle Signing Config

**Decision**: Use Gradle's built-in signing configuration with GitHub Secrets for keystore management

**Rationale**:
- **Native Solution**: Built into Android build system, no additional tools
- **Environment Variables**: Supports reading signing credentials from environment variables
- **Secure**: Keystore stored as base64-encoded GitHub Secret
- **Simple**: Minimal configuration in `build.gradle.kts`
- **Fast**: No additional build overhead
- **Standard Practice**: Recommended by Google's official documentation

**Alternatives Considered**:
- **Fastlane (Android)**: Adds Ruby dependency for Android, unnecessary overhead
- **Manual Signing**: Not automatable, requires local keystore
- **Google Play Signing**: Delegates signing to Google but still needs initial keystore

**Why Gradle Signing Won**: Simplest solution, no additional dependencies, official Android approach, well-documented.

---

### 4. Scripting Language: Bash

**Decision**: Use bash scripts for reusable CI/CD helper functions

**Rationale**:
- **Universal**: Available on all GitHub Actions runners (ubuntu, macos)
- **Git/CLI Integration**: Direct integration with git, flutter CLI, fastlane
- **CI/CD Standard**: De facto standard for CI/CD scripting
- **Simple**: No compilation, easy debugging, version-controlled
- **Portable**: Works across local development and CI environments

**Alternatives Considered**:
- **PowerShell**: Windows-centric, less portable to macOS/Linux runners
- **Python**: Requires Python setup, overkill for simple automation
- **Dart**: Not ideal for system/CLI automation tasks
- **Make**: Less readable, platform-specific behavior differences

**Why Bash Won**: Universal availability, perfect fit for CI/CD automation, simple, portable, industry standard.

---

### 5. Code Coverage Tool: lcov

**Decision**: Use lcov for code coverage collection and reporting

**Rationale**:
- **Flutter Native**: `flutter test` generates lcov format by default (`coverage/lcov.info`)
- **GitHub Integration**: Easily integrated with GitHub Actions coverage reporting
- **Standard Format**: Industry-standard coverage format, tool-agnostic
- **Free**: Open-source, no cost
- **Visualization**: Supports HTML reports and badge generation

**Alternatives Considered**:
- **Codecov**: External service, requires account, data leaves GitHub
- **Coveralls**: External service, additional setup
- **SonarQube**: Heavy, requires server setup, overkill

**Why lcov Won**: Flutter native format, no external dependencies, free, GitHub Actions supports it natively.

---

### 6. Build Number Management: Git-Based Versioning

**Decision**: Use Git commit count or tag-based versioning for automated build number increments

**Rationale**:
- **Deterministic**: Build numbers derived from Git history, no state to manage
- **Automatic**: No manual intervention required
- **Unique**: Guaranteed unique build numbers per commit
- **Traceable**: Build number maps directly to Git commit SHA
- **Simple**: Shell script using `git rev-list --count`

**Implementation**:
```bash
# Get commit count on current branch
BUILD_NUMBER=$(git rev-list --count HEAD)
# Or use timestamp for uniqueness
BUILD_NUMBER=$(date +%s)
```

**Alternatives Considered**:
- **Manual Increment**: Error-prone, requires PR updates
- **External Counter**: Requires state storage, additional complexity
- **Timestamp**: Less readable, harder to sequence

**Why Git-Based Won**: Zero state management, deterministic, traceable, automatic, simple.

---

### 7. Artifact Storage: GitHub Artifacts

**Decision**: Use GitHub Artifacts for build artifact storage and retention

**Rationale**:
- **Native Integration**: Built into GitHub Actions, no setup
- **Free Storage**: Included in GitHub Actions quota
- **Retention Policy**: Configurable retention (90 days default, adjustable)
- **Download API**: Accessible via GitHub API and web UI
- **Secure**: Same access controls as repository

**Alternatives Considered**:
- **AWS S3**: Additional cost, external dependency, credential management
- **Google Cloud Storage**: Additional cost, external dependency
- **Azure Blob Storage**: Additional cost, external dependency
- **Artifactory**: Self-hosted, maintenance overhead

**Why GitHub Artifacts Won**: Zero cost, native integration, sufficient retention, no external dependencies.

---

### 8. Beta Distribution

**Decision**: 
- **iOS**: TestFlight via Fastlane Pilot
- **Android**: Google Play Internal Testing via Fastlane Supply

**Rationale**:
- **Official Platforms**: Apple and Google's official beta distribution channels
- **Free**: No additional cost beyond developer account ($99/year Apple, $25 one-time Google)
- **Tester Management**: Built-in tester management and notifications
- **Crash Reporting**: Integrated crash analytics
- **Gradual Rollout**: Support for phased rollouts
- **Fastlane Support**: Excellent Fastlane integration for automation

**Alternatives Considered**:
- **Firebase App Distribution**: Good but adds Firebase dependency
- **HockeyApp/App Center**: Deprecated or being deprecated
- **Custom Solution**: Reinventing the wheel, no crash reporting

**Why Official Platforms Won**: Official support, tester notifications, crash reporting, Fastlane integration, industry standard.

---

## GitHub Actions Workflow Architecture

### Workflow Strategy

**Decision**: Use 4 separate workflow files for clear separation of concerns

1. **`ci.yml`**: Continuous Integration (triggered on every push/PR)
   - Lint checks
   - Run all tests
   - Build debug builds (Android/iOS)
   - Coverage reporting
   
2. **`release.yml`**: Release builds (triggered on merge to main)
   - Build signed release APK
   - Build signed release AAB
   - Build signed release IPA
   - Upload artifacts
   
3. **`deploy-beta.yml`**: Beta deployment (triggered on release tags)
   - Upload AAB to Google Play Internal Testing
   - Upload IPA to TestFlight
   
4. **`manual-build.yml`**: Manual builds (workflow_dispatch trigger)
   - On-demand builds for any branch
   - Useful for debugging or special builds

**Rationale**: Separation of concerns, easier debugging, clearer logs, independent execution, better performance (don't run release builds on feature branches).

---

### Reusable Actions Strategy

**Decision**: Create 3 custom composite actions for common patterns

1. **`setup-flutter`**: Setup Flutter SDK with caching
   - Install Flutter
   - Cache Flutter SDK
   - Cache pub dependencies
   - Run `flutter pub get`
   
2. **`run-tests`**: Execute test suite with coverage
   - Run `flutter test --coverage`
   - Generate coverage report
   - Upload coverage artifact
   
3. **`build-mobile`**: Build Android or iOS app
   - Platform-specific build steps
   - Signing configuration
   - Artifact upload

**Rationale**: DRY principle, consistency across workflows, easier maintenance, testable in isolation.

---

## Secrets Management

### Required GitHub Secrets

**Android**:
- `ANDROID_KEYSTORE_BASE64`: Base64-encoded keystore file
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password
- `ANDROID_KEY_ALIAS`: Key alias
- `ANDROID_KEY_PASSWORD`: Key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Service account JSON for Play Console API

**iOS**:
- `IOS_CERTIFICATE_BASE64`: Base64-encoded distribution certificate (.p12)
- `IOS_CERTIFICATE_PASSWORD`: Certificate password
- `IOS_PROVISIONING_PROFILE_BASE64`: Base64-encoded provisioning profile
- `APP_STORE_CONNECT_API_KEY`: App Store Connect API key
- `APP_STORE_CONNECT_API_ISSUER_ID`: API key issuer ID
- `APP_STORE_CONNECT_API_KEY_ID`: API key ID

**General**:
- `GH_TOKEN`: GitHub personal access token (for API access if needed)

**Security Best Practices**:
- Use GitHub environment secrets for production
- Rotate credentials regularly
- Limit secret access to specific workflows
- Use temporary credentials where possible
- Never log secrets (GitHub automatically masks registered secrets)

---

## Performance Optimization Strategies

### 1. Dependency Caching

**Strategy**: Cache Flutter SDK, pub dependencies, CocoaPods, Gradle caches

```yaml
- uses: actions/cache@v3
  with:
    path: |
      ${{ runner.tool_cache }}/flutter
      ~/.pub-cache
      ~/Library/Caches/CocoaPods
      ~/.gradle/caches
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
```

**Expected Impact**: Reduce build time by 50-70% (3-5 minutes saved per build)

---

### 2. Matrix Builds

**Strategy**: Run Android and iOS builds in parallel using matrix strategy

```yaml
strategy:
  matrix:
    platform: [android, ios]
    include:
      - platform: android
        runner: ubuntu-latest
      - platform: ios
        runner: macos-latest
```

**Expected Impact**: Reduce total pipeline time by 40% (platforms build simultaneously)

---

### 3. Conditional Execution

**Strategy**: Skip unnecessary jobs based on file changes

```yaml
- name: Check for Dart changes
  uses: dorny/paths-filter@v2
  with:
    filters: |
      dart:
        - 'lib/**'
        - 'test/**'
        - 'pubspec.yaml'
```

**Expected Impact**: Skip builds when only documentation changes, saving 10-15 minutes per doc update

---

### 4. Test Sharding

**Strategy**: Split tests across multiple runners for faster execution

```yaml
strategy:
  matrix:
    shard: [1, 2, 3, 4]
run: flutter test --total-shards=4 --shard-index=${{ matrix.shard }}
```

**Expected Impact**: Reduce test execution time from 5 minutes to 1.5 minutes (4x parallelization)

**Decision**: Implement if test suite grows beyond 1000 tests (current: 530 tests, ~2-3 min execution)

---

## Quality Gates

### Enforcement Strategy

**Decision**: Implement progressive quality gates that block merges

1. **Lint Gate**: Zero lint errors required
   ```bash
   flutter analyze --fatal-infos --fatal-warnings
   ```

2. **Test Gate**: All tests must pass
   ```bash
   flutter test
   ```

3. **Coverage Gate**: Minimum 80% coverage required
   ```bash
   lcov --summary coverage/lcov.info | grep "lines......: 80"
   ```

4. **Build Gate**: Debug builds must succeed on both platforms

**Rationale**: Enforce constitution requirements automatically, prevent broken code from merging, maintain high quality standards.

---

## Risk Mitigation

### 1. macOS Runner Cost Management

**Risk**: macOS runners cost 10x Linux minutes (1 macOS minute = 10 Linux minutes)

**Mitigation**:
- Only run iOS builds when necessary (path filters for iOS-specific changes)
- Cache aggressively to minimize build time
- Use smallest macOS runner tier (macos-latest)
- Monitor usage via GitHub billing dashboard
- Consider self-hosted macOS runner for high-volume projects

---

### 2. Secret Rotation

**Risk**: Long-lived credentials may be compromised

**Mitigation**:
- Document secret rotation procedure
- Set calendar reminders for quarterly rotation
- Use App Store Connect API keys with limited permissions
- Use Google Play service accounts with minimal permissions
- Monitor for unauthorized access via audit logs

---

### 3. Build Failures Due to External Dependencies

**Risk**: pub.dev, CocoaPods, or other external services may be unavailable

**Mitigation**:
- Retry logic in scripts (up to 3 attempts with exponential backoff)
- Cache dependencies aggressively
- Timeout limits on network operations
- Fallback to cached dependencies when possible
- Monitor external service status pages

---

### 4. Artifact Storage Limits

**Risk**: 90-day retention may not be sufficient, or storage may reach limits

**Mitigation**:
- Configure retention policy per workflow (90 days for releases, 7 days for feature branches)
- Archive important releases to external storage (S3, Google Cloud)
- Implement artifact cleanup automation
- Monitor storage usage via GitHub API

---

## Workflow Triggers

### Trigger Strategy

**Decision**: Use these trigger patterns

```yaml
# CI Workflow (ci.yml)
on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, develop]

# Release Workflow (release.yml)
on:
  push:
    branches: [main]
    
# Beta Deploy Workflow (deploy-beta.yml)
on:
  push:
    tags:
      - 'v*.*.*'
      
# Manual Build Workflow (manual-build.yml)
on:
  workflow_dispatch:
    inputs:
      platform:
        description: 'Platform to build'
        required: true
        type: choice
        options: [android, ios, both]
```

**Rationale**: 
- CI runs on all branches/PRs (early feedback)
- Release builds only on main (avoid unnecessary signing)
- Beta deploys only on version tags (controlled releases)
- Manual builds for special cases (debugging, one-off builds)

---

## Testing Strategy in CI

### Test Execution Approach

**Decision**: Run tests in this order with fail-fast disabled

1. **Lint** (fast feedback, ~30 seconds)
2. **Unit Tests** (fast, isolated, ~1 minute)
3. **Widget Tests** (medium speed, ~2 minutes)
4. **Integration Tests** (slower, ~2-3 minutes)

**Parallel Execution**: Run lint and tests in parallel jobs for speed

**Coverage Collection**: Generate coverage only in test job (not lint)

**Rationale**: Fast feedback loop, progressive complexity, parallel execution for speed, comprehensive coverage.

---

## Documentation Requirements

### Required Documentation

1. **CI_CD_SETUP.md**: Comprehensive setup guide
   - Prerequisites (developer accounts, credentials)
   - Secret setup instructions
   - First-time configuration
   - Troubleshooting common issues
   
2. **secrets-requirements.md**: Detailed secret documentation
   - Each secret's purpose
   - How to generate/obtain each secret
   - Rotation procedures
   - Security considerations
   
3. **Workflow README**: Inline comments in YAML
   - Explain each step's purpose
   - Document input variables
   - Link to relevant documentation

**Rationale**: Enable team members to maintain and troubleshoot CI/CD independently, reduce bus factor, onboard new developers quickly.

---

## Success Metrics

### Key Performance Indicators (KPIs)

**Build Performance**:
- Lint check: <1 minute (target: 30 seconds)
- Test suite: <5 minutes (target: 2-3 minutes)
- Android debug build: <8 minutes (target: 5-6 minutes)
- iOS debug build: <12 minutes (target: 8-10 minutes)
- Total CI pipeline: <15 minutes (target: 10-12 minutes)

**Reliability**:
- Build success rate: >95% for valid code
- False positive rate: <2%
- Flaky test rate: <1%

**Coverage**:
- Code coverage: ≥80%
- Coverage visibility: 100% of commits

**Cost**:
- GitHub Actions minutes/month: <2000 (free tier limit)
- macOS runner usage: <200 minutes/month (after 10x multiplier)

---

## Conclusion

This research establishes a comprehensive, production-ready CI/CD pipeline architecture using GitHub Actions, Fastlane, and bash scripting. All technology choices are based on industry best practices, cost-effectiveness, and alignment with the existing Flutter/GitHub ecosystem. The implementation will enforce constitution requirements automatically while providing fast feedback and reliable builds.

**Next Steps**: Proceed to Phase 1 (Design & Contracts) to create detailed workflow specifications and API contracts.
