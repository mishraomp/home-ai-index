# Data Model: Google Cloud Vision API Integration

**Feature**: Upgrade to Google Cloud Vision API  
**Date**: 2025-10-16

## Overview

This document defines the data models for Google Cloud Vision API integration, including request/response structures, credential storage, and result mapping.

---

## 1. Core Entities

### CloudVisionRequest

Represents an image recognition request to Google Cloud Vision API.

**Purpose**: Encapsulate image data and request configuration for API calls.

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `imageBytes` | `Uint8List` | Yes | Raw image data (JPEG/PNG) |
| `imageBase64` | `String` | Computed | Base64-encoded image for API |
| `maxResults` | `int` | No | Maximum labels to return (default: 10) |
| `features` | `List<Feature>` | Yes | API features to request (LABEL_DETECTION) |

**Relationships**:
- Converts to JSON for API POST request
- Created by `CloudVisionService` from image bytes

**Validation Rules**:
- `imageBytes` must not be empty
- Image size must be ≤20MB after preprocessing
- `maxResults` must be between 1 and 50

**Example**:
```dart
class CloudVisionRequest {
  final Uint8List imageBytes;
  final int maxResults;
  
  CloudVisionRequest({
    required this.imageBytes,
    this.maxResults = 10,
  });
  
  Map<String, dynamic> toJson() {
    return {
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
        }
      ],
    };
  }
}
```

---

### CloudVisionResponse

Represents the response from Google Cloud Vision API.

**Purpose**: Parse and structure API response data for processing.

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `labelAnnotations` | `List<LabelAnnotation>` | Yes | Detected labels with scores |
| `error` | `ErrorInfo?` | No | Error information if request failed |

**Nested Types**:

#### LabelAnnotation

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | `String` | Yes | Label text (e.g., "Apple", "Fruit") |
| `score` | `double` | Yes | Confidence score (0.0 to 1.0) |
| `topicality` | `double?` | No | Topicality score (optional) |

#### ErrorInfo

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | `int` | Yes | HTTP error code |
| `message` | `String` | Yes | Error message |
| `status` | `String` | Yes | Error status (e.g., "INVALID_ARGUMENT") |

**Relationships**:
- Parsed from API JSON response
- Used by `CloudVisionService` to extract labels

**Validation Rules**:
- At least one response must be present
- Scores must be between 0.0 and 1.0
- Labels must not be empty strings

**Example**:
```dart
class CloudVisionResponse {
  final List<LabelAnnotation> labelAnnotations;
  final ErrorInfo? error;
  
  CloudVisionResponse({
    required this.labelAnnotations,
    this.error,
  });
  
  factory CloudVisionResponse.fromJson(Map<String, dynamic> json) {
    final responses = json['responses'] as List;
    if (responses.isEmpty) {
      throw ApiException('Empty response from API');
    }
    
    final firstResponse = responses[0] as Map<String, dynamic>;
    
    if (firstResponse.containsKey('error')) {
      return CloudVisionResponse(
        labelAnnotations: [],
        error: ErrorInfo.fromJson(firstResponse['error']),
      );
    }
    
    final annotations = (firstResponse['labelAnnotations'] as List?)
        ?.map((json) => LabelAnnotation.fromJson(json))
        .toList() ?? [];
    
    return CloudVisionResponse(
      labelAnnotations: annotations,
      error: null,
    );
  }
  
  LabelAnnotation? get topLabel {
    if (labelAnnotations.isEmpty) return null;
    return labelAnnotations.first;
  }
}

class LabelAnnotation {
  final String description;
  final double score;
  final double? topicality;
  
  LabelAnnotation({
    required this.description,
    required this.score,
    this.topicality,
  });
  
  factory LabelAnnotation.fromJson(Map<String, dynamic> json) {
    return LabelAnnotation(
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
      topicality: (json['topicality'] as num?)?.toDouble(),
    );
  }
}

class ErrorInfo {
  final int code;
  final String message;
  final String status;
  
  ErrorInfo({
    required this.code,
    required this.message,
    required this.status,
  });
  
  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
      code: json['code'] as int,
      message: json['message'] as String,
      status: json['status'] as String,
    );
  }
}
```

---

### APICredentials

Represents securely stored Google Cloud API credentials.

