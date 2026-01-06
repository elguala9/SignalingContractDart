import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:signaling_contract_sdk/generated/signaling_contract.dart' hide hexToBytes;
import 'package:http/http.dart' as http;

/// Example demonstrating how to use the auto-generated contract bindings
void main() async {
  // Configuration for Ganache (from docker-compose)
  const rpcUrl = 'http://localhost:7545';
  
  print('🔗 Contract SDK Example with Auto-Generated Bindings');
  print('');
  
  try {
    // Create Web3Client (reusable for all operations)
    final client = Web3Client(rpcUrl, http.Client());
    
    // Create credentials from private key
    final credentials = EthPrivateKey.fromHex(
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
    );
    
    print('📋 Using account: ${credentials.address.eip55With0x}');
    
    // Check connection
    final chainIdValue = await client.getChainId();
    print('✅ Connected to RPC - Chain ID: $chainIdValue');
    print('');
    
    // Get balance
    final balance = await client.getBalance(credentials.address);
    print('💰 Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
    print('');
    
    // Deploy new contract
    print('🚀 Deploying new Signaling contract...');
    final contract = await SignalingContract.deploy(
      client: client,
      credentials: credentials,
      chainId: 1337,  // Ganache default
    );
    
    print('✅ Deployed at: ${contract.contract.address.eip55With0x}');
    print('');
    
    // Initialize the contract with owner
    print('⚙️  Initializing contract...');
    final initTx = await contract.initialize(credentials.address);
    print('✅ Initialized! Tx: $initTx');
    print('');
    
    // Example: Set an offer
    print('📤 Setting an offer...');
    final offerData = 'Hello from Dart SDK!'.codeUnits;
    final txHash = await contract.setOffer(Uint8List.fromList(offerData));
    
    print('✅ Offer set! Transaction hash: $txHash');
    print('');
    
    // Example: Get the offer back
    print('📥 Retrieving offer...');
    final offer = await contract.getOffer(credentials.address);
    
    if (offer != null) {
      print('📋 Offer retrieved');
      print('');
    }
    
    // Example: Connect to existing contract using factory method
    print('');
    print('🔄 Connecting to deployed contract via factory method...');
    final connectedContract = await SignalingContract.connect(
      client: client,
      contractAddress: contract.contract.address,
      credentials: credentials,
    );
    
    print('✅ Connected to: ${connectedContract.contract.address.eip55With0x}');
    print('');
    
    // Verify owner
    final owner = await connectedContract.owner();
    print('👤 Contract owner: ${owner.eip55With0x}');
    
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

