/// Dart SDK for interacting with blockchain signaling smart contracts.
///
/// This package provides auto-generated type-safe bindings for the Signaling contract,
/// built on top of web3dart for seamless Ethereum/EVM compatibility.
///
/// ## Features
///
/// - 🔐 Type-safe contract bindings generated from Solidity ABIs
/// - 🚀 Easy-to-use API for contract interaction
/// - 📦 Built with web3dart for Ethereum/EVM compatibility
/// - 🔄 Auto-generated from TypeChain artifacts
/// - ✅ Full deployment and initialization support
/// - 📖 Well-documented examples
///
/// ## Quick Start
///
/// ```dart
/// import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';
/// import 'package:web3dart/web3dart.dart';
/// import 'package:http/http.dart' as http;
/// import 'dart:typed_data';
///
/// void main() async {
///   // Create credentials from private key
///   final credentials = EthPrivateKey.fromHex('0x...');
///
///   // Connect to existing contract
///   final signaling = await SignalingContract.connect(
///     rpcUrl: 'http://localhost:8545',
///     contractAddress: EthereumAddress.fromHex('0x...'),
///     credentials: credentials,
///   );
///
///   // Set an offer
///   final data = 'Hello WebRTC SDP'.codeUnits;
///   final txHash = await signaling.setOffer(Uint8List.fromList(data));
///   print('Offer set! Transaction: $txHash');
///
///   // Get an offer
///   final offer = await signaling.getOffer(credentials.address);
///   print('Offer: $offer');
/// }
/// ```
///
/// ## Deployment
///
/// To deploy a new contract instance:
///
/// ```dart
/// final signaling = await SignalingContract.deploy(
///   rpcUrl: 'http://localhost:8545',
///   credentials: credentials,
/// );
///
/// print('Contract deployed at: ${signaling.contract.address.eip55With0x}');
/// ```
///
/// ## Environment Variables
///
/// For better organization, you may set:
/// - `RPC_URL`: Ethereum RPC endpoint (default: http://localhost:8545)
/// - `PRIVATE_KEY`: Contract deployer private key
/// - `CONTRACT_ADDRESS`: Deployed contract address
///
/// ## Network Support
///
/// This SDK works with any EVM-compatible network:
/// - ✅ Ethereum (mainnet, testnet)
/// - ✅ Polygon
/// - ✅ Arbitrum
/// - ✅ Optimism
/// - ✅ BSC
/// - ✅ Ganache (local development)
///
/// See the [example] directory for complete working examples.
library signaling_contract_sdk;

// Export the main contract binding
export 'generated/contracts.dart' show SignalingContract;

// Re-export commonly used types from web3dart
export 'package:web3dart/web3dart.dart' show
    EthPrivateKey,
    Web3Client,
    Transaction,
    DeployedContract,
    ContractAbi,
    BlockNum;
