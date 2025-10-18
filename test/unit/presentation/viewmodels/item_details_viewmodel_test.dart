import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/core/exceptions.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/models/location_history.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_history_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:home_ai_index/presentation/viewmodels/item_details_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'item_details_viewmodel_test.mocks.dart';

@GenerateMocks([
  ItemRepository,
  CategoryRepository,
  LocationRepository,
  LocationHistoryRepository,
])
void main() {
  group('ItemDetailsViewModel', () {
    late MockItemRepository mockItemRepository;
    late MockCategoryRepository mockCategoryRepository;
    late MockLocationRepository mockLocationRepository;
    late MockLocationHistoryRepository mockLocationHistoryRepository;
    late ItemDetailsViewModel viewModel;

    late Item testItem;
    late Location testLocation;
    late LocationHistory testHistory;

    setUp(() {
      mockItemRepository = MockItemRepository();
      mockCategoryRepository = MockCategoryRepository();
      mockLocationRepository = MockLocationRepository();
      mockLocationHistoryRepository = MockLocationHistoryRepository();

      testItem = Item(
        id: 'item-1',
        name: 'Test Item',
        categoryId: 'cat-1',
        locationId: 'loc-1',
        quantity: 1,
        imagePath: '/test/image.jpg',
        notes: 'Test notes',
        addedAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      testLocation = const Location(id: 'loc-1', name: 'Test Location');

      testHistory = LocationHistory(
        id: 'hist-1',
        itemId: 'item-1',
        locationId: 'loc-1',
        timestamp: DateTime(2025),
      );

      viewModel = ItemDetailsViewModel(
        itemId: 'item-1',
        itemRepository: mockItemRepository,
        categoryRepository: mockCategoryRepository,
        locationRepository: mockLocationRepository,
        locationHistoryRepository: mockLocationHistoryRepository,
      );
    });

    group('loadItem', () {
      test('should load item successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);

        await viewModel.loadItem();

        expect(viewModel.isLoading, isFalse);
        expect(viewModel.item, equals(testItem));
        expect(viewModel.errorMessage, isNull);
      });

      test('should set loading state while loading', () async {
        when(mockItemRepository.getItemById('item-1')).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testItem;
        });

        final loadFuture = viewModel.loadItem();
        expect(viewModel.isLoading, isTrue);

        await loadFuture;
        expect(viewModel.isLoading, isFalse);
      });

      test('should handle item not found error', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(const ItemNotFoundException('item-1'));

        await viewModel.loadItem();

        expect(viewModel.isLoading, isFalse);
        expect(viewModel.item, isNull);
        expect(viewModel.errorMessage, contains('not found'));
      });

      test('should handle general errors', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(Exception('Database error'));

        await viewModel.loadItem();

        expect(viewModel.isLoading, isFalse);
        expect(viewModel.item, isNull);
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('loadLocationHistory', () {
      test('should load location history successfully', () async {
        final historyList = [testHistory];
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => historyList);

        await viewModel.loadLocationHistory();

        expect(viewModel.locationHistory, equals(historyList));
        expect(viewModel.errorMessage, isNull);
      });

      test('should load locations for each history entry', () async {
        final oldLocationHistory = LocationHistory(
          id: 'hist-old',
          itemId: 'item-1',
          locationId: 'loc-old',
          timestamp: DateTime(2024, 12),
        );
        final historyList = [oldLocationHistory, testHistory];
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => historyList);
        when(mockLocationRepository.getLocationById('loc-old')).thenAnswer(
          (_) async => const Location(id: 'loc-old', name: 'Old Location'),
        );
        when(
          mockLocationRepository.getLocationById('loc-1'),
        ).thenAnswer((_) async => testLocation);

        await viewModel.loadLocationHistory();

        verify(mockLocationRepository.getLocationById('loc-old')).called(1);
        verify(mockLocationRepository.getLocationById('loc-1')).called(1);
      });

      test('should handle empty history', () async {
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => []);

        await viewModel.loadLocationHistory();

        expect(viewModel.locationHistory, isEmpty);
        expect(viewModel.errorMessage, isNull);
      });

      test('should handle history load error', () async {
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenThrow(Exception('Failed to load history'));

        await viewModel.loadLocationHistory();

        expect(viewModel.locationHistory, isEmpty);
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('updateItemName', () {
      test('should update item name successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenAnswer((_) async => Future.value());

        await viewModel.updateItemName('Updated Name');

        expect(viewModel.item?.name, equals('Updated Name'));
        verify(mockItemRepository.updateItem(any)).called(1);
      });

      test('should validate empty name', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        await viewModel.updateItemName('');

        expect(viewModel.errorMessage, contains('cannot be empty'));
        verifyNever(mockItemRepository.updateItem(any));
      });

      test('should handle update error', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenThrow(Exception('Update failed'));

        await viewModel.updateItemName('New Name');

        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('updateItemQuantity', () {
      test('should update quantity successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});

        await viewModel.updateItemQuantity(5);

        expect(viewModel.item?.quantity, equals(5));
        verify(mockItemRepository.updateItem(any)).called(1);
      });

      test('should validate positive quantity', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        await viewModel.updateItemQuantity(0);

        expect(viewModel.errorMessage, contains('must be greater than 0'));
        verifyNever(mockItemRepository.updateItem(any));
      });

      test('should validate negative quantity', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        await viewModel.updateItemQuantity(-1);

        expect(viewModel.errorMessage, contains('must be greater than 0'));
        verifyNever(mockItemRepository.updateItem(any));
      });
    });

    group('updateItemNotes', () {
      test('should update notes successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});

        await viewModel.updateItemNotes('New notes');

        expect(viewModel.item?.notes, equals('New notes'));
        verify(mockItemRepository.updateItem(any)).called(1);
      });

      test('should allow empty notes', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenAnswer((_) async => Future.value());

        await viewModel.updateItemNotes('');

        // Empty notes are normalized to null
        expect(viewModel.item?.notes, isNull);
        verify(mockItemRepository.updateItem(any)).called(1);
      });

      test('should allow null notes', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenAnswer((_) async => Future.value());

        await viewModel.updateItemNotes(null);

        expect(viewModel.item?.notes, isNull);
        verify(mockItemRepository.updateItem(any)).called(1);
      });
    });

    group('updateItemLocation', () {
      test('should update location and create history entry', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockLocationHistoryRepository.createHistoryEntry(any),
        ).thenAnswer((_) async => testHistory);
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => [testHistory]);
        when(
          mockLocationRepository.getLocationById(any),
        ).thenAnswer((_) async => testLocation);

        await viewModel.updateItemLocation('loc-2');

        expect(viewModel.item?.locationId, equals('loc-2'));
        verify(mockItemRepository.updateItem(any)).called(1);
        verify(mockLocationHistoryRepository.createHistoryEntry(any)).called(1);
      });

      test('should handle location update to null (unassign)', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockLocationHistoryRepository.createHistoryEntry(any),
        ).thenAnswer((_) async => testHistory);
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => [testHistory]);
        when(
          mockLocationRepository.getLocationById(any),
        ).thenAnswer((_) async => testLocation);

        await viewModel.updateItemLocation(null);

        expect(viewModel.item?.locationId, isNull);
        verify(mockItemRepository.updateItem(any)).called(1);
        verify(mockLocationHistoryRepository.createHistoryEntry(any)).called(1);
      });

      test('should not update if location is same', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        await viewModel.updateItemLocation('loc-1');

        verifyNever(mockItemRepository.updateItem(any));
        verifyNever(mockLocationHistoryRepository.createHistoryEntry(any));
      });

      test('should handle update error', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.updateItem(any),
        ).thenThrow(Exception('Update failed'));

        await viewModel.updateItemLocation('loc-2');

        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('updateItemCategory', () {
      test('should update category successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.updateItem(any)).thenAnswer((_) async {});

        await viewModel.updateItemCategory('cat-2');

        expect(viewModel.item?.categoryId, equals('cat-2'));
        verify(mockItemRepository.updateItem(any)).called(1);
      });

      test('should validate empty category', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        await viewModel.updateItemCategory('');

        expect(viewModel.errorMessage, contains('Category cannot be empty'));
        verifyNever(mockItemRepository.updateItem(any));
      });
    });

    group('deleteItem', () {
      test('should delete item successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.deleteItem('item-1')).thenAnswer((_) async {});

        final result = await viewModel.deleteItem();

        expect(result, isTrue);
        verify(mockItemRepository.deleteItem('item-1')).called(1);
      });

      test('should handle delete error', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(
          mockItemRepository.deleteItem('item-1'),
        ).thenThrow(Exception('Delete failed'));

        final result = await viewModel.deleteItem();

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should store deleted item for undo', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.deleteItem('item-1')).thenAnswer((_) async {});

        await viewModel.deleteItem();

        expect(viewModel.deletedItem, equals(testItem));
      });
    });

    group('restoreItem', () {
      test('should restore deleted item successfully', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.deleteItem('item-1')).thenAnswer((_) async {});
        await viewModel.deleteItem();

        when(
          mockItemRepository.createItem(testItem),
        ).thenAnswer((_) async => testItem.id);

        final result = await viewModel.restoreItem();

        expect(result, isTrue);
        expect(viewModel.item, equals(testItem));
        expect(viewModel.deletedItem, isNull);
        verify(mockItemRepository.createItem(testItem)).called(1);
      });

      test('should return false if no deleted item', () async {
        final result = await viewModel.restoreItem();

        expect(result, isFalse);
        verifyNever(mockItemRepository.createItem(any));
      });

      test('should handle restore error', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.deleteItem('item-1')).thenAnswer((_) async {});
        await viewModel.deleteItem();

        when(
          mockItemRepository.createItem(testItem),
        ).thenThrow(Exception('Restore failed'));

        final result = await viewModel.restoreItem();

        expect(result, isFalse);
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('clearUndoData', () {
      test('should clear deleted item', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenAnswer((_) async => testItem);
        await viewModel.loadItem();

        when(mockItemRepository.deleteItem('item-1')).thenAnswer((_) async {});
        await viewModel.deleteItem();

        expect(viewModel.deletedItem, isNotNull);

        viewModel.clearUndoData();

        expect(viewModel.deletedItem, isNull);
      });
    });

    group('getLocationName', () {
      test('should return location name for valid location', () async {
        // First load the location into cache via loadLocationHistory
        final historyList = [testHistory];
        when(
          mockLocationHistoryRepository.getHistoryForItem('item-1'),
        ).thenAnswer((_) async => historyList);
        when(
          mockLocationRepository.getLocationById('loc-1'),
        ).thenAnswer((_) async => testLocation);

        await viewModel.loadLocationHistory();

        final name = viewModel.getLocationName('loc-1');

        expect(name, equals('Test Location'));
      });

      test('should return "Unlocated" for null location', () {
        final name = viewModel.getLocationName(null);

        expect(name, equals('Unlocated'));
      });

      test('should return "Unknown" for location not in cache', () {
        final name = viewModel.getLocationName('loc-1');

        expect(name, equals('Unknown'));
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        when(
          mockItemRepository.getItemById('item-1'),
        ).thenThrow(Exception('Error'));
        await viewModel.loadItem();

        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
      });
    });
  });
}
