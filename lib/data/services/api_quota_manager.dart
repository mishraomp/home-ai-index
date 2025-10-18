import 'package:flutter/foundation.dart';
import 'package:home_ai_index/data/services/api_usage_logger.dart';

/// Google Cloud Vision API Quota Manager
///
/// Manages API quota to stay within free tier limits and warn users
/// when approaching or exceeding limits.
///
/// Free Tier: First 1000 units/month per feature
/// - Label Detection: Free for first 1000, then $1.50/1000
class APIQuotaManager {
  APIQuotaManager({required APIUsageLogger usageLogger})
    : _usageLogger = usageLogger;

  final APIUsageLogger _usageLogger;

  // Free tier limits
  static const int freeMonthlyLimit = 1000;
  static const int warningThreshold = 900; // Warn at 90% of free tier
  static const int criticalThreshold = 950; // Critical warning at 95%

  // Pricing (per 1000 units)
  static const double labelDetectionPrice = 1.50;
  static const double textDetectionPrice = 1.50;
  static const double faceDetectionPrice = 1.50;
  static const double landmarkDetectionPrice = 1.50;
  static const double logoDetectionPrice = 1.50;
  static const double imagePropertiesPrice = 1.50;
  static const double webDetectionPrice = 3.50;
  static const double objectLocalizationPrice = 2.25;

  /// Check current month's usage
  Future<QuotaStatus> checkQuota() async {
    final monthLogs = await _usageLogger.getMonthLogs();
    final successfulCalls = monthLogs.where((log) => log.success).length;

    // Debug logging
    debugPrint('🔍 QUOTA MANAGER - checkQuota():');
    debugPrint('   Total logs this month: ${monthLogs.length}');
    debugPrint('   Successful calls: $successfulCalls');
    if (monthLogs.isNotEmpty) {
      debugPrint('   First log: ${monthLogs.first}');
      debugPrint('   Last log: ${monthLogs.last}');
    }

    return QuotaStatus(
      currentUsage: successfulCalls,
      freeLimit: freeMonthlyLimit,
      warningThreshold: warningThreshold,
      criticalThreshold: criticalThreshold,
      remainingFreeUnits: freeMonthlyLimit - successfulCalls,
      isInFreeTier: successfulCalls < freeMonthlyLimit,
      hasExceededLimit: false, // No hard limit, just billing starts
      estimatedMonthlyCost: _calculateMonthlyCost(successfulCalls),
    );
  }

  /// Calculate estimated monthly cost based on usage
  double _calculateMonthlyCost(int totalCalls) {
    if (totalCalls <= freeMonthlyLimit) {
      return 0.0;
    }

    final billableUnits = totalCalls - freeMonthlyLimit;
    // Using Label Detection price as default
    return (billableUnits / 1000) * labelDetectionPrice;
  }

  /// Check if user should be warned before making API call
  Future<QuotaWarning?> shouldWarnUser() async {
    final status = await checkQuota();

    if (status.hasExceededFreeTier) {
      return QuotaWarning(
        level: QuotaWarningLevel.exceeded,
        message:
            'You have exceeded the free tier limit (${status.freeLimit} calls/month).\n'
            'Each additional API call will cost approximately \$${(labelDetectionPrice / 1000).toStringAsFixed(4)}.\n'
            'Current month cost: \$${status.estimatedMonthlyCost.toStringAsFixed(2)}',
        currentUsage: status.currentUsage,
        costPerCall: labelDetectionPrice / 1000,
        estimatedMonthlyCost: status.estimatedMonthlyCost,
      );
    }

    if (status.isAtCriticalThreshold) {
      return QuotaWarning(
        level: QuotaWarningLevel.critical,
        message:
            'Warning: You are approaching the free tier limit!\n'
            'Used: ${status.currentUsage} of ${status.freeLimit} free calls.\n'
            'Remaining: ${status.remainingFreeUnits} free calls this month.',
        currentUsage: status.currentUsage,
        costPerCall: labelDetectionPrice / 1000,
        estimatedMonthlyCost: status.estimatedMonthlyCost,
      );
    }

    if (status.isAtWarningThreshold) {
      return QuotaWarning(
        level: QuotaWarningLevel.warning,
        message:
            'Notice: You have used ${status.currentUsage} of ${status.freeLimit} free API calls this month.\n'
            'Remaining: ${status.remainingFreeUnits} free calls.',
        currentUsage: status.currentUsage,
        costPerCall: 0.0,
        estimatedMonthlyCost: 0.0,
      );
    }

    return null;
  }

  /// Get a user-friendly quota status message
  Future<String> getQuotaStatusMessage() async {
    final status = await checkQuota();

    if (status.hasExceededFreeTier) {
      return '⚠️ Billing Active\n'
          'Used: ${status.currentUsage} calls this month\n'
          'Cost: \$${status.estimatedMonthlyCost.toStringAsFixed(2)}\n'
          'Each call: ~\$${(labelDetectionPrice / 1000).toStringAsFixed(4)}';
    }

    if (status.isAtCriticalThreshold) {
      return '⚠️ Critical: ${status.remainingFreeUnits} free calls left';
    }

    if (status.isAtWarningThreshold) {
      return '⚠️ ${status.remainingFreeUnits} free calls remaining this month';
    }

    return '✅ ${status.remainingFreeUnits} free calls remaining (${status.currentUsage}/${status.freeLimit} used)';
  }
}

/// Represents the current API quota status
class QuotaStatus {
  const QuotaStatus({
    required this.currentUsage,
    required this.freeLimit,
    required this.warningThreshold,
    required this.criticalThreshold,
    required this.remainingFreeUnits,
    required this.isInFreeTier,
    required this.hasExceededLimit,
    required this.estimatedMonthlyCost,
  });

  final int currentUsage;
  final int freeLimit;
  final int warningThreshold;
  final int criticalThreshold;
  final int remainingFreeUnits;
  final bool isInFreeTier;
  final bool hasExceededLimit;
  final double estimatedMonthlyCost;

  bool get isAtWarningThreshold => currentUsage >= warningThreshold;
  bool get isAtCriticalThreshold => currentUsage >= criticalThreshold;
  bool get hasExceededFreeTier => currentUsage >= freeLimit;

  double get percentUsed => (currentUsage / freeLimit) * 100;
}

/// Warning to display to user before API call
class QuotaWarning {
  const QuotaWarning({
    required this.level,
    required this.message,
    required this.currentUsage,
    required this.costPerCall,
    required this.estimatedMonthlyCost,
  });

  final QuotaWarningLevel level;
  final String message;
  final int currentUsage;
  final double costPerCall;
  final double estimatedMonthlyCost;

  bool get shouldBlockAction => level == QuotaWarningLevel.exceeded;
  bool get requiresConfirmation =>
      level == QuotaWarningLevel.critical ||
      level == QuotaWarningLevel.exceeded;
}

/// Severity level of quota warning
enum QuotaWarningLevel {
  warning, // 90% of free tier used
  critical, // 95% of free tier used
  exceeded, // Free tier exceeded, billing active
}
