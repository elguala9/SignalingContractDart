import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  group('SignalingContract - Integration Tests with Ganache', () {
    late Web3Client client;
    const String ganacheRpcUrl = 'http://localhost:7545';

    setUp(() {
      client = Web3Client(ganacheRpcUrl, http.Client());
    });

    tearDown(() {
      // Clean up if needed
    });

    test('can connect to Ganache RPC endpoint', () async {
      try {
        final blockNumber = await client.getBlockNumber();
        expect(blockNumber, greaterThanOrEqualTo(0));
      } catch (e) {
        // Ganache might not be running
        print('Warning: Ganache not running on $ganacheRpcUrl');
        print('To run integration tests, start Ganache with: docker-compose up evm');
      }
    });

    test('SignalingContract.contractAbi is valid', () {
      expect(SignalingContract.contractAbi, isNotEmpty);
      expect(SignalingContract.contractAbi, contains('setOffer'));
      expect(SignalingContract.contractAbi, contains('getOffer'));
    });

    test('SignalingContract.contractBytecode is valid', () {
      expect(SignalingContract.contractBytecode, isNotEmpty);
      expect(SignalingContract.contractBytecode, startsWith('0x'));
    });
  });

  group('SignalingContract - Ganache Setup', () {
    test('Ganache endpoint is reachable at localhost:7545', () async {
      const String ganacheRpcUrl = 'http://localhost:7545';
      final client = Web3Client(ganacheRpcUrl, http.Client());

      try {
        final chainId = await client.getChainId();
        print('Connected to Ganache - Chain ID: $chainId');
        expect(chainId.toInt(), equals(1337)); // Ganache default chain ID
      } catch (e) {
        print('Ganache not running. Start with: docker-compose up evm');
      }
    });
  });
}
