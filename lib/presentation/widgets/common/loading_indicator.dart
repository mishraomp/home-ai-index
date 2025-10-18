import 'package:flutter/material.dart';

/// A reusable loading indicator widget
///
/// Features:
/// - Centered circular progress indicator
/// - Optional loading message
/// - Material 3 design
/// - Semantic labels for accessibility
/// - Overlay mode for full-screen loading
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.message,
    this.size = LoadingSize.medium,
    super.key,
  });

  /// Optional message to display below the indicator
  final String? message;

  /// Size of the loading indicator
  final LoadingSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final indicatorSize = switch (size) {
      LoadingSize.small => 24.0,
      LoadingSize.medium => 40.0,
      LoadingSize.large => 56.0,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: size == LoadingSize.small ? 2.5 : 3.5,
                semanticsLabel: 'Loading',
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Size options for the loading indicator
enum LoadingSize { small, medium, large }

/// A full-screen loading overlay
///
/// Use this to show loading state that blocks user interaction
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({this.message, super.key});

  /// Optional message to display
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: LoadingIndicator(message: message, size: LoadingSize.large),
    );
  }
}

/// A shimmer loading effect for list items
///
/// Use this for skeleton loading states
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton loader for list items
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Thumbnail
          const ShimmerLoading(width: 56, height: 56),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: MediaQuery.of(context).size.width * 0.6),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
