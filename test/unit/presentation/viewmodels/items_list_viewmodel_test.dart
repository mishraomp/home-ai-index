import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/home_viewmodel.dart';
import 'package:home_ai_index/presentation/viewmodels/items_list_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'items_list_viewmodel_test.mocks.dart';

@GenerateMocks([ItemRepository])
void main() {
  late ItemsListViewModel viewModel;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    viewModel = ItemsListViewModel(itemRepository: mockItemRepository);
  });

  group('ItemsListViewModel', () {
    final testItems = List.generate(
      50,
      (index) => Item(
        id: 'item-$index',
        name: 'Item $index',
        categoryId: 'cat-${index % 3}', // 3 categories
        locationId: 'loc-${index % 2}', // 2 locations
        imagePath: '/path/to/image$index.jpg',
        quantity: 1,
        addedAt: DateTime(2025, 10, index + 1),
        updatedAt: DateTime(2025, 10, index + 1),
      ),
    );

    group('loadItems', () {
      test('should load items successfully', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.loadItems();

        // Assert
        expect(viewModel.items, testItems);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        verify(mockItemRepository.getItems()).called(1);
      });

      test('should set loading state while loading', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        expect(viewModel.isLoading, false);
        final loadFuture = viewModel.loadItems();
        expect(viewModel.isLoading, true);
        await loadFuture;

        // Assert
        expect(viewModel.isLoading, false);
      });

      test('should handle error during load', () async {
        // Arrange
        when(
          mockItemRepository.getItems(),
        ).thenThrow(Exception('Database error'));

        // Act
        await viewModel.loadItems();

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.items, isEmpty);
      });
    });

    group('loadItemsByCategory', () {
      test('should load items filtered by category', () async {
        // Arrange
        final categoryItems = testItems
            .where((i) => i.categoryId == 'cat-0')
            .toList();
        when(
          mockItemRepository.getItemsByCategory('cat-0'),
        ).thenAnswer((_) async => categoryItems);

        // Act
        await viewModel.loadItemsByCategory('cat-0');

        // Assert
        expect(viewModel.items, categoryItems);
        expect(viewModel.filterCategoryId, 'cat-0');
        verify(mockItemRepository.getItemsByCategory('cat-0')).called(1);
      });
    });

    group('loadItemsByLocation', () {
      test('should load items filtered by location', () async {
        // Arrange
        final locationItems = testItems
            .where((i) => i.locationId == 'loc-0')
            .toList();
        when(
          mockItemRepository.getItemsByLocation('loc-0'),
        ).thenAnswer((_) async => locationItems);

        // Act
        await viewModel.loadItemsByLocation('loc-0');

        // Assert
        expect(viewModel.items, locationItems);
        expect(viewModel.filterLocationId, 'loc-0');
        verify(mockItemRepository.getItemsByLocation('loc-0')).called(1);
      });
    });

    group('pagination', () {
      test('should load first page of items', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final page = viewModel.getPage(0);

        // Assert
        expect(page.length, 20);
        expect(page.first.id, 'item-0');
        expect(page.last.id, 'item-19');
      });

      test('should load second page of items', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final page = viewModel.getPage(1);

        // Assert
        expect(page.length, 20);
        expect(page.first.id, 'item-20');
        expect(page.last.id, 'item-39');
      });

      test('should return partial page when reaching end', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final page = viewModel.getPage(2);

        // Assert
        expect(page.length, 10); // Only 10 items left
        expect(page.first.id, 'item-40');
        expect(page.last.id, 'item-49');
      });

      test('should return empty list when page out of bounds', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final page = viewModel.getPage(10);

        // Assert
        expect(page, isEmpty);
      });

      test('should calculate total pages correctly', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act & Assert
        expect(viewModel.getTotalPages(), 3); // 50 items / 20 per page
        expect(
          viewModel.getTotalPages(pageSize: 10),
          5,
        ); // 50 items / 10 per page
        expect(
          viewModel.getTotalPages(pageSize: 100),
          1,
        ); // All fit in one page
      });

      test('should check if has next page', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act & Assert
        expect(viewModel.hasNextPage(0), true);
        expect(viewModel.hasNextPage(1), true);
        expect(viewModel.hasNextPage(2), false); // Last page
      });
    });

    group('grouping', () {
      test('should group items by category', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final grouped = viewModel.groupByCategory();

        // Assert
        expect(grouped.keys.length, 3); // 3 categories
        expect(grouped.containsKey('cat-0'), true);
        expect(grouped.containsKey('cat-1'), true);
        expect(grouped.containsKey('cat-2'), true);
        expect(
          grouped['cat-0']!.every((item) => item.categoryId == 'cat-0'),
          true,
        );
      });

      test('should group items by location', () {
        // Arrange
        viewModel.setItems(testItems);

        // Act
        final grouped = viewModel.groupByLocation();

        // Assert
        expect(grouped.keys.length, 2); // 2 locations
        expect(grouped.containsKey('loc-0'), true);
        expect(grouped.containsKey('loc-1'), true);
        expect(
          grouped['loc-0']!.every((item) => item.locationId == 'loc-0'),
          true,
        );
      });

      test('should return empty map when no items', () {
        // Act
        final groupedByCategory = viewModel.groupByCategory();
        final groupedByLocation = viewModel.groupByLocation();

        // Assert
        expect(groupedByCategory, isEmpty);
        expect(groupedByLocation, isEmpty);
      });
    });

    group('sorting', () {
      test('should sort items by name ascending', () {
        // Arrange
        final unsortedItems = [
          testItems[10], // Item 10
          testItems[5], // Item 5
          testItems[20], // Item 20
        ];
        viewModel.setItems(unsortedItems);

        // Act
        viewModel.sortBy(SortOption.nameAsc);

        // Assert
        expect(viewModel.items[0].name, 'Item 10');
        expect(viewModel.items[1].name, 'Item 20');
        expect(viewModel.items[2].name, 'Item 5');
      });

      test('should sort items by date newest first', () {
        // Arrange
        viewModel.setItems(testItems.take(5).toList());

        // Act
        viewModel.sortBy(SortOption.dateNewest);

        // Assert
        expect(viewModel.items.first.id, 'item-4'); // Most recent
        expect(viewModel.items.last.id, 'item-0'); // Oldest
      });

      test('should sort items by date oldest first', () {
        // Arrange
        viewModel.setItems(testItems.take(5).toList());

        // Act
        viewModel.sortBy(SortOption.dateOldest);

        // Assert
        expect(viewModel.items.first.id, 'item-0'); // Oldest
        expect(viewModel.items.last.id, 'item-4'); // Most recent
      });
    });

    group('filtering', () {
      test('should apply category filter', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadItems();

        // Act
        viewModel.applyFilter(categoryId: 'cat-0');

        // Assert
        expect(
          viewModel.filteredItems.every((i) => i.categoryId == 'cat-0'),
          true,
        );
      });

      test('should apply location filter', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadItems();

        // Act
        viewModel.applyFilter(locationId: 'loc-0');

        // Assert
        expect(
          viewModel.filteredItems.every((i) => i.locationId == 'loc-0'),
          true,
        );
      });

      test('should apply both category and location filters', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadItems();

        // Act
        viewModel.applyFilter(categoryId: 'cat-0', locationId: 'loc-0');

        // Assert
        expect(
          viewModel.filteredItems.every(
            (i) => i.categoryId == 'cat-0' && i.locationId == 'loc-0',
          ),
          true,
        );
      });

      test('should clear filters', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadItems();
        viewModel.applyFilter(categoryId: 'cat-0');

        // Act
        viewModel.clearFilters();

        // Assert
        expect(viewModel.filteredItems, viewModel.items);
        expect(viewModel.filterCategoryId, null);
        expect(viewModel.filterLocationId, null);
      });
    });

    group('refresh', () {
      test('should reload items when refresh is called', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.loadItems();

        // Act
        await viewModel.refresh();

        // Assert
        verify(mockItemRepository.getItems()).called(2); // Initial + refresh
      });
    });
  });
}