**Purpose**: Encapsulate authentication information for API calls.

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `apiKey` | `String` | Yes | Google Cloud Vision API key |
| `projectId` | `String?` | No | Google Cloud project ID (optional) |

**Storage**:
- Stored encrypted using `flutter_secure_storage`
- Never logged or exposed in error messages
- Separate credentials for dev/prod environments

**Validation Rules**:
- `apiKey` must not be empty
- `apiKey` must match Google's format (40-character alphanumeric)

**Example**:
```dart
class APICredentials {
  final String apiKey;
  final String? projectId;
  
  APICredentials({
    required this.apiKey,
    this.projectId,
  });
  
  // Factory constructor from secure storage
  static Future<APICredentials?> load(
    FlutterSecureStorage storage,
  ) async {
    final apiKey = await storage.read(key: 'cloud_vision_api_key');
    if (apiKey == null || apiKey.isEmpty) return null;
    
    final projectId = await storage.read(key: 'cloud_vision_project_id');
    
    return APICredentials(
      apiKey: apiKey,
      projectId: projectId,
    );
  }
  
  // Save to secure storage
  Future<void> save(FlutterSecureStorage storage) async {
    await storage.write(key: 'cloud_vision_api_key', value: apiKey);
    if (projectId != null) {
      await storage.write(key: 'cloud_vision_project_id', value: projectId);
    }
  }
  
  // Clear from storage (for logout/testing)
  static Future<void> clear(FlutterSecureStorage storage) async {
    await storage.delete(key: 'cloud_vision_api_key');
    await storage.delete(key: 'cloud_vision_project_id');
  }
}
```

---

### RecognitionResult (Modified)

Represents the processed result of image recognition.

**Purpose**: Bridge between API response and app domain model.

**Fields** (new fields marked with *):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | `String` | Yes | Primary item name |
| `category` | `String` | Yes | Mapped category (groceries, electronics, etc.) |
| `confidence` | `double` | Yes | Confidence score (0.0 to 1.0) * |
| `alternativeLabels` | `List<String>` | No | Other suggested labels * |
| `source` | `RecognitionSource` | Yes | API or offline * |

**Enum Types**:

#### RecognitionSource

```dart
enum RecognitionSource {
  cloudVision,   // Google Cloud Vision API
  offline,       // Offline TFLite (deprecated)
  manual,        // User manual entry
}
```

**Relationships**:
- Created by `CloudVisionService` from `CloudVisionResponse`
- Used by `AddItemViewModel` to populate form fields
- Label mapped to category using `LabelMapper`

**Validation Rules**:
- `label` must not be empty
- `category` must be one of predefined categories
- `confidence` must be between 0.0 and 1.0

**Example**:
```dart
class RecognitionResult {
  final String label;
  final String category;
  final double confidence;
  final List<String> alternativeLabels;
  final RecognitionSource source;
  
  RecognitionResult({
    required this.label,
    required this.category,
    required this.confidence,
    this.alternativeLabels = const [],
    required this.source,
  });
  
  // Factory from Cloud Vision response
  factory RecognitionResult.fromCloudVision(
    CloudVisionResponse response,
    LabelMapper mapper,
  ) {
    final topLabel = response.topLabel;
    if (topLabel == null) {
      throw ApiException('No labels detected in image');
    }
    
    final category = mapper.mapLabelToCategory(topLabel.description) 
        ?? 'miscellaneous';
    
    final alternatives = response.labelAnnotations
        .skip(1)
        .take(3)
        .map((annotation) => annotation.description)
        .toList();
    
    return RecognitionResult(
      label: topLabel.description,
      category: category,
      confidence: topLabel.score,
      alternativeLabels: alternatives,
      source: RecognitionSource.cloudVision,
    );
  }
  
  // For offline/manual scenarios
  factory RecognitionResult.manual(String label, String category) {
    return RecognitionResult(
      label: label,
      category: category,
      confidence: 1.0,
      source: RecognitionSource.manual,
    );
  }
}
```

---

## 2. Supporting Models

### APILogEntry

Represents a logged API call for monitoring and debugging.

**Purpose**: Track API usage, performance, and errors.

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `String` | Yes | Unique log entry ID (UUID) |
| `timestamp` | `DateTime` | Yes | When the call was made |
| `endpoint` | `String` | Yes | API endpoint called |
| `statusCode` | `int?` | No | HTTP status code (null if failed) |
| `latency` | `Duration?` | No | Request duration |
| `error` | `String?` | No | Error message if failed |
| `success` | `bool` | Yes | Whether call succeeded |

