/// Represents a logged API call for monitoring and debugging
class APILogEntry {
  /// Create from database map
  factory APILogEntry.fromDatabase(Map<String, dynamic> map) {
    return APILogEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      endpoint: map['endpoint'] as String,
      statusCode: map['status_code'] as int?,
      latency: map['latency_ms'] != null
          ? Duration(milliseconds: map['latency_ms'] as int)
          : null,
      error: map['error'] as String?,
      success: (map['success'] as int) == 1,
    );
  }
  const APILogEntry({
    required this.id,
    required this.timestamp,
    required this.endpoint,
    this.statusCode,
    this.latency,
    this.error,
    required this.success,
  });

  /// Parse from JSON
  factory APILogEntry.fromJson(Map<String, dynamic> json) {
    return APILogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      endpoint: json['endpoint'] as String,
      statusCode: json['statusCode'] as int?,
      latency: json['latencyMs'] != null
          ? Duration(milliseconds: json['latencyMs'] as int)
          : null,
      error: json['error'] as String?,
      success: json['success'] as bool,
    );
  }

  /// Create a successful log entry
  factory APILogEntry.success({
    required String id,
    required String endpoint,
    required int statusCode,
    required Duration latency,
  }) {
    return APILogEntry(
      id: id,
      timestamp: DateTime.now(),
      endpoint: endpoint,
      statusCode: statusCode,
      latency: latency,
      success: true,
    );
  }

  /// Create a failed log entry
  factory APILogEntry.failure({
    required String id,
    required String endpoint,
    int? statusCode,
    Duration? latency,
    required String error,
  }) {
    return APILogEntry(
      id: id,
      timestamp: DateTime.now(),
      endpoint: endpoint,
      statusCode: statusCode,
      latency: latency,
      error: error,
      success: false,
    );
  }

  /// Unique log entry ID
  final String id;

  /// When the API call was made
  final DateTime timestamp;

  /// API endpoint called
  final String endpoint;

  /// HTTP status code (null if failed before receiving response)
  final int? statusCode;

  /// Request duration
  final Duration? latency;

  /// Error message if call failed
  final String? error;

  /// Whether the call succeeded
  final bool success;

  /// Convert to JSON for logging/storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'endpoint': endpoint,
      'statusCode': statusCode,
      'latencyMs': latency?.inMilliseconds,
      'error': error,
      'success': success,
    };
  }

  /// Convert to database map for SQLite storage
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'endpoint': endpoint,
      'status_code': statusCode,
      'latency_ms': latency?.inMilliseconds,
      'error': error,
      'success': success ? 1 : 0, // SQLite uses INTEGER for boolean
    };
  }

  @override
  String toString() {
    final latencyStr = latency != null ? '${latency!.inMilliseconds}ms' : 'N/A';
    final statusStr = statusCode != null ? 'HTTP $statusCode' : 'No response';

    if (success) {
      return 'APILogEntry(id: $id, endpoint: $endpoint, status: $statusStr, latency: $latencyStr)';
    } else {
      return 'APILogEntry(id: $id, endpoint: $endpoint, error: $error, latency: $latencyStr)';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APILogEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          endpoint == other.endpoint &&
          statusCode == other.statusCode &&
          latency == other.latency &&
          error == other.error &&
          success == other.success;

  @override
  int get hashCode =>
      id.hashCode ^
      timestamp.hashCode ^
      endpoint.hashCode ^
      statusCode.hashCode ^
      latency.hashCode ^
      error.hashCode ^
      success.hashCode;
}
