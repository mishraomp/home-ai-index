# Quickstart Guide: Google Cloud Vision API Integration

**Feature**: Upgrade to Google Cloud Vision API  
**Date**: 2025-10-16  
**Estimated Setup Time**: 15-20 minutes

## Overview

This guide walks you through setting up Google Cloud Vision API integration for the Home AI Index app, from obtaining API credentials to running your first image recognition test.

---

## Prerequisites

Before starting, ensure you have:

- ✅ Google Cloud Platform (GCP) account
- ✅ Flutter SDK 3.16+ installed
- ✅ Dart 3.2+ installed
- ✅ Android Studio / Xcode configured
- ✅ Active internet connection
- ✅ Credit card (for GCP - free tier available)

---

## Step 1: Google Cloud Setup (5 minutes)

### 1.1 Create a New Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter project name: `home-ai-index-dev`
4. Click **Create**

### 1.2 Enable Cloud Vision API

1. Navigate to **APIs & Services** → **Library**
2. Search for "Cloud Vision API"
3. Click **Cloud Vision API**
4. Click **Enable**

### 1.3 Create API Credentials

1. Navigate to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **API Key**
3. Copy the generated API key (40 characters)
4. Click **Edit API key** to restrict it:
   - **Application restrictions**: None (for development)
   - **API restrictions**: Select "Cloud Vision API"
   - Click **Save**

**⚠️ Security Note**: For production, use application restrictions (Android/iOS app certificates).

### 1.4 Enable Billing (Required)

1. Navigate to **Billing** → **Link a billing account**
2. Add payment method
3. **Free Tier**: 1,000 requests/month free
4. **Pricing**: $1.50 per 1,000 requests after free tier

---

## Step 2: Project Setup (3 minutes)

### 2.1 Update Dependencies

Add the following to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies
  flutter:
    sdk: flutter
  provider: ^6.1.0
  image: ^4.0.17
  
  # New dependencies for Cloud Vision
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  # Existing dev dependencies
  flutter_test:
    sdk: flutter
  
  # For testing HTTP requests
  mockito: ^5.4.2
  build_runner: ^2.4.6
```

### 2.2 Install Dependencies

```bash
flutter pub get
```

### 2.3 Configure Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS (`ios/Runner/Info.plist`)

Add before `</dict>`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## Step 3: Store API Credentials (2 minutes)

### 3.1 First-Time Setup

Run the app and navigate to **Settings** → **API Configuration**:

1. Tap **Configure Google Cloud Vision**
2. Paste your API key
3. Tap **Save**

API key is now encrypted and stored securely using `flutter_secure_storage`.

### 3.2 Manual Setup (Development)

For testing, you can manually store credentials:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> setupDevCredentials() async {
  const storage = FlutterSecureStorage();
  await storage.write(
    key: 'cloud_vision_api_key',
    value: 'YOUR_API_KEY_HERE',
  );
}
```

**⚠️ Never commit API keys to Git!**

---

## Step 4: Test the Integration (5 minutes)

### 4.1 Run the App

```bash
flutter run
```

### 4.2 Test Image Recognition

1. Tap **+** button to add new item
2. Tap **Take Photo** or **Choose from Gallery**
3. Select an image (e.g., apple, banana, laptop)
4. Wait 2-3 seconds for API response
5. Verify the suggested item name and category

**Expected Result**:
- ✅ Item name filled automatically (e.g., "Apple")
- ✅ Category selected (e.g., "Groceries")
- ✅ Confidence score displayed (e.g., 98%)

### 4.3 Test Error Handling

**Test 1: No Internet**
1. Turn off Wi-Fi/mobile data
2. Try to add item with photo
3. **Expected**: "No internet connection. Enter item manually." message

**Test 2: Invalid API Key**
1. Go to Settings → API Configuration
2. Enter invalid key: `invalid_key_123`
3. Try to add item with photo
4. **Expected**: "Invalid API credentials" error with retry option

---

## Step 5: Verify Setup (2 minutes)

### 5.1 Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### 5.2 Check Logs

Enable debug logging to verify API calls:

```dart
// In lib/data/services/cloud_vision_service_impl.dart
void _logApiCall(APILogEntry entry) {
  if (kDebugMode) {
    print('API Call: ${entry.endpoint}');
    print('Status: ${entry.statusCode}');
    print('Latency: ${entry.latency?.inMilliseconds}ms');
    print('Success: ${entry.success}');
  }
}
```

Expected log output:

```
API Call: vision.googleapis.com/v1/images:annotate
Status: 200
Latency: 1523ms
Success: true
```

---

## Step 6: Monitor Usage (Ongoing)

### 6.1 Check GCP Console