**Example**:
```dart
class APILogEntry {
  final String id;
  final DateTime timestamp;
  final String endpoint;
  final int? statusCode;
  final Duration? latency;
  final String? error;
  final bool success;
  
  APILogEntry({
    required this.id,
    required this.timestamp,
    required this.endpoint,
    this.statusCode,
    this.latency,
    this.error,
    required this.success,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'endpoint': endpoint,
      'statusCode': statusCode,
      'latency': latency?.inMilliseconds,
      'error': error,
      'success': success,
    };
  }
}
```

---

### NetworkState

Represents the current network connectivity state.

**Purpose**: Track connectivity for UI state and API call decisions.

**Fields**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `isConnected` | `bool` | Yes | Whether device has internet |
| `connectionType` | `ConnectionType` | Yes | Type of connection |

**Enum Types**:

#### ConnectionType

```dart
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  none,
}
```

**Example**:
```dart
class NetworkState {
  final bool isConnected;
  final ConnectionType connectionType;
  
  NetworkState({
    required this.isConnected,
    required this.connectionType,
  });
  
  static Future<NetworkState> check() async {
    final connectivity = await Connectivity().checkConnectivity();
    
    final isConnected = connectivity != ConnectivityResult.none;
    final type = _mapToConnectionType(connectivity);
    
    return NetworkState(
      isConnected: isConnected,
      connectionType: type,
    );
  }
  
  static ConnectionType _mapToConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      default:
        return ConnectionType.none;
    }
  }
}
```

---

## 3. State Models

### AddItemState (Modified)

Represents the UI state during item addition with AI recognition.

**Purpose**: Manage async API call states in the UI.

**States**:

```dart
sealed class AddItemState {}

class AddItemInitial extends AddItemState {}

class AddItemLoading extends AddItemState {
  final String message;
  AddItemLoading([this.message = 'Analyzing image...']);
}

class AddItemSuccess extends AddItemState {
  final RecognitionResult result;
  AddItemSuccess(this.result);
}

class AddItemError extends AddItemState {
  final String message;
  final String? technicalDetails;
  final bool canRetry;
  
  AddItemError({
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });
}

class AddItemOffline extends AddItemState {
  final String message;
  AddItemOffline([this.message = 'No internet connection. Enter item manually.']);
}
```

---

## 4. Entity Relationships

```
┌─────────────────────┐
│  CloudVisionRequest │
└──────────┬──────────┘
           │ sends
           ▼
    ┌──────────────┐
    │  HTTP Client │
    └──────┬───────┘
           │ receives
           ▼
┌─────────────────────┐
│ CloudVisionResponse │
└──────────┬──────────┘
           │ processes
           ▼
    ┌──────────────┐
    │ LabelMapper  │
    └──────┬───────┘
           │ creates
           ▼
┌─────────────────────┐
│  RecognitionResult  │
└──────────┬──────────┘
           │ updates
           ▼
    ┌──────────────┐
    │ AddItemState │
    └──────────────┘
```

---

## 5. Validation and Constraints

### Image Constraints

- **Maximum size**: 20MB (Cloud Vision API limit)
- **Supported formats**: JPEG, PNG
- **Recommended size**: 1024x1024 pixels
- **Aspect ratio**: Any (will be resized maintaining ratio)

### API Constraints

- **Request timeout**: 10 seconds
- **Max retries**: 2 (total 3 attempts)
- **Rate limits**: Per Google Cloud project quotas
- **Max labels per request**: 50
- **Default labels requested**: 10

### Confidence Thresholds

- **Minimum confidence to suggest**: 0.7 (70%)
- **High confidence**: >0.9 (90%)
- **Low confidence warning**: <0.8 (80%)

---

## Summary

This data model provides:
- **Type-safe API interaction** with request/response models
- **Secure credential storage** with encryption
- **Comprehensive error handling** with typed exceptions
- **State management** for UI responsiveness
- **Monitoring and logging** for debugging and cost tracking
- **Backwards compatibility** with existing `ImageRecognitionResult` interface

All models follow Dart best practices with immutability, named constructors, and clear validation rules.
