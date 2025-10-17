import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents the current network connectivity state
class NetworkState {
  const NetworkState({required this.isConnected, required this.connectionType});

  /// Whether device has internet connectivity
  final bool isConnected;

  /// Type of network connection
  final ConnectionType connectionType;

  /// Check current network connectivity state
  static Future<NetworkState> check() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // connectivity_plus v7+ returns a list of results
    final isConnected =
        connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);
    final type = _mapToConnectionType(
      connectivityResults.isNotEmpty
          ? connectivityResults.first
          : ConnectivityResult.none,
    );

    return NetworkState(isConnected: isConnected, connectionType: type);
  }

  /// Map ConnectivityResult to ConnectionType
  static ConnectionType _mapToConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.none:
      default:
        return ConnectionType.none;
    }
  }

  /// Create a disconnected state
  static NetworkState disconnected() {
    return const NetworkState(
      isConnected: false,
      connectionType: ConnectionType.none,
    );
  }

  /// Create a connected WiFi state
  static NetworkState wifi() {
    return const NetworkState(
      isConnected: true,
      connectionType: ConnectionType.wifi,
    );
  }

  /// Create a connected mobile data state
  static NetworkState mobile() {
    return const NetworkState(
      isConnected: true,
      connectionType: ConnectionType.mobile,
    );
  }

  @override
  String toString() {
    return 'NetworkState(isConnected: $isConnected, connectionType: $connectionType)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkState &&
          runtimeType == other.runtimeType &&
          isConnected == other.isConnected &&
          connectionType == other.connectionType;

  @override
  int get hashCode => isConnected.hashCode ^ connectionType.hashCode;
}

/// Types of network connections
enum ConnectionType {
  /// WiFi connection
  wifi,

  /// Mobile data connection (3G/4G/5G)
  mobile,

  /// Ethernet connection
  ethernet,

  /// No connection
  none,
}
