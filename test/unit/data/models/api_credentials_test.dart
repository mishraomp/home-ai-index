import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/api_credentials.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_credentials_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
  });

  group('APICredentials', () {
    const testApiKey = 'AIzaSyDTestKey1234567890123456789012';
    const testProjectId = 'my-project-123';

    group('load()', () {
      test('should return credentials when API key exists', () async {
        // Arrange
        when(
          mockStorage.read(key: 'cloud_vision_api_key'),
        ).thenAnswer((_) async => testApiKey);
        when(
          mockStorage.read(key: 'cloud_vision_project_id'),
        ).thenAnswer((_) async => testProjectId);

        // Act
        final result = await APICredentials.load(mockStorage);

        // Assert
        expect(result, isNotNull);
        expect(result!.apiKey, testApiKey);
        expect(result.projectId, testProjectId);
        verify(mockStorage.read(key: 'cloud_vision_api_key')).called(1);
        verify(mockStorage.read(key: 'cloud_vision_project_id')).called(1);
      });

      test('should return credentials without project ID', () async {
        // Arrange
        when(
          mockStorage.read(key: 'cloud_vision_api_key'),
        ).thenAnswer((_) async => testApiKey);
        when(
          mockStorage.read(key: 'cloud_vision_project_id'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await APICredentials.load(mockStorage);

        // Assert
        expect(result, isNotNull);
        expect(result!.apiKey, testApiKey);
        expect(result.projectId, isNull);
      });

      test('should return null when API key is missing', () async {
        // Arrange
        when(
          mockStorage.read(key: 'cloud_vision_api_key'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await APICredentials.load(mockStorage);

        // Assert
        expect(result, isNull);
        verify(mockStorage.read(key: 'cloud_vision_api_key')).called(1);
        verifyNever(mockStorage.read(key: 'cloud_vision_project_id'));
      });

      test('should return null when API key is empty', () async {
        // Arrange
        when(
          mockStorage.read(key: 'cloud_vision_api_key'),
        ).thenAnswer((_) async => '');

        // Act
        final result = await APICredentials.load(mockStorage);

        // Assert
        expect(result, isNull);
      });
    });

    group('save()', () {
      test('should save API key and project ID to storage', () async {
        // Arrange
        const credentials = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});

        // Act
        await credentials.save(mockStorage);

        // Assert
        verify(
          mockStorage.write(key: 'cloud_vision_api_key', value: testApiKey),
        ).called(1);
        verify(
          mockStorage.write(
            key: 'cloud_vision_project_id',
            value: testProjectId,
          ),
        ).called(1);
      });

      test('should save only API key when project ID is null', () async {
        // Arrange
        const credentials = APICredentials(apiKey: testApiKey);
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});

        // Act
        await credentials.save(mockStorage);

        // Assert
        verify(
          mockStorage.write(key: 'cloud_vision_api_key', value: testApiKey),
        ).called(1);
        verifyNever(
          mockStorage.write(
            key: 'cloud_vision_project_id',
            value: anyNamed('value'),
          ),
        );
      });
    });

    group('clear()', () {
      test('should delete both API key and project ID', () async {
        // Arrange
        when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

        // Act
        await APICredentials.clear(mockStorage);

        // Assert
        verify(mockStorage.delete(key: 'cloud_vision_api_key')).called(1);
        verify(mockStorage.delete(key: 'cloud_vision_project_id')).called(1);
      });
    });

    group('isValid()', () {
      test('should return true for valid API key', () {
        // Arrange
        const credentials = APICredentials(apiKey: testApiKey);

        // Act & Assert
        expect(credentials.isValid(), isTrue);
      });

      test('should return true for 20-character key', () {
        // Arrange
        const credentials = APICredentials(apiKey: '12345678901234567890');

        // Act & Assert
        expect(credentials.isValid(), isTrue);
      });

      test('should return false for empty API key', () {
        // Arrange
        const credentials = APICredentials(apiKey: '');

        // Act & Assert
        expect(credentials.isValid(), isFalse);
      });

      test('should return false for short API key', () {
        // Arrange
        const credentials = APICredentials(apiKey: 'short');

        // Act & Assert
        expect(credentials.isValid(), isFalse);
      });
    });

    group('toString()', () {
      test('should mask API key in string representation', () {
        // Arrange
        const credentials = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );

        // Act
        final result = credentials.toString();

        // Assert
        expect(result, contains('AIza'));
        expect(result, contains('9012'));
        expect(result, isNot(contains(testApiKey)));
        expect(result, contains(testProjectId));
      });

      test('should mask short API key completely', () {
        // Arrange
        const credentials = APICredentials(apiKey: 'short');

        // Act
        final result = credentials.toString();

        // Assert
        expect(result, contains('****'));
        expect(result, isNot(contains('short')));
      });
    });

    group('equality', () {
      test('should be equal when API key and project ID match', () {
        // Arrange
        const credentials1 = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );
        const credentials2 = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );

        // Act & Assert
        expect(credentials1, equals(credentials2));
        expect(credentials1.hashCode, equals(credentials2.hashCode));
      });

      test('should not be equal when API keys differ', () {
        // Arrange
        const credentials1 = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );
        const credentials2 = APICredentials(
          apiKey: 'different',
          projectId: testProjectId,
        );

        // Act & Assert
        expect(credentials1, isNot(equals(credentials2)));
      });

      test('should not be equal when project IDs differ', () {
        // Arrange
        const credentials1 = APICredentials(
          apiKey: testApiKey,
          projectId: testProjectId,
        );
        const credentials2 = APICredentials(
          apiKey: testApiKey,
          projectId: 'different',
        );

        // Act & Assert
        expect(credentials1, isNot(equals(credentials2)));
      });

      test('should be equal when both have null project IDs', () {
        // Arrange
        const credentials1 = APICredentials(apiKey: testApiKey);
        const credentials2 = APICredentials(apiKey: testApiKey);

        // Act & Assert
        expect(credentials1, equals(credentials2));
      });
    });
  });
}
