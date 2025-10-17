import 'dart:async';

import 'package:home_ai_index/data/datasources/local/database_helper.dart';
import 'package:home_ai_index/data/models/api_log_entry.dart';
import 'package:sqflite/sqflite.dart';

/// Service for logging API usage for monitoring and cost tracking
class APIUsageLogger {
  APIUsageLogger({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;
  static const int _maxLogs = 10000; // Keep last 10,000 entries

  final _logController = StreamController<APILogEntry>.broadcast();

  /// Stream of new log entries
  Stream<APILogEntry> get logStream => _logController.stream;

  /// Log an API call
  Future<void> logApiCall(APILogEntry entry) async {
    // Add to memory stream
    _logController.add(entry);

    // Persist to database
    final db = await _databaseHelper.database;
    await db.insert(
      'api_logs',
      entry.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Clean up old logs if we exceed max
    await _cleanupOldLogsIfNeeded(db);
  }

  /// Log a successful API call
  Future<void> logSuccess({
    required String endpoint,
    required int statusCode,
    required Duration latency,
    int? imageSize,
    int? labelsReturned,
    String? requestId,
  }) async {
    final entry = APILogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      endpoint: endpoint,
      statusCode: statusCode,
      latency: latency,
      success: true,
    );

    await logApiCall(entry);
  }

  /// Log a failed API call
  Future<void> logFailure({
    required String endpoint,
    int? statusCode,
    Duration? latency,
    required String error,
  }) async {
    final entry = APILogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      endpoint: endpoint,
      statusCode: statusCode,
      latency: latency,
      error: error,
      success: false,
    );

    await logApiCall(entry);
  }

  /// Get all stored logs (up to max limit)
  Future<List<APILogEntry>> getLogs() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_logs',
      orderBy: 'timestamp DESC',
      limit: _maxLogs,
    );

    return maps.map((map) => APILogEntry.fromDatabase(map)).toList();
  }

  /// Get logs within a date range
  Future<List<APILogEntry>> getLogsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_logs',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => APILogEntry.fromDatabase(map)).toList();
  }

  /// Get logs for today
  Future<List<APILogEntry>> getTodaysLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getLogsByDateRange(start: startOfDay, end: endOfDay);
  }

  /// Get logs for current month
  Future<List<APILogEntry>> getMonthLogs() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);

    return getLogsByDateRange(start: startOfMonth, end: endOfMonth);
  }

  /// Get statistics for a list of logs
  APIUsageStats getStats(List<APILogEntry> logs) {
    if (logs.isEmpty) {
      return const APIUsageStats(
        totalCalls: 0,
        successfulCalls: 0,
        failedCalls: 0,
        averageLatencyMs: 0,
        estimatedCost: 0.0,
      );
    }

    final successfulCalls = logs.where((log) => log.success).length;
    final failedCalls = logs.length - successfulCalls;

    final latencies = logs
        .where((log) => log.latency != null)
        .map((log) => log.latency!.inMilliseconds)
        .toList();

    final avgLatency = latencies.isEmpty
        ? 0
        : latencies.reduce((a, b) => a + b) ~/ latencies.length;

    // Estimated cost: $1.50 per 1000 images, first 1000 free per month
    final monthLogs = logs.where((log) {
      final now = DateTime.now();
      return log.timestamp.year == now.year && log.timestamp.month == now.month;
    }).length;

    final billableImages = monthLogs > 1000 ? monthLogs - 1000 : 0;
    final estimatedCost = billableImages * 0.0015; // $1.50 / 1000

    return APIUsageStats(
      totalCalls: logs.length,
      successfulCalls: successfulCalls,
      failedCalls: failedCalls,
      averageLatencyMs: avgLatency,
      estimatedCost: estimatedCost,
    );
  }

  /// Get statistics for today
  Future<APIUsageStats> getTodaysStats() async {
    final logs = await getTodaysLogs();
    return getStats(logs);
  }

  /// Get statistics for current month
  Future<APIUsageStats> getMonthStats() async {
    final logs = await getMonthLogs();
    return getStats(logs);
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    final db = await _databaseHelper.database;
    await db.delete('api_logs');
  }

  /// Clear old logs (older than specified days)
  Future<void> clearOldLogs(int daysToKeep) async {
    final db = await _databaseHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'api_logs',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Clean up old logs if we exceed the max limit
  Future<void> _cleanupOldLogsIfNeeded(Database db) async {
    // Count total logs
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM api_logs',
    );
    final count = countResult.first['count'] as int;

    if (count > _maxLogs) {
      // Delete oldest logs to get back to max
      final deleteCount = count - _maxLogs;
      await db.rawDelete(
        '''
        DELETE FROM api_logs
        WHERE id IN (
          SELECT id FROM api_logs
          ORDER BY timestamp ASC
          LIMIT ?
        )
      ''',
        [deleteCount],
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _logController.close();
  }
}

/// Statistics summary for API usage
class APIUsageStats {
  const APIUsageStats({
    required this.totalCalls,
    required this.successfulCalls,
    required this.failedCalls,
    required this.averageLatencyMs,
    required this.estimatedCost,
  });

  final int totalCalls;
  final int successfulCalls;
  final int failedCalls;
  final int averageLatencyMs;
  final double estimatedCost;

  double get successRate => totalCalls > 0 ? successfulCalls / totalCalls : 0.0;

  String get formattedCost => '\$${estimatedCost.toStringAsFixed(2)}';
}
