// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from Signaling.sol

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

class StringParam extends ContractParameter {
  @override
  final String value;
  const StringParam(this.value);
}

class BytesParam extends ContractParameter {
  @override
  final Uint8List value;
  const BytesParam(this.value);
}

class ListParam extends ContractParameter {
  @override
  final List<ContractParameter> value;
  const ListParam(this.value);
}

/// Dart binding for Signaling smart contract
class SignalingContract {
  static const String contractAbi = '''[{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"bytes","name":"signal","type":"bytes"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"SignalEmitted","type":"event"},{"inputs":[{"internalType":"address","name":"offerer","type":"address"}],"name":"getSignal","outputs":[{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"internalType":"struct Signal","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"compressedSignal","type":"bytes"}],"name":"setSignal","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"}]''';
  static const String contractBytecode = '0x608060405234801561000f575f80fd5b506040516108b73803806108b783398101604081905261002e916100bb565b806001600160a01b03811661005c57604051631e4fbdf760e01b81525f600482015260240160405180910390fd5b6100658161006c565b50506100e8565b5f80546001600160a01b038381166001600160a01b0319831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b5f602082840312156100cb575f80fd5b81516001600160a01b03811681146100e1575f80fd5b9392505050565b6107c2806100f55f395ff3fe608060405234801561000f575f80fd5b5060043610610064575f3560e01c8063715018a61161004d578063715018a6146100a65780638da5cb5b146100ae578063f2fde38b146100c8575f80fd5b80631329c0a9146100685780631628825114610091575b5f80fd5b61007b6100763660046104b3565b6100db565b6040516100889190610523565b60405180910390f35b6100a461009f366004610568565b6101b0565b005b6100a461039e565b5f546040516001600160a01b039091168152602001610088565b6100a46100d63660046104b3565b6103b1565b60408051808201909152606081525f60208201526001600160a01b0382165f9081526001602052604090819020815180830190925280548290829061011f90610613565b80601f016020809104026020016040519081016040528092919081815260200182805461014b90610613565b80156101965780601f1061016d57610100808354040283529160200191610196565b820191905f5260205f20905b81548152906001019060200180831161017957829003601f168201915b505050505081526020016001820154815250509050919050565b6002815110156102075760405162461bcd60e51b815260206004820152601e60248201527f496e76616c696420636f6d70726573736564206461746120666f726d6174000060448201526064015b60405180910390fd5b805f815181106102195761021961064b565b6020910101517fff00000000000000000000000000000000000000000000000000000000000000167f1f000000000000000000000000000000000000000000000000000000000000001480156102c857508060018151811061027d5761027d61064b565b6020910101517fff00000000000000000000000000000000000000000000000000000000000000167f8b00000000000000000000000000000000000000000000000000000000000000145b6103145760405162461bcd60e51b815260206004820152601b60248201527f44617461206d75737420626520696e20677a697020666f726d6174000000000060448201526064016101fe565b60408051808201825282815242602080830191909152335f9081526001909152919091208151829190819061034990826106ab565b5060208201518160010155905050336001600160a01b03167f4f7ab02db55c26729a8a9923caf3088122b7a76a6f8a2deba4cff184690add82834260405161039292919061076b565b60405180910390a25050565b6103a6610407565b6103af5f61044c565b565b6103b9610407565b6001600160a01b0381166103fb576040517f1e4fbdf70000000000000000000000000000000000000000000000000000000081525f60048201526024016101fe565b6104048161044c565b50565b5f546001600160a01b031633146103af576040517f118cdaa70000000000000000000000000000000000000000000000000000000081523360048201526024016101fe565b5f80546001600160a01b038381167fffffffffffffffffffffffff0000000000000000000000000000000000000000831681178455604051919092169283917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09190a35050565b5f602082840312156104c3575f80fd5b81356001600160a01b03811681146104d9575f80fd5b9392505050565b5f81518084525f5b81811015610504576020818501810151868301820152016104e8565b505f602082860101526020601f19601f83011685010191505092915050565b602081525f82516040602084015261053e60608401826104e0565b9050602084015160408401528091505092915050565b634e487b7160e01b5f52604160045260245ffd5b5f60208284031215610578575f80fd5b813567ffffffffffffffff8082111561058f575f80fd5b818401915084601f8301126105a2575f80fd5b8135818111156105b4576105b4610554565b604051601f8201601f19908116603f011681019083821181831017156105dc576105dc610554565b816040528281528760208487010111156105f4575f80fd5b826020860160208301375f928101602001929092525095945050505050565b600181811c9082168061062757607f821691505b60208210810361064557634e487b7160e01b5f52602260045260245ffd5b50919050565b634e487b7160e01b5f52603260045260245ffd5b601f8211156106a657805f5260205f20601f840160051c810160208510156106845750805b601f840160051c820191505b818110156106a3575f8155600101610690565b50505b505050565b815167ffffffffffffffff8111156106c5576106c5610554565b6106d9816106d38454610613565b8461065f565b602080601f83116001811461070c575f84156106f55750858301515b5f19600386901b1c1916600185901b178555610763565b5f85815260208120601f198616915b8281101561073a5788860151825594840194600190910190840161071b565b508582101561075757878501515f19600388901b60f8161c191681555b505060018460011b0185555b505050505050565b604081525f61077d60408301856104e0565b9050826020830152939250505056fea2646970667358221220eedc1afeae6a5cfff4abe0dcceabdfa4c6635e35446297b97e3f812d39278ffb64736f6c63430008180033';

