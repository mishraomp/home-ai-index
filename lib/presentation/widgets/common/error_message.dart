import 'package:flutter/material.dart';

/// A reusable error message widget
///
/// Features:
/// - Error icon with customizable color
/// - Error message text
/// - Optional retry button
/// - Material 3 design
/// - Semantic labels for accessibility
class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    super.key,
  });

  /// The error message to display
  final String message;

  /// Optional callback when retry button is pressed
  final VoidCallback? onRetry;

  /// The icon to display (defaults to error_outline)
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.error,
              semanticLabel: 'Error',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured error messages for common scenarios
class ErrorMessages {
  ErrorMessages._();

  /// Generic error message
  static ErrorMessage generic({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Something went wrong. Please try again.',
      onRetry: onRetry,
    );
  }

  /// Network error message
  static ErrorMessage network({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Unable to connect. Please check your internet connection.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }

  /// Database error message
  static ErrorMessage database({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Database error. Please restart the app.',
      icon: Icons.storage,
      onRetry: onRetry,
    );
  }

  /// Permission denied error
  static ErrorMessage permission({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Permission denied. Please grant the required permissions.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
    );
  }

  /// Item not found error
  static ErrorMessage notFound({String? itemType, VoidCallback? onRetry}) {
    return ErrorMessage(
      message: itemType != null
          ? '$itemType not found.'
          : 'The requested item could not be found.',
      icon: Icons.search_off,
      onRetry: onRetry,
    );
  }

  /// Load failed error
  static ErrorMessage loadFailed({String? resource, VoidCallback? onRetry}) {
    return ErrorMessage(
      message: resource != null
          ? 'Failed to load $resource.'
          : 'Failed to load data.',
      onRetry: onRetry,
    );
  }

  /// Save failed error
  static ErrorMessage saveFailed({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Failed to save changes. Please try again.',
      icon: Icons.save_outlined,
      onRetry: onRetry,
    );
  }

  /// Delete failed error
  static ErrorMessage deleteFailed({VoidCallback? onRetry}) {
    return ErrorMessage(
      message: 'Failed to delete item. Please try again.',
      icon: Icons.delete_outline,
      onRetry: onRetry,
    );
  }
}

/// A compact inline error message
///
/// Use this for form validation or inline errors
class InlineErrorMessage extends StatelessWidget {
  const InlineErrorMessage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: colorScheme.error,
            semanticLabel: 'Error',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A banner error message that appears at the top of the screen
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({required this.message, this.onDismiss, super.key});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
                size: 20,
                semanticLabel: 'Error',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onErrorContainer),
                  onPressed: onDismiss,
                  tooltip: 'Dismiss',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
