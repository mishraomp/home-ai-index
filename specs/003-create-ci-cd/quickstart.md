# CI/CD Pipeline Quickstart Guide

**Date**: 2025-10-17  
**Feature**: CI/CD Pipeline for Home AI Index  
**Audience**: Developers setting up CI/CD for the first time

## Overview

This guide will help you set up the complete CI/CD pipeline for the Home AI Index Flutter mobile application. After completing these steps, every code push will automatically trigger builds, tests, and deployments.

**Estimated Setup Time**: 2-3 hours (first time)

---

## Prerequisites

Before starting, ensure you have:

- [ ] Admin access to the GitHub repository
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] Active Google Play Console account ($25 one-time)
- [ ] macOS machine with Xcode (for generating iOS certificates)
- [ ] Android Studio or Java JDK 17+ (for generating Android keystore)
- [ ] Git and Flutter SDK installed locally

---

## Step 1: Generate Android Signing Credentials

### 1.1 Create Android Keystore

**On Linux/macOS/Windows**:
```bash
keytool -genkey -v -keystore home-ai-index.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias home-ai-index
```

**You'll be prompted for**:
- Keystore password (remember this!)
- Key password (remember this!)
- Your name, organization, city, state, country

**Store securely**:
- Save `home-ai-index.jks` in a secure location (password manager, encrypted drive)
- **Never commit to Git!**

### 1.2 Encode Keystore to Base64

**Linux/macOS**:
```bash
cat home-ai-index.jks | base64 | tr -d '\n' > keystore-base64.txt
```

