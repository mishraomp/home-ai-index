import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_ai_index/data/services/api_quota_manager.dart';

/// Dialog to show API quota warnings before making API calls
class QuotaWarningDialog extends StatelessWidget {
  const QuotaWarningDialog({
    super.key,
    required this.warning,
    required this.onProceed,
    required this.onCancel,
  });

  final QuotaWarning warning;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        _getIconForLevel(warning.level),
        color: _getColorForLevel(warning.level),
        size: 48,
      ),
      title: Text(_getTitleForLevel(warning.level)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(warning.message),
          if (warning.level == QuotaWarningLevel.exceeded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cost per API call: ~\$${warning.costPerCall.toStringAsFixed(4)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Month-to-date cost: \$${warning.estimatedMonthlyCost.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        if (warning.level == QuotaWarningLevel.exceeded)
          ElevatedButton(
            onPressed: onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed Anyway'),
          )
        else
          ElevatedButton(onPressed: onProceed, child: const Text('Continue')),
      ],
    );
  }

  IconData _getIconForLevel(QuotaWarningLevel level) {
    switch (level) {
      case QuotaWarningLevel.warning:
        return Icons.info_outline;
      case QuotaWarningLevel.critical:
        return Icons.warning_amber;
      case QuotaWarningLevel.exceeded:
        return Icons.error_outline;
    }
  }

  Color _getColorForLevel(QuotaWarningLevel level) {
    switch (level) {
      case QuotaWarningLevel.warning:
        return Colors.blue;
      case QuotaWarningLevel.critical:
        return Colors.orange;
      case QuotaWarningLevel.exceeded:
        return Colors.red;
    }
  }

  String _getTitleForLevel(QuotaWarningLevel level) {
    switch (level) {
      case QuotaWarningLevel.warning:
        return 'API Usage Notice';
      case QuotaWarningLevel.critical:
        return 'API Quota Warning';
      case QuotaWarningLevel.exceeded:
        return 'Free Tier Exceeded';
    }
  }

  /// Show quota warning dialog
  static Future<bool> show(BuildContext context, QuotaWarning warning) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuotaWarningDialog(
        warning: warning,
        onProceed: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}

/// Banner to display current quota status in settings
class QuotaStatusBanner extends StatelessWidget {
  const QuotaStatusBanner({super.key, required this.status});

  final QuotaStatus status;

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🎨 BANNER BUILD - Current: ${status.currentUsage}, Limit: ${status.freeLimit}, Remaining: ${status.remainingFreeUnits}',
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIcon(), color: _getIconColor(), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getTitle(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: status.percentUsed / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  final text =
                      '${status.currentUsage} / ${status.freeLimit} calls used';
                  debugPrint('📊 USAGE TEXT: "$text"');
                  return Text(
                    text,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final text = '${status.remainingFreeUnits} remaining';
                  debugPrint('📊 REMAINING TEXT: "$text"');
                  return Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(),
                    ),
                  );
                },
              ),
            ],
          ),
          if (status.hasExceededFreeTier) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estimated month cost: \$${status.estimatedMonthlyCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (status.hasExceededFreeTier) return Colors.red.shade50;
    if (status.isAtCriticalThreshold) return Colors.orange.shade50;
    if (status.isAtWarningThreshold) return Colors.blue.shade50;
    return Colors.green.shade50;
  }

  Color _getBorderColor() {
    if (status.hasExceededFreeTier) return Colors.red.shade200;
    if (status.isAtCriticalThreshold) return Colors.orange.shade200;
    if (status.isAtWarningThreshold) return Colors.blue.shade200;
    return Colors.green.shade200;
  }

  Color _getIconColor() {
    if (status.hasExceededFreeTier) return Colors.red;
    if (status.isAtCriticalThreshold) return Colors.orange;
    if (status.isAtWarningThreshold) return Colors.blue;
    return Colors.green;
  }

  Color _getTextColor() {
    if (status.hasExceededFreeTier) return Colors.red.shade900;
    if (status.isAtCriticalThreshold) return Colors.orange.shade900;
    if (status.isAtWarningThreshold) return Colors.blue.shade900;
    return Colors.green.shade900;
  }

  Color _getProgressColor() {
    if (status.hasExceededFreeTier) return Colors.red;
    if (status.isAtCriticalThreshold) return Colors.orange;
    if (status.isAtWarningThreshold) return Colors.blue;
    return Colors.green;
  }

  IconData _getIcon() {
    if (status.hasExceededFreeTier) return Icons.error_outline;
    if (status.isAtCriticalThreshold) return Icons.warning_amber;
    if (status.isAtWarningThreshold) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  String _getTitle() {
    if (status.hasExceededFreeTier) {
      return 'Free Tier Exceeded - Billing Active';
    }
    if (status.isAtCriticalThreshold) {
      return 'Warning: Approaching Free Tier Limit';
    }
    if (status.isAtWarningThreshold) {
      return 'API Usage Status';
    }
    return 'Within Free Tier';
  }
}
