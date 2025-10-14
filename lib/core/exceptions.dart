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
