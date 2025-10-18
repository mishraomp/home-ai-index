import 'dart:io';

import 'package:flutter/material.dart';

/// Widget to display an item's thumbnail image with fallback
class ItemThumbnail extends StatelessWidget {
  const ItemThumbnail({
    super.key,
    this.imagePath,
    this.size = 80,
    this.fallbackIcon = Icons.inventory_2,
  });
  final String? imagePath;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imagePath != null && imagePath!.isNotEmpty
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                // Optimize memory usage by decoding at display size
                cacheWidth: (size * MediaQuery.of(context).devicePixelRatio)
                    .round(),
                cacheHeight: (size * MediaQuery.of(context).devicePixelRatio)
                    .round(),
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(context);
                },
              )
            : _buildFallback(context),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
