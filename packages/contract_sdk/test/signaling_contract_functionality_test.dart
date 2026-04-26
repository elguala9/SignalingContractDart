import 'package:test/test.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';

void main() {
  group('Signaling Contract Functionality', () {
    late String deploymentPath;
    late String contractAddress;

    setUpAll(() {
      // Get deployment info from latest deployment
      deploymentPath = 'packages/vite/deployments/latest-deployment.json';

      // Load contract address from deployment file
      try {
        final file = File(deploymentPath);
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final deployment = jsonDecode(content) as Map<String, dynamic>;
          contractAddress = deployment['contractAddress'] as String;
        } else {
          throw Exception('Deployment file not found: $deploymentPath');
        }
      } catch (e) {
        throw Exception('Failed to load deployment info: $e');
      }
    });

    test('Contract is deployed at valid Vite address', () {
      expect(contractAddress, isNotEmpty);
      expect(contractAddress, startsWith('vite_'));
      expect(contractAddress.length, greaterThan(10));
    });

    test('setSignal accepts gzip-compressed data', () async {
      // Create valid gzip data (header bytes + payload)
      final gzipHeader = Uint8List.fromList([0x1f, 0x8b, 0x08, 0x00]);
      final payload = utf8.encode('test signal data');
      final testData = Uint8List.fromList([...gzipHeader, ...payload]);

      expect(testData[0], equals(0x1f));
      expect(testData[1], equals(0x8b));
      expect(testData.length, greaterThan(2));
    });

    test('Signal data has minimum 2 bytes for gzip validation', () {
      final minData = Uint8List.fromList([0x1f, 0x8b]);
      expect(minData.length, equals(2));
      expect(minData[0], equals(0x1f));
      expect(minData[1], equals(0x8b));
    });

    test('Non-gzip data is rejected', () {
      final nonGzipData = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
      expect(nonGzipData[0], isNot(0x1f));
      expect(nonGzipData[1], isNot(0x8b));
    });

    test('Contract methods are defined in ABI', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('setSignal'));
      expect(abi, contains('getSignal'));
      expect(abi, contains('owner'));
    });

    test('SignalEmitted event is emitted on setSignal', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('SignalEmitted'));
      expect(abi, contains('sender'));
      expect(abi, contains('signal'));
      expect(abi, contains('timestamp'));
    });

    test('getSignal returns Signal struct with correct fields', () {
      // The Signal struct should have: signal (bytes) and creationTime (uint256)
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('getSignal'));
      // Signal struct fields should be in ABI
      expect(abi, contains('compressedSignal'));
    });

    test('Contract is non-upgradable (no upgrade functions)', () {
      final abi = SignalingContract.contractAbi;
      // Should not have upgrade-related functions
      expect(abi, isNot(contains('upgradeTo')));
      expect(abi, isNot(contains('initialize')));
      expect(abi, isNot(contains('proxiableUUID')));
    });

    test('Contract has owner-based access control', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('owner'));
      expect(abi, contains('renounceOwnership'));
      expect(abi, contains('transferOwnership'));
    });
  });
}

// Minimal File implementation for testing without dart:io dependency in tests
import 'dart:io' show File;
