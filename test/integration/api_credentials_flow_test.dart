import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:home_ai_index/data/services/api_credentials_manager.dart';

/// Integration test for API credentials flow (T047).
///
/// Tests the complete flow: save credentials → verify secure storage →
/// load credentials → verify data integrity.
///
/// Note: These tests use FlutterSecureStorage, which requires platform
/// channel support. In CI/CD, mock the platform channel or use integration
/// test environment.
void main() {
  group('API Credentials Flow Integration Test (T047)', () {
    late FlutterSecureStorage secureStorage;
    late APICredentialsManager credentialsManager;

    setUp(() {
      // Use FlutterSecureStorage with default options
      secureStorage = const FlutterSecureStorage();
      credentialsManager = APICredentialsManager();
    });

    tearDown(() async {
      // Clean up: clear all credentials after each test
      try {
        await APICredentials.clear(secureStorage);
      } catch (e) {
        // Ignore errors during cleanup (platform may not be available)
      }
    });

    test(
      'complete credential flow - save, load, verify',
      () async {
        // ARRANGE
        const testApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu'; // 40 chars
        const testProjectId = 'my-test-project';

        // ACT 1: Save credentials
        await credentialsManager.save(
          apiKey: testApiKey,
          projectId: testProjectId,
        );

        // ASSERT 1: Credentials should be saved
        final hasCredentials = await credentialsManager.hasValidCredentials();
        expect(hasCredentials, isTrue, reason: 'Credentials should be saved');

        // ACT 2: Load credentials
        final loadedCredentials = await credentialsManager.load();

        // ASSERT 2: Loaded credentials should match saved values
        expect(
          loadedCredentials,
          isNotNull,
          reason: 'Credentials should be loadable',
        );
        expect(
          loadedCredentials!.apiKey,
          testApiKey,
          reason: 'API key should match saved value',
        );
        expect(
          loadedCredentials.projectId,
          testProjectId,
          reason: 'Project ID should match saved value',
        );

        // ASSERT 3: Credentials should be valid
        expect(
          loadedCredentials.isValid(),
          isTrue,
          reason: 'Loaded credentials should be valid',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'credential flow without project ID',
      () async {
        // ARRANGE
        const testApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu';

        // ACT: Save credentials without project ID
        await credentialsManager.save(apiKey: testApiKey);

        // ASSERT: Load and verify
        final loadedCredentials = await credentialsManager.load();
        expect(loadedCredentials, isNotNull);
        expect(loadedCredentials!.apiKey, testApiKey);
        expect(loadedCredentials.projectId, isNull);
        expect(loadedCredentials.isValid(), isTrue);
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'clear credentials removes all data',
      () async {
        // ARRANGE: Save credentials first
        const testApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu';
        await credentialsManager.save(apiKey: testApiKey);

        // Verify credentials exist
        var hasCredentials = await credentialsManager.hasValidCredentials();
        expect(hasCredentials, isTrue);

        // ACT: Clear credentials
        await credentialsManager.clear();

        // ASSERT: Credentials should be removed
        hasCredentials = await credentialsManager.hasValidCredentials();
        expect(
          hasCredentials,
          isFalse,
          reason: 'Credentials should be cleared',
        );

        final loadedCredentials = await credentialsManager.load();
        expect(
          loadedCredentials,
          isNull,
          reason: 'Load should return null after clearing',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'invalid credentials are detected',
      () async {
        // ARRANGE: Save credentials with invalid API key (too short)
        const invalidApiKey = 'short-key'; // Less than 20 characters

        // ACT: Save credentials
        await credentialsManager.save(apiKey: invalidApiKey);

        // ASSERT: hasValidCredentials should return false
        final hasCredentials = await credentialsManager.hasValidCredentials();
        expect(
          hasCredentials,
          isFalse,
          reason: 'Short API key should be invalid',
        );

        // Load credentials to verify
        final loadedCredentials = await credentialsManager.load();
        expect(loadedCredentials, isNotNull);
        expect(
          loadedCredentials!.isValid(),
          isFalse,
          reason: 'Loaded credentials should be invalid',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'credentials persist across manager instances',
      () async {
        // ARRANGE
        const testApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu';
        const testProjectId = 'persistence-test';

        // ACT 1: Save with first manager instance
        final manager1 = APICredentialsManager();
        await manager1.save(apiKey: testApiKey, projectId: testProjectId);

        // ACT 2: Load with second manager instance
        final manager2 = APICredentialsManager();
        final loadedCredentials = await manager2.load();

        // ASSERT: Data should persist across instances
        expect(loadedCredentials, isNotNull);
        expect(loadedCredentials!.apiKey, testApiKey);
        expect(loadedCredentials.projectId, testProjectId);
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'empty string project ID is treated as null',
      () async {
        // ARRANGE
        const testApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu';

        // ACT: Save with empty project ID
        await credentialsManager.save(apiKey: testApiKey, projectId: '');

        // ASSERT: Empty project ID should not be saved
        final loadedCredentials = await credentialsManager.load();
        expect(loadedCredentials, isNotNull);
        expect(loadedCredentials!.apiKey, testApiKey);
        expect(
          loadedCredentials.projectId,
          isNull,
          reason: 'Empty project ID should be treated as null',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'update existing credentials',
      () async {
        // ARRANGE: Save initial credentials
        const initialApiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstu';
        const initialProjectId = 'initial-project';
        await credentialsManager.save(
          apiKey: initialApiKey,
          projectId: initialProjectId,
        );

        // ACT: Update with new credentials
        const updatedApiKey = 'AIzaSyDNEWKEY567890abcdefghijklmnop';
        const updatedProjectId = 'updated-project';
        await credentialsManager.save(
          apiKey: updatedApiKey,
          projectId: updatedProjectId,
        );

        // ASSERT: Should have updated credentials
        final loadedCredentials = await credentialsManager.load();
        expect(loadedCredentials, isNotNull);
        expect(
          loadedCredentials!.apiKey,
          updatedApiKey,
          reason: 'API key should be updated',
        );
        expect(
          loadedCredentials.projectId,
          updatedProjectId,
          reason: 'Project ID should be updated',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );

    test(
      'credentials with special characters',
      () async {
        // ARRANGE: API key with various special characters
        const testApiKey =
            'AIzaSyD-_1234567890abcdefghijklmnop.QRST'; // 44 chars
        const testProjectId = 'project-with-dashes_and_underscores';

        // ACT: Save and load
        await credentialsManager.save(
          apiKey: testApiKey,
          projectId: testProjectId,
        );
        final loadedCredentials = await credentialsManager.load();

        // ASSERT: Special characters should be preserved
        expect(loadedCredentials, isNotNull);
        expect(
          loadedCredentials!.apiKey,
          testApiKey,
          reason: 'Special characters in API key should be preserved',
        );
        expect(
          loadedCredentials.projectId,
          testProjectId,
          reason: 'Special characters in project ID should be preserved',
        );
      },
      skip: 'Requires platform channel - run in integration test environment',
    );
  });
}
