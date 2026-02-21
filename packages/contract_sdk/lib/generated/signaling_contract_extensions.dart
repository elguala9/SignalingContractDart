// Custom extensions for SignalingContract
// This file is NOT auto-generated and can be safely modified

library signaling_contract_extensions;

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart' as web3;

// Import generated file and make types available
import 'signaling_contract.dart';

/// Extension to provide Web3Client-based connect method
extension SignalingContractExtension on SignalingContract {
  /// Connect to existing contract with pre-configured Web3Client
  ///
  /// This method allows using an existing Web3Client instance,
  /// which is useful for connection pooling and management.
  static Future<SignalingContract> connectWithClient({
    required dynamic client,
    required dynamic contractAddress,
    dynamic credentials,
  }) async {
    // Use DeployedContract and ContractAbi from web3dart
    final contract = web3.DeployedContract(
      web3.ContractAbi.fromJson(SignalingContract.contractAbi, 'Signaling'),
      contractAddress,
    );

    return SignalingContract(
      client: client,
      contract: contract,
      credentials: credentials,
    );
  }
}
