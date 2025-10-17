import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/services/api_credentials_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_credentials_manager_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late APICredentialsManager manager;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    manager = APICredentialsManager(storage: mockStorage);
  });

  group('APICredentialsManager', () {
    group('save', () {
      test('should save API key to secure storage', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async => {});

        // Act
        await manager.save(apiKey: apiKey);

        // Assert
        verify(
          mockStorage.write(key: 'google_cloud_vision_api_key', value: apiKey),
        ).called(1);
      });

      test('should save both API key and project ID', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        const projectId = 'my-project-id';
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async => {});

        // Act
        await manager.save(apiKey: apiKey, projectId: projectId);

        // Assert
        verify(
          mockStorage.write(key: 'google_cloud_vision_api_key', value: apiKey),
        ).called(1);
        verify(
          mockStorage.write(key: 'google_cloud_project_id', value: projectId),
        ).called(1);
      });

      test('should clear project ID when not provided', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async => {});
        when(
          mockStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async => {});

        // Act
        await manager.save(apiKey: apiKey);

        // Assert
        verify(mockStorage.delete(key: 'google_cloud_project_id')).called(1);
      });

      test('should clear project ID when empty string provided', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async => {});
        when(
          mockStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async => {});

        // Act
        await manager.save(apiKey: apiKey, projectId: '');

        // Assert
        verify(mockStorage.delete(key: 'google_cloud_project_id')).called(1);
      });

      test('should throw ArgumentError when API key is empty', () async {
        // Act & Assert
        expect(() => manager.save(apiKey: ''), throwsArgumentError);
      });
    });

    group('load', () {
      test('should load credentials with API key only', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => apiKey);
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => null);

        // Act
        final credentials = await manager.load();

        // Assert
        expect(credentials, isNotNull);
        expect(credentials!.apiKey, equals(apiKey));
        expect(credentials.projectId, isNull);
      });

      test(
        'should load credentials with both API key and project ID',
        () async {
          // Arrange
          const apiKey = 'test-api-key-123';
          const projectId = 'my-project-id';
          when(
            mockStorage.read(key: 'google_cloud_vision_api_key'),
          ).thenAnswer((_) async => apiKey);
          when(
            mockStorage.read(key: 'google_cloud_project_id'),
          ).thenAnswer((_) async => projectId);

          // Act
          final credentials = await manager.load();

          // Assert
          expect(credentials, isNotNull);
          expect(credentials!.apiKey, equals(apiKey));
          expect(credentials.projectId, equals(projectId));
        },
      );

      test('should return null when no API key is stored', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => null);

        // Act
        final credentials = await manager.load();

        // Assert
        expect(credentials, isNull);
      });

      test('should return null when API key is empty', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => '');

        // Act
        final credentials = await manager.load();

        // Assert
        expect(credentials, isNull);
      });
    });

    group('clear', () {
      test('should delete both API key and project ID', () async {
        // Arrange
        when(
          mockStorage.delete(key: anyNamed('key')),
        ).thenAnswer((_) async => {});

        // Act
        await manager.clear();

        // Assert
        verify(
          mockStorage.delete(key: 'google_cloud_vision_api_key'),
        ).called(1);
        verify(mockStorage.delete(key: 'google_cloud_project_id')).called(1);
      });
    });

    group('hasValidCredentials', () {
      test('should return true when valid API key exists', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => 'test-api-key-123');

        // Act
        final hasCredentials = await manager.hasValidCredentials();

        // Assert
        expect(hasCredentials, isTrue);
      });

      test('should return false when no API key exists', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => null);

        // Act
        final hasCredentials = await manager.hasValidCredentials();

        // Assert
        expect(hasCredentials, isFalse);
      });

      test('should return false when API key is empty', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => '');

        // Act
        final hasCredentials = await manager.hasValidCredentials();

        // Assert
        expect(hasCredentials, isFalse);
      });
    });

    group('getApiKey', () {
      test('should return API key when it exists', () async {
        // Arrange
        const apiKey = 'test-api-key-123';
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => apiKey);

        // Act
        final result = await manager.getApiKey();

        // Assert
        expect(result, equals(apiKey));
      });

      test('should return null when API key does not exist', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_vision_api_key'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await manager.getApiKey();

        // Assert
        expect(result, isNull);
      });
    });

    group('getProjectId', () {
      test('should return project ID when it exists', () async {
        // Arrange
        const projectId = 'my-project-id';
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => projectId);

        // Act
        final result = await manager.getProjectId();

        // Assert
        expect(result, equals(projectId));
      });

      test('should return null when project ID does not exist', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await manager.getProjectId();

        // Assert
        expect(result, isNull);
      });
    });

    group('hasProjectId', () {
      test('should return true when project ID exists', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => 'my-project-id');

        // Act
        final result = await manager.hasProjectId();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when project ID does not exist', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await manager.hasProjectId();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when project ID is empty', () async {
        // Arrange
        when(
          mockStorage.read(key: 'google_cloud_project_id'),
        ).thenAnswer((_) async => '');

        // Act
        final result = await manager.hasProjectId();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
