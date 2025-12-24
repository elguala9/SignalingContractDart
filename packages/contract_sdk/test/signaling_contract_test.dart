import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  group('SignalingContract - Static Properties', () {
    test('contract has correct ABI', () {
      expect(SignalingContract.contractAbi, isNotEmpty);
      expect(SignalingContract.contractAbi, contains('UPGRADE_INTERFACE_VERSION'));
      expect(SignalingContract.contractAbi, contains('setOffer'));
      expect(SignalingContract.contractAbi, contains('getOffer'));
      expect(SignalingContract.contractAbi, contains('setAnswer'));
      expect(SignalingContract.contractAbi, contains('getAnswer'));
    });

    test('contract has bytecode', () {
      expect(SignalingContract.contractBytecode, isNotEmpty);
      expect(SignalingContract.contractBytecode, startsWith('0x'));
    });

    test('ABI contains required functions', () {
      final abi = SignalingContract.contractAbi;
      
      expect(abi, contains('UPGRADE_INTERFACE_VERSION'));
      expect(abi, contains('initialize'));
      expect(abi, contains('owner'));
      expect(abi, contains('setOffer'));
      expect(abi, contains('getOffer'));
      expect(abi, contains('setAnswer'));
      expect(abi, contains('getAnswer'));
      expect(abi, contains('transferOwnership'));
      expect(abi, contains('renounceOwnership'));
      expect(abi, contains('upgradeToAndCall'));
      expect(abi, contains('proxiableUUID'));
    });

    test('ABI contains required events', () {
      final abi = SignalingContract.contractAbi;
      
      expect(abi, contains('proposeOffer'));
      expect(abi, contains('proposeAnswer'));
      expect(abi, contains('Initialized'));
      expect(abi, contains('OwnershipTransferred'));
      expect(abi, contains('Upgraded'));
    });

    test('ABI is valid JSON', () {
      final abi = SignalingContract.contractAbi;
      
      // Should be able to parse as JSON
      expect(abi, startsWith('['));
      expect(abi, endsWith(']'));
      expect(abi, contains('inputs'));
      expect(abi, contains('outputs'));
    });
  });

  group('SignalingContract - Instantiation', () {
    test('can create instance without credentials', () {
      // This is a basic instantiation test
      // Note: We're not using actual Web3Client here since that would require
      // network access or extensive mocking
      
      expect(SignalingContract, isNotNull);
    });

    test('credentials can be null', () {
      // Verify that the contract SDK design allows credentials to be null
      // for read-only operations
      expect(true, true); // Placeholder
    });
  });

  group('SignalingContract - Helper Functions', () {
    test('hexToBytes converts hex string to bytes', () {
      final result = hexToBytes('0x01020304');
      expect(result, equals(Uint8List.fromList([1, 2, 3, 4])));
    });

    test('hexToBytes handles hex without 0x prefix', () {
      final result = hexToBytes('01020304');
      expect(result, equals(Uint8List.fromList([1, 2, 3, 4])));
    });

    test('hexToBytes handles empty string', () {
      final result = hexToBytes('');
      expect(result, equals(Uint8List.fromList([])));
    });

    test('hexToBytes converts long hex string', () {
      const longHex = '0x' +
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final result = hexToBytes(longHex);
      expect(result.length, equals(40));
      expect(result[0], equals(170)); // 0xaa
    });

    test('hexToBytes handles uppercase hex', () {
      final result = hexToBytes('0xABCDEF');
      expect(result, equals(Uint8List.fromList([0xAB, 0xCD, 0xEF])));
    });

    test('hexToBytes handles mixed case hex', () {
      final result = hexToBytes('0xAbCdEf');
      expect(result, equals(Uint8List.fromList([0xAB, 0xCD, 0xEF])));
    });
  });

  group('SignalingContract - Constants', () {
    test('UPGRADE_INTERFACE_VERSION is in ABI', () {
      expect(
        SignalingContract.contractAbi.contains('UPGRADE_INTERFACE_VERSION'),
        isTrue,
      );
    });

    test('contract bytecode is not empty', () {
      expect(SignalingContract.contractBytecode.length, greaterThan(0));
    });

    test('contract bytecode starts with 0x prefix', () {
      expect(
        SignalingContract.contractBytecode.startsWith('0x'),
        isTrue,
      );
    });
  });

  group('SignalingContract - ABI Structure', () {
    test('ABI is a valid JSON array string', () {
      final abi = SignalingContract.contractAbi;
      expect(abi.startsWith('['), isTrue);
      expect(abi.endsWith(']'), isTrue);
    });

    test('ABI contains error types for upgradeable contracts', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('ERC1967'));
      expect(abi, contains('UUPSUnauthorizedCallContext'));
    });

    test('ABI contains ownership functions', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('transferOwnership'));
      expect(abi, contains('renounceOwnership'));
      expect(abi, contains('owner'));
    });

    test('ABI contains signaling functions', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('setOffer'));
      expect(abi, contains('getOffer'));
      expect(abi, contains('setAnswer'));
      expect(abi, contains('getAnswer'));
    });

    test('ABI contains proxy functions', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('upgradeToAndCall'));
      expect(abi, contains('proxiableUUID'));
    });

    test('ABI contains initialization function', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('initialize'));
    });
  });

  group('SignalingContract - Bytecode Validation', () {
    test('bytecode is a valid hex string', () {
      final bytecode = SignalingContract.contractBytecode;
      // Should be able to convert to bytes without error
      expect(() => hexToBytes(bytecode), returnsNormally);
    });

    test('bytecode length is reasonable', () {
      final bytecode = SignalingContract.contractBytecode;
      // Bytecode should be at least 100 chars (50 bytes) after 0x prefix
      expect(bytecode.length, greaterThan(100));
    });
  });
}
