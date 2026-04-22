// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from Signaling.solpp (Vite Blockchain)

import 'dart:convert';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:http/http.dart' show Client;

/// Contract parameter type - sealed hierarchy for type-safe parameter handling
sealed class ContractParameter {
  const ContractParameter();
  Object get value;
}

class AddressParam extends ContractParameter {
  @override
  final EthereumAddress value;
  const AddressParam(this.value);
}

class UintParam extends ContractParameter {
  @override
  final BigInt value;
  const UintParam(this.value);
}

class BoolParam extends ContractParameter {
  @override
  final bool value;
  const BoolParam(this.value);
}

class BytesParam extends ContractParameter {
  @override
  final Uint8List value;
  const BytesParam(this.value);
}

/// Signal struct returned from getSignal
class Signal {
  final Uint8List signal;
  final BigInt creationTime;

  Signal({required this.signal, required this.creationTime});
}

/// Dart binding for Signaling smart contract (Vite Blockchain)
class SignalingContract {
  static const String contractAbi = '''[{"inputs":[{"internalType":"address","name":"initialOwner","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"bytes","name":"signal","type":"bytes"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"SignalEmitted","type":"event"},{"inputs":[{"internalType":"address","name":"offerer","type":"address"}],"name":"getSignal","outputs":[{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"internalType":"struct Signal","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes","name":"compressedSignal","type":"bytes"}],"name":"setSignal","outputs":[],"stateMutability":"nonpayable","type":"function"}]''';
  static const String contractBytecode = '608060405234801561001057600080fd5b50604051610b5b380380610b5b833981810160405281019061003291906100ec565b806000806101000a81548174ffffffffffffffffffffffffffffffffffffffffff021916908374ffffffffffffffffffffffffffffffffffffffffff1602179055508074ffffffffffffffffffffffffffffffffffffffffff16600074ffffffffffffffffffffffffffffffffffffffffff167f9a78605a08fe53b920adfc51344c28abd504bd2378db8d7dcdd50e527cbebe5760405160405180910390a35061015f565b6000815190506100e681610148565b92915050565b6000602082840312156100fe57600080fd5b600061010c848285016100d7565b91505092915050565b600061012082610127565b9050919050565b600074ffffffffffffffffffffffffffffffffffffffffff82169050919050565b61015181610115565b811461015c57600080fd5b50565b6109ed8061016e6000396000f3fe6080604052610421565b60008060009054906101000a900474ffffffffffffffffffffffffffffffffffffffffff16905090565b61003b610364565b600160008374ffffffffffffffffffffffffffffffffffffffffff1674ffffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002160405180604001604052908160008201805461009790610886565b80601f01602080910402602001604051908101604052809291908181526020018280546100c390610886565b80156101105780601f106100e557610100808354040283529160200191610110565b820191906000526020600021905b8154815290600101906020018083116100f357829003601f168201915b505050505081526020016001820154815250509050919050565b60028151101561016f576040517f4b2bae7e00000000000000000000000000000000000000000000000000000000815260040161016690610731565b60405180910390fd5b601f60f81b816000815181106101ae577fe0f8f85500000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b602001015160f81c60f81b7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff19161480156102515750608b60f81b81600181518110610222577fe0f8f85500000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b602001015160f81c60f81b7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916145b610290576040517f4b2bae7e00000000000000000000000000000000000000000000000000000000815260040161028790610711565b60405180910390fd5b604051806040016040528082815260200142815250600160003374ffffffffffffffffffffffffffffffffffffffffff1674ffffffffffffffffffffffffffffffffffffffffff168152602001908152602001600021600082015181600001908051906020019061030292919061037e565b50602082015181600101559050503374ffffffffffffffffffffffffffffffffffffffffff167fd7d827947ce9f436a7d9b9d90e1e4cfa6e3ccb21bd297839c25345f1c55e935d82426040516103599291906106e1565b60405180910390a250565b604051806040016040528060608152602001600081525090565b82805461038a90610886565b90600052602060002190601f0160209004810192826103ac57600085556103f3565b82601f106103c557805160ff19168380011785556103f3565b828001600101855582156103f3579182015b828111156103f25782518255916020019190600101906103d7565b5b5090506104009190610404565b5090565b5b8082111561041d576000816000905550600101610405565b5090565b600436106104515760003560e01c8063336139331461045357806347172d4814610471578063dca946a0146104a1575b005b61045b610009565b60405161046891906106c6565b60405180910390f35b61048b6004803603810190610486919061053a565b610033565b6040516104989190610751565b60405180910390f35b6104bb60048036038101906104b69190610563565b61012a565b005b60006104d06104cb84610798565b610773565b9050828152602081018484840111156104e857600080fd5b6104f3848285610844565b509392505050565b60008135905061050a816109aa565b92915050565b600082601f83011261052157600080fd5b81356105318482602086016104bd565b91505092915050565b60006020828403121561054c57600080fd5b600061055a848285016104fb565b91505092915050565b60006020828403121561057557600080fd5b600082013567ffffffffffffffff81111561058f57600080fd5b61059b84828501610510565b91505092915050565b6105ad81610807565b82525050565b60006105be826107c9565b6105c881856107d4565b93506105d8818560208601610853565b6105e181610947565b840191505092915050565b60006105f7826107c9565b61060181856107e5565b9350610611818560208601610853565b61061a81610947565b840191505092915050565b6000610632601b836107f6565b915061063d82610958565b602082019050919050565b6000610655601e836107f6565b915061066082610981565b602082019050919050565b6000604083016000830151848203600086015261068882826105b3565b915050602083015161069d60208601826106a8565b508091505092915050565b6106b18161083a565b82525050565b6106c08161083a565b82525050565b60006020820190506106db60008301846105a4565b92915050565b600060408201905081810360008301526106fb81856105ec565b905061070a60208301846106b7565b9392505050565b6000602082019050818103600083015261072a81610625565b9050919050565b6000602082019050818103600083015261074a81610648565b9050919050565b6000602082019050818103600083015261076b818461066b565b905092915050565b600061077d61078e565b905061078982826108b8565b919050565b6000604051905090565b600067ffffffffffffffff8211156107b3576107b2610918565b5b6107bc82610947565b9050602081019050919050565b600081519050919050565b600082825260208201905092915050565b600082825260208201905092915050565b600082825260208201905092915050565b600061081282610819565b9050919050565b600074ffffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b82818337600083830152505050565b60005b83811015610871578082015181840152602081019050610856565b83811115610880576000848401525b50505050565b6000600282049050600182168061089e57607f821691505b602082108114156108b2576108b16108e9565b5b50919050565b6108c182610947565b810181811067ffffffffffffffff821117156108e0576108df610918565b5b80604052505050565b7fe0f8f85500000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b7fe0f8f85500000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6000601f19601f8301169050919050565b7f44617461206d75737420626520696e20677a697020666f726d61740000000000600082015250565b7f496e76616c696420636f6d70726573736564206461746120666f726d61740000600082015250565b6109b381610807565b81146109be57600080fd5b5056fea165627a7a7230582000000000000000000000000000000000000000000000000000000000000000000029';

