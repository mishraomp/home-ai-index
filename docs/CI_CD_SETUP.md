# CI/CD Setup Guide

This document describes the CI/CD pipeline setup for the Home AI Index mobile application using GitHub Actions.

## 📋 Table of Contents

- [Overview](#overview)
- [Pipeline Architecture](#pipeline-architecture)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Workflows](#workflows)
- [Secrets Management](#secrets-management)
- [Build Artifacts](#build-artifacts)
- [Troubleshooting](#troubleshooting)

## Overview

The CI/CD pipeline automates:
- ✅ Code quality checks (lint, analyze, format)
- ✅ Automated testing with coverage enforcement (80% minimum)
- ✅ Android app builds (debug for PRs, release for main branch)
- ✅ Build artifact uploads
- ✅ Coverage reporting with PR comments

### Pipeline Triggers

- **Push** to `main`, `develop`, or `feature/**` branches
- **Pull requests** to `main` or `develop`
- **Manual** workflow dispatch

## Pipeline Architecture

```
┌─────────────┐
│   Trigger   │
│ (Push/PR)   │
└──────┬──────┘
       │
       ├──────────────┬──────────────┐
       ▼              ▼              ▼
  ┌────────┐    ┌─────────┐    ┌─────────┐
  │  Lint  │    │  Test   │    │  Build  │
  │Analyze │    │Coverage │    │ Android │
  └────────┘    └─────────┘    └─────────┘
       │              │              │
       └──────────────┴──────────────┘
                      │
                      ▼
              ┌──────────────┐
              │   Artifacts  │
              │    Upload    │
              └──────────────┘
```

### Jobs

1. **lint** (10 min timeout)
   - Code formatting verification
   - Static analysis with `flutter analyze`
   - Dependency checks
   - Runs on: `ubuntu-latest`

2. **test** (15 min timeout)
   - Unit, widget, and integration tests
   - Coverage collection (80% threshold)
   - Coverage summary generation
   - PR comment posting
   - Runs on: `ubuntu-latest`

3. **build-android** (20 min timeout)
   - Requires: lint + test to pass
   - Debug builds for PRs
   - Release builds for main branch
   - Automatic version bumping (git commit count)
   - Signed release builds with keystore
   - Runs on: `ubuntu-latest`

## Prerequisites

### Required Tools

- Flutter 3.35.6 or later
- Dart 3.9+
- Java 17 (for Android builds)
- lcov (for coverage reporting)

### GitHub Repository Settings

1. Enable GitHub Actions in repository settings
2. Configure branch protection rules (recommended):
   - Require status checks to pass before merging
   - Require branches to be up to date before merging
   - Include status checks: `lint`, `test`, `build-android`

## Setup Instructions

### 1. Generate Android Keystore

```bash
# Generate a new keystore (one-time setup)
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# You will be prompted for:
# - Keystore password (save this!)
# - Key password (save this!)
# - Distinguished name information
```

### 2. Encode Keystore to Base64

```bash
# Linux/macOS
base64 -i keystore.jks -o keystore.b64

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("keystore.jks")) | Out-File -Encoding ASCII keystore.b64
```

### 3. Configure GitHub Secrets

Navigate to: **Settings > Secrets and variables > Actions**

Create the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file | (paste from keystore.b64) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | `your-store-password` |
| `ANDROID_KEY_ALIAS` | Key alias from keystore | `upload` |
| `ANDROID_KEY_PASSWORD` | Key password | `your-key-password` |

#### Optional Secrets (for Google Play deployment)

| Secret Name | Description |
|-------------|-------------|
| `ANDROID_SERVICE_ACCOUNT_JSON_BASE64` | Google Play service account JSON (base64) |
| `SLACK_WEBHOOK_URL` | Slack webhook for build notifications |

### 4. Local Testing Setup (Optional)

Create `android/key.properties` for local release builds:

```bash
cp android/key.properties.example android/key.properties
# Edit android/key.properties with your values
```

**⚠️ Never commit `android/key.properties` to git!** (Already in .gitignore)

### 5. Verify Setup

Run the verification script locally:

```bash
# Make scripts executable
chmod +x .github/scripts/*.sh

# Verify secrets (requires env vars set)
export ANDROID_KEYSTORE_BASE64="..."
export ANDROID_KEYSTORE_PASSWORD="..."
export ANDROID_KEY_ALIAS="..."
export ANDROID_KEY_PASSWORD="..."

.github/scripts/verify-secrets.sh
```

## Workflows

### ci.yml - Main CI/CD Pipeline

**Location:** `.github/workflows/ci.yml`

**Features:**
- Parallel lint and test execution
- Conditional release builds (main branch only)
- Automatic build number incrementation
- Coverage threshold enforcement
- Artifact retention: 7 days (debug), 30 days (release)

**Workflow Inputs:**
- None (fully automated based on trigger)

### Reusable Actions

#### setup-flutter
**Location:** `.github/actions/setup-flutter/`

Configures Flutter environment with SDK caching.

**Inputs:**
- `flutter-version` (optional): Flutter version to install

**Outputs:**
- `version`: Installed Flutter version

#### run-tests
**Location:** `.github/actions/run-tests/`

Executes tests with coverage enforcement.

**Inputs:**
- `coverage-threshold` (optional): Minimum coverage % (default: 80)

**Outputs:**
- `coverage`: Actual coverage percentage

#### build-mobile
**Location:** `.github/actions/build-mobile/`

Builds Android/iOS apps (Phase 1: Android only).

**Inputs:**
- `platform`: Target platform (`android` or `ios`)
- `build-type`: Build type (`debug` or `release`)

**Outputs:**
- `artifact-name`: Uploaded artifact name

### Helper Scripts

| Script | Purpose |
|--------|---------|
| `setup-android.sh` | Decode keystore and create key.properties |
| `increment-build-number.sh` | Auto-increment build number from git commits |
| `verify-secrets.sh` | Validate required secrets are present |
| `upload-coverage.sh` | Generate coverage summary and PR comments |

## Secrets Management

### Security Best Practices

1. **Never commit secrets** to version control
2. **Rotate secrets** annually or when compromised
3. **Use separate keystores** for debug/release
4. **Limit secret access** using environment protection rules

### Secret Rotation Procedure

1. Generate new keystore
2. Update GitHub secrets
3. Test with a manual workflow run
4. Archive old keystore securely
5. Update Play Console upload keys (if applicable)

### Secret Validation

The pipeline automatically validates secrets before release builds:

```yaml
- name: Verify secrets
  run: .github/scripts/verify-secrets.sh
  env:
    ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
    # ... other secrets
```

## Build Artifacts

### Artifact Retention

| Artifact Type | Retention | Trigger |
|---------------|-----------|---------|
| Debug APK | 7 days | Pull requests |
| Release APK | 30 days | Push to main |
| Release AAB | 30 days | Push to main |
| Coverage Report | 30 days | All builds |

### Downloading Artifacts

1. Navigate to **Actions** tab
2. Select a workflow run
3. Scroll to **Artifacts** section
4. Click artifact name to download

### Artifact Naming Convention

- `android-debug-{version}+{build}` - Debug APK
- `android-release-{version}+{build}` - Release APK + AAB
- `coverage-report-{version}+{build}` - Coverage data

## Troubleshooting

### Common Issues

#### Build Fails: "keystore.jks not found"

**Cause:** Missing or invalid `ANDROID_KEYSTORE_BASE64` secret

**Solution:**
1. Verify secret exists in repository settings
2. Re-encode keystore: `base64 -i keystore.jks`
3. Update GitHub secret with new value

#### Build Fails: "Invalid keystore format"

**Cause:** Keystore not properly base64-encoded

**Solution:**
```bash
# Ensure no line breaks in base64 output
base64 -w 0 keystore.jks > keystore.b64  # Linux
base64 -i keystore.jks | tr -d '\n' > keystore.b64  # macOS
```

#### Test Coverage Below Threshold

**Cause:** Test coverage fell below 80%

**Solution:**
1. Run locally: `flutter test --coverage`
2. Generate HTML report: `genhtml coverage/lcov.info -o coverage/html`
3. Open `coverage/html/index.html` to identify untested code
4. Add tests to increase coverage

#### Build Timeout

**Cause:** Build exceeded 20-minute timeout

**Solution:**
1. Check for infinite loops in tests
2. Reduce test parallelization
3. Contact GitHub support to request higher timeout limits

### Debug Mode

Enable step-level debugging:

1. Go to **Settings > Secrets and variables > Actions**
2. Add variable: `ACTIONS_STEP_DEBUG` = `true`
3. Re-run workflow

### Viewing Logs

- **Real-time logs:** Actions tab > Running workflow
- **Historical logs:** Actions tab > Completed workflow > Job > Step
- **Download logs:** Workflow run > gear icon > Download log archive

### Manual Workflow Dispatch

To trigger a workflow manually:

1. Go to **Actions** tab
2. Select **CI** workflow
3. Click **Run workflow** button
4. Select branch
5. Click **Run workflow**

## Performance Optimization

### Caching Strategy

The pipeline caches:
- ✅ Flutter SDK (`~/.flutter`)
- ✅ Pub dependencies (`~/.pub-cache`)
- ✅ Gradle dependencies (`~/.gradle`)

**Cache hit rate:** ~90% on subsequent runs

### Parallelization

- Lint and test jobs run in parallel
- Build job waits for both (fail-fast)

### Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Automatically cancels outdated runs on new pushes.

## Next Steps

### Phase 2 Features (Future)

- [ ] iOS builds (requires macOS runners)
- [ ] Automated Google Play deployment
- [ ] Beta testing distribution (Firebase App Distribution)
- [ ] Slack/Discord notifications
- [ ] Changelog generation
- [ ] Automated release notes

### Monitoring

- [ ] Set up Codecov integration
- [ ] Configure GitHub branch protection rules
- [ ] Create CODEOWNERS file

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Android Signing Guide](https://developer.android.com/studio/publish/app-signing)

---

**Last Updated:** 2025-10-18  
**Maintained By:** DevOps Team  
**Contact:** [Create an issue](../../issues/new)
