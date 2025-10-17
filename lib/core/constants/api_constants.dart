/// Constants for Google Cloud Vision API integration
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Google Cloud Vision API base URL
  static const String baseUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  /// API request timeout duration
  static const Duration timeout = Duration(seconds: 10);

  /// Maximum number of retry attempts
  static const int maxRetries = 2;

  /// Retry delay configuration (exponential backoff)
  static const List<Duration> retryDelays = [
    Duration(seconds: 1), // First retry after 1 second
    Duration(seconds: 2), // Second retry after 2 seconds
  ];

  /// Maximum image size (20MB - Cloud Vision API limit)
  static const int maxImageSizeBytes = 20 * 1024 * 1024;

  /// Recommended image size for preprocessing
  static const int recommendedImageSize = 1024;

  /// JPEG quality for image compression (0-100)
  static const int jpegQuality = 85;

  /// Default maximum number of labels to request
  static const int defaultMaxLabels = 10;

  /// Maximum allowed labels per request (API limit)
  static const int maxLabelsLimit = 50;

  /// Minimum confidence threshold for label suggestions
  static const double minConfidenceThreshold = 0.7;

  /// High confidence threshold
  static const double highConfidenceThreshold = 0.9;

  /// Secure storage keys
  static const String apiKeyStorageKey = 'cloud_vision_api_key';
  static const String projectIdStorageKey = 'cloud_vision_project_id';

  /// API error codes
  static const int errorCodeBadRequest = 400;
  static const int errorCodeUnauthorized = 401;
  static const int errorCodeForbidden = 403;
  static const int errorCodeNotFound = 404;
  static const int errorCodeTooManyRequests = 429;
  static const int errorCodeInternalServer = 500;
  static const int errorCodeServiceUnavailable = 503;
  static const int errorCodeGatewayTimeout = 504;

  /// API error status strings
  static const String statusInvalidArgument = 'INVALID_ARGUMENT';
  static const String statusPermissionDenied = 'PERMISSION_DENIED';
  static const String statusResourceExhausted = 'RESOURCE_EXHAUSTED';
  static const String statusInternal = 'INTERNAL';
  static const String statusUnavailable = 'UNAVAILABLE';
  static const String statusDeadlineExceeded = 'DEADLINE_EXCEEDED';
}
