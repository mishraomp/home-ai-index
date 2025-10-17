import 'package:flutter/foundation.dart';
import 'package:home_ai_index/data/services/api_credentials_manager.dart';
import 'package:home_ai_index/data/services/api_quota_manager.dart';

/// ViewModel for managing API credentials settings.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    APICredentialsManager? credentialsManager,
    APIQuotaManager? quotaManager,
  }) : _credentialsManager = credentialsManager ?? APICredentialsManager(),
       _quotaManager = quotaManager {
    _checkCredentials();
    _loadQuotaStatus();
  }
  final APICredentialsManager _credentialsManager;
  final APIQuotaManager? _quotaManager;

  bool _hasCredentials = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  QuotaStatus? _quotaStatus;

  bool get hasCredentials => _hasCredentials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  QuotaStatus? get quotaStatus => _quotaStatus;

  Future<void> _checkCredentials() async {
    _hasCredentials = await _credentialsManager.hasValidCredentials();
    notifyListeners();
  }

  /// Load stored credentials (for display in UI)
  Future<Map<String, String?>> loadStoredCredentials() async {
    try {
      final credentials = await _credentialsManager.load();
      return {
        'apiKey': credentials?.apiKey,
        'projectId': credentials?.projectId,
      };
    } catch (e) {
      debugPrint('Failed to load stored credentials: $e');
      return {'apiKey': null, 'projectId': null};
    }
  }

  /// Load current quota status
  Future<void> _loadQuotaStatus() async {
    if (_quotaManager != null) {
      try {
        _quotaStatus = await _quotaManager.checkQuota();
        notifyListeners();
      } catch (e) {
        // Quota status is optional, don't fail if unavailable
        debugPrint('Failed to load quota status: $e');
      }
    }
  }

  /// Refresh quota status
  Future<void> refreshQuotaStatus() async {
    await _loadQuotaStatus();
  }

  /// Saves API credentials.
  Future<void> saveCredentials({
    required String apiKey,
    String? projectId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Validate API key format (basic validation)
      if (apiKey.isEmpty) {
        throw ArgumentError('API key cannot be empty');
      }

      if (apiKey.length < 20) {
        throw ArgumentError('API key appears to be too short');
      }

      await _credentialsManager.save(apiKey: apiKey, projectId: projectId);

      _hasCredentials = true;
      _successMessage = 'API credentials saved successfully';

      // Refresh quota status after saving credentials
      await _loadQuotaStatus();
    } catch (e) {
      _errorMessage = e.toString();
      _hasCredentials = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears stored API credentials.
  Future<void> clearCredentials() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _credentialsManager.clear();
      _hasCredentials = false;
      _successMessage = 'API credentials cleared';
    } catch (e) {
      _errorMessage = 'Failed to clear credentials: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tests the stored credentials by checking if they're valid.
  Future<void> testCredentials() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final credentials = await _credentialsManager.load();
      if (credentials == null || !credentials.isValid()) {
        throw Exception('No valid credentials found');
      }

      _successMessage = 'Credentials are valid';
    } catch (e) {
      _errorMessage = 'Invalid credentials: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any displayed messages.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
