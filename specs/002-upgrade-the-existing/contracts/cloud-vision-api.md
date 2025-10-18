# API Contract: Google Cloud Vision API Integration

**Feature**: Upgrade to Google Cloud Vision API  
**Date**: 2025-10-16  
**API Version**: v1

## Overview

This document specifies the contract for integrating with Google Cloud Vision API, including endpoint specifications, request/response schemas, authentication, and error handling.

---

## 1. Base Configuration

### Endpoint

```
POST https://vision.googleapis.com/v1/images:annotate
```

### Authentication

**Method**: API Key (Query Parameter)

```
POST https://vision.googleapis.com/v1/images:annotate?key={API_KEY}
```

**Security Requirements**:
- API key stored encrypted using `flutter_secure_storage`
- API key never logged or exposed in error messages
- Separate keys for development and production environments
- Key rotation supported via settings UI

### Rate Limits

| Limit Type | Value | Notes |
|------------|-------|-------|
| Requests per minute | 1800 | Per project |
| Requests per day | 100,000 | Free tier limit |
| Image size | 20MB | Maximum |
| API timeout | 10 seconds | Client-side |

---

## 2. Request Specification

### HTTP Request

**Method**: `POST`  
**Content-Type**: `application/json`

### Request Schema

```json
{
  "requests": [
    {
      "image": {
        "content": "string (base64-encoded)"
      },
      "features": [
        {
          "type": "LABEL_DETECTION",
          "maxResults": 10
        }
      ],
      "imageContext": {
        "languageHints": ["en"]
      }
    }
  ]
}
```

### Field Descriptions

#### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `requests` | `Array<Request>` | Yes | Batch of image annotation requests |

#### Request Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | `Image` | Yes | The image to analyze |
| `features` | `Array<Feature>` | Yes | Features to detect |
| `imageContext` | `ImageContext` | No | Additional context |

#### Image Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `content` | `string` | Yes* | Base64-encoded image bytes |
| `source` | `ImageSource` | Yes* | Image URL or Cloud Storage URI |

*One of `content` or `source` is required. We use `content` for direct upload.

#### Feature Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | `string` | Yes | Feature type (e.g., "LABEL_DETECTION") |
| `maxResults` | `integer` | No | Maximum results to return (1-50) |
| `model` | `string` | No | Model version (default: "builtin/stable") |

**Supported Feature Types** (we only use LABEL_DETECTION):
- `LABEL_DETECTION` - Detect general labels
- `TEXT_DETECTION` - OCR (not used)
- `FACE_DETECTION` - Face detection (not used)
- `LOGO_DETECTION` - Logo detection (not used)
- `LANDMARK_DETECTION` - Landmark detection (not used)

#### ImageContext Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `languageHints` | `Array<string>` | No | Language codes (ISO 639-1) |

### Example Request

```json
{
  "requests": [
    {
      "image": {
        "content": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL..."
      },
      "features": [
        {
          "type": "LABEL_DETECTION",
          "maxResults": 10
        }
      ],
      "imageContext": {
        "languageHints": ["en"]
      }
    }
  ]
}
```

---

## 3. Response Specification

### Success Response

**Status Code**: `200 OK`  
**Content-Type**: `application/json`

### Response Schema

```json
{
  "responses": [
    {
      "labelAnnotations": [
        {
          "mid": "string",
          "description": "string",
          "score": 0.98,
          "topicality": 0.98
        }
      ]
    }
  ]
}
```

### Field Descriptions

#### Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `responses` | `Array<AnnotateImageResponse>` | Results for each image in request |

#### AnnotateImageResponse Object

| Field | Type | Description |
|-------|------|-------------|
| `labelAnnotations` | `Array<EntityAnnotation>` | Label detection results |
| `error` | `Status` | Error information if detection failed |

#### EntityAnnotation Object (Label)

| Field | Type | Description |
|-------|------|-------------|
| `mid` | `string` | Opaque entity ID (Knowledge Graph) |
| `description` | `string` | Human-readable label (e.g., "Apple") |
| `score` | `number` | Confidence score (0.0 to 1.0) |
| `topicality` | `number` | Image-to-label relevance (0.0 to 1.0) |

**Score Interpretation**:
- `0.9 - 1.0`: Very high confidence
- `0.8 - 0.9`: High confidence
- `0.7 - 0.8`: Medium confidence
- `< 0.7`: Low confidence (filter out)

### Example Success Response

```json
{
  "responses": [
    {
      "labelAnnotations": [
        {
          "mid": "/m/014j1m",
          "description": "Apple",
          "score": 0.9876543,
          "topicality": 0.9876543
        },
        {
          "mid": "/m/0cyhg",
          "description": "Fruit",
          "score": 0.9654321,
          "topicality": 0.9654321
        },
        {
          "mid": "/m/02wbm",
          "description": "Food",
          "score": 0.9432109,
          "topicality": 0.9432109
        },
        {
          "mid": "/m/0cmf2",
          "description": "Red",
          "score": 0.8765432,
          "topicality": 0.8765432
        }
      ]
    }
  ]
}
```

