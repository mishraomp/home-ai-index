import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/search_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_viewmodel_test.mocks.dart';

@GenerateMocks([ItemRepository])
void main() {
  late SearchViewModel viewModel;
  late MockItemRepository mockItemRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    viewModel = SearchViewModel(itemRepository: mockItemRepository);
  });

  group('SearchViewModel', () {
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
      Item(
        id: 'item-4',
        name: 'Screwdriver',
        categoryId: 'cat-2',
        locationId: 'loc-2',
        imagePath: '/path/to/image4.jpg',
        quantity: 2,
        addedAt: DateTime(2025, 10, 4),
        updatedAt: DateTime(2025, 10, 4),
      ),
    ];

    group('search', () {
      test('should return all items when query is empty', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);

        // Act
        await viewModel.search('');

        // Assert
        expect(viewModel.searchResults, testItems);
        expect(viewModel.isSearching, false);
        verify(mockItemRepository.getItems()).called(1);
      });

      test('should search by name and return matching items', () async {
        // Arrange
        final expectedResults = [
          testItems[1],
          testItems[3],
        ]; // Hammer and Screwdriver
        when(
          mockItemRepository.searchItems('er'),
        ).thenAnswer((_) async => expectedResults);

        // Act
        await viewModel.search('er');

        // Assert
        expect(viewModel.searchResults, expectedResults);
        expect(viewModel.searchQuery, 'er');
        verify(mockItemRepository.searchItems('er')).called(1);
      });

      test('should return empty list when no items match', () async {
        // Arrange
        when(
          mockItemRepository.searchItems('nonexistent'),
        ).thenAnswer((_) async => []);

        // Act
        await viewModel.search('nonexistent');

        // Assert
        expect(viewModel.searchResults, isEmpty);
        expect(viewModel.searchQuery, 'nonexistent');
      });

      test('should set searching state while searching', () async {
        // Arrange
        when(
          mockItemRepository.searchItems('milk'),
        ).thenAnswer((_) async => [testItems[0]]);

        // Act
        expect(viewModel.isSearching, false);
        final searchFuture = viewModel.search('milk');
        expect(viewModel.isSearching, true);
        await searchFuture;

        // Assert
        expect(viewModel.isSearching, false);
      });

      test('should handle error during search', () async {
        // Arrange
        when(
          mockItemRepository.searchItems('error'),
        ).thenThrow(Exception('Database error'));

        // Act
        await viewModel.search('error');

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.errorMessage, contains('Failed to search'));
        expect(viewModel.searchResults, isEmpty);
      });

      test('should clear previous error on successful search', () async {
        // Arrange - First search fails
        when(
          mockItemRepository.searchItems('error'),
        ).thenThrow(Exception('Database error'));
        await viewModel.search('error');
        expect(viewModel.errorMessage, isNotNull);

        // Arrange - Second search succeeds
        when(
          mockItemRepository.searchItems('milk'),
        ).thenAnswer((_) async => [testItems[0]]);

        // Act
        await viewModel.search('milk');

        // Assert
        expect(viewModel.errorMessage, null);
      });
    });

    group('debouncing', () {
      test('should debounce multiple rapid searches', () async {
        // Arrange
        when(
          mockItemRepository.searchItems(any),
        ).thenAnswer((_) async => testItems);

        // Act - Simulate rapid typing
        viewModel.searchWithDebounce('h');
        viewModel.searchWithDebounce('ha');
        viewModel.searchWithDebounce('ham');
        viewModel.searchWithDebounce('hamm');
        viewModel.searchWithDebounce('hamme');
        viewModel.searchWithDebounce('hammer');

        // Wait for debounce delay plus execution time
        await Future.delayed(const Duration(milliseconds: 400));

        // Assert - Should only call search once with final query
        verify(mockItemRepository.searchItems('hammer')).called(1);
        verifyNever(mockItemRepository.searchItems('h'));
        verifyNever(mockItemRepository.searchItems('ha'));
        verifyNever(mockItemRepository.searchItems('ham'));
        verifyNever(mockItemRepository.searchItems('hamm'));
        verifyNever(mockItemRepository.searchItems('hamme'));
      });

      test(
        'should cancel previous debounced search when new query comes',
        () async {
          // Arrange
          when(
            mockItemRepository.searchItems(any),
          ).thenAnswer((_) async => testItems);

          // Act
          viewModel.searchWithDebounce('milk');
          await Future.delayed(const Duration(milliseconds: 100));
          viewModel.searchWithDebounce('hammer');
          await Future.delayed(const Duration(milliseconds: 400));

          // Assert - Only the last search should execute
          verify(mockItemRepository.searchItems('hammer')).called(1);
          verifyNever(mockItemRepository.searchItems('milk'));
        },
      );

      test('should execute search immediately if delay has passed', () async {
        // Arrange
        when(
          mockItemRepository.searchItems('milk'),
        ).thenAnswer((_) async => [testItems[0]]);

        // Act
        viewModel.searchWithDebounce('milk');
        await Future.delayed(const Duration(milliseconds: 400));

        // Assert
        verify(mockItemRepository.searchItems('milk')).called(1);
        expect(viewModel.searchResults.length, 1);
      });
    });

    group('filterByCategory', () {
      test('should filter search results by category', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');

        // Act
        viewModel.filterByCategory('cat-2'); // Tools category

        // Assert
        expect(viewModel.filteredResults.length, 2); // Hammer and Screwdriver
        expect(
          viewModel.filteredResults.every((item) => item.categoryId == 'cat-2'),
          true,
        );
      });

      test('should show all results when category filter is null', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');
        viewModel.filterByCategory('cat-2');

        // Act
        viewModel.filterByCategory(null);

        // Assert
        expect(viewModel.filteredResults, testItems);
      });
    });

    group('filterByLocation', () {
      test('should filter search results by location', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');

        // Act
        viewModel.filterByLocation('loc-1'); // Kitchen

        // Assert
        expect(viewModel.filteredResults.length, 2); // Milk and Phone Charger
        expect(
          viewModel.filteredResults.every((item) => item.locationId == 'loc-1'),
          true,
        );
      });

      test('should show all results when location filter is null', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');
        viewModel.filterByLocation('loc-1');

        // Act
        viewModel.filterByLocation(null);

        // Assert
        expect(viewModel.filteredResults, testItems);
      });
    });

    group('combined filters', () {
      test('should apply both category and location filters', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');

        // Act - Filter for Tools in Garage
        viewModel.filterByCategory('cat-2');
        viewModel.filterByLocation('loc-2');

        // Assert
        expect(viewModel.filteredResults.length, 2); // Hammer and Screwdriver
        expect(
          viewModel.filteredResults.every(
            (item) => item.categoryId == 'cat-2' && item.locationId == 'loc-2',
          ),
          true,
        );
      });
    });

    group('clearSearch', () {
      test('should clear search query and results', () async {
        // Arrange
        when(
          mockItemRepository.searchItems('milk'),
        ).thenAnswer((_) async => [testItems[0]]);
        await viewModel.search('milk');

        // Act
        viewModel.clearSearch();

        // Assert
        expect(viewModel.searchQuery, isEmpty);
        expect(viewModel.searchResults, isEmpty);
        expect(viewModel.filteredResults, isEmpty);
      });

      test('should clear filters', () async {
        // Arrange
        when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
        await viewModel.search('');
        viewModel.filterByCategory('cat-1');
        viewModel.filterByLocation('loc-1');

        // Act
        viewModel.clearSearch();

        // Assert
        expect(viewModel.selectedCategoryId, null);
        expect(viewModel.selectedLocationId, null);
      });
    });

    group('result ranking', () {
      test('should rank exact matches higher than partial matches', () async {
        // Arrange
        final resultsWithRanking = [
          testItems[1], // Hammer - contains 'ham'
          testItems[0], // Milk - doesn't contain 'ham'
        ];
        when(
          mockItemRepository.searchItems('hammer'),
        ).thenAnswer((_) async => resultsWithRanking);

        // Act
        await viewModel.search('hammer');

        // Assert
        // Results should be ranked with Hammer first (exact match)
        expect(viewModel.searchResults.first.name, 'Hammer');
      });
    });

    group('dispose', () {
      test('should dispose resources without error', () {
        // Act & Assert
        expect(() => viewModel.dispose(), returnsNormally);
      });
    });
  });
}
