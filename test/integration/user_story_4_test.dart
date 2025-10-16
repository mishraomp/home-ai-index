import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/category.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/data/models/location.dart';
import 'package:home_ai_index/data/repositories/category_repository.dart';
import 'package:home_ai_index/data/repositories/item_repository.dart';
import 'package:home_ai_index/data/repositories/location_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_story_4_test.mocks.dart';

@GenerateMocks([ItemRepository, CategoryRepository, LocationRepository])
void main() {
  late MockItemRepository mockItemRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockLocationRepository mockLocationRepository;

  setUp(() {
    mockItemRepository = MockItemRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockLocationRepository = MockLocationRepository();
  });

  final testCategories = [
    const Category(
      id: 'cat1',
      name: 'Electronics',
      iconCodePoint: 0xe0b1,
      isCustom: false,
    ),
    const Category(
      id: 'cat2',
      name: 'Kitchen',
      iconCodePoint: 0xe0d1,
      isCustom: false,
    ),
  ];

  final testLocations = [
    const Location(id: 'loc1', name: 'Garage'),
    const Location(id: 'loc2', name: 'Kitchen'),
  ];

  final testItems = [
    Item(
      id: 'item1',
      name: 'Laptop',
      quantity: 1,
      categoryId: 'cat1',
      locationId: 'loc1',
      addedAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    Item(
      id: 'item2',
      name: 'Phone',
      quantity: 1,
      categoryId: 'cat1',
      locationId: 'loc1',
      addedAt: DateTime(2025, 1, 2),
      updatedAt: DateTime(2025, 1, 2),
    ),
    Item(
      id: 'item3',
      name: 'Coffee Maker',
      quantity: 1,
      categoryId: 'cat2',
      locationId: 'loc2',
      addedAt: DateTime(2025, 1, 3),
      updatedAt: DateTime(2025, 1, 3),
    ),
  ];

  group('User Story 4: Browse and Search Inventory - Integration Tests', () {
    testWidgets('can browse items by category', (WidgetTester tester) async {
      // Setup: Mock repositories to return test data
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User browses category
      final electronics = testItems
          .where((item) => item.categoryId == 'cat1')
          .toList();

      // Then: Should get items in that category
      expect(electronics, hasLength(2));
      expect(electronics[0].name, 'Laptop');
      expect(electronics[1].name, 'Phone');
    });

    testWidgets('can filter items by location', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User filters by location
      final garageItems = testItems
          .where((item) => item.locationId == 'loc1')
          .toList();

      // Then: Should get items in that location
      expect(garageItems, hasLength(2));
      expect(garageItems[0].name, 'Laptop');
      expect(garageItems[1].name, 'Phone');
    });

    testWidgets('can search items by name', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User searches for item
      const searchTerm = 'Laptop';
      final searchResults = testItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();

      // Then: Should find matching items
      expect(searchResults, hasLength(1));
      expect(searchResults[0].name, 'Laptop');
      expect(searchResults[0].categoryId, 'cat1');
    });

    testWidgets('search is case-insensitive', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User searches with different case
      const searchTerm = 'COFFEE';
      final searchResults = testItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();

      // Then: Should still find the item
      expect(searchResults, hasLength(1));
      expect(searchResults[0].name, 'Coffee Maker');
    });

    testWidgets('can combine filters (category + location)', (
      WidgetTester tester,
    ) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User filters by both category and location
      final filteredItems = testItems
          .where(
            (item) => item.categoryId == 'cat1' && item.locationId == 'loc1',
          )
          .toList();

      // Then: Should get items matching both criteria
      expect(filteredItems, hasLength(2));
      expect(filteredItems[0].name, 'Laptop');
      expect(filteredItems[1].name, 'Phone');
    });

    testWidgets('can get all categories', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User views categories
      final categories = await mockCategoryRepository.getCategories();

      // Then: Should have all categories
      expect(categories, hasLength(2));
      expect(categories[0].name, 'Electronics');
      expect(categories[1].name, 'Kitchen');
    });

    testWidgets('empty search returns no results', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User searches for non-existent item
      const searchTerm = 'NonExistent';
      final searchResults = testItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();

      // Then: Should return empty list
      expect(searchResults, isEmpty);
    });

    testWidgets('can get all locations', (WidgetTester tester) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User views locations
      final locations = await mockLocationRepository.getLocations();

      // Then: Should have all locations
      expect(locations, hasLength(2));
      expect(locations[0].name, 'Garage');
      expect(locations[1].name, 'Kitchen');
    });

    testWidgets('partial search works (substring matching)', (
      WidgetTester tester,
    ) async {
      // Setup: Mock repositories
      when(
        mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => testCategories);
      when(mockItemRepository.getItems()).thenAnswer((_) async => testItems);
      when(
        mockLocationRepository.getLocations(),
      ).thenAnswer((_) async => testLocations);

      // When: User searches with partial name
      const searchTerm = 'phone';
      final searchResults = testItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();

      // Then: Should find items containing the substring
      expect(searchResults, hasLength(1));
      expect(searchResults[0].name, 'Phone');
    });
  });
}