1. Go to **APIs & Services** → **Dashboard**
2. Select **Cloud Vision API**
3. View **Metrics**:
   - Requests per day
   - Error rate
   - Latency

### 6.2 Set Up Billing Alerts

1. Navigate to **Billing** → **Budgets & alerts**
2. Click **+ CREATE BUDGET**
3. Set budget: $5/month (covers ~3,333 requests)
4. Set alert at 50%, 90%, 100%

---

## Troubleshooting

### Problem: "API key not valid"

**Solution**:
1. Verify API key in GCP Console
2. Check API restrictions (should allow Cloud Vision API)
3. Ensure billing is enabled
4. Re-save key in app settings

### Problem: "Quota exceeded"

**Solution**:
1. Check GCP Console → Quotas
2. Wait until quota resets (daily limit)
3. Upgrade to paid tier if needed
4. Implement request caching

### Problem: "Network timeout"

**Solution**:
1. Check internet connection
2. Verify image size <20MB
3. Try smaller/compressed image
4. Check GCP service status

### Problem: "No labels detected"

**Solution**:
1. Ensure image is clear (not blurry)
2. Try different image
3. Check image format (JPEG/PNG)
4. Verify image contains recognizable objects

---

## Development Workflow

### Daily Development

1. **Start**: Verify API key is set
2. **Code**: Use mock responses for most tests
3. **Test**: Run unit tests (no API calls)
4. **Integration Test**: Run with real API (limited)
5. **Monitor**: Check GCP usage daily

### Best Practices

✅ **DO**:
- Use mock HTTP client for unit tests
- Cache API responses for repeated images
- Log API usage for cost tracking
- Test offline scenarios
- Compress images before upload

❌ **DON'T**:
- Commit API keys to Git
- Make unnecessary API calls in tests
- Upload full-resolution images (resize first)
- Ignore billing alerts
- Skip error handling

---

## Example Code Snippets

### Basic Image Recognition

```dart
import 'package:home_ai_index/data/services/cloud_vision_service.dart';
import 'package:image/image.dart' as img;

Future<void> recognizeImage(File imageFile) async {
  // Read and preprocess image
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes)!;
  final resized = img.copyResize(image, width: 1024);
  final jpeg = img.encodeJpg(resized, quality: 85);
  
  // Get service instance
  final service = CloudVisionService();
  
  // Recognize
  try {
    final result = await service.recognizeImage(Uint8List.fromList(jpeg));
    print('Label: ${result.label}');
    print('Category: ${result.category}');
    print('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
  } on NetworkException {
    print('No internet connection');
  } on AuthenticationException {
    print('Invalid API credentials');
  } on ApiException catch (e) {
    print('API error: $e');
  }
}
```

### Check Connectivity Before API Call

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnected() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> recognizeImageWithCheck(File imageFile) async {
  if (!await isConnected()) {
    print('No internet connection');
    return;
  }
  
  // Proceed with API call
  await recognizeImage(imageFile);
}
```

### Mock Response for Testing

```dart
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  test('should parse successful response', () async {
    final client = MockClient();
    
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('''
          {
            "responses": [
              {
                "labelAnnotations": [
                  {
                    "description": "Apple",
                    "score": 0.98
                  }
                ]
              }
            ]
          }
        ''', 200));
    
    // Test your service with mock client
  });
}
```

---

## Next Steps

After completing this quickstart:

1. ✅ **Read**: Review `data-model.md` for data structures
2. ✅ **Read**: Review `contracts/cloud-vision-api.md` for API details
3. ✅ **Implement**: Follow tasks in `tasks.md`
4. ✅ **Test**: Run full test suite
5. ✅ **Deploy**: Follow deployment guide

---

## Resources

### Documentation

- [Google Cloud Vision API Docs](https://cloud.google.com/vision/docs)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus)
- [HTTP Package](https://pub.dev/packages/http)

### Pricing

- [Cloud Vision Pricing](https://cloud.google.com/vision/pricing)
- **Free Tier**: 1,000 requests/month
- **After Free Tier**: $1.50 per 1,000 requests

### Support

- [GCP Support](https://cloud.google.com/support)
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/google-cloud-vision)

---

## Summary

You should now have:

- ✅ Google Cloud Vision API enabled
- ✅ API key created and secured
- ✅ Dependencies installed
- ✅ Permissions configured
- ✅ First successful image recognition test
- ✅ Error handling tested
- ✅ Monitoring set up

**Estimated API Usage**:
- Development: ~50-100 requests/day
- Testing: ~200-300 requests/day
- Production: Depends on user activity

**Total Setup Time**: ~15-20 minutes

Ready to implement! 🚀
