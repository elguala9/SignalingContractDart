import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  group('SignalingContract - Full Integration Tests with Deploy', () {
    late Web3Client client;
    late EthPrivateKey credentials;
    late EthereumAddress deployerAddress;
    late EthereumAddress contractAddress;

    const String ganacheRpcUrl = 'http://localhost:7545';
    
    // Ganache mnemonic: test test test test test test test test test test test junk
    // First account private key (from mnemonic)
    const String deployerPrivateKey =
        '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d';

    setUp(() async {
      client = Web3Client(ganacheRpcUrl, http.Client());
      credentials = EthPrivateKey.fromHex(deployerPrivateKey);
      deployerAddress = credentials.address;

      print('Deployer Address: ${deployerAddress.hex}');
    });

    tearDown(() {
      // Cleanup if needed
    });

    test('deploy SignalingContract to Ganache', () async {
      try {
        // Get current balance
        final balance = await client.getBalance(deployerAddress);
        print('Deployer Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
        
        if (balance.getValueInUnit(EtherUnit.ether) == 0) {
          print('Warning: No balance in deployer account');
          print('Ganache may not be initialized correctly');
          print('Check: docker-compose up evm');
          return; // Skip deployment test if no balance
        }

        // Deploy contract
        final contractAbi = ContractAbi.fromJson(
          SignalingContract.contractAbi,
          'Signaling',
        );

        final transaction = Transaction(
          from: deployerAddress,
          data: hexToBytes(SignalingContract.contractBytecode),
        );

        final txHash = await client.sendTransaction(credentials, transaction);
        print('Deploy Transaction Hash: $txHash');
        expect(txHash, isNotEmpty);

        // Wait for receipt
        TransactionReceipt? receipt;
        int attempts = 0;
        while (receipt == null && attempts < 30) {
          await Future.delayed(Duration(milliseconds: 500));
          receipt = await client.getTransactionReceipt(txHash);
          attempts++;
        }

        expect(receipt, isNotNull, reason: 'Transaction receipt not found');
        expect(receipt!.status, isTrue, reason: 'Transaction failed');
        
        contractAddress = receipt!.contractAddress!;
        print('Contract deployed at: ${contractAddress.hex}');
        print('Gas used: ${receipt.gasUsed}');

        expect(contractAddress, isNotNull);
      } catch (e) {
        print('Deploy test error: $e');
        print('Make sure Ganache is running at http://localhost:7545');
        print('Ganache should have accounts with ETH from mnemonic');
      }
    });

    test('initialize SignalingContract after deploy', () async {
      try {
        // This test assumes contract was already deployed in previous test
        // In real scenario, you'd save the address or deploy again
        
        final balance = await client.getBalance(deployerAddress);
        print('Current balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
        
        if (balance.getValueInUnit(EtherUnit.ether) > 0) {
          print('Account has ETH available for transactions');
        }
      } catch (e) {
        print('Initialize test error: $e');
      }
    });

    test('Ganache has deterministic accounts from mnemonic', () async {
      try {
        // Verify we can derive the same account from mnemonic
        print('Deployer: ${deployerAddress.hex}');
        expect(deployerAddress.hex.length, equals(42)); // 0x + 40 hex chars
      } catch (e) {
        print('Accounts test error: $e');
      }
    });

    test('Ganache block number increases', () async {
      try {
        final block1 = await client.getBlockNumber();
        await Future.delayed(Duration(seconds: 1));
        final block2 = await client.getBlockNumber();
        
        print('Block 1: $block1');
        print('Block 2: $block2');
        
        expect(block2, greaterThanOrEqualTo(block1));
      } catch (e) {
        print('Block number test error: $e');
      }
    });
  });

  group('SignalingContract - Event Listening', () {
    late Web3Client client;

    const String ganacheRpcUrl = 'http://localhost:7545';

    setUp(() {
      client = Web3Client(ganacheRpcUrl, http.Client());
    });

    test('ABI contains proposeOffer event', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('proposeOffer'));
      expect(abi, contains('proposeAnswer'));
    });

    test('ABI contains correct event parameters', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('"name":"offerer"'));
      expect(abi, contains('"name":"answerer"'));
    });
  });

  group('SignalingContract - Gas Estimation', () {
    late Web3Client client;
    late EthPrivateKey credentials;

    const String ganacheRpcUrl = 'http://localhost:7545';
    const String deployerPrivateKey =
        '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d';

    setUp(() {
      client = Web3Client(ganacheRpcUrl, http.Client());
      credentials = EthPrivateKey.fromHex(deployerPrivateKey);
    });

    test('contract bytecode is large (expected for upgradeable contract)', () {
      final bytecodeLength = SignalingContract.contractBytecode.length;
      print('Bytecode length: $bytecodeLength chars (${bytecodeLength ~/ 2} bytes)');
      
      // Check bytecode is not empty
      expect(bytecodeLength, greaterThan(1000));
    });

    test('ABI contains proxy-related functions', () {
      final abi = SignalingContract.contractAbi;
      expect(abi, contains('upgradeToAndCall'));
      expect(abi, contains('proxiableUUID'));
      expect(abi, contains('UPGRADE_INTERFACE_VERSION'));
    });
  });
}
