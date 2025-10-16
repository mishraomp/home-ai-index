import 'package:flutter/material.dart';

import 'package:home_ai_index/core/utils/date_utils.dart';
import 'package:home_ai_index/data/models/item.dart';
import 'package:home_ai_index/presentation/widgets/category/category_badge.dart';
import 'package:home_ai_index/presentation/widgets/item/item_thumbnail.dart';

/// Widget to display an item card in a list
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.categoryName,
    required this.categoryIcon,
    this.locationName,
    this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });
  final Item item;
  final String categoryName;
  final IconData categoryIcon;
  final String? locationName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  /// Build expiration date badge with appropriate color
  Widget _buildExpirationBadge(BuildContext context, DateTime expirationDate) {
    final isExpired = ExpirationDateUtils.isExpired(expirationDate);
    final isExpiringSoon = ExpirationDateUtils.isExpiringSoon(
      expirationDate,
    );

    Color backgroundColor;
    Color foregroundColor;

    if (isExpired) {
      backgroundColor = Colors.red.shade100;
      foregroundColor = Colors.red.shade900;
    } else if (isExpiringSoon) {
      backgroundColor = Colors.orange.shade100;
      foregroundColor = Colors.orange.shade900;
    } else {
      backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
      foregroundColor = Theme.of(context).colorScheme.onTertiaryContainer;
    }

    final status = ExpirationDateUtils.getExpirationStatus(expirationDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, color: foregroundColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build semantic label
    final semanticLabel = StringBuffer('Item ${item.name}');
    if (item.quantity > 1) {
      semanticLabel.write(', quantity ${item.quantity}');
    }
    semanticLabel.write(' in $categoryName category');
    if (locationName != null) {
      semanticLabel.write(', located at $locationName');
    }
    if (item.expirationDate != null) {
      final status = ExpirationDateUtils.getExpirationStatus(
        item.expirationDate!,
      );
      semanticLabel.write(', $status');
    }

    return Semantics(
      label: semanticLabel.toString(),
      hint: 'Tap to view details',
      button: true,
      enabled: onTap != null,
      selected: isSelected,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : null,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (isSelectionMode) ...[
                  Checkbox(value: isSelected, onChanged: (_) => onTap?.call()),
                  const SizedBox(width: 8),
                ],
                ItemThumbnail(imagePath: item.imagePath, size: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CategoryBadge(
                            categoryName: categoryName,
                            icon: categoryIcon,
                            isCompact: true,
                          ),
                          if (locationName != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    locationName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (item.expirationDate != null) ...[
                        const SizedBox(height: 4),
                        _buildExpirationBadge(context, item.expirationDate!),
                      ],
                    ],
                  ),
                ),
                if (item.quantity > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
