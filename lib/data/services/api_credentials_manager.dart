import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';

/// Manages secure storage of API credentials for Google Cloud Vision API.
///
/// Uses flutter_secure_storage to securely store API keys on device.
/// For development, can optionally fall back to environment variables.
class APICredentialsManager {

  APICredentialsManager({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const String _apiKeyKey = 'google_cloud_vision_api_key';
  static const String _projectIdKey = 'google_cloud_project_id';

  /// Saves API credentials to secure storage.
  ///
  /// [apiKey] is required and must be non-empty.
  /// [projectId] is optional and can be null.
  ///
  /// Throws [ArgumentError] if apiKey is empty.
  Future<void> save({required String apiKey, String? projectId}) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }

    await _storage.write(key: _apiKeyKey, value: apiKey);

    if (projectId != null && projectId.isNotEmpty) {
      await _storage.write(key: _projectIdKey, value: projectId);
    } else {
      // Clear project ID if not provided
      await _storage.delete(key: _projectIdKey);
    }
  }

  /// Loads API credentials from secure storage.
  ///
  /// Returns [APICredentials] if valid credentials exist, null otherwise.
  Future<APICredentials?> load() async {
    final apiKey = await _storage.read(key: _apiKeyKey);

    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final projectId = await _storage.read(key: _projectIdKey);

    return APICredentials(apiKey: apiKey, projectId: projectId);
  }

  /// Clears all stored API credentials from secure storage.
  Future<void> clear() async {
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _projectIdKey);
  }

  /// Checks if valid credentials exist in secure storage.
  ///
  /// Returns true if a non-empty API key is stored.
  Future<bool> hasValidCredentials() async {
    final apiKey = await _storage.read(key: _apiKeyKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Gets just the API key without loading full credentials.
  ///
  /// Returns the API key string or null if not found.
  Future<String?> getApiKey() async {
    return _storage.read(key: _apiKeyKey);
  }

  /// Gets just the project ID without loading full credentials.
  ///
  /// Returns the project ID string or null if not found.
  Future<String?> getProjectId() async {
    return _storage.read(key: _projectIdKey);
  }

  /// Checks if a project ID is stored.
  Future<bool> hasProjectId() async {
    final projectId = await _storage.read(key: _projectIdKey);
    return projectId != null && projectId.isNotEmpty;
  }
}
