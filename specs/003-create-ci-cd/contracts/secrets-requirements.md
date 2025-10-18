# Secrets Requirements

**Date**: 2025-10-17  
**Feature**: CI/CD Pipeline Implementation  
**Purpose**: Document all required GitHub Secrets for CI/CD pipeline operation

## Overview

This document details every secret required for the CI/CD pipeline, including how to generate them, where to obtain them, rotation procedures, and security considerations.

---

## Android Secrets

### ANDROID_KEYSTORE_BASE64

**Purpose**: Base64-encoded Android keystore file for app signing

**How to Generate**:

1. **Create new keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore home-ai-index.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias home-ai-index \
     -storepass <KEYSTORE_PASSWORD> \
     -keypass <KEY_PASSWORD>
   ```

2. **Encode to base64**:
   ```bash
   # On Linux/macOS
   cat home-ai-index.jks | base64 | tr -d '\n' > keystore.txt
   
   # On Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("home-ai-index.jks")) | Out-File -FilePath keystore.txt -Encoding ASCII -NoNewline
   ```

3. **Add to GitHub Secrets**:
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `ANDROID_KEYSTORE_BASE64`
   - Value: Contents of `keystore.txt`

**Rotation Schedule**: Every 2 years (or when compromised)

**Security Notes**:
- Never commit `.jks` file to repository
- Store backup in secure password manager
- Keep keystore password separate from keystore file

---

### ANDROID_KEYSTORE_PASSWORD

**Purpose**: Password for the Android keystore file

**How to Obtain**: Created when generating keystore (see above)

**Format**: String (alphanumeric + special characters, 12+ characters recommended)

**Add to GitHub Secrets**:
- Name: `ANDROID_KEYSTORE_PASSWORD`
- Value: The password you used when creating the keystore

**Rotation Schedule**: Every 6 months (or when team member leaves)

**Security Notes**:
- Use strong password (≥16 characters, mixed case, numbers, symbols)
- Store in password manager
- Different from `ANDROID_KEY_PASSWORD`

---

### ANDROID_KEY_ALIAS

**Purpose**: Alias name for the signing key within the keystore

**How to Obtain**: The alias you specified when creating the keystore (e.g., `home-ai-index`)

**Format**: String (lowercase, no spaces)

**Add to GitHub Secrets**:
- Name: `ANDROID_KEY_ALIAS`
- Value: `home-ai-index` (or your chosen alias)

**Rotation Schedule**: Never (unless creating new keystore)

**Security Notes**: Not sensitive but stored as secret for consistency

---

### ANDROID_KEY_PASSWORD

**Purpose**: Password for the specific key (alias) within the keystore

**How to Obtain**: Created when generating keystore (see above)

**Format**: String (alphanumeric + special characters, 12+ characters recommended)

**Add to GitHub Secrets**:
- Name: `ANDROID_KEY_PASSWORD`
- Value: The key password you used when creating the keystore

**Rotation Schedule**: Every 6 months (or when team member leaves)

**Security Notes**:
- Use strong password (≥16 characters)
- Can be same as keystore password but not recommended
- Store in password manager

---

### GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

**Purpose**: Google Play Console API service account credentials for automated uploads

**How to Generate**:

1. **Access Google Play Console**:
   - Go to https://play.google.com/console
   - Select your app
   - Go to "Setup" → "API access"

2. **Create Service Account**:
   - Click "Create new service account"
   - Follow link to Google Cloud Console
   - Create service account with name like `github-actions-ci`
   - Grant role: "Service Account User"

3. **Create JSON Key**:
   - Click on the service account
   - Go to "Keys" tab
   - Click "Add Key" → "Create new key"
   - Choose JSON format
   - Download JSON file

4. **Grant Permissions in Play Console**:
   - Return to Play Console → API access
   - Find the service account
   - Click "Grant access"
   - Grant permissions:
     - Releases: "Create and edit releases"
     - App access: "View app information"
   - Click "Invite user"

5. **Add to GitHub Secrets**:
   - Name: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
   - Value: Entire contents of the JSON file (including curly braces)

**Rotation Schedule**: Every 12 months

**Security Notes**:
- Service account has limited permissions (only release management)
- Never commit JSON file to repository
- Revoke immediately if compromised
- Monitor usage in Google Cloud Console audit logs

---

## iOS Secrets

### IOS_CERTIFICATE_BASE64

**Purpose**: Base64-encoded iOS distribution certificate (.p12)

**How to Generate**:

1. **Create Distribution Certificate** (if you don't have one):
   - Open Xcode
   - Go to Preferences → Accounts
   - Select your Apple ID → Manage Certificates
   - Click "+" → "Apple Distribution"
   - Certificate is created and stored in Keychain

2. **Export Certificate from Keychain**:
   - Open Keychain Access app
   - Select "login" keychain
   - Find "Apple Distribution: [Your Name]"
   - Right-click → Export "Apple Distribution..."
   - Save as `.p12` file
   - Set a strong password

3. **Encode to base64**:
   ```bash
   # On macOS/Linux
   cat certificate.p12 | base64 | tr -d '\n' > certificate.txt
   
   # On Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -FilePath certificate.txt -Encoding ASCII -NoNewline
   ```

4. **Add to GitHub Secrets**:
   - Name: `IOS_CERTIFICATE_BASE64`
   - Value: Contents of `certificate.txt`

**Rotation Schedule**: Every 12 months (certificates expire annually)

**Security Notes**:
- Certificate is tied to your Apple Developer account
- Never commit `.p12` file to repository
- Certificate expires after 1 year and must be renewed
- Store backup in secure location

---

### IOS_CERTIFICATE_PASSWORD

**Purpose**: Password for the exported iOS certificate (.p12 file)

**How to Obtain**: The password you set when exporting the certificate

**Format**: String (alphanumeric + special characters, 12+ characters recommended)

**Add to GitHub Secrets**:
- Name: `IOS_CERTIFICATE_PASSWORD`
- Value: The export password you used

**Rotation Schedule**: When certificate is renewed (every 12 months)

**Security Notes**:
- Use strong password (≥16 characters)
- Store in password manager
- Only protects the exported .p12 file

---

### IOS_PROVISIONING_PROFILE_BASE64

**Purpose**: Base64-encoded iOS provisioning profile for app distribution

**How to Generate**:

1. **Create Provisioning Profile**:
   - Go to https://developer.apple.com/account/resources/profiles
   - Click "+" to create new profile
   - Select "App Store" distribution
   - Select your App ID
   - Select your distribution certificate
   - Name the profile (e.g., "Home AI Index AppStore")
   - Download the `.mobileprovision` file

2. **Encode to base64**:
   ```bash
   # On macOS/Linux
   cat profile.mobileprovision | base64 | tr -d '\n' > profile.txt
   
   # On Windows (PowerShell)
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Out-File -FilePath profile.txt -Encoding ASCII -NoNewline
   ```

3. **Add to GitHub Secrets**:
   - Name: `IOS_PROVISIONING_PROFILE_BASE64`
   - Value: Contents of `profile.txt`

**Rotation Schedule**: Every 12 months (or when certificate changes)

**Security Notes**:
- Profile is tied to specific app ID and certificate
- Not highly sensitive but should be protected
- Must match the certificate and app bundle ID

---

### APP_STORE_CONNECT_API_KEY

**Purpose**: App Store Connect API key for automated TestFlight uploads

**How to Generate**:

1. **Create API Key**:
   - Go to https://appstoreconnect.apple.com/access/api
   - Click "+" to create new key
   - Name: "GitHub Actions CI"
   - Access: "App Manager" role (minimum)
   - Click "Generate"
   - Download the `.p8` file immediately (only shown once!)

2. **Add to GitHub Secrets**:
   - Name: `APP_STORE_CONNECT_API_KEY`
   - Value: Entire contents of the `.p8` file (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

**Rotation Schedule**: Every 12 months (or when team member leaves)

**Security Notes**:
- API key is shown only once - save immediately
- Use "App Manager" role (not "Admin") for least privilege
- Can be revoked from App Store Connect at any time
- Monitor usage in App Store Connect

---

### APP_STORE_CONNECT_API_ISSUER_ID

**Purpose**: Issuer ID for App Store Connect API authentication

**How to Obtain**:
- Go to https://appstoreconnect.apple.com/access/api
- Issuer ID is displayed at the top of the page
- Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (UUID)

**Add to GitHub Secrets**:
- Name: `APP_STORE_CONNECT_API_ISSUER_ID`
- Value: The UUID from App Store Connect

**Rotation Schedule**: Never (static identifier)

**Security Notes**: Not sensitive by itself but required for API authentication

---

### APP_STORE_CONNECT_API_KEY_ID

**Purpose**: Key ID for the App Store Connect API key

**How to Obtain**:
- Go to https://appstoreconnect.apple.com/access/api
- Find your API key in the list
- Key ID is displayed (e.g., `ABCD1234EF`)

**Add to GitHub Secrets**:
- Name: `APP_STORE_CONNECT_API_KEY_ID`
- Value: The key ID (10 characters)

**Rotation Schedule**: When API key is rotated

**Security Notes**: Not sensitive by itself but required for API authentication

---

## Optional Secrets

### GH_TOKEN

**Purpose**: GitHub Personal Access Token for API access (if needed)

**How to Generate**:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes:
   - `repo` (full control of private repositories)
   - `workflow` (update GitHub Actions workflows)
4. Generate token and copy immediately

**Add to GitHub Secrets**:
- Name: `GH_TOKEN`
- Value: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

**Rotation Schedule**: Every 12 months

**Security Notes**:
- Use fine-grained tokens when available
- Limit scope to minimum required
- Token has same permissions as your account

**When Needed**: Only if workflows need to trigger other workflows or access private repositories

---

## Secret Setup Checklist

**Before first CI/CD run, ensure all secrets are configured**:

### Android Deployment
- [ ] `ANDROID_KEYSTORE_BASE64`
- [ ] `ANDROID_KEYSTORE_PASSWORD`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`
- [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (for beta deployment)

### iOS Deployment
- [ ] `IOS_CERTIFICATE_BASE64`
- [ ] `IOS_CERTIFICATE_PASSWORD`
- [ ] `IOS_PROVISIONING_PROFILE_BASE64`
- [ ] `APP_STORE_CONNECT_API_KEY` (for beta deployment)
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID` (for beta deployment)
- [ ] `APP_STORE_CONNECT_API_KEY_ID` (for beta deployment)

### Optional
- [ ] `GH_TOKEN` (only if needed)

---

## Secret Rotation Procedures

### Quarterly Rotation (Every 3 Months)
1. Review all secret access logs
2. Verify team membership hasn't changed
3. Update passwords if team member left

### Annual Rotation (Every 12 Months)
1. Rotate all passwords and API keys
2. Renew iOS certificates
3. Update provisioning profiles
4. Regenerate service account keys
5. Test CI/CD pipeline with new credentials

### Emergency Rotation (Immediately if Compromised)
1. Revoke compromised secret
2. Generate new secret
3. Update GitHub Secret
4. Monitor for unauthorized access
5. Audit recent CI/CD runs
6. Document incident

---

## Security Best Practices

### Storage
- ✅ Store all production secrets in GitHub Secrets (encrypted at rest)
- ✅ Use separate GitHub Environments for staging/production
- ✅ Keep backup copies in secure password manager (1Password, LastPass, etc.)
- ✅ Never commit secrets to repository (even private repos)

### Access Control
- ✅ Limit secret access to required workflows only
- ✅ Use environment protection rules for production secrets
- ✅ Require approval for production deployments
- ✅ Monitor secret access via GitHub audit log

### Monitoring
- ✅ Enable GitHub audit log for repository
- ✅ Monitor workflow runs for suspicious activity
- ✅ Review Google Play Console and App Store Connect audit logs
- ✅ Set up alerts for failed authentication attempts

### Rotation
- ✅ Document rotation schedule in team calendar
- ✅ Assign ownership for each secret type
- ✅ Test CI/CD pipeline after rotation
- ✅ Keep rotation history for compliance

---

## Troubleshooting

### Common Issues

**Secret Not Found**:
- Verify secret name exactly matches (case-sensitive)
- Check secret is configured at repository level (not user level)
- Ensure workflow has access to secrets

**Invalid Keystore/Certificate**:
- Verify base64 encoding is correct (no newlines)
- Check password matches keystore/certificate
- Validate keystore: `keytool -list -v -keystore keystore.jks`

**Service Account Permission Denied**:
- Verify service account has correct permissions in Play Console
- Check JSON file is complete and valid
- Ensure service account invitation was accepted

**iOS Code Signing Failed**:
- Verify certificate and provisioning profile match
- Check bundle ID matches provisioning profile
- Ensure certificate hasn't expired
- Validate profile: `security cms -D -i profile.mobileprovision`

---

## Validation Scripts

### Validate Android Secrets
```bash
#!/bin/bash
# Validate Android secrets are configured

required_secrets=(
  "ANDROID_KEYSTORE_BASE64"
  "ANDROID_KEYSTORE_PASSWORD"
  "ANDROID_KEY_ALIAS"
  "ANDROID_KEY_PASSWORD"
)

for secret in "${required_secrets[@]}"; do
  if [ -z "${!secret}" ]; then
    echo "❌ Missing: $secret"
    exit 1
  else
    echo "✅ Found: $secret"
  fi
done

echo "✅ All Android secrets configured"
```

### Validate iOS Secrets
```bash
#!/bin/bash
# Validate iOS secrets are configured

required_secrets=(
  "IOS_CERTIFICATE_BASE64"
  "IOS_CERTIFICATE_PASSWORD"
  "IOS_PROVISIONING_PROFILE_BASE64"
)

for secret in "${required_secrets[@]}"; do
  if [ -z "${!secret}" ]; then
    echo "❌ Missing: $secret"
    exit 1
  else
    echo "✅ Found: $secret"
  fi
done

echo "✅ All iOS secrets configured"
```

---

## Contact & Support

**For Secret Issues**:
- GitHub Secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- Android Signing: https://developer.android.com/studio/publish/app-signing
- iOS Signing: https://developer.apple.com/support/code-signing
- App Store Connect API: https://developer.apple.com/documentation/appstoreconnectapi

**Internal Team Contacts**:
- Secret Rotation: [Team Lead]
- Android KeyStore: [Android Dev]
- iOS Certificates: [iOS Dev]
- CI/CD Pipeline: [DevOps Lead]

---

## Conclusion

This document provides comprehensive guidance for managing all CI/CD secrets. Follow security best practices, maintain rotation schedule, and keep this document updated as requirements change.

**Next Update**: 2026-01-17 (quarterly review)
