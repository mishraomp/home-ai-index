import 'package:flutter/material.dart';
import 'package:home_ai_index/data/models/category.dart';

/// A grid widget that displays categories with icons
///
/// Features:
/// - Responsive grid layout (2 columns on phones, 3+ on tablets)
/// - Material 3 design with cards
/// - Icon display using Material Icons
/// - Tap handling with ripple effect
/// - Item count badges
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
    this.itemCounts,
    super.key,
  });

  /// List of categories to display
  final List<Category> categories;

  /// Callback when a category is tapped
  final void Function(Category category) onCategoryTap;

  /// Optional map of category ID to item count
  final Map<String, int>? itemCounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Responsive columns: 2 on phones, 3 on tablets, 4 on large screens
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 900
        ? 3
        : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = itemCounts?[category.id] ?? 0;

        return _CategoryCard(
          category: category,
          count: count,
          onTap: () => onCategoryTap(category),
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
    required this.colorScheme,
  });

  final Category category;
  final int count;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              // Category name
              Text(
                category.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Item count badge
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count ${count == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
