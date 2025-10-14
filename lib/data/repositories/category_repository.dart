import 'package:home_ai_index/data/models/category.dart';

/// Repository interface for Category data operations
abstract class CategoryRepository {
  /// Retrieves all categories (both default and custom)
  Future<List<Category>> getCategories();

  /// Retrieves a category by its ID
  Future<Category?> getCategoryById(String id);

  /// Creates a new custom category
  Future<String> createCategory(Category category);

  /// Updates an existing custom category
  Future<void> updateCategory(Category category);

  /// Deletes a custom category
  Future<void> deleteCategory(String id);
}
