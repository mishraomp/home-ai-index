import 'dart:typed_data';

import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/models/recognition_result.dart';

export 'recognition_service_impl.dart';

/// Unified service for image recognition that intelligently chooses between
/// online (Cloud Vision API) and offline (TFLite) recognition.
///
/// The service attempts to use Cloud Vision API first for better accuracy,
/// and falls back to offline TFLite if:
/// - No API credentials configured
/// - Network unavailable
/// - API quota exceeded
/// - Any other Cloud Vision error
abstract class RecognitionService {
  /// Recognize an image and return the result
  ///
  /// This method automatically chooses the best recognition method:
  /// 1. Try Cloud Vision API if credentials are available
  /// 2. Fall back to offline TFLite on any error
  ///
  /// The returned [RecognitionResult] contains metadata about which
  /// source was used (cloudVision, offline, or manual).
  Future<RecognitionResult> recognizeImage(Uint8List imageBytes);

  /// Set Cloud Vision API credentials
  ///
  /// Pass null to disable Cloud Vision and use offline-only mode.
  void setCredentials(APICredentials? credentials);

  /// Get current API credentials (if any)
  APICredentials? getCredentials();

  /// Force offline-only mode
  ///
  /// When enabled, will skip Cloud Vision API attempts even if
  /// credentials are configured. Useful for testing or conserving quota.
  void setOfflineMode(bool enabled);

  /// Check if currently in offline-only mode
  bool isOfflineMode();

  /// Dispose of resources
  void dispose();
}