**Windows PowerShell**:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("home-ai-index.jks")) | Out-File -FilePath keystore-base64.txt -Encoding ASCII -NoNewline
```

**Result**: `keystore-base64.txt` contains the base64-encoded keystore

---

## Step 2: Generate iOS Signing Credentials

### 2.1 Create Distribution Certificate

**Using Xcode**:
1. Open Xcode
2. Go to **Xcode → Preferences → Accounts**
3. Select your Apple ID → **Manage Certificates**
4. Click **+** → **Apple Distribution**
5. Certificate is created and added to your Keychain

### 2.2 Export Certificate

**Using Keychain Access**:
1. Open **Keychain Access** app
2. Select **login** keychain
3. Find **Apple Distribution: [Your Name]**
4. Right-click → **Export "Apple Distribution..."**
5. Save as `ios-distribution.p12`
6. Set a strong password (remember this!)

### 2.3 Create Provisioning Profile

**Using Apple Developer Portal**:
1. Go to https://developer.apple.com/account/resources/profiles
2. Click **+** to create new profile
3. Select **App Store** under Distribution
4. Select your App ID (create if doesn't exist)
5. Select your Distribution certificate
6. Name it: `Home AI Index AppStore`
7. **Download** `Home_AI_Index_AppStore.mobileprovision`

### 2.4 Encode Certificate and Profile

**Encode certificate**:
```bash
# macOS/Linux
cat ios-distribution.p12 | base64 | tr -d '\n' > certificate-base64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios-distribution.p12")) | Out-File -FilePath certificate-base64.txt -Encoding ASCII -NoNewline
```

**Encode provisioning profile**:
```bash
# macOS/Linux
cat Home_AI_Index_AppStore.mobileprovision | base64 | tr -d '\n' > profile-base64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("Home_AI_Index_AppStore.mobileprovision")) | Out-File -FilePath profile-base64.txt -Encoding ASCII -NoNewline
```

---

## Step 3: Generate Google Play Service Account

### 3.1 Access Google Play Console

1. Go to https://play.google.com/console
2. Select your app (or create app if new)
3. Navigate to **Setup → API access**

### 3.2 Create Service Account

1. Click **Create new service account**
2. Follow link to **Google Cloud Console**
3. Click **Create Service Account**
4. Name: `github-actions-ci`
5. Description: `GitHub Actions CI/CD automation`
6. Click **Create and Continue**
7. Grant role: **Service Account User**
8. Click **Continue** → **Done**

### 3.3 Create JSON Key

1. Click on the newly created service account
2. Go to **Keys** tab
3. Click **Add Key → Create new key**
4. Select **JSON** format
5. Click **Create**
6. **Download** the JSON file (e.g., `github-actions-ci-xxxxx.json`)

### 3.4 Grant Permissions in Play Console

1. Return to **Google Play Console → API access**
2. Find `github-actions-ci@...` service account
3. Click **Grant access**
4. Under **App permissions**, select your app
5. Grant permissions:
   - **Releases**: Create and edit releases → **Internal testing**
   - **Release to production**: NOT selected
6. Click **Invite user**
7. **Accept invitation** (check service account email)

---

## Step 4: Create App Store Connect API Key

### 4.1 Generate API Key

1. Go to https://appstoreconnect.apple.com/access/api
2. Click **+** to create new key
3. **Name**: `GitHub Actions CI`
4. **Access**: **App Manager**
5. Click **Generate**
6. **Download** the `.p8` file immediately (only shown once!)
7. Note the **Key ID** (e.g., `ABC123DEFG`)
8. Note the **Issuer ID** (UUID at top of page)

**Important**: Save the `.p8` file securely - it cannot be re-downloaded!

---

## Step 5: Configure GitHub Secrets

### 5.1 Access Repository Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### 5.2 Add Android Secrets

Add these secrets one by one:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `ANDROID_KEYSTORE_BASE64` | Contents of `keystore-base64.txt` | Step 1.2 |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | Step 1.1 |
| `ANDROID_KEY_ALIAS` | `home-ai-index` | Step 1.1 |
| `ANDROID_KEY_PASSWORD` | Key password | Step 1.1 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Contents of JSON file | Step 3.3 |

### 5.3 Add iOS Secrets

Add these secrets:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `IOS_CERTIFICATE_BASE64` | Contents of `certificate-base64.txt` | Step 2.4 |
| `IOS_CERTIFICATE_PASSWORD` | Certificate export password | Step 2.2 |
| `IOS_PROVISIONING_PROFILE_BASE64` | Contents of `profile-base64.txt` | Step 2.4 |
| `APP_STORE_CONNECT_API_KEY` | Contents of `.p8` file (including BEGIN/END lines) | Step 4.1 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID (UUID) | Step 4.1 |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID (10 chars) | Step 4.1 |

### 5.4 Verify Secrets

**Check that all secrets are configured**:
- Go to Settings → Secrets and variables → Actions
- You should see 11 repository secrets total
- Verify names match exactly (case-sensitive)

---

## Step 6: Create Workflow Files

### 6.1 Create Directory Structure

```bash
cd /path/to/home-ai-index
mkdir -p .github/workflows
mkdir -p .github/scripts
mkdir -p .github/actions/setup-flutter
mkdir -p .github/actions/run-tests
mkdir -p .github/actions/build-mobile
```

### 6.2 Create Workflow Files

Create these files in `.github/workflows/`:

**Required workflows**:
- `ci.yml` - Continuous Integration (lint, test, build)
- `release.yml` - Release builds (signed APK/AAB/IPA)
- `deploy-beta.yml` - Beta deployment (TestFlight/Play Internal)
- `manual-build.yml` - Manual build trigger

**See the implementation files in the actual `.github/workflows/` directory**

### 6.3 Create Helper Scripts

Create these files in `.github/scripts/`:
- `setup-android.sh` - Android environment setup
- `setup-ios.sh` - iOS environment setup
- `increment-build-number.sh` - Auto-increment build numbers
- `verify-secrets.sh` - Validate secrets configuration
- `upload-coverage.sh` - Upload coverage reports

### 6.4 Create Reusable Actions

Create `action.yml` files in:
- `.github/actions/setup-flutter/`
- `.github/actions/run-tests/`
- `.github/actions/build-mobile/`

---

## Step 7: Update Android Build Configuration

### 7.1 Update build.gradle.kts

Edit `android/app/build.gradle.kts`:

```kotlin
// Add before android {} block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... existing release config ...
        }
    }
}
```

### 7.2 Add key.properties to .gitignore

Ensure `android/key.properties` is in `.gitignore`:

```
# Android signing
android/key.properties
android/app/*.jks
android/app/*.keystore
```

---

## Step 8: Setup iOS Build Configuration (Optional)

### 8.1 Install Fastlane

```bash
cd ios
gem install fastlane
fastlane init
```

### 8.2 Configure Fastlane

Edit `ios/fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "build/ios/ipa"
    )
    
    upload_to_testflight(
      api_key_path: "app_store_connect_api_key.json",
      skip_waiting_for_build_processing: true
    )
  end
end
```

---

## Step 9: Test the Pipeline

### 9.1 Commit and Push

```bash
git add .github/
git commit -m "feat: Add CI/CD pipeline"
git push origin 003-create-ci-cd
```

### 9.2 Verify CI Workflow Runs

1. Go to GitHub → **Actions** tab
2. You should see `CI Pipeline` workflow running
3. Monitor the jobs:
   - **lint** - Should complete in ~1 minute
   - **test** - Should complete in ~3 minutes
   - **build-android** - Should complete in ~8 minutes
   - **build-ios** - Should complete in ~12 minutes (if iOS files changed)

### 9.3 Check for Errors

**If workflow fails**:
1. Click on the failed job
2. Expand failed step
3. Read error message
4. Common issues:
   - Missing secrets → Go back to Step 5
   - Flutter version mismatch → Update workflow
   - Test failures → Fix tests locally first
   - Build errors → Test build locally

---

## Step 10: Test Release Workflow

### 10.1 Merge to Main

```bash
# After CI passes on feature branch
git checkout main
git merge 003-create-ci-cd
git push origin main
```

### 10.2 Verify Release Workflow

1. Go to GitHub → **Actions** tab
2. You should see `Release Builds` workflow running
3. Monitor jobs:
   - **release-android** - Builds signed APK & AAB
   - **release-ios** - Builds signed IPA

### 10.3 Download Artifacts

1. Click on completed workflow run
2. Scroll to **Artifacts** section
3. Download:
   - `android-release-apk`
   - `android-release-aab`
   - `ios-release-ipa`
4. Verify files are signed correctly:
   ```bash
   # Verify Android APK signature
   jarsigner -verify -verbose -certs app-release.apk
   
   # Verify iOS IPA (macOS)
   codesign -dvv Runner.app
   ```

---

## Step 11: Test Beta Deployment (Optional)

### 11.1 Create Release Tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 11.2 Verify Deploy Workflow

1. Go to GitHub → **Actions** tab
2. You should see `Deploy Beta` workflow running
3. Monitor jobs:
   - **deploy-android-beta** - Uploads AAB to Google Play Internal Testing
   - **deploy-ios-beta** - Uploads IPA to TestFlight

### 11.3 Verify Uploads

**Google Play Console**:
1. Go to https://play.google.com/console
2. Select your app → **Internal testing**
3. You should see new version uploaded

**App Store Connect**:
1. Go to https://appstoreconnect.apple.com
2. Select your app → **TestFlight**
3. You should see new build processing

---

## Step 12: Monitor and Maintain

### 12.1 Set Up Notifications

1. Go to GitHub → **Settings** → **Notifications**
2. Enable **GitHub Actions** notifications
3. Choose email or mobile notifications

### 12.2 Monitor Workflow Runs

- Check GitHub Actions dashboard regularly
- Review failed workflows promptly
- Monitor build times for performance degradation

### 12.3 Rotate Secrets (Quarterly)

- Set calendar reminder for secret rotation
- Follow rotation procedures in `secrets-requirements.md`
- Test CI/CD after rotation

---

## Troubleshooting

### Common Issues

**Issue**: `Secret not found`  
**Solution**: Verify secret name matches exactly (case-sensitive), check repository settings

**Issue**: `Android build failed - keystore not found`  
**Solution**: Verify `ANDROID_KEYSTORE_BASE64` is valid, check base64 encoding

**Issue**: `iOS build failed - code signing error`  
**Solution**: Verify certificate and provisioning profile match, check bundle ID

**Issue**: `Tests failing in CI but passing locally`  
**Solution**: Check Flutter version matches, verify test isolation, check for file system dependencies

**Issue**: `Workflow not triggering`  
**Solution**: Check trigger conditions, verify workflow file is in correct location

**Issue**: `Google Play upload failed - Permission denied`  
**Solution**: Verify service account has correct permissions, check JSON key is valid

**Issue**: `TestFlight upload failed - Invalid API key`  
**Solution**: Verify API key, issuer ID, and key ID are correct

---

## Next Steps

After successful setup:

1. ✅ **Document your setup** - Add team-specific notes to this guide
2. ✅ **Train team members** - Share this guide with the team
3. ✅ **Monitor costs** - Track GitHub Actions minutes usage
4. ✅ **Optimize performance** - Review build times and optimize caching
5. ✅ **Set up environments** - Create staging/production GitHub Environments
6. ✅ **Add status badges** - Add workflow status badges to README

---

## Quick Reference

### Key Files
- `.github/workflows/ci.yml` - Main CI workflow
- `.github/workflows/release.yml` - Release builds
- `.github/workflows/deploy-beta.yml` - Beta deployment
- `.github/scripts/` - Helper scripts
- `android/app/build.gradle.kts` - Android signing config
- `ios/fastlane/Fastfile` - iOS automation config

### Key Commands
```bash
# Run CI checks locally
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build ios --debug --no-codesign

# Check workflow syntax
actionlint .github/workflows/*.yml

# View recent workflow runs
gh run list

# Trigger manual build
gh workflow run manual-build.yml -f platform=both -f build-type=debug
```

### Helpful Links
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)

---

## Support

**For help with CI/CD pipeline**:
- Check documentation in `specs/003-create-ci-cd/`
- Review GitHub Actions logs
- Consult team lead or DevOps engineer

**For emergency issues**:
- Disable workflows temporarily (GitHub Settings → Actions)
- Rotate compromised secrets immediately
- Contact repository administrators

---

## Conclusion

You now have a fully automated CI/CD pipeline that:
- ✅ Runs lint and tests on every push
- ✅ Builds debug builds for every branch
- ✅ Creates signed release builds on main
- ✅ Deploys to beta testing on tags
- ✅ Enforces 80% code coverage
- ✅ Provides fast feedback (<15 minutes)

**Happy building! 🚀**