  final Web3Client client;
  final DeployedContract contract;
  final Credentials? credentials;
  final int? chainId;

  SignalingContract({
    required this.client,
    required this.contract,
    this.credentials,
    this.chainId,
  });

  /// Factory constructor to connect to existing contract
  static Future<SignalingContract> connect({
    required String rpcUrl,
    required EthereumAddress contractAddress,
    Credentials? credentials,
  }) async {
    final client = Web3Client(rpcUrl, Client());

    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'Signaling'),
      contractAddress,
    );

    return SignalingContract(
      client: client,
      contract: contract,
      credentials: credentials,
      chainId: null,
    );
  }

  /// Connect to existing contract with pre-configured Web3Client
  ///
  /// This method allows using an existing Web3Client instance,
  /// which is useful for connection pooling and management.
  static Future<SignalingContract> connectWithClient({
    required Web3Client client,
    required EthereumAddress contractAddress,
    Credentials? credentials,
    int? chainId,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'Signaling'),
      contractAddress,
    );

    // If chainId not provided, fetch from network
    int? resolvedChainId = chainId;
    if (resolvedChainId == null && credentials != null) {
      try {
        final chainIdBigInt = await client.getChainId();
        resolvedChainId = chainIdBigInt.toInt();
      } catch (e) {
        // Continue without chainId if unable to fetch
      }
    }

    return SignalingContract(
      client: client,
      contract: contract,
      credentials: credentials,
      chainId: resolvedChainId,
    );
  }

  /// Deploy new contract instance
  static Future<SignalingContract> deploy({
    required String rpcUrl,
    required Credentials credentials,
    List<ContractParameter> constructorParams = const [],
  }) async {
    final client = Web3Client(rpcUrl, Client());

    // Encode constructor parameters if any
    String deployData = contractBytecode;
    if (constructorParams.isNotEmpty) {
      deployData = _encodeDeployData(contractBytecode, constructorParams);
    }

    final transaction = Transaction(
      from: credentials.address,
      data: hexToBytes(deployData),
    );

    final txHash = await client.sendTransaction(credentials, transaction);

    // Wait for transaction receipt and get contract address
    TransactionReceipt? receipt;
    int attempts = 0;
    while (receipt == null && attempts < 60) {
      await Future.delayed(const Duration(seconds: 1));
      receipt = await client.getTransactionReceipt(txHash);
      attempts++;
    }

    if (receipt == null) {
      throw Exception('Contract deployment failed: transaction receipt not found after 60 seconds');
    }

    final contractAddr = receipt.contractAddress;
    if (contractAddr == null) {
      throw Exception('Contract deployment failed: no contract address in receipt');
    }

    // Return connected instance
    return connect(
      rpcUrl: rpcUrl,
      contractAddress: contractAddr,
      credentials: credentials,
    );
  }

  /// Encode constructor parameters into deployment data
  static String _encodeDeployData(String bytecode, List<ContractParameter> params) {
    try {
      final List<Object?> abiList = jsonDecode(contractAbi) as List<Object?>;
      final constructorItem = abiList.firstWhere(
        (item) => item is Map<String, Object?> && item['type'] == 'constructor',
        orElse: () => null,
      );

      if (constructorItem == null || constructorItem is! Map<String, Object?>) {
        return bytecode;
      }

      final List<Object?>? inputs = constructorItem['inputs'] as List<Object?>?;
      if (inputs == null || inputs.isEmpty) {
        return bytecode;
      }

      final StringBuffer encodedParams = StringBuffer();

      for (int i = 0; i < inputs.length && i < params.length; i++) {
        final input = inputs[i];
        if (input is! Map<String, Object?>) continue;

        final String? paramType = input['type'] as String?;
        if (paramType == null) continue;

        final paramValue = params[i];

        final encoded = _encodeParameter(paramType, paramValue);
        if (encoded != null) {
          encodedParams.write(encoded);
        }
      }

      return bytecode + encodedParams.toString();
    } catch (e) {
      print('Warning: Could not encode constructor params: $e');
      return bytecode;
    }
  }

  /// Encode a single parameter value based on its Solidity type
  static String? _encodeParameter(String paramType, ContractParameter paramValue) {
    try {
      return switch (paramValue) {
        AddressParam(:final value) => paramType == 'address'
            ? value.toString().replaceAll('0x', '').replaceAll('0X', '').toLowerCase().padLeft(64, '0')
            : null,
        UintParam(:final value) => paramType.startsWith('uint')
            ? value.toRadixString(16).padLeft(64, '0')
            : null,
        BoolParam(:final value) => paramType == 'bool'
            ? (value ? '1' : '0').padLeft(64, '0')
            : null,
        BytesParam(:final value) => paramType.startsWith('bytes')
            ? value.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')
            : null,
        ListParam(:final value) => paramType.contains('[]')
            ? value.fold<String>('', (String acc, ContractParameter p) {
              final encoded = _encodeParameter(paramType.replaceAll('[]', ''), p);
              return encoded != null ? acc + encoded : acc;
            })
            : null,
        StringParam(:final value) => null, // String encoding requires hash, complex
      };
    } catch (e) {
      print('Warning: Could not encode parameter of type $paramType: $e');
      return null;
    }
  }


  /// getSignal - View function
  Future<Map<String, Object?>> getSignal(EthereumAddress offerer) async {
    final function = contract.function('getSignal');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [offerer],
    );
    
    return result.first as Map<String, Object?>;
  }

  /// owner - View function
  Future<EthereumAddress> owner() async {
    final function = contract.function('owner');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [],
    );
    
    return result.first as EthereumAddress;
  }

  /// renounceOwnership - Transaction function
  Future<String> renounceOwnership() async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('renounceOwnership');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [],
    );

    final txHash = await client.sendTransaction(credentials!, transaction, chainId: chainId);
    return txHash;
  }

  /// setSignal - Transaction function
  Future<String> setSignal(Uint8List compressedSignal) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('setSignal');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [compressedSignal],
    );

    final txHash = await client.sendTransaction(credentials!, transaction, chainId: chainId);
    return txHash;
  }

  /// transferOwnership - Transaction function
  Future<String> transferOwnership(EthereumAddress newOwner) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('transferOwnership');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [newOwner],
    );

    final txHash = await client.sendTransaction(credentials!, transaction, chainId: chainId);
    return txHash;
  }

}

/// Helper function to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) hex = hex.substring(2);
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}