  final Web3Client client;
  final DeployedContract contract;
  final Credentials? credentials;
  final int? chainId;

  SignalingContract({
    required this.client,
    required DeployedContract contract,
    this.credentials,
    this.chainId,
  }) : contract = contract;

  /// Connect with a Web3Client and fetch chainId from network
  static Future<SignalingContract> connectWithClient({
    required Web3Client client,
    required EthereumAddress contractAddress,
    Credentials? credentials,
  }) async {
    final chainId = await client.getChainId();
    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, contractName),
      contractAddress,
    );
    return SignalingContract(
      client: client,
      contract: contract,
      credentials: credentials,
      chainId: chainId.toInt(),
    );
  }

  // View Methods

  /// Get the owner address
  Future<EthereumAddress> getOwner() async {
    final function = contract.function('owner');
    final result = await client.call(contract: contract, function: function, params: []);
    return result.first as EthereumAddress;
  }

  /// Get signal for a given address
  Future<Signal> getSignal(EthereumAddress offerer) async {
    final function = contract.function('getSignal');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [offerer],
    );

    final tuple = result.first as List<dynamic>;
    return Signal(
      signal: tuple[0] as Uint8List,
      creationTime: tuple[1] as BigInt,
    );
  }

  // Write Methods

  /// Set signal (gzip compressed)
  ///
  /// Requirements:
  /// - Signal must be at least 2 bytes long
  /// - Signal must start with gzip magic bytes: 0x1f 0x8b
  Future<String> setSignal(
    Uint8List compressedSignal, {
    Credentials? credentials,
  }) async {
    final function = contract.function('setSignal');
    final creds = credentials ?? this.credentials;

    if (creds == null) {
      throw StateError('No credentials provided for write operation');
    }

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [compressedSignal],
      from: await creds.extractAddress(),
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 200000,
    );

    return client.sendTransaction(creds, transaction, chainId: chainId);
  }

  // Deployment

  /// Deploy Signaling contract
  static Future<String> deploy({
    required Web3Client client,
    required Credentials credentials,
    required EthereumAddress initialOwner,
    int? chainId,
  }) async {
    final abi = ContractAbi.fromJson(contractAbi, contractName);

    // Find constructor in ABI
    final constructorAbi = abi.constructor;
    if (constructorAbi == null) {
      throw StateError('Constructor not found in ABI');
    }

    // Encode constructor parameters
    final params = [initialOwner];

    // Get bytecode and encode parameters
    String deploymentBytecode = contractBytecode;

    try {
      final encodedParams = abi.encodeConstructorParams(params);
      deploymentBytecode = contractBytecode + encodedParams.substring(2);
    } catch (e) {
      throw StateError('Failed to encode constructor parameters: $e');
    }

    final transaction = Transaction(
      to: null,
      data: hexToBytes(deploymentBytecode),
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 5000000,
    );

    return client.sendTransaction(
      credentials,
      transaction,
      chainId: chainId,
    );
  }
}
