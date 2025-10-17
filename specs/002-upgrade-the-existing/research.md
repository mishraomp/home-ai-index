# Phase 0: Research & Technology Decisions

**Feature**: Upgrade to Google Cloud Vision API  
**Date**: 2025-10-16

## Overview

This document captures research findings and technology decisions for migrating from offline TensorFlow Lite to Google Cloud Vision API.

---

## 1. Google Cloud Vision API Integration Patterns

### Decision: Use REST API with HTTP Client

**Rationale**:
- Flutter's `http` package provides robust, well-tested HTTP client functionality
- Google Cloud Vision REST API is straightforward and doesn't require gRPC
- Easier to mock and test compared to SDK-based approaches
- No additional platform-specific dependencies required

**Alternatives Considered**:
- **Official Google Cloud Client Libraries**: Not available for Dart/Flutter; only for server-side languages
- **gRPC**: Adds complexity with protocol buffers; overkill for label detection use case
- **Firebase ML Kit**: Provides on-device and cloud-based options but requires Firebase integration; Cloud Vision API more flexible

**Implementation Approach**:
```dart
// Pseudo-code structure
class CloudVisionService {
  final http.Client _client;
  final APICredentialsManager _credentials;
  
  Future<RecognitionResult> classifyImage(Uint8List imageBytes) async {
    // 1. Convert image to base64
    // 2. Build API request JSON
    // 3. Add authentication (API key in header)
    // 4. POST to https://vision.googleapis.com/v1/images:annotate
    // 5. Parse response JSON
    // 6. Map labels to app categories
    // 7. Return RecognitionResult
  }
}
```

**API Endpoint**: `https://vision.googleapis.com/v1/images:annotate`  
**Authentication**: API Key in request header or URL parameter  
**Request Format**: JSON with base64-encoded image  
**Response Format**: JSON with label annotations and confidence scores

---

## 2. Secure Credential Storage

### Decision: Use flutter_secure_storage Package

**Rationale**:
- Industry-standard package with 5k+ pub points
- Platform-specific secure storage: Keychain (iOS), KeyStore (Android)
- Simple async API that works well with Flutter patterns
- Encrypted at rest on both platforms
- No additional native code required

**Alternatives Considered**:
- **Environment Variables**: Not secure; visible in build artifacts and version control
- **Encrypted SharedPreferences**: Requires manual encryption/decryption; error-prone
- **Platform Channels**: Reinventing the wheel; flutter_secure_storage already wraps native APIs

**Implementation Approach**:
```dart
class APICredentialsManager {
  final FlutterSecureStorage _storage;
  
  static const String _apiKeyKey = 'google_cloud_vision_api_key';
  static const String _projectIdKey = 'google_cloud_project_id';
  
  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }
  
  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }
}
```

**Security Best Practices**:
- Never commit API keys to version control
- Use separate keys for development and production
- Rotate keys periodically
- Monitor API usage for anomalies
- Consider using service account credentials with IAM for production

---

## 3. Network Connectivity and Retry Logic

### Decision: Use connectivity_plus with Exponential Backoff

**Rationale**:
- `connectivity_plus` is the official Flutter Community plugin
- Provides both connection status and stream of changes
- Works across Android, iOS, web, and desktop
- Exponential backoff prevents overwhelming servers during transient failures

**Alternatives Considered**:
- **Manual Platform Channels**: Too much effort; connectivity_plus already handles it
- **Simple Fixed Retry**: Can overwhelm API during sustained issues
- **No Retry Logic**: Poor user experience for transient network failures

**Implementation Approach**:
```dart
class NetworkUtils {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  static Future<T> retryWithExponentialBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 2,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (attempt >= maxRetries) rethrow;
        attempt++;
        await Future.delayed(initialDelay * pow(2, attempt - 1));
      }
    }
  }
}
```

**Retry Strategy**:
- Maximum 2 retries (total 3 attempts)
- Exponential backoff: 1s, 2s, 4s delays
- Only retry on network errors (not authentication/quota errors)
- Timeout per attempt: 10 seconds

---

## 4. Error Handling Patterns

### Decision: Typed Exception Hierarchy with User-Friendly Messages

**Rationale**:
- Clear separation of error types enables appropriate handling
- User-friendly messages improve UX
- Typed exceptions are testable and maintainable
- Follows Dart/Flutter exception handling best practices

**Exception Hierarchy**:
```dart
// Base exception
abstract class CloudVisionException implements Exception {
  final String message;
  final String? userMessage;
  CloudVisionException(this.message, {this.userMessage});
}

// Network-related errors
class NetworkException extends CloudVisionException {
  NetworkException(String message)
      : super(message, userMessage: 'No internet connection. Please check your network.');
}

// API errors
class ApiException extends CloudVisionException {
  final int? statusCode;
  ApiException(String message, {this.statusCode, String? userMessage})
      : super(message, userMessage: userMessage);
}

// Authentication errors
class AuthenticationException extends CloudVisionException {
  AuthenticationException(String message)
      : super(message, userMessage: 'Authentication failed. Please contact support.');
}

// Quota errors
class QuotaExceededException extends CloudVisionException {
  QuotaExceededException(String message)
      : super(message, userMessage: 'Daily limit reached. Please try again tomorrow.');
}

// Timeout errors
class TimeoutException extends CloudVisionException {
  TimeoutException(String message)
      : super(message, userMessage: 'Request timed out. Please try again.');
}
```