---

## 4. Error Response Specification

### Error Response Schema

**Status Code**: `200 OK` (errors are in response body)  
**Content-Type**: `application/json`

```json
{
  "responses": [
    {
      "error": {
        "code": 400,
        "message": "Invalid image content",
        "status": "INVALID_ARGUMENT"
      }
    }
  ]
}
```

### Status Object

| Field | Type | Description |
|-------|------|-------------|
| `code` | `integer` | HTTP status code |
| `message` | `string` | Human-readable error message |
| `status` | `string` | Error status code |

### Error Status Codes

| Status | HTTP Code | Description | Client Action |
|--------|-----------|-------------|---------------|
| `INVALID_ARGUMENT` | 400 | Invalid request format | Show validation error |
| `PERMISSION_DENIED` | 403 | Invalid or missing API key | Prompt for credentials |
| `NOT_FOUND` | 404 | Resource not found | Retry or report error |
| `RESOURCE_EXHAUSTED` | 429 | Rate limit exceeded | Show quota error, retry later |
| `INTERNAL` | 500 | Server error | Retry with backoff |
| `UNAVAILABLE` | 503 | Service unavailable | Retry with backoff |
| `DEADLINE_EXCEEDED` | 504 | Request timeout | Retry or show timeout error |

### Example Error Responses

#### Invalid API Key

```json
{
  "error": {
    "code": 403,
    "message": "The request is missing a valid API key.",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "API_KEY_INVALID",
        "domain": "googleapis.com",
        "metadata": {
          "service": "vision.googleapis.com"
        }
      }
    ]
  }
}
```

#### Invalid Image

```json
{
  "responses": [
    {
      "error": {
        "code": 400,
        "message": "Invalid image content",
        "status": "INVALID_ARGUMENT"
      }
    }
  ]
}
```

#### Rate Limit Exceeded

```json
{
  "error": {
    "code": 429,
    "message": "Quota exceeded for quota metric 'Vision requests' and limit 'Vision requests per minute' of service 'vision.googleapis.com'",
    "status": "RESOURCE_EXHAUSTED"
  }
}
```

---

## 5. Client Implementation Contract

### HTTP Client Configuration

```dart
final client = http.Client();
const baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
const timeout = Duration(seconds: 10);
```

### Request Builder

```dart
Future<http.Response> analyzeImage({
  required Uint8List imageBytes,
  required String apiKey,
  int maxResults = 10,
}) async {
  final url = Uri.parse('$baseUrl?key=$apiKey');
  
  final requestBody = {
    'requests': [
      {
        'image': {
          'content': base64Encode(imageBytes),
        },
        'features': [
          {
            'type': 'LABEL_DETECTION',
            'maxResults': maxResults,
          }
        ],
        'imageContext': {
          'languageHints': ['en'],
        },
      }
    ],
  };
  
  final response = await client
      .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      )
      .timeout(timeout);
  
  return response;
}
```

### Response Parser

```dart
CloudVisionResponse parseResponse(http.Response response) {
  // Check HTTP status
  if (response.statusCode != 200) {
    throw ApiException(
      'HTTP ${response.statusCode}: ${response.body}',
    );
  }
  
  // Parse JSON
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  
  // Check for top-level error (invalid API key, rate limit, etc.)
  if (json.containsKey('error')) {
    final error = json['error'] as Map<String, dynamic>;
    throw _mapErrorToException(error);
  }
  
  // Parse response
  return CloudVisionResponse.fromJson(json);
}

Exception _mapErrorToException(Map<String, dynamic> error) {
  final code = error['code'] as int;
  final message = error['message'] as String;
  final status = error['status'] as String;
  
  switch (status) {
    case 'PERMISSION_DENIED':
      return AuthenticationException(
        'Invalid API key: $message',
        details: error,
      );
    case 'RESOURCE_EXHAUSTED':
      return QuotaExceededException(
        'API quota exceeded: $message',
        details: error,
      );
    case 'INVALID_ARGUMENT':
      return ApiException(
        'Invalid request: $message',
        details: error,
      );
    case 'UNAVAILABLE':
    case 'INTERNAL':
      return ApiException(
        'Service error: $message',
        details: error,
        canRetry: true,
      );
    case 'DEADLINE_EXCEEDED':
      return TimeoutException(
        'Request timeout: $message',
      );
    default:
      return ApiException(
        'API error ($status): $message',
        details: error,
      );
  }
}
```

---

## 6. Retry Policy

### Configuration

```dart
const maxRetries = 2;
const retryDelays = [
  Duration(seconds: 1),  // First retry
  Duration(seconds: 2),  // Second retry
];
```

### Retryable Conditions

| Condition | Retry? | Reason |
|-----------|--------|--------|
| Network timeout | Yes | Transient network issue |
| HTTP 500 (Internal Server Error) | Yes | Temporary server issue |
| HTTP 503 (Service Unavailable) | Yes | Service is temporarily down |
| HTTP 429 (Rate Limit) | No | Requires user action or delay |
| HTTP 403 (Permission Denied) | No | Invalid credentials |
| HTTP 400 (Invalid Argument) | No | Client-side error |

