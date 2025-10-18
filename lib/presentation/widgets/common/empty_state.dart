import 'package:flutter/material.dart';

/// A widget that displays an empty state message with an optional action
///
/// Features:
/// - Customizable icon, title, and message
/// - Optional action button
/// - Material 3 design
/// - Responsive layout
/// - Semantic labels for accessibility
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// The icon to display (defaults to inbox icon if not provided)
  final IconData? icon;

  /// The main title text
  final String title;

  /// The descriptive message text
  final String message;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action button callback
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
                semanticLabel: 'Empty state icon',
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  const EmptyStates._();

  /// Empty state for when no items exist
  static EmptyState noItems({required VoidCallback onAddItem}) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No Items Yet',
      message: 'Start building your inventory by adding your first item.',
      actionLabel: 'Add Item',
      onAction: onAddItem,
    );
  }

  /// Empty state for when no search results found
  static EmptyState noSearchResults({required String query}) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message:
          'We couldn\'t find any items matching "$query". Try a different search term.',
    );
  }

  /// Empty state for when no items in category
  static EmptyState noCategoryItems({required String categoryName}) {
    return EmptyState(
      icon: Icons.category_outlined,
      title: 'No $categoryName Items',
      message: 'You don\'t have any items in this category yet.',
    );
  }

  /// Empty state for when no items in location
  static EmptyState noLocationItems({required String locationName}) {
    return EmptyState(
      icon: Icons.location_on_outlined,
      title: 'No Items in $locationName',
      message: 'This location doesn\'t have any items yet.',
    );
  }

  /// Empty state for when no locations exist
  static EmptyState noLocations({required VoidCallback onAddLocation}) {
    return EmptyState(
      icon: Icons.room_outlined,
      title: 'No Locations Found',
      message: 'Create your first storage location to organize your items.',
      actionLabel: 'Add Location',
      onAction: onAddLocation,
    );
  }

  /// Empty state for when no categories exist (shouldn't happen with defaults)
  static const EmptyState noCategories = EmptyState(
    icon: Icons.grid_view_outlined,
    title: 'No Categories',
    message: 'Categories are used to organize your items.',
  );
}