**Error Handling Flow**:
1. Service layer throws typed exceptions
2. ViewModel catches and maps to UI state
3. UI displays user-friendly message with action buttons
4. Logging captures technical details for debugging

---

## 5. Image Preprocessing and Optimization

### Decision: Resize Images to 1024x1024 Max, Convert to JPEG

**Rationale**:
- Cloud Vision API has 20MB limit; preprocessing ensures compliance
- Smaller images reduce network transfer time and costs
- JPEG provides good compression while maintaining recognition quality
- 1024x1024 is sufficient for household item recognition

**Alternatives Considered**:
- **No Preprocessing**: Risk of exceeding API limits; slow upload times
- **Server-Side Resize**: Adds latency; unnecessary network transfer
- **PNG Format**: Larger file sizes; no quality benefit for photos

**Implementation Approach**:
```dart
class ImagePreprocessor {
  static Future<Uint8List> prepareForApi(Uint8List imageBytes) async {
    // 1. Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) throw ImageProcessingException('Failed to decode image');
    
    // 2. Resize if needed (maintain aspect ratio)
    if (image.width > 1024 || image.height > 1024) {
      image = img.copyResize(image, width: 1024, height: 1024);
    }
    
    // 3. Convert to JPEG with 85% quality
    return img.encodeJpg(image, quality: 85);
  }
}
```

**Processing Requirements**:
- Target size: 1024x1024 pixels maximum
- Format: JPEG with 85% quality
- Maintain aspect ratio
- Processing time target: <1 second

---

## 6. API Response Parsing and Label Mapping

### Decision: Parse JSON Response, Map Labels to App Categories

**Rationale**:
- Cloud Vision returns ImageNet-style labels
- App uses predefined categories (groceries, electronics, etc.)
- Mapping layer allows customization and localization
- Confidence threshold (0.7) filters low-confidence predictions

**Label Mapping Strategy**:
```dart
class LabelMapper {
  static const Map<String, String> _labelToCategoryMap = {
    // Groceries
    'fruit': 'groceries',
    'vegetable': 'groceries',
    'food': 'groceries',
    'apple': 'groceries',
    'banana': 'groceries',
    
    // Electronics
    'electronics': 'electronics',
    'computer': 'electronics',
    'phone': 'electronics',
    'laptop': 'electronics',
    
    // Tools
    'tool': 'tools',
    'equipment': 'tools',
    'hardware': 'tools',
    
    // Add more mappings...
  };
  
  static String? mapLabelToCategory(String label) {
    final lowercaseLabel = label.toLowerCase();
    
    // Direct match
    if (_labelToCategoryMap.containsKey(lowercaseLabel)) {
      return _labelToCategoryMap[lowercaseLabel];
    }
    
    // Partial match (e.g., "red apple" -> "apple" -> "groceries")
    for (final key in _labelToCategoryMap.keys) {
      if (lowercaseLabel.contains(key)) {
        return _labelToCategoryMap[key];
      }
    }
    
    // Default to miscellaneous
    return 'miscellaneous';
  }
}
```

**Response Processing**:
1. Parse JSON response
2. Extract label annotations array
3. Sort by confidence score (descending)
4. Take top label with confidence >0.7
5. Map label to app category
6. Return RecognitionResult with label, category, and confidence

---

## 7. Offline Detection and Fallback

### Decision: Check Connectivity Before API Call, Show Offline Banner

**Rationale**:
- Proactive check prevents wasted time on doomed requests
- Clear offline indication sets user expectations
- Graceful degradation maintains app usability
- Users can still manually enter items

**Implementation Approach**:
```dart
// In AddItemViewModel
Future<void> recognizeImage(Uint8List imageBytes) async {
  // 1. Check connectivity
  final isOnline = await NetworkUtils.isConnected();
  
  if (!isOnline) {
    _state = AddItemState.offline();
    return; // Show offline banner, allow manual entry
  }
  
  // 2. Attempt API call with loading state
  _state = AddItemState.loading();
  
  try {
    final result = await _cloudVisionService.classifyImage(imageBytes);
    _state = AddItemState.success(result);
  } catch (e) {
    _state = AddItemState.error(e);
  }
}
```

**UI States**:
- `loading`: Show progress indicator
- `success`: Display suggested name, category, confidence
- `error`: Show error dialog with retry option
- `offline`: Show offline banner, enable manual entry

---

## 8. API Usage Logging and Monitoring