### Implementation

```dart
Future<CloudVisionResponse> analyzeImageWithRetry({
  required Uint8List imageBytes,
  required String apiKey,
  int maxResults = 10,
}) async {
  Exception? lastException;
  
  for (int attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      final response = await analyzeImage(
        imageBytes: imageBytes,
        apiKey: apiKey,
        maxResults: maxResults,
      );
      
      return parseResponse(response);
      
    } on TimeoutException catch (e) {
      lastException = e;
      if (attempt < maxRetries) {
        await Future.delayed(retryDelays[attempt]);
        continue;
      }
    } on ApiException catch (e) {
      if (e.canRetry && attempt < maxRetries) {
        lastException = e;
        await Future.delayed(retryDelays[attempt]);
        continue;
      }
      rethrow;
    } on NetworkException catch (e) {
      lastException = e;
      if (attempt < maxRetries) {
        await Future.delayed(retryDelays[attempt]);
        continue;
      }
    }
  }
  
  throw lastException ?? ApiException('Unknown error occurred');
}
```

---

## 7. Testing Contract

### Mock Responses

#### Success Response (for tests)

```dart
const mockSuccessResponse = '''
{
  "responses": [
    {
      "labelAnnotations": [
        {
          "mid": "/m/014j1m",
          "description": "Apple",
          "score": 0.98,
          "topicality": 0.98
        },
        {
          "mid": "/m/0cyhg",
          "description": "Fruit",
          "score": 0.96,
          "topicality": 0.96
        }
      ]
    }
  ]
}
''';
```

#### Error Response (for tests)

```dart
const mockErrorResponse = '''
{
  "error": {
    "code": 403,
    "message": "The request is missing a valid API key.",
    "status": "PERMISSION_DENIED"
  }
}
''';
```

### Test Requirements

1. **Unit Tests**:
   - Request body serialization
   - Response parsing
   - Error mapping
   - Retry logic

2. **Integration Tests**:
   - Mock HTTP client responses
   - Network error simulation
   - Timeout simulation
   - Rate limit handling

3. **Test Coverage**:
   - Success path: Valid image → parsed labels
   - Error paths: Invalid key, rate limit, timeout, invalid image
   - Retry scenarios: Transient failures, permanent failures

---

## 8. Monitoring and Logging

### Log Entry Format

```dart
final logEntry = APILogEntry(
  id: Uuid().v4(),
  timestamp: DateTime.now(),
  endpoint: 'vision.googleapis.com/v1/images:annotate',
  statusCode: response.statusCode,
  latency: requestDuration,
  error: exception?.toString(),
  success: exception == null,
);
```

### Metrics to Track

| Metric | Description | Purpose |
|--------|-------------|---------|
| Request count | Total API calls | Monitor usage against quota |
| Success rate | % of successful calls | Detect API issues |
| Average latency | Mean response time | Monitor performance |
| Error rate by type | % of each error type | Identify common failures |
| Retry count | How many retries triggered | Assess network quality |

---

## 9. Security Requirements

### API Key Protection

1. **Storage**: Encrypted using `flutter_secure_storage`
2. **Transmission**: HTTPS only
3. **Logging**: Never log API key (mask in logs: `sk_...abc123`)
4. **Error Messages**: Never expose key in user-facing errors
5. **Version Control**: Never commit keys to Git

### Request Validation

1. **Image Size**: Validate ≤20MB before upload
2. **Image Format**: Validate JPEG/PNG
3. **API Key Format**: Validate 40-character alphanumeric
4. **Request Body**: Validate JSON schema

### Environment Separation

| Environment | API Key Source | Project |
|-------------|----------------|---------|
| Development | `.env` (local) | `home-ai-dev` |
| Production | Secure storage | `home-ai-prod` |
| Testing | Mock (no real key) | N/A |

---

## 10. Migration Path

### From TFLite to Cloud Vision

**Phase 1**: Parallel Run (1 week)
- Keep TFLite as fallback
- Call Cloud Vision first
- Log success/failure rates

**Phase 2**: Primary Cloud (2 weeks)
- Cloud Vision is primary
- TFLite only on network failure
- Monitor performance

**Phase 3**: Cloud Only (ongoing)
- Remove TFLite dependency
- Show manual entry on network failure
- Monitor user feedback

### Rollback Plan

If Cloud Vision fails:
1. Re-enable TFLite code path
2. Update feature flag
3. Deploy hotfix

---

## Summary

This contract ensures:
- ✅ Type-safe API integration
- ✅ Comprehensive error handling
- ✅ Security best practices
- ✅ Retry logic for resilience
- ✅ Testability with mocks
- ✅ Monitoring and logging
- ✅ Clear migration path

All client code must adhere to this contract for consistent, reliable API integration.
