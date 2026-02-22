// ignore_for_file: avoid_print
/// Example usage of the Signaling Contract SDK
///
/// This example demonstrates:
/// 1. Connecting to an existing contract
/// 2. Reading contract state
/// 3. Writing data to the contract
/// 4. Deploying a new contract
library signaling_contract_sdk.example;

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart';
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';
import 'package:signaling_contract_sdk/generated/signaling_contract_extensions.dart';

Future<void> main() async {
  print('Signaling Contract SDK Example\n');

  // Example 1: Connect to an existing contract
  await connectToContract();

  // Example 2: Read contract state
  // Uncomment to run:
  // await readContractState();

  // Example 3: Set a signal
  // Uncomment to run:
  // await setSignal();

  // Example 4: Set a signal with automatic compression
  // Uncomment to run:
  // await setSignalWithCompression();

  // Example 5: Deploy a new contract
  // Uncomment to run:
  // await deployContract();
}

/// Example 1: Connect to an existing contract
///
/// This example shows how to connect to a contract that's already deployed
/// on the blockchain.
Future<void> connectToContract() async {
  print('Example 1: Connecting to contract...\n');

  // Configuration
  const rpcUrl = 'http://localhost:8545'; // Local Ganache or Hardhat node
  const contractAddressHex = '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';

  try {
    // Create a Web3Client
    final client = Web3Client(rpcUrl, http.Client());

    // Connect to the contract without credentials (read-only)
    await SignalingContract.connectWithClient(
      client: client,
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
    );

    print('✓ Connected to contract at: $contractAddressHex');
    print('  RPC URL: $rpcUrl\n');

    // Clean up
    client.dispose();
  } catch (e) {
    print('✗ Connection failed: $e');
    print('  Make sure the blockchain node is running at $rpcUrl\n');
  }
}

/// Example 2: Read contract state
///
/// This example shows how to read the owner and offers from the contract.
Future<void> readContractState() async {
  print('Example 2: Reading contract state...\n');

  const rpcUrl = 'http://localhost:8545';
  const contractAddressHex = '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';

  try {
    // Create a Web3Client
    final client = Web3Client(rpcUrl, http.Client());

    final contract = await SignalingContract.connectWithClient(
      client: client,
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
    );

    // Read the owner
    final owner = await contract.owner();
    print('Contract Owner: $owner\n');

    // Try to read a signal for a specific address
    final testAddress =
        EthereumAddress.fromHex('0x1234567890123456789012345678901234567890');
    final signal = await contract.getSignal(testAddress);
    print('Signal for $testAddress:');
    print('  Data: $signal');
    print('');

    client.dispose();
  } catch (e) {
    print('✗ Failed to read contract state: $e\n');
  }
}

/// Example 3: Set a signal
///
/// This example shows how to set a signal in the contract (requires credentials).
Future<void> setSignal() async {
  print('Example 3: Setting a signal...\n');

  const rpcUrl = 'http://localhost:8545';
  const contractAddressHex = '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';
  // WARNING: Never use private keys in production code!
  // This is only for development/testing.
  const privateKeyHex =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078';

  try {
    final credentials = EthPrivateKey.fromHex(privateKeyHex);

    // Create a Web3Client
    final client = Web3Client(rpcUrl, http.Client());

    // Connect with credentials (allows write operations)
    final contract = await SignalingContract.connectWithClient(
      client: client,
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
      credentials: credentials,
    );

    // Create test data
    final testData = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

    print('Sending signal...');
    print('  Data: $testData');

    // Set the signal
    final txHash = await contract.setSignal(testData);

    print('✓ Signal sent!');
    print('  Transaction hash: $txHash\n');

    // Wait for transaction to be confirmed
    print('Waiting for transaction confirmation...');
    await Future.delayed(Duration(seconds: 2));
    print('✓ Transaction confirmed\n');

    client.dispose();
  } catch (e) {
    print('✗ Failed to set signal: $e\n');
  }
}

/// Example 4: Set a signal with automatic compression
///
/// This example shows how to set a signal with automatic gzip compression.
/// The data is compressed client-side before being sent to the contract,
/// reducing storage costs while maintaining data integrity.
Future<void> setSignalWithCompression() async {
  print('Example 4: Setting a signal with automatic compression...\n');

  const rpcUrl = 'http://localhost:8545';
  const contractAddressHex = '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';
  // WARNING: Never use private keys in production code!
  const privateKeyHex =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078';

  try {
    final credentials = EthPrivateKey.fromHex(privateKeyHex);

    // Create a Web3Client
    final client = Web3Client(rpcUrl, http.Client());

    // Connect with credentials
    final contract = await SignalingContract.connectWithClient(
      client: client,
      contractAddress: EthereumAddress.fromHex(contractAddressHex),
      credentials: credentials,
    );

    // Create raw uncompressed data
    final rawData = '''
    {
      "type": "offer",
      "sdp": "v=0\r\no=- 123456789 2 IN IP4 127.0.0.1\r\n..."
    }
    ''';

    print('Raw data size: ${rawData.length} bytes');
    print('Sending signal with automatic compression...');

    // Use setSignalCompressed - data is automatically compressed
    final txHash = await contract.setSignalCompressed(rawData);

    print('✓ Signal sent with compression!');
    print('  Transaction hash: $txHash\n');

    // Wait for transaction confirmation
    print('Waiting for transaction confirmation...');
    await Future.delayed(Duration(seconds: 2));

    // Retrieve and verify the signal
    final signal = await contract.getSignal(credentials.address);
    final compressedBytes = signal[0] as Uint8List;
    final compressionRatio =
        (compressedBytes.length / rawData.length * 100).toStringAsFixed(1);

    print('✓ Transaction confirmed');
    print('  Compressed size: ${compressedBytes.length} bytes');
    print('  Compression ratio: $compressionRatio%\n');

    // Decompress to verify (for demonstration)
    final decompressed =
        SignalingDataCompression.decompressToString(compressedBytes);
    print('  Data verified: ${decompressed.isNotEmpty ? "✓" : "✗"}\n');

    client.dispose();
  } catch (e) {
    print('✗ Failed to set signal: $e\n');
  }
}

/// Example 5: Deploy a new contract
///
/// This example shows how to deploy a new instance of the contract.
/// The contract is non-upgradable and requires an owner address in the constructor.
Future<void> deployContract() async {
  print('Example 4: Deploying a new contract...\n');

  const rpcUrl = 'http://localhost:8545';
  // WARNING: Never use private keys in production code!
  const privateKeyHex =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078';

  try {
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    final ownerAddress = credentials.address;

    print('Deploying contract...');
    print('  Owner: $ownerAddress');
    print('  RPC URL: $rpcUrl');

    // Deploy the contract - pass owner address as constructor parameter
    // Using AddressParam for type-safe address parameter
    final contract = await SignalingContract.deploy(
      rpcUrl: rpcUrl,
      credentials: credentials,
      constructorParams: [AddressParam(ownerAddress)],
    );

    print('\n✓ Contract deployed!');
    print('  Contract address: ${contract.contract.address}\n');
  } catch (e) {
    print('✗ Deployment failed: $e');
    print(
        '  Make sure the blockchain node is running and you have enough funds\n');
  }
}
