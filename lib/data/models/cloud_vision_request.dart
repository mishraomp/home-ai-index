import 'dart:convert';
import 'dart:typed_data';

/// Represents an image recognition request to Google Cloud Vision API
class CloudVisionRequest {
  const CloudVisionRequest({required this.imageBytes, this.maxResults = 10});

  /// Raw image data (JPEG/PNG)
  final Uint8List imageBytes;

  /// Maximum number of labels to return (1-50)
  final int maxResults;

  /// Convert to JSON format for API request
  ///
  /// Returns a Map that can be encoded to JSON for the POST request body.
  Map<String, dynamic> toJson() {
    return {
      'requests': [
        {
          'image': {'content': base64Encode(imageBytes)},
          'features': [
            {'type': 'LABEL_DETECTION', 'maxResults': maxResults},
          ],
          'imageContext': {
            'languageHints': ['en'],
          },
        },
      ],
    };
  }

  /// Validate request parameters
  ///
  /// Throws [ArgumentError] if validation fails.
  void validate() {
    if (imageBytes.isEmpty) {
      throw ArgumentError('Image bytes cannot be empty');
    }

    // Google Cloud Vision API limit is 20MB
    const maxSizeBytes = 20 * 1024 * 1024; // 20MB
    if (imageBytes.length > maxSizeBytes) {
      throw ArgumentError(
        'Image size (${imageBytes.length} bytes) exceeds maximum (20MB)',
      );
    }

    if (maxResults < 1 || maxResults > 50) {
      throw ArgumentError(
        'maxResults must be between 1 and 50, got $maxResults',
      );
    }
  }

  @override
  String toString() {
    return 'CloudVisionRequest(imageSize: ${imageBytes.length} bytes, maxResults: $maxResults)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudVisionRequest &&
          runtimeType == other.runtimeType &&
          imageBytes == other.imageBytes &&
          maxResults == other.maxResults;

  @override
  int get hashCode => imageBytes.hashCode ^ maxResults.hashCode;
}
