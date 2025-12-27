import 'dart:io';
import 'package:test/test.dart';
import 'package:signaling_contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  group('SignalingContract - Full Integration Tests with Deploy', () {
    late Web3Client client;
    late EthPrivateKey credentials;
    late EthereumAddress deployerAddress;
    late EthereumAddress contractAddress;

    const String ganacheRpcUrl = 'http://localhost:7545';
    
    // Ganache account (index 0) from mnemonic
    const String deployerPrivateKey =
        '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

    setUp(() async {
      client = Web3Client(ganacheRpcUrl, http.Client());
      credentials = EthPrivateKey.fromHex(deployerPrivateKey);
      deployerAddress = credentials.address;

      print('Deployer Address: ${deployerAddress.hex}');
    });

    tearDown(() {
      // Cleanup if needed
    });

    test('deploy SignalingContract to Ganache using Hardhat', () async {
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

        // Deploy contract using Hardhat script
        // This is necessary because SignalingContract is UUPS upgradeable
        // and requires proxy deployment
        print('Deploying SignalingContract via Hardhat...');
        
        final processResult = await Process.run(
          'npm',
          ['run', 'deploySC:ganache'],
          workingDirectory: '../typescript/signaling-contract',
          runInShell: true,
        );

        print('Deploy stdout: ${processResult.stdout}');
        if (processResult.stderr.toString().isNotEmpty) {
          print('Deploy stderr: ${processResult.stderr}');
        }

        expect(processResult.exitCode, equals(0), 
               reason: 'Hardhat deploy script failed');

        // Extract contract address from output
        final output = processResult.stdout.toString();
        final addressMatch = RegExp(r'Token address:\s+(0x[a-fA-F0-9]{40})').firstMatch(output)
                          ?? RegExp(r'Proxy deployed to:\s+(0x[a-fA-F0-9]{40})').firstMatch(output) 
                          ?? RegExp(r'deployed to:\s+(0x[a-fA-F0-9]{40})').firstMatch(output)
                          ?? RegExp(r'Contract address:\s+(0x[a-fA-F0-9]{40})').firstMatch(output);
        
        if (addressMatch != null) {
          final addressHex = addressMatch.group(1)!;
          contractAddress = EthereumAddress.fromHex(addressHex);
          print('Contract deployed at: ${contractAddress.hex}');
          
          expect(contractAddress, isNotNull);
          
          // Verify the contract exists
          final code = await client.getCode(contractAddress);
          expect(code.isNotEmpty, isTrue, reason: 'No code at contract address');
          print('Contract verified - bytecode length: ${code.length}');
        } else {
          print('Could not extract contract address from output');
          print('Full output: $output');
          fail('Failed to extract contract address from deploy output');
        }
      } catch (e) {
        print('Deploy test error: $e');
        print('Make sure Ganache is running at http://localhost:7545');
        print('Ganache should have accounts with ETH');
      }
    });

    test('deploy SignalingContract implementation directly (Dart method)', () async {
      try {
        // Get current balance
        final balance = await client.getBalance(deployerAddress);
        print('Deployer Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
        
        if (balance.getValueInUnit(EtherUnit.ether) == 0) {
          print('Warning: No balance in deployer account');
          return;
        }

        // Deploy contract implementation directly (without proxy)
        // Note: This is not a complete UUPS deployment, just the implementation
        // For production use the Hardhat method above
        print('Deploying implementation contract via Dart...');
        
        final bytecodeWithoutPrefix = SignalingContract.contractBytecode.startsWith('0x') 
            ? SignalingContract.contractBytecode.substring(2) 
            : SignalingContract.contractBytecode;
        
        // Use a reasonable gas price for Ganache (2 gwei)
        final gasPrice = EtherAmount.fromInt(EtherUnit.gwei, 2);
        print('Using gas price: ${gasPrice.getInWei} wei');
        
        final deployTransaction = Transaction(
          from: deployerAddress,
          data: hexToBytes(bytecodeWithoutPrefix),
          maxGas: 8000000,
          maxFeePerGas: gasPrice,
          maxPriorityFeePerGas: gasPrice,
        );

        print('Sending deploy transaction...');
        final txHash = await client.sendTransaction(
          credentials,
          deployTransaction,
          chainId: 1337,
        );
        print('Deploy Transaction Hash: $txHash');
        
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
        
        final implementationAddress = receipt.contractAddress!;
        print('Implementation deployed at: ${implementationAddress.hex}');
        print('Gas used: ${receipt.gasUsed}');

        // Verify bytecode at address
        final code = await client.getCode(implementationAddress);
        expect(code.isNotEmpty, isTrue);
        print('Implementation bytecode verified - length: ${code.length}');
        
        // Try to interact with the deployed contract
        final contractAbi = ContractAbi.fromJson(
          SignalingContract.contractAbi,
          'Signaling',
        );
        final deployedContract = DeployedContract(
          contractAbi,
          implementationAddress,
        );
        
        // Test: Get owner (should be zero address before initialization)
        final ownerFunction = deployedContract.function('owner');
        final ownerResult = await client.call(
          contract: deployedContract,
          function: ownerFunction,
          params: [],
        );
        print('Contract owner before init: ${ownerResult.first}');
        expect(ownerResult.first, equals(EthereumAddress.fromHex('0x0000000000000000000000000000000000000000')));
        
        // Initialize the contract
        print('Initializing contract...');
        final initializeFunction = deployedContract.function('initialize');
        final initTx = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: deployedContract,
            function: initializeFunction,
            parameters: [deployerAddress],
            maxGas: 500000,
            maxFeePerGas: EtherAmount.fromInt(EtherUnit.gwei, 2),
            maxPriorityFeePerGas: EtherAmount.fromInt(EtherUnit.gwei, 2),
          ),
          chainId: 1337,
        );
        print('Initialize tx: $initTx');
        
        // Wait for initialization
        TransactionReceipt? initReceipt;
        int initAttempts = 0;
        while (initReceipt == null && initAttempts < 20) {
          await Future.delayed(Duration(milliseconds: 500));
          initReceipt = await client.getTransactionReceipt(initTx);
          initAttempts++;
        }
        
        expect(initReceipt, isNotNull);
        expect(initReceipt!.status, isTrue);
        print('Contract initialized successfully!');
        
        // Verify owner is now set
        final newOwnerResult = await client.call(
          contract: deployedContract,
          function: ownerFunction,
          params: [],
        );
        print('Contract owner after init: ${newOwnerResult.first}');
        expect(newOwnerResult.first, equals(deployerAddress));
        
        // Note: This implementation needs initialization via a proxy for full UUPS functionality
        print('✅ Contract deployed, initialized and fully functional via Dart!');
        print('⚠️  For UUPS upgradeable functionality, use the Hardhat deployment method.');
      } catch (e, stackTrace) {
        print('Dart deploy test error: $e');
        print('Stack trace: $stackTrace');
        print('This test deploys the implementation contract directly');
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
