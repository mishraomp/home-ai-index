import 'package:flutter_test/flutter_test.dart';
import 'package:home_ai_index/data/models/network_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkState', () {
    group('check()', () {
      test(
        'should detect connected state with WiFi',
        () async {
          // Note: This test uses the actual Connectivity plugin
          // In a real environment, this would be mocked
          // Skipped because it requires platform channel implementation
          final state = await NetworkState.check();

          // Assert - state should have isConnected and connectionType properties
          expect(state, isA<NetworkState>());
          expect(state.isConnected, isA<bool>());
          expect(state.connectionType, isA<ConnectionType>());
        },
        skip: 'Requires platform channel - test in integration tests',
      );
    });

    group('Factory Constructors', () {
      test('disconnected() should create disconnected state', () {
        // Act
        final state = NetworkState.disconnected();

        // Assert
        expect(state.isConnected, false);
        expect(state.connectionType, ConnectionType.none);
      });

      test('wifi() should create WiFi connected state', () {
        // Act
        final state = NetworkState.wifi();

        // Assert
        expect(state.isConnected, true);
        expect(state.connectionType, ConnectionType.wifi);
      });

      test('mobile() should create mobile connected state', () {
        // Act
        final state = NetworkState.mobile();

        // Assert
        expect(state.isConnected, true);
        expect(state.connectionType, ConnectionType.mobile);
      });
    });

    group('Connection Type Mapping', () {
      test('should map WiFi correctly', () {
        // Arrange & Act
        final state = NetworkState.wifi();

        // Assert
        expect(state.connectionType, ConnectionType.wifi);
        expect(state.isConnected, true);
      });

      test('should map mobile correctly', () {
        // Arrange & Act
        final state = NetworkState.mobile();

        // Assert
        expect(state.connectionType, ConnectionType.mobile);
        expect(state.isConnected, true);
      });

      test('should map none/disconnected correctly', () {
        // Arrange & Act
        final state = NetworkState.disconnected();

        // Assert
        expect(state.connectionType, ConnectionType.none);
        expect(state.isConnected, false);
      });
    });

    group('Equality', () {
      test('should be equal when properties match', () {
        // Arrange
        const state1 = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.wifi,
        );
        const state2 = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.wifi,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when isConnected differs', () {
        // Arrange
        const state1 = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.wifi,
        );
        const state2 = NetworkState(
          isConnected: false,
          connectionType: ConnectionType.wifi,
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when connectionType differs', () {
        // Arrange
        const state1 = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.wifi,
        );
        const state2 = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.mobile,
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString()', () {
      test('should return formatted string representation', () {
        // Arrange
        const state = NetworkState(
          isConnected: true,
          connectionType: ConnectionType.wifi,
        );

        // Act
        final result = state.toString();

        // Assert
        expect(result, contains('NetworkState'));
        expect(result, contains('isConnected: true'));
        expect(result, contains('connectionType: ConnectionType.wifi'));
      });
    });

    group('ConnectionType Enum', () {
      test('should have all expected connection types', () {
        // Assert
        expect(ConnectionType.values, contains(ConnectionType.wifi));
        expect(ConnectionType.values, contains(ConnectionType.mobile));
        expect(ConnectionType.values, contains(ConnectionType.ethernet));
        expect(ConnectionType.values, contains(ConnectionType.none));
        expect(ConnectionType.values.length, 4);
      });
    });
  });
}