### Decision: Log All API Calls with Timestamps, Errors, and Latency

**Rationale**:
- Monitor API usage for cost control
- Debug issues with error logs
- Track performance metrics (latency, success rate)
- Identify patterns for optimization

**Implementation Approach**:
```dart
class APILogger {
  static final List<APILogEntry> _logs = [];
  
  static void logApiCall({
    required String endpoint,
    required DateTime timestamp,
    required int statusCode,
    String? error,
    Duration? latency,
  }) {
    _logs.add(APILogEntry(
      endpoint: endpoint,
      timestamp: timestamp,
      statusCode: statusCode,
      error: error,
      latency: latency,
    ));
    
    // Optional: Send to analytics service
    // Optional: Persist to local storage for debugging
  }
  
  static List<APILogEntry> getLogs() => List.unmodifiable(_logs);
  
  static void clearLogs() => _logs.clear();
}
```

**Logged Data**:
- Timestamp
- Endpoint
- HTTP status code
- Response time (latency)
- Error messages (if any)
- Success/failure status

---

## 9. Testing Strategy

### Decision: Unit Tests with Mocked HTTP, Widget Tests with Mocked Service

**Rationale**:
- Mocking HTTP client prevents actual API calls in tests
- Fast test execution (no network I/O)
- Deterministic test results
- Can test error scenarios easily

**Testing Approach**:

**Unit Tests**:
```dart
// Test CloudVisionService with mocked HTTP
test('classifyImage returns correct result on success', () async {
  final mockClient = MockClient((request) async {
    return http.Response(jsonEncode({
      'responses': [{
        'labelAnnotations': [
          {'description': 'Apple', 'score': 0.95},
          {'description': 'Fruit', 'score': 0.88}
        ]
      }]
    }), 200);
  });
  
  final service = CloudVisionService(mockClient, credentialsManager);
  final result = await service.classifyImage(imageBytes);
  
  expect(result.label, 'Apple');
  expect(result.confidence, 0.95);
  expect(result.category, 'groceries');
});
```

**Widget Tests**:
```dart
testWidgets('shows loading indicator during API call', (tester) async {
  final mockService = MockCloudVisionService();
  when(mockService.classifyImage(any))
      .thenAnswer((_) async => Future.delayed(Duration(seconds: 1)));
  
  await tester.pumpWidget(AddItemScreen(service: mockService));
  await tester.tap(find.byIcon(Icons.camera));
  await tester.pump();
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

**Integration Tests**:
- Test with real API calls (use test API key with quota monitoring)
- Verify end-to-end flow from camera to item creation
- Test offline scenarios with airplane mode
- Verify error recovery and retry logic

---

## 10. Migration and Rollout Strategy

### Decision: Feature Flag with Gradual Rollout

**Rationale**:
- Safe rollback if issues discovered
- Gradual user exposure reduces risk
- A/B testing possible to compare accuracy
- Can run both implementations temporarily

**Migration Steps**:
1. **Phase 1**: Add CloudVisionService alongside existing TFLite service
2. **Phase 2**: Add feature flag to switch between implementations
3. **Phase 3**: Test thoroughly with internal users
4. **Phase 4**: Enable for 10% of users, monitor metrics
5. **Phase 5**: Gradually increase to 50%, then 100%
6. **Phase 6**: Remove TFLite code and dependencies

**Feature Flag Implementation**:
```dart
class FeatureFlags {
  static bool get useCloudVision => true; // Toggle for testing
  
  static ImageRecognitionService getRecognitionService() {
    if (useCloudVision) {
      return CloudVisionService(http.Client(), credentialsManager);
    } else {
      return TFLiteImageRecognitionService(interpreter, labels);
    }
  }
}
```

**Rollback Plan**:
- Set feature flag to `false` to revert to TFLite
- Keep TFLite dependencies for one release cycle
- Monitor crash rates and user feedback

---

## Summary of Key Decisions

| Area | Decision | Package/Technology |
|------|----------|-------------------|
| API Integration | REST API with HTTP client | `http` ^1.1.0 |
| Credential Storage | Secure encrypted storage | `flutter_secure_storage` ^9.0.0 |
| Network Detection | Connectivity plugin | `connectivity_plus` ^5.0.0 |
| Retry Logic | Exponential backoff | Custom implementation |
| Error Handling | Typed exception hierarchy | Custom exceptions |
| Image Preprocessing | Resize to 1024x1024, JPEG | `image` ^4.0.17 |
| Label Mapping | Static map with fallback | Custom mapper |
| Logging | In-memory logs | Custom logger |
| Testing | Mocked HTTP and services | `mockito` ^5.4.3 |
| Migration | Feature flag rollout | Custom flag |

---

## Next Steps

Proceed to **Phase 1: Design & Contracts** to:
1. Define data models (CloudVisionRequest, CloudVisionResponse)
2. Create API contracts (REST endpoint specifications)
3. Document service interfaces
4. Create quickstart guide for setup and usage
