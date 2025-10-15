import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/locations_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([LocationRepository])
import 'locations_viewmodel_test.mocks.dart';

void main() {
  group('LocationsViewModel', () {
    late LocationsViewModel viewModel;
    late MockLocationRepository mockLocationRepository;

    setUp(() {
      mockLocationRepository = MockLocationRepository();
      viewModel = LocationsViewModel(
        locationRepository: mockLocationRepository,
      );
    });

    group('initialization', () {
      test('should start with initial state', () {
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.locations, isEmpty);
        expect(viewModel.selectedLocation, isNull);
      });
    });

    group('loadLocations', () {
      test('should load all locations successfully', () async {
        // Arrange
        final locations = [
          const Location(id: '1', name: 'Kitchen'),
          const Location(id: '2', name: 'Bedroom'),
          const Location(id: '3', name: 'Closet', parentId: '2'),
        ];
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => locations);

        // Act
        await viewModel.loadLocations();

        // Assert
        expect(viewModel.locations, locations);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNull);
        verify(mockLocationRepository.getLocations()).called(1);
      });

      test('should load root locations only when rootOnly is true', () async {
        // Arrange
        final rootLocations = [
          const Location(id: '1', name: 'Kitchen'),
          const Location(id: '2', name: 'Bedroom'),
        ];
        when(
          mockLocationRepository.getLocations(rootOnly: true),
        ).thenAnswer((_) async => rootLocations);

        // Act
        await viewModel.loadLocations(rootOnly: true);

        // Assert
        expect(viewModel.locations, rootLocations);
        expect(viewModel.locations.length, 2);
        verify(mockLocationRepository.getLocations(rootOnly: true)).called(1);
      });

      test('should set loading state while fetching', () async {
        // Arrange
        final locations = [const Location(id: '1', name: 'Kitchen')];
        when(mockLocationRepository.getLocations()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return locations;
        });

        // Act
        final future = viewModel.loadLocations();

        // Assert - loading should be true during operation
        expect(viewModel.isLoading, true);

        await future;
        expect(viewModel.isLoading, false);
      });

      test('should handle error when loading fails', () async {
        // Arrange
        when(
          mockLocationRepository.getLocations(),
        ).thenThrow(const DatabaseException('Database error'));

        // Act
        await viewModel.loadLocations();

        // Assert
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, contains('Failed to load locations'));
        expect(viewModel.locations, isEmpty);
      });

      test(
        'should clear error on successful load after previous error',
        () async {
          // Arrange - first call fails
          when(
            mockLocationRepository.getLocations(),
          ).thenThrow(const DatabaseException('Database error'));
          await viewModel.loadLocations();
          expect(viewModel.errorMessage, isNotNull);

          // Arrange - second call succeeds
          final locations = [const Location(id: '1', name: 'Kitchen')];
          when(
            mockLocationRepository.getLocations(),
          ).thenAnswer((_) async => locations);

          // Act
          await viewModel.loadLocations();

          // Assert
          expect(viewModel.errorMessage, isNull);
          expect(viewModel.locations, locations);
        },
      );
    });

    group('loadChildLocations', () {
      test('should load child locations for parent', () async {
        // Arrange
        final childLocations = [
          const Location(id: '3', name: 'Top Shelf', parentId: '2'),
          const Location(id: '4', name: 'Bottom Drawer', parentId: '2'),
        ];
        when(
          mockLocationRepository.getChildLocations('2'),
        ).thenAnswer((_) async => childLocations);

        // Act
        await viewModel.loadChildLocations('2');

        // Assert
        expect(viewModel.locations, childLocations);
        verify(mockLocationRepository.getChildLocations('2')).called(1);
      });

      test('should return empty list when parent has no children', () async {
        // Arrange
        when(
          mockLocationRepository.getChildLocations('1'),
        ).thenAnswer((_) async => []);

        // Act
        await viewModel.loadChildLocations('1');

        // Assert
        expect(viewModel.locations, isEmpty);
      });

      test('should handle error when loading children fails', () async {
        // Arrange
        when(
          mockLocationRepository.getChildLocations('1'),
        ).thenThrow(const DatabaseException('Database error'));

        // Act
        await viewModel.loadChildLocations('1');

        // Assert
        expect(
          viewModel.errorMessage,
          contains('Failed to load child locations'),
        );
      });
    });

    group('createLocation', () {
      test('should create root location successfully', () async {
        // Arrange
        const newLocation = Location(id: '1', name: 'Kitchen');
        when(
          mockLocationRepository.createLocation(any),
        ).thenAnswer((_) async => newLocation);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => [newLocation]);

        // Act
        await viewModel.createLocation('Kitchen', null);

        // Assert
        expect(viewModel.errorMessage, isNull);
        verify(mockLocationRepository.createLocation(any)).called(1);
        verify(mockLocationRepository.getLocations()).called(1);
      });

      test('should create child location successfully', () async {
        // Arrange
        const childLocation = Location(id: '2', name: 'Pantry', parentId: '1');
        when(
          mockLocationRepository.createLocation(any),
        ).thenAnswer((_) async => childLocation);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => [childLocation]);

        // Act
        await viewModel.createLocation('Pantry', '1');

        // Assert
        expect(viewModel.errorMessage, isNull);
        verify(mockLocationRepository.createLocation(any)).called(1);
      });

      test('should validate empty name', () async {
        // Act
        await viewModel.createLocation('', null);

        // Assert
        expect(
          viewModel.errorMessage,
          contains('Location name cannot be empty'),
        );
        verifyNever(mockLocationRepository.createLocation(any));
      });

      test('should validate whitespace-only name', () async {
        // Act
        await viewModel.createLocation('   ', null);

        // Assert
        expect(
          viewModel.errorMessage,
          contains('Location name cannot be empty'),
        );
        verifyNever(mockLocationRepository.createLocation(any));
      });

      test('should handle validation exception from repository', () async {
        // Arrange
        when(mockLocationRepository.createLocation(any)).thenThrow(
          const ValidationException('Maximum hierarchy depth exceeded'),
        );

        // Act
        await viewModel.createLocation('Too Deep', 'parent5');

        // Assert
        expect(
          viewModel.errorMessage,
          contains('Maximum hierarchy depth exceeded'),
        );
      });

      test('should handle database exception', () async {
        // Arrange
        when(
          mockLocationRepository.createLocation(any),
        ).thenThrow(const DatabaseException('Database error'));

        // Act
        await viewModel.createLocation('Kitchen', null);

        // Assert
        expect(viewModel.errorMessage, contains('Failed to create location'));
      });
    });

    group('updateLocation', () {
      test('should update location name successfully', () async {
        // Arrange
        const updatedLocation = Location(id: '1', name: 'New Kitchen');
        when(
          mockLocationRepository.updateLocation(any),
        ).thenAnswer((_) async => updatedLocation);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => [updatedLocation]);

        // Act
        await viewModel.updateLocation('1', 'New Kitchen');

        // Assert
        expect(viewModel.errorMessage, isNull);
        verify(mockLocationRepository.updateLocation(any)).called(1);
        verify(mockLocationRepository.getLocations()).called(1);
      });

      test('should validate empty name on update', () async {
        // Act
        await viewModel.updateLocation('1', '');

        // Assert
        expect(
          viewModel.errorMessage,
          contains('Location name cannot be empty'),
        );
        verifyNever(mockLocationRepository.updateLocation(any));
      });

      test('should handle location not found', () async {
        // Arrange
        when(
          mockLocationRepository.updateLocation(any),
        ).thenThrow(const LocationNotFoundException('Location not found'));

        // Act
        await viewModel.updateLocation('999', 'New Name');

        // Assert
        expect(viewModel.errorMessage, contains('Location not found'));
      });

      test('should handle database exception on update', () async {
        // Arrange
        when(
          mockLocationRepository.updateLocation(any),
        ).thenThrow(const DatabaseException('Database error'));

        // Act
        await viewModel.updateLocation('1', 'New Name');

        // Assert
        expect(viewModel.errorMessage, contains('Failed to update location'));
      });
    });

    group('deleteLocation', () {
      test('should delete location without items successfully', () async {
        // Arrange
        when(
          mockLocationRepository.hasItems('1'),
        ).thenAnswer((_) async => false);
        when(
          mockLocationRepository.deleteLocation('1'),
        ).thenAnswer((_) async => true);
        when(mockLocationRepository.getLocations()).thenAnswer((_) async => []);

        // Act
        await viewModel.deleteLocation('1', deleteItems: false);

        // Assert
        expect(viewModel.errorMessage, isNull);
        verify(mockLocationRepository.deleteLocation('1')).called(1);
        verify(mockLocationRepository.getLocations()).called(1);
      });

      test('should warn when deleting location with items', () async {
        // Arrange
        when(
          mockLocationRepository.hasItems('1'),
        ).thenAnswer((_) async => true);

        // Act
        final hasItems = await viewModel.checkLocationHasItems('1');

        // Assert
        expect(hasItems, true);
        verify(mockLocationRepository.hasItems('1')).called(1);
      });

      test('should delete location and unassign items', () async {
        // Arrange
        when(
          mockLocationRepository.deleteLocation('1'),
        ).thenAnswer((_) async => true);
        when(mockLocationRepository.getLocations()).thenAnswer((_) async => []);

        // Act
        await viewModel.deleteLocation('1', deleteItems: false);

        // Assert
        verify(mockLocationRepository.deleteLocation('1')).called(1);
      });

      test('should handle database exception on delete', () async {
        // Arrange
        when(
          mockLocationRepository.deleteLocation('1'),
        ).thenThrow(const DatabaseException('Database error'));

        // Act
        await viewModel.deleteLocation('1', deleteItems: false);

        // Assert
        expect(viewModel.errorMessage, contains('Failed to delete location'));
      });
    });

    group('getLocationPath', () {
      test('should get full location path', () async {
        // Arrange
        final path = [
          const Location(id: '1', name: 'Bedroom'),
          const Location(id: '2', name: 'Closet', parentId: '1'),
          const Location(id: '3', name: 'Top Shelf', parentId: '2'),
        ];
        when(
          mockLocationRepository.getLocationPath('3'),
        ).thenAnswer((_) async => path);

        // Act
        final result = await viewModel.getLocationPath('3');

        // Assert
        expect(result, path);
        expect(result.length, 3);
        expect(result.first.name, 'Bedroom');
        expect(result.last.name, 'Top Shelf');
      });

      test('should get path for root location', () async {
        // Arrange
        final path = [const Location(id: '1', name: 'Kitchen')];
        when(
          mockLocationRepository.getLocationPath('1'),
        ).thenAnswer((_) async => path);

        // Act
        final result = await viewModel.getLocationPath('1');

        // Assert
        expect(result, path);
        expect(result.length, 1);
      });

      test('should handle location not found in path', () async {
        // Arrange
        when(
          mockLocationRepository.getLocationPath('999'),
        ).thenThrow(const LocationNotFoundException('Location not found'));

        // Act & Assert
        expect(
          () => viewModel.getLocationPath('999'),
          throwsA(isA<LocationNotFoundException>()),
        );
      });
    });

    group('selectLocation', () {
      test('should select location', () {
        // Arrange
        const location = Location(id: '1', name: 'Kitchen');

        // Act
        viewModel.selectLocation(location);

        // Assert
        expect(viewModel.selectedLocation, location);
      });

      test('should clear selection', () {
        // Arrange
        const location = Location(id: '1', name: 'Kitchen');
        viewModel.selectLocation(location);
        expect(viewModel.selectedLocation, isNotNull);

        // Act
        viewModel.clearSelection();

        // Assert
        expect(viewModel.selectedLocation, isNull);
      });
    });

    group('validateLocationMove', () {
      test('should validate valid location move', () async {
        // Arrange
        when(
          mockLocationRepository.validateLocationMove('1', '2'),
        ).thenAnswer((_) async => true);

        // Act
        final isValid = await viewModel.validateLocationMove('1', '2');

        // Assert
        expect(isValid, true);
        verify(mockLocationRepository.validateLocationMove('1', '2')).called(1);
      });

      test('should detect circular reference', () async {
        // Arrange
        when(
          mockLocationRepository.validateLocationMove('1', '2'),
        ).thenThrow(const ValidationException('Circular reference detected'));

        // Act
        final isValid = await viewModel.validateLocationMove('1', '2');

        // Assert
        expect(isValid, false);
        expect(viewModel.errorMessage, contains('Circular reference'));
      });

      test('should detect self-assignment', () async {
        // Arrange
        when(mockLocationRepository.validateLocationMove('1', '1')).thenThrow(
          const ValidationException('Cannot move location to itself'),
        );

        // Act
        final isValid = await viewModel.validateLocationMove('1', '1');

        // Assert
        expect(isValid, false);
        expect(
          viewModel.errorMessage,
          contains('Cannot move location to itself'),
        );
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Arrange - trigger an error
        when(
          mockLocationRepository.getLocations(),
        ).thenThrow(const DatabaseException('Database error'));
        await viewModel.loadLocations();
        expect(viewModel.errorMessage, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
