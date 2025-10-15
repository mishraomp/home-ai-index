import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/bulk_actions_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bulk_actions_viewmodel_test.mocks.dart';

@GenerateMocks([ItemRepository, LocationRepository, LocationHistoryRepository])
void main() {
  late BulkActionsViewModel viewModel;
  late MockItemRepository mockItemRepository;
  late MockLocationRepository mockLocationRepository;
  late MockLocationHistoryRepository mockLocationHistoryRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockLocationRepository = MockLocationRepository();
    mockLocationHistoryRepository = MockLocationHistoryRepository();

    viewModel = BulkActionsViewModel(
      itemRepository: mockItemRepository,
      locationRepository: mockLocationRepository,
      locationHistoryRepository: mockLocationHistoryRepository,
    );
  });

  group('BulkActionsViewModel', () {
    final testItems = [
      Item(
        id: 'item-1',
        name: 'Item 1',
        categoryId: 'cat-1',
        quantity: 1,
        addedAt: DateTime(2025, 1),
        updatedAt: DateTime(2025, 1),
        locationId: 'old-loc-1',
      ),
      Item(
        id: 'item-2',
        name: 'Item 2',
        categoryId: 'cat-1',
        quantity: 1,
        addedAt: DateTime(2025, 1),
        updatedAt: DateTime(2025, 1),
        locationId: 'old-loc-2',
      ),
      Item(
        id: 'item-3',
        name: 'Item 3',
        categoryId: 'cat-1',
        quantity: 1,
        addedAt: DateTime(2025, 1),
        updatedAt: DateTime(2025, 1),
      ),
    ];

    const testLocation = Location(id: 'new-loc', name: 'New Location');

    group('Initial State', () {
      test('should have no error initially', () {
        expect(viewModel.errorMessage, isNull);
      });

      test('should not be loading initially', () {
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('moveSelectedItems', () {
      test('should move all items to new location successfully', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItems[0]);
        when(
          mockItemRepository.getItemById('item-2'),
        ).thenAnswer((_) async => testItems[1]);
        when(
          mockItemRepository.getItemById('item-3'),
        ).thenAnswer((_) async => testItems[2]);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenAnswer((_) async => testLocation);
        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});
        when(mockLocationHistoryRepository.createHistoryEntry(any)).thenAnswer(
          (_) async => LocationHistory(
            id: 'history-1',
            itemId: 'item-1',
            locationId: 'new-loc',
            timestamp: DateTime.now(),
          ),
        );

        // Act
        await viewModel.moveSelectedItems([
          'item-1',
          'item-2',
          'item-3',
        ], 'new-loc');

        // Assert - verify items were updated
        verify(
          mockItemRepository.updateItem(
            argThat(
              predicate<Item>(
                (item) => item.id == 'item-1' && item.locationId == 'new-loc',
              ),
            ),
          ),
        ).called(1);
        verify(
          mockItemRepository.updateItem(
            argThat(
              predicate<Item>(
                (item) => item.id == 'item-2' && item.locationId == 'new-loc',
              ),
            ),
          ),
        ).called(1);
        verify(
          mockItemRepository.updateItem(
            argThat(
              predicate<Item>(
                (item) => item.id == 'item-3' && item.locationId == 'new-loc',
              ),
            ),
          ),
        ).called(1);
        expect(viewModel.errorMessage, isNull);
      });

      test('should create location history for each moved item', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItems[0]);
        when(
          mockItemRepository.getItemById('item-2'),
        ).thenAnswer((_) async => testItems[1]);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenAnswer((_) async => testLocation);
        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});
        when(mockLocationHistoryRepository.createHistoryEntry(any)).thenAnswer(
          (_) async => LocationHistory(
            id: 'history-1',
            itemId: 'item-1',
            locationId: 'new-loc',
            timestamp: DateTime.now(),
          ),
        );

        // Act
        await viewModel.moveSelectedItems(['item-1', 'item-2'], 'new-loc');

        // Assert - verify history entries were created
        verify(
          mockLocationHistoryRepository.createHistoryEntry(
            argThat(
              predicate<LocationHistory>(
                (history) =>
                    history.itemId == 'item-1' &&
                    history.locationId == 'new-loc',
              ),
            ),
          ),
        ).called(1);
        verify(
          mockLocationHistoryRepository.createHistoryEntry(
            argThat(
              predicate<LocationHistory>(
                (history) =>
                    history.itemId == 'item-2' &&
                    history.locationId == 'new-loc',
              ),
            ),
          ),
        ).called(1);
      });

      test('should move items to unlocated (empty string locationId)', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItems[0]);
        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});
        when(mockLocationHistoryRepository.createHistoryEntry(any)).thenAnswer(
          (_) async => LocationHistory(
            id: 'history-1',
            itemId: 'item-1',
            locationId: '',
            timestamp: DateTime.now(),
          ),
        );

        // Act
        await viewModel.moveSelectedItems(['item-1'], null);

        // Assert - null locationId should be stored as empty string in history
        verify(
          mockItemRepository.updateItem(
            argThat(
              predicate<Item>(
                (item) => item.id == 'item-1' && item.locationId == null,
              ),
            ),
          ),
        ).called(1);
        verify(
          mockLocationHistoryRepository.createHistoryEntry(
            argThat(
              predicate<LocationHistory>(
                (history) =>
                    history.itemId == 'item-1' && history.locationId == '',
              ),
            ),
          ),
        ).called(1);
        expect(viewModel.errorMessage, isNull);
      });

      test('should set loading state during operation', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItems[0]);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenAnswer((_) async => testLocation);
        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});
        when(mockLocationHistoryRepository.createHistoryEntry(any)).thenAnswer(
          (_) async => LocationHistory(
            id: 'history-1',
            itemId: 'item-1',
            locationId: 'new-loc',
            timestamp: DateTime.now(),
          ),
        );

        // Act & Assert
        expect(viewModel.isLoading, isFalse);
        final future = viewModel.moveSelectedItems(['item-1'], 'new-loc');
        expect(viewModel.isLoading, isTrue);
        await future;
        expect(viewModel.isLoading, isFalse);
      });

      test('should handle error when item not found', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(Exception('Item not found'));

        // Act
        await viewModel.moveSelectedItems(['item-1'], 'new-loc');

        // Assert
        expect(viewModel.errorMessage, contains('Failed to move items'));
        verifyNever(mockItemRepository.updateItem(any));
        verifyNever(mockLocationHistoryRepository.createHistoryEntry(any));
      });

      test('should handle error when location not found', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItems[0]);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenThrow(Exception('Location not found'));

        // Act
        await viewModel.moveSelectedItems(['item-1'], 'new-loc');

        // Assert
        expect(viewModel.errorMessage, contains('Failed to move items'));
        verifyNever(mockItemRepository.updateItem(any));
        verifyNever(mockLocationHistoryRepository.createHistoryEntry(any));
      });

      test('should not create history if location did not change', () async {
        // Arrange
        final itemWithSameLocation = Item(
          id: 'item-1',
          name: 'Item 1',
          categoryId: 'cat-1',
          quantity: 1,
          addedAt: DateTime(2025, 1),
          updatedAt: DateTime(2025, 1),
          locationId: 'new-loc',
        );
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => itemWithSameLocation);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenAnswer((_) async => testLocation);

        // Act
        await viewModel.moveSelectedItems(['item-1'], 'new-loc');

        // Assert - no update or history since location didn't change
        verifyNever(mockItemRepository.updateItem(any));
        verifyNever(mockLocationHistoryRepository.createHistoryEntry(any));
      });

      test('should handle empty item list', () async {
        // Act
        await viewModel.moveSelectedItems([], 'new-loc');

        // Assert
        expect(viewModel.errorMessage, isNull);
        verifyNever(mockItemRepository.getItemById(any));
        verifyNever(mockItemRepository.updateItem(any));
        verifyNever(mockLocationHistoryRepository.createHistoryEntry(any));
      });

      test('should continue processing remaining items if one fails', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(Exception('Item 1 not found'));
        when(
          mockItemRepository.getItemById('item-2'),
        ).thenAnswer((_) async => testItems[1]);
        when(
          mockLocationRepository.getLocationById('new-loc'),
        ).thenAnswer((_) async => testLocation);
        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});
        when(mockLocationHistoryRepository.createHistoryEntry(any)).thenAnswer(
          (_) async => LocationHistory(
            id: 'history-1',
            itemId: 'item-2',
            locationId: 'new-loc',
            timestamp: DateTime.now(),
          ),
        );

        // Act
        await viewModel.moveSelectedItems(['item-1', 'item-2'], 'new-loc');

        // Assert - should still process item-2 even though item-1 failed
        verify(
          mockItemRepository.updateItem(
            argThat(predicate<Item>((item) => item.id == 'item-2')),
          ),
        ).called(1);
        expect(viewModel.errorMessage, contains('Failed to move items'));
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Arrange
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(Exception('Error'));
        await viewModel.moveSelectedItems(['item-1'], 'new-loc');
        expect(viewModel.errorMessage, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
