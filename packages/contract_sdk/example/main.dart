import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:http/http.dart' as http;

/// Example demonstrating how to use the auto-generated contract bindings
void main() async {
  // Configuration for Ganache (from docker-compose)
  const rpcUrl = 'http://localhost:7545';
  const chainId = 1337;
  
  // Using the test mnemonic from docker-compose
  const mnemonic = 'test test test test test test test test test test test junk';
  
  print('🔗 Contract SDK Example with Auto-Generated Bindings');
  print('');
  
  try {
    // Create credentials from mnemonic (first account)
    // First account from test mnemonic
    final credentials = EthPrivateKey.fromHex(
      '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d',
    );
    
    print('📋 Using account: ${credentials.address.hex}');
    print('');
    
    // Create Web3Client
    final client = Web3Client(rpcUrl, http.Client());
    
    // Check connection
    final chainId = await client.getChainId();
    print('✅ Connected to Ganache - Chain ID: $chainId');
    print('');
    
    // Connect to existing Signaling contract
    // Note: You need to deploy a contract first and get its address
    final contractAddress = EthereumAddress.fromHex(
      '0x1234567890123456789012345678901234567890',
    ); // Replace with actual address
    
    print('🔄 Connecting to Signaling contract...');
    final signaling = SignalingContract(
      client: client,
      contract: DeployedContract(
        ContractAbi.fromJson(SignalingContract.contractAbi, 'Signaling'),
        contractAddress,
      ),
      credentials: credentials,
    );
    
    print('✅ Connected to contract at ${contractAddress.hex}');
    print('');
    
    // Example: Set an offer
    print('📤 Setting an offer...');
    final offerData = 'Hello from Dart SDK!'.codeUnits;
    final txHash = await signaling.setOffer(Uint8List.fromList(offerData));
    
    print('✅ Offer set! Transaction hash: $txHash');
    print('');
    
    // Example: Get the offer back
    print('📥 Retrieving offer...');
    final offer = await signaling.getOffer(credentials.address);
    
    if (offer != null) {
      print('📋 Offer retrieved');
      print('');
    }
    
    print('');
    print('🎉 Example completed successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    
    if (e.toString().contains('connection refused')) {
      print('');
      print('💡 Make sure Ganache is running:');
      print('   docker-compose up -d evm');
    }
    
    if (e.toString().contains('revert') || e.toString().contains('execution reverted')) {
      print('');
      print('💡 Make sure the contract is deployed to the specified address');
    }
  }
}

/// Example of deploying a new contract
Future<EthereumAddress> deploySignalingContract({
  required String rpcUrl,
  required EthPrivateKey credentials,
}) async {
  print('🚀 Deploying new Signaling contract...');
  
  final client = Web3Client(rpcUrl, http.Client());
  
  final transaction = Transaction(
    from: credentials.address,
    data: hexToBytes(SignalingContract.contractBytecode),
  );

  try {
    final txHash = await client.sendTransaction(credentials, transaction);
    print('✅ Deploy transaction sent: $txHash');
    
    // Wait for receipt
    TransactionReceipt? receipt;
    int attempts = 0;
    while (receipt == null && attempts < 30) {
      await Future.delayed(Duration(milliseconds: 500));
      receipt = await client.getTransactionReceipt(txHash);
      attempts++;
    }

    if (receipt != null && receipt.contractAddress != null) {
      print('✅ Contract deployed at: ${receipt.contractAddress!.hex}');
      return receipt.contractAddress!;
    } else {
      throw Exception('Failed to get contract address from receipt');
    }
  } catch (e) {
    print('❌ Deployment failed: $e');
    rethrow;
  }
}
