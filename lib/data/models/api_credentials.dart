import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Represents Google Cloud Vision API credentials
///
/// Credentials are stored encrypted using flutter_secure_storage and
/// are never logged or exposed in error messages for security.
class APICredentials {
  const APICredentials({required this.apiKey, this.projectId});

  /// Google Cloud Vision API key (required)
  final String apiKey;

  /// Google Cloud project ID (optional)
  final String? projectId;

  /// Load credentials from secure storage
  ///
  /// Returns null if API key is not found or is empty.
  static Future<APICredentials?> load(FlutterSecureStorage storage) async {
    final apiKey = await storage.read(key: 'cloud_vision_api_key');
    if (apiKey == null || apiKey.isEmpty) return null;

    final projectId = await storage.read(key: 'cloud_vision_project_id');

    return APICredentials(apiKey: apiKey, projectId: projectId);
  }

  /// Save credentials to secure storage
  ///
  /// Encrypts and stores the API key and optional project ID.
  Future<void> save(FlutterSecureStorage storage) async {
    await storage.write(key: 'cloud_vision_api_key', value: apiKey);
    if (projectId != null) {
      await storage.write(key: 'cloud_vision_project_id', value: projectId);
    }
  }

  /// Clear credentials from storage
  ///
  /// Used for logout or testing scenarios.
  static Future<void> clear(FlutterSecureStorage storage) async {
    await storage.delete(key: 'cloud_vision_api_key');
    await storage.delete(key: 'cloud_vision_project_id');
  }

  /// Validate API key format
  ///
  /// Google Cloud API keys are typically 40-character alphanumeric strings.
  bool isValid() {
    // Basic validation: non-empty and reasonable length
    return apiKey.isNotEmpty && apiKey.length >= 20;
  }

  @override
  String toString() {
    // Never expose the full API key in logs
    final maskedKey = apiKey.length > 8
        ? '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}'
        : '****';
    return 'APICredentials(apiKey: $maskedKey, projectId: $projectId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APICredentials &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          projectId == other.projectId;

  @override
  int get hashCode => apiKey.hashCode ^ projectId.hashCode;
}
