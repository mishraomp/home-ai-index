/// Custom exception hierarchy for Home AI Index
///
/// All application exceptions extend [AppException] for consistent error handling.
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(String message) : super(message, 'DB_ERROR');
}

// Entity not found exceptions
class ItemNotFoundException extends AppException {
  const ItemNotFoundException(String id)
    : super('Item not found: $id', 'ITEM_NOT_FOUND');
}

class CategoryNotFoundException extends AppException {
  const CategoryNotFoundException(String id)
    : super('Category not found: $id', 'CATEGORY_NOT_FOUND');
}

class LocationNotFoundException extends AppException {
  const LocationNotFoundException(String id)
    : super('Location not found: $id', 'LOCATION_NOT_FOUND');
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(String message)
    : super(message, 'VALIDATION_ERROR');
}

// File system exceptions
class FileSystemException extends AppException {
  const FileSystemException(String message) : super(message, 'FILE_ERROR');
}

class FileNotFoundException extends FileSystemException {
  const FileNotFoundException(String path) : super('File not found: $path');
}

// Image processing exceptions
class ImageProcessingException extends AppException {
  const ImageProcessingException(String message)
    : super(message, 'IMAGE_ERROR');
}

// ML model exceptions
class ModelLoadException extends AppException {
  const ModelLoadException(String message) : super(message, 'MODEL_LOAD_ERROR');
}

class ModelNotInitializedException extends AppException {
  const ModelNotInitializedException([String? message])
    : super(message ?? 'ML model not initialized', 'MODEL_NOT_INITIALIZED');
}

// Network exceptions for Cloud Vision API
class NetworkException extends AppException {
  const NetworkException(String message, {this.details})
    : super(message, 'NETWORK_ERROR');

  final Map<String, dynamic>? details;

  @override
  String toString() {
    if (details != null) {
      return '[$code] $message | Details: $details';
    }
    return super.toString();
  }
}

// API exceptions for Cloud Vision API
class ApiException extends AppException {
  const ApiException(
    String message, {
    this.statusCode,
    this.details,
    this.canRetry = false,
  }) : super(message, 'API_ERROR');

  final int? statusCode;
  final Map<String, dynamic>? details;
  final bool canRetry;

  @override
  String toString() {
    final statusInfo = statusCode != null ? 'Status: $statusCode | ' : '';
    if (details != null) {
      return '[$code] $statusInfo$message | Retryable: $canRetry | Details: $details';
    }
    return '[$code] $statusInfo$message | Retryable: $canRetry';
  }
}

// Authentication exceptions for Cloud Vision API
class AuthenticationException extends AppException {
  const AuthenticationException(String message, {this.details})
    : super(message, 'AUTH_ERROR');

  final Map<String, dynamic>? details;

  @override
  String toString() {
    if (details != null) {
      return '[$code] $message | Details: $details';
    }
    return super.toString();
  }
}

// Quota exceeded exception for Cloud Vision API
class QuotaExceededException extends AppException {
  const QuotaExceededException(String message, {this.details})
    : super(message, 'QUOTA_EXCEEDED');

  final Map<String, dynamic>? details;

  @override
  String toString() {
    if (details != null) {
      return '[$code] $message | Details: $details';
    }
    return super.toString();
  }
}

// Timeout exception for Cloud Vision API
class TimeoutException extends AppException {
  const TimeoutException(String message) : super(message, 'TIMEOUT_ERROR');
}
