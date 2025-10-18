# Phase 1 Implementation - Testing & Validation Checklist

This checklist tracks validation tasks for Phase 1 of the CI/CD pipeline implementation.

## ✅ Completed Tasks

### Setup (Phase 1)
- [x] Create directory structure (.github/workflows, .github/actions, .github/scripts)
- [x] Update .gitignore with CI/CD patterns

### Reusable Actions (Phase 2)
- [x] Create setup-flutter action
- [x] Create run-tests action
- [x] Create build-mobile action

### Helper Scripts (Phase 3)
- [x] Create setup-android.sh
- [x] Create increment-build-number.sh
- [x] Create verify-secrets.sh
- [x] Create upload-coverage.sh

### CI Workflow (Phase 4)
- [x] Create ci.yml workflow with lint, test, and build-android jobs

### Android Configuration (Phase 5)
- [x] Update build.gradle.kts with signing configuration
- [x] Create proguard-rules.pro
- [x] Create key.properties.example

### Documentation (Phase 6)
- [x] Create docs/CI_CD_SETUP.md
- [x] Update README.md with CI badge and documentation link

## 🔄 Pending Validation Tasks

### 1. YAML Syntax Validation
- [ ] Validate ci.yml syntax
- [ ] Validate setup-flutter action.yml syntax
- [ ] Validate run-tests action.yml syntax
- [ ] Validate build-mobile action.yml syntax

**How to validate:**
```bash
# Option 1: Using yamllint (requires installation)
yamllint .github/workflows/ci.yml
yamllint .github/actions/*/action.yml

# Option 2: Using GitHub Actions CLI (requires gh CLI)
gh workflow view ci.yml

# Option 3: Push to GitHub and check for syntax errors
```

### 2. Bash Script Validation
- [ ] Validate setup-android.sh syntax
- [ ] Validate increment-build-number.sh syntax
- [ ] Validate verify-secrets.sh syntax
- [ ] Validate upload-coverage.sh syntax

**How to validate:**
```bash
# Option 1: Using shellcheck (requires installation)
shellcheck .github/scripts/*.sh

# Option 2: Using bash -n (dry-run)
bash -n .github/scripts/setup-android.sh
bash -n .github/scripts/increment-build-number.sh
bash -n .github/scripts/verify-secrets.sh
bash -n .github/scripts/upload-coverage.sh

# Option 3: Manual execution in test environment
```

### 3. Local Testing (Optional but Recommended)
- [ ] Test setup-android.sh with mock secrets
- [ ] Test increment-build-number.sh
- [ ] Test verify-secrets.sh with valid/invalid secrets
- [ ] Test upload-coverage.sh after running tests

**Local test commands:**
```bash
# Make scripts executable (Linux/macOS)
chmod +x .github/scripts/*.sh

# Test increment-build-number.sh
.github/scripts/increment-build-number.sh

# Test verify-secrets.sh (set env vars first)
export ANDROID_KEYSTORE_BASE64="test"
export ANDROID_KEYSTORE_PASSWORD="test"
export ANDROID_KEY_ALIAS="test"
export ANDROID_KEY_PASSWORD="test"
.github/scripts/verify-secrets.sh

# Test upload-coverage.sh (after running flutter test --coverage)
flutter test --coverage
.github/scripts/upload-coverage.sh
```

### 4. Commit and Push
- [ ] Review all changes with git diff
- [ ] Commit changes to 003-create-ci-cd branch
- [ ] Push to remote repository

**Git commands:**
```bash
git status
git add .github/
git add android/
git add docs/CI_CD_SETUP.md
git add README.md
git commit -m "feat: implement CI/CD pipeline with GitHub Actions

- Add reusable composite actions (setup-flutter, run-tests, build-mobile)
- Add helper scripts for Android setup, build numbering, secrets validation
- Create ci.yml workflow with lint, test, and build jobs
- Configure Android signing with ProGuard rules
- Add comprehensive CI/CD setup documentation
- Update README with CI badge and documentation links

Implements Phase 1: Ubuntu runners, Android builds only
Addresses user stories: P1-001, P1-002, P1-003, P1-004"

git push origin 003-create-ci-cd
```

### 5. Monitor First Workflow Run
- [ ] Verify workflow appears in GitHub Actions tab
- [ ] Check lint job passes
- [ ] Check test job passes (with 80% coverage)
- [ ] Check build-android job passes (debug build for PR)
- [ ] Review workflow logs for warnings

**What to check:**
- Workflow run time (should be <15 minutes)
- Cache hit rates (pub-cache, gradle-cache)
- Test coverage percentage (must be ≥80%)
- Artifact uploads (debug APK)

### 6. Verify Artifacts
- [ ] Download debug APK from workflow artifacts
- [ ] Verify APK installs on Android device/emulator
- [ ] Check coverage report artifact
- [ ] Verify artifact retention policies

**Expected artifacts:**
- `android-debug-{version}+{build}` (7-day retention)
- `coverage-report-{version}+{build}` (30-day retention)

### 7. Test PR Flow
- [ ] Create a test PR from 003-create-ci-cd to main
- [ ] Verify CI checks run automatically
- [ ] Check that coverage PR comment is posted
- [ ] Verify debug build artifact is uploaded
- [ ] Confirm no release build is triggered

### 8. Test Release Flow (After Merge)
- [ ] Merge PR to main branch
- [ ] Verify CI runs on main branch push
- [ ] Check secrets validation passes
- [ ] Verify Android signing setup works
- [ ] Confirm release APK + AAB are built
- [ ] Download and verify signed release artifacts

**Note:** Release flow requires GitHub secrets to be configured first!

## 🎯 Success Criteria

All items must be ✅ before Phase 1 is considered complete:

- [ ] All YAML files have valid syntax
- [ ] All bash scripts pass shellcheck
- [ ] At least one successful workflow run
- [ ] All 530+ tests pass in CI
- [ ] Coverage ≥80% enforced
- [ ] Debug APK artifact downloadable
- [ ] Documentation is complete and accurate
- [ ] README badges are working

## 📝 Notes

### Known Limitations (Phase 1)
- Ubuntu runners only (no macOS for iOS builds)
- Android builds only (iOS in Phase 2)
- Manual Google Play deployment (automation in Phase 2)
- No beta distribution yet (Phase 3)

### Next Steps (Future Phases)
- Phase 2: Add iOS builds with macOS runners
- Phase 2: Implement Google Play automated deployment
- Phase 3: Add Firebase App Distribution for beta testing
- Phase 3: Implement Slack/Discord notifications
- Phase 3: Add performance monitoring integration

## 🐛 Troubleshooting

### If YAML validation fails:
1. Check indentation (use spaces, not tabs)
2. Verify all required fields are present
3. Check for typos in action/workflow names
4. Validate with online YAML linter

### If bash scripts fail:
1. Check for Windows line endings (should be LF, not CRLF)
2. Verify shebang is correct: `#!/bin/bash`
3. Test with `bash -n` for syntax errors
4. Run shellcheck for best practices

### If workflow fails on first run:
1. Check GitHub Actions logs for specific error
2. Verify Flutter version 3.35.6 is available
3. Check for network issues (pub.dev, GitHub)
4. Review dependency compatibility

---

**Last Updated:** 2025-01-XX  
**Phase:** 1 (Ubuntu + Android only)  
**Status:** Implementation complete, validation pending
