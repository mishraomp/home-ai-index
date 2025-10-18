import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/home_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateMocks([ItemRepository, CategoryRepository, LocationRepository])
void main() {
  late HomeViewModel viewModel;
  late MockItemRepository mockItemRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockLocationRepository mockLocationRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockLocationRepository = MockLocationRepository();
    viewModel = HomeViewModel(
      itemRepository: mockItemRepository,
      categoryRepository: mockCategoryRepository,
      locationRepository: mockLocationRepository,
    );
  });

  group('HomeViewModel', () {
    final testCategories = [
      const Category(
        id: 'cat-1',
        name: 'Groceries',
        iconCodePoint: 0xe59c,
        isCustom: false,
      ),
      const Category(
        id: 'cat-2',
        name: 'Tools',
        iconCodePoint: 0xe869,
        isCustom: false,
      ),
      const Category(
        id: 'cat-3',
        name: 'Electronics',
        iconCodePoint: 0xe1b1,
        isCustom: false,
      ),
    ];

    final testLocations = [
      const Location(id: 'loc-1', name: 'Kitchen'),
      const Location(id: 'loc-2', name: 'Garage'),
    ];

    final testItems = [
      Item(
        id: 'item-1',
        name: 'Milk',
        categoryId: 'cat-1',
        locationId: 'loc-1',
        imagePath: '/path/to/image1.jpg',
        quantity: 1,
        addedAt: DateTime(2025, 10),
        updatedAt: DateTime(2025, 10),
      ),
      Item(
        id: 'item-2',
        name: 'Hammer',
        categoryId: 'cat-2',
        locationId: 'loc-2',
        imagePath: '/path/to/image2.jpg',
        quantity: 1,
        addedAt: DateTime(2025, 10, 2),
        updatedAt: DateTime(2025, 10, 2),
      ),
      Item(
        id: 'item-3',
        name: 'Phone Charger',
        categoryId: 'cat-3',
        locationId: 'loc-1',
        imagePath: '/path/to/image3.jpg',
        quantity: 1,
        addedAt: DateTime(2025, 10, 3),
        updatedAt: DateTime(2025, 10, 3),
      ),
    ];

    group('loadData', () {
      test(
        'should load categories, locations, and recent items successfully',
        () async {
          // Arrange
          when(
            mockCategoryRepository.getCategories(),
          ).thenAnswer((_) async => testCategories);
          when(
            mockLocationRepository.getLocations(),
          ).thenAnswer((_) async => testLocations);
          when(
            mockItemRepository.getItems(),
          ).thenAnswer((_) async => testItems);

          // Act
          await viewModel.loadData();

          // Assert
          expect(viewModel.isLoading, false);
          expect(viewModel.categories, testCategories);
          expect(viewModel.locations, testLocations);
          expect(viewModel.recentItems, testItems);
          expect(viewModel.errorMessage, null);
          verify(mockCategoryRepository.getCategories()).called(1);
          verify(mockLocationRepository.getLocations()).called(1);
          verify(mockItemRepository.getItems()).called(1);
        },
      );

      test('should set loading state while loading data', () async {
        // Arrange
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        expect(viewModel.isLoading, false);
        final loadFuture = viewModel.loadData();
        expect(viewModel.isLoading, true);
        await loadFuture;

        // Assert
        expect(viewModel.isLoading, false);
      });

      test('should handle error when loading data fails', () async {
        // Arrange
        when(
          mockCategoryRepository.getCategories(),
        ).thenThrow(Exception('Database error'));

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.errorMessage, contains('Failed to load data'));
      });

      test('should clear previous error on successful load', () async {
        // Arrange - First load fails
        when(
          mockCategoryRepository.getCategories(),
        ).thenThrow(Exception('Database error'));
        await viewModel.loadData();
        expect(viewModel.errorMessage, isNotNull);

        // Arrange - Second load succeeds
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.loadData();

        // Assert
        expect(viewModel.errorMessage, null);
      });
    });

    group('filterByCategory', () {
      test('should load items filtered by category', () async {
        // Arrange
        final groceryItems = [testItems[0]]; // Only milk
        when(
          mockItemRepository.getItemsByCategory('cat-1'),
        ).thenAnswer((_) async => groceryItems);

        // Act
        await viewModel.filterByCategory('cat-1');

        // Assert
        expect(viewModel.filteredItems, groceryItems);
        expect(viewModel.selectedCategoryId, 'cat-1');
        expect(viewModel.selectedLocationId, null);
        verify(mockItemRepository.getItemsByCategory('cat-1')).called(1);
      });

      test('should clear filters when category is null', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.filterByCategory(null);

        // Assert
        expect(viewModel.filteredItems, testItems);
        expect(viewModel.selectedCategoryId, null);
        verify(mockItemRepository.getItems()).called(1);
      });

      test('should handle error when filtering by category fails', () async {
        // Arrange
        when(
          mockItemRepository.getItemsByCategory('cat-1'),
        ).thenThrow(Exception('Query error'));

        // Act
        await viewModel.filterByCategory('cat-1');

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.filteredItems, isEmpty);
      });
    });

    group('filterByLocation', () {
      test('should load items filtered by location', () async {
        // Arrange
        final kitchenItems = [testItems[0], testItems[2]]; // Milk and charger
        when(
          mockItemRepository.getItemsByLocation('loc-1'),
        ).thenAnswer((_) async => kitchenItems);

        // Act
        await viewModel.filterByLocation('loc-1');

        // Assert
        expect(viewModel.filteredItems, kitchenItems);
        expect(viewModel.selectedLocationId, 'loc-1');
        expect(viewModel.selectedCategoryId, null);
        verify(mockItemRepository.getItemsByLocation('loc-1')).called(1);
      });

      test('should clear filters when location is null', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.filterByLocation(null);

        // Assert
        expect(viewModel.filteredItems, testItems);
        expect(viewModel.selectedLocationId, null);
        verify(mockItemRepository.getItems()).called(1);
      });

      test('should handle error when filtering by location fails', () async {
        // Arrange
        when(
          mockItemRepository.getItemsByLocation('loc-1'),
        ).thenThrow(Exception('Query error'));

        // Act
        await viewModel.filterByLocation('loc-1');

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.filteredItems, isEmpty);
      });
    });

    group('sortItems', () {
      test('should sort items by name ascending', () {
        // Arrange
        viewModel.setFilteredItems(testItems);

        // Act
        viewModel.sortItems(SortOption.nameAsc);

        // Assert
        expect(viewModel.filteredItems[0].name, 'Hammer');
        expect(viewModel.filteredItems[1].name, 'Milk');
        expect(viewModel.filteredItems[2].name, 'Phone Charger');
        expect(viewModel.currentSortOption, SortOption.nameAsc);
      });

      test('should sort items by name descending', () {
        // Arrange
        viewModel.setFilteredItems(testItems);

        // Act
        viewModel.sortItems(SortOption.nameDesc);

        // Assert
        expect(viewModel.filteredItems[0].name, 'Phone Charger');
        expect(viewModel.filteredItems[1].name, 'Milk');
        expect(viewModel.filteredItems[2].name, 'Hammer');
        expect(viewModel.currentSortOption, SortOption.nameDesc);
      });

      test('should sort items by date newest first', () {
        // Arrange
        viewModel.setFilteredItems(testItems);

        // Act
        viewModel.sortItems(SortOption.dateNewest);

        // Assert
        expect(viewModel.filteredItems[0].id, 'item-3');
        expect(viewModel.filteredItems[1].id, 'item-2');
        expect(viewModel.filteredItems[2].id, 'item-1');
        expect(viewModel.currentSortOption, SortOption.dateNewest);
      });

      test('should sort items by date oldest first', () {
        // Arrange
        viewModel.setFilteredItems(testItems);

        // Act
        viewModel.sortItems(SortOption.dateOldest);

        // Assert
        expect(viewModel.filteredItems[0].id, 'item-1');
        expect(viewModel.filteredItems[1].id, 'item-2');
        expect(viewModel.filteredItems[2].id, 'item-3');
        expect(viewModel.currentSortOption, SortOption.dateOldest);
      });
    });

    group('getCategoryById', () {
      test('should return category when found', () async {
        // Arrange
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadData();

        // Act
        final category = viewModel.getCategoryById('cat-1');

        // Assert
        expect(category, isNotNull);
        expect(category!.name, 'Groceries');
      });

      test('should return null when category not found', () async {
        // Arrange
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadData();

        // Act
        final category = viewModel.getCategoryById('invalid-id');

        // Assert
        expect(category, null);
      });
    });

    group('getLocationById', () {
      test('should return location when found', () async {
        // Arrange
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(mockItemRepository.getItems()).thenAnswer((_) async => []);
        await viewModel.loadData();

        // Act
        final location = viewModel.getLocationById('loc-1');

        // Assert
        expect(location, isNotNull);
        expect(location!.name, 'Kitchen');
      });

      test('should return null when location not found', () async {
        // Arrange
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(mockItemRepository.getItems()).thenAnswer((_) async => []);
        await viewModel.loadData();

        // Act
        final location = viewModel.getLocationById('invalid-id');

        // Assert
        expect(location, null);
      });
    });

    group('refresh', () {
      test('should reload all data when refresh is called', () async {
        // Arrange
        when(
          mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => testCategories);
        when(
          mockLocationRepository.getLocations(),
        ).thenAnswer((_) async => testLocations);
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.refresh();

        // Assert
        expect(viewModel.categories, testCategories);
        expect(viewModel.locations, testLocations);
        expect(viewModel.recentItems, testItems);
        verify(mockCategoryRepository.getCategories()).called(1);
        verify(mockLocationRepository.getLocations()).called(1);
        verify(mockItemRepository.getItems()).called(1);
      });
    });
  });
}
