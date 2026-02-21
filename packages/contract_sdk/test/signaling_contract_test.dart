import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';

void main() {
  group('Contract Utilities', () {
    test('hexToBytes converts valid hex string with 0x prefix', () {
      const hex = '0x0102';
      final result = hexToBytes(hex);
      expect(result, equals(Uint8List.fromList([1, 2])));
    });

    test('hexToBytes converts valid hex string without 0x prefix', () {
      const hex = 'deadbeef';
      final result = hexToBytes(hex);
      expect(result, equals(Uint8List.fromList([0xde, 0xad, 0xbe, 0xef])));
    });

    test('hexToBytes handles empty string', () {
      const hex = '0x';
      final result = hexToBytes(hex);
      expect(result, isEmpty);
    });

    test('hexToBytes handles uppercase hex', () {
      const hex = '0xABCD';
      final result = hexToBytes(hex);
      expect(result, equals(Uint8List.fromList([0xAB, 0xCD])));
    });

    test('hexToBytes handles mixed case hex', () {
      const hex = 'aAbBcCdD';
      final result = hexToBytes(hex);
      expect(
        result,
        equals(Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD])),
      );
    });

    test('hexToBytes converts long hex string', () {
      const hex =
          '0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';
      final result = hexToBytes(hex);
      expect(result.length, equals(31));
    });
  });

  group('Signaling Contract Binding', () {
    test('SignalingContract has valid contract ABI', () {
      expect(
        SignalingContract.contractAbi,
        contains('getSignal'),
      );
      expect(
        SignalingContract.contractAbi,
        contains('setSignal'),
      );
      expect(
        SignalingContract.contractAbi,
        contains('owner'),
      );
    });

    test('SignalingContract has valid contract bytecode', () {
      expect(
        SignalingContract.contractBytecode,
        startsWith('0x'),
      );
      expect(
        SignalingContract.contractBytecode.length,
        greaterThan(10),
      );
    });

    test('Contract ABI contains required functions', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('getSignal'));
      expect(abi, contains('setSignal'));
      expect(abi, contains('transferOwnership'));
      expect(abi, contains('renounceOwnership'));
    });

    test('Contract ABI contains required events', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('SignalEmitted'));
      expect(abi, contains('OwnershipTransferred'));
    });
  });

  group('Contract Constants', () {
    test('contractAbi is a valid JSON string', () {
      expect(
        SignalingContract.contractAbi,
        allOf([
          startsWith('['),
          endsWith(']'),
          contains('"type"'),
          contains('"name"'),
        ]),
      );
    });

    test('contractBytecode follows EVM format', () {
      expect(SignalingContract.contractBytecode, startsWith('0x'));
      // Bytecode should only contain hex characters
      final bytes = SignalingContract.contractBytecode.substring(2);
      expect(
        bytes,
        matches(RegExp(r'^[0-9a-fA-F]*$')),
      );
    });
  });

  group('Event Listening', () {
    test('Contract ABI contains SignalEmitted event with correct parameters', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('SignalEmitted'));
      expect(abi, contains('sender'));
      expect(abi, contains('signal'));
      expect(abi, contains('timestamp'));
    });

    test('Contract ABI event sender is indexed', () {
      final abi = SignalingContract.contractAbi;
      // Verify the event structure includes indexed parameter for sender
      expect(abi, contains('"indexed":true'));
      expect(abi, contains('sender'));
    });
  });
}
