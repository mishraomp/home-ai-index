/// Application-wide constants for Home AI Index
library;

/// Maximum file size for photos (2MB in bytes)
const int maxImageSizeBytes = 2 * 1024 * 1024;

/// Maximum image dimensions for storage
const int maxImageWidth = 1920;
const int maxImageHeight = 1080;

/// JPEG quality for image compression (0-100)
const int imageCompressionQuality = 85;

/// Thumbnail dimensions
const int thumbnailSize = 200;

/// Thumbnail JPEG quality
const int thumbnailQuality = 70;

/// Maximum hierarchy depth for locations
const int maxLocationHierarchyDepth = 5;

/// Maximum number of location history entries to keep per item
const int maxLocationHistoryEntries = 10;

/// Number of recent items to display on home screen
const int recentItemsLimit = 10;

/// Default search results limit
const int searchResultsLimit = 50;

/// Number of days to show expiring items warning
const int expiringItemsThresholdDays = 7;

/// Undo deletion timeout in seconds
const int undoDeletionTimeoutSeconds = 30;

/// Database name
const String databaseName = 'home_ai_index.db';

/// Database version
const int databaseVersion = 1;

/// Image recognition confidence threshold (0.0-1.0)
const double mlConfidenceThreshold = 0.5;

/// Maximum number of ML predictions to return
const int mlMaxPredictions = 5;

/// ML model input dimensions
const int mlModelInputWidth = 224;
const int mlModelInputHeight = 224;
