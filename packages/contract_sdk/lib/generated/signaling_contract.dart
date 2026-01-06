// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from Signaling.sol

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:http/http.dart';

/// Dart binding for Signaling smart contract
class SignalingContract {
  static const String contractAbi = '''[{"inputs":[{"internalType":"address","name":"target","type":"address"}],"name":"AddressEmptyCode","type":"error"},{"inputs":[{"internalType":"address","name":"implementation","type":"address"}],"name":"ERC1967InvalidImplementation","type":"error"},{"inputs":[],"name":"ERC1967NonPayable","type":"error"},{"inputs":[],"name":"FailedCall","type":"error"},{"inputs":[],"name":"InvalidInitialization","type":"error"},{"inputs":[],"name":"NotInitializing","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"inputs":[],"name":"UUPSUnauthorizedCallContext","type":"error"},{"inputs":[{"internalType":"bytes32","name":"slot","type":"bytes32"}],"name":"UUPSUnsupportedProxiableUUID","type":"error"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint64","name":"version","type":"uint64"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"implementation","type":"address"}],"name":"Upgraded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"offerer","type":"address"},{"indexed":true,"internalType":"address","name":"answerer","type":"address"},{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"indexed":false,"internalType":"struct Signal","name":"answer","type":"tuple"}],"name":"proposeAnswer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"offerer","type":"address"},{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"indexed":false,"internalType":"struct Signal","name":"offer","type":"tuple"}],"name":"proposeOffer","type":"event"},{"inputs":[],"name":"UPGRADE_INTERFACE_VERSION","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"answerer","type":"address"},{"internalType":"address","name":"offerer","type":"address"}],"name":"getAnswer","outputs":[{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"internalType":"struct Signal","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"offerer","type":"address"}],"name":"getOffer","outputs":[{"components":[{"internalType":"bytes","name":"signal","type":"bytes"},{"internalType":"uint256","name":"creationTime","type":"uint256"}],"internalType":"struct Signal","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"proxiableUUID","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"answer","type":"bytes"},{"internalType":"address","name":"offerer","type":"address"}],"name":"setAnswer","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"offer","type":"bytes"}],"name":"setOffer","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newImplementation","type":"address"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"upgradeToAndCall","outputs":[],"stateMutability":"payable","type":"function"}]''';
  static const String contractBytecode = '0x60a060405230608052348015610013575f80fd5b506080516111d261003a5f395f81816107d70152818161080001526109ba01526111d25ff3fe6080604052600436106100b8575f3560e01c80638da5cb5b11610071578063ddf7c0ce1161004c578063ddf7c0ce14610215578063eb75c41014610234578063f2fde38b14610253575f80fd5b80638da5cb5b1461015b578063ad3cb1cc146101a1578063c4d66de8146101f6575f80fd5b80634f1ef286116100a15780634f1ef2861461011257806352d1902d14610125578063715018a614610147575f80fd5b8063224c06b8146100bc5780634c0b2d94146100dd575b5f80fd5b3480156100c7575f80fd5b506100db6100d6366004610e41565b610272565b005b3480156100e8575f80fd5b506100fc6100f7366004610e96565b6102f9565b6040516101099190610f14565b60405180910390f35b6100db610120366004610f45565b6103d9565b348015610130575f80fd5b506101396103f8565b604051908152602001610109565b348015610152575f80fd5b506100db610426565b348015610166575f80fd5b507f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300546040516001600160a01b039091168152602001610109565b3480156101ac575f80fd5b506101e96040518060400160405280600581526020017f352e302e3000000000000000000000000000000000000000000000000000000081525081565b6040516101099190610f90565b348015610201575f80fd5b506100db610210366004610fa2565b610439565b348015610220575f80fd5b506100db61022f366004610fbb565b610574565b34801561023f575f80fd5b506100fc61024e366004610fa2565b6106a1565b34801561025e575f80fd5b506100db61026d366004610fa2565b610776565b60408051808201825282815242602080830191909152335f9081529081905291909120815182919081906102a69082611080565b5060208201518160010155905050336001600160a01b03167f9c647382d7799e7e4b4c67ed15f6a91fddfd228ec1949b2eae5f05ca58d61158826040516102ed9190610f14565b60405180910390a25050565b604080518082018252606081525f60208083018290526001600160a01b0386811683526001825284832090861683529052829020825180840190935280549192918290829061034790610ffd565b80601f016020809104026020016040519081016040528092919081815260200182805461037390610ffd565b80156103be5780601f10610395576101008083540402835291602001916103be565b820191905f5260205f20905b8154815290600101906020018083116103a157829003601f168201915b50505050508152602001600182015481525050905092915050565b6103e16107cc565b6103ea82610883565b6103f482826108c2565b5050565b5f6104016109af565b507f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc90565b61042e6109f8565b6104375f610a6c565b565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00805468010000000000000000810460ff16159067ffffffffffffffff165f811580156104835750825b90505f8267ffffffffffffffff16600114801561049f5750303b155b9050811580156104ad575080155b156104e4576040517ff92ee8a900000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b845467ffffffffffffffff19166001178555831561051857845468ff00000000000000001916680100000000000000001785555b61052186610ae9565b831561056c57845468ff000000000000000019168555604051600181527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d29060200160405180910390a15b505050505050565b6001600160a01b0381165f9081526020819052604090206001015481906105fc576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152600e60248201527f4e6f206f6666657220666f756e6400000000000000000000000000000000000060448201526064015b60405180910390fd5b60408051808201825284815242602080830191909152335f908152600182528381206001600160a01b038716825290915291909120815182919081906106429082611080565b5060208201518160010155905050336001600160a01b0316836001600160a01b03167f5ecfe35cd7e8831a41cd757bcde8154a54a57dae4bfd09f34ae1aa0cce0778af836040516106939190610f14565b60405180910390a350505050565b60408051808201909152606081525f60208201526001600160a01b0382165f908152602081905260409081902081518083019092528054829082906106e590610ffd565b80601f016020809104026020016040519081016040528092919081815260200182805461071190610ffd565b801561075c5780601f106107335761010080835404028352916020019161075c565b820191905f5260205f20905b81548152906001019060200180831161073f57829003601f168201915b505050505081526020016001820154815250509050919050565b61077e6109f8565b6001600160a01b0381166107c0576040517f1e4fbdf70000000000000000000000000000000000000000000000000000000081525f60048201526024016105f3565b6107c981610a6c565b50565b306001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016148061086557507f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166108597f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc546001600160a01b031690565b6001600160a01b031614155b156104375760405163703e46dd60e11b815260040160405180910390fd5b61088b6109f8565b6002805463ffffffff16905f6108a08361113c565b91906101000a81548163ffffffff021916908363ffffffff1602179055505050565b816001600160a01b03166352d1902d6040518163ffffffff1660e01b8152600401602060405180830381865afa92505050801561091c575060408051601f3d908101601f191682019092526109199181019061116a565b60015b61094457604051634c9c8ce360e01b81526001600160a01b03831660048201526024016105f3565b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc81146109a0576040517faa1d49a4000000000000000000000000000000000000000000000000000000008152600481018290526024016105f3565b6109aa8383610afa565b505050565b306001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146104375760405163703e46dd60e11b815260040160405180910390fd5b33610a2a7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300546001600160a01b031690565b6001600160a01b031614610437576040517f118cdaa70000000000000000000000000000000000000000000000000000000081523360048201526024016105f3565b7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300805473ffffffffffffffffffffffffffffffffffffffff1981166001600160a01b03848116918217845560405192169182907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0905f90a3505050565b610af1610b4f565b6107c981610bb6565b610b0382610bbe565b6040516001600160a01b038316907fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b905f90a2805115610b47576109aa8282610c41565b6103f4610cb3565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a005468010000000000000000900460ff16610437576040517fd7e6bcf800000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b61077e610b4f565b806001600160a01b03163b5f03610bf357604051634c9c8ce360e01b81526001600160a01b03821660048201526024016105f3565b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc805473ffffffffffffffffffffffffffffffffffffffff19166001600160a01b0392909216919091179055565b60605f80846001600160a01b031684604051610c5d9190611181565b5f60405180830381855af49150503d805f8114610c95576040519150601f19603f3d011682016040523d82523d5f602084013e610c9a565b606091505b5091509150610caa858383610ceb565b95945050505050565b3415610437576040517fb398979f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b606082610d0057610cfb82610d63565b610d5c565b8151158015610d1757506001600160a01b0384163b155b15610d59576040517f9996b3150000000000000000000000000000000000000000000000000000000081526001600160a01b03851660048201526024016105f3565b50805b9392505050565b805115610d7257805160208201fd5b6040517fd6bda27500000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b634e487b7160e01b5f52604160045260245ffd5b5f82601f830112610dc7575f80fd5b813567ffffffffffffffff80821115610de257610de2610da4565b604051601f8301601f19908116603f01168101908282118183101715610e0a57610e0a610da4565b81604052838152866020858801011115610e22575f80fd5b836020870160208301375f602085830101528094505050505092915050565b5f60208284031215610e51575f80fd5b813567ffffffffffffffff811115610e67575f80fd5b610e7384828501610db8565b949350505050565b80356001600160a01b0381168114610e91575f80fd5b919050565b5f8060408385031215610ea7575f80fd5b610eb083610e7b565b9150610ebe60208401610e7b565b90509250929050565b5f5b83811015610ee1578181015183820152602001610ec9565b50505f910152565b5f8151808452610f00816020860160208601610ec7565b601f01601f19169290920160200192915050565b602081525f825160406020840152610f2f6060840182610ee9565b9050602084015160408401528091505092915050565b5f8060408385031215610f56575f80fd5b610f5f83610e7b565b9150602083013567ffffffffffffffff811115610f7a575f80fd5b610f8685828601610db8565b9150509250929050565b602081525f610d5c6020830184610ee9565b5f60208284031215610fb2575f80fd5b610d5c82610e7b565b5f8060408385031215610fcc575f80fd5b823567ffffffffffffffff811115610fe2575f80fd5b610fee85828601610db8565b925050610ebe60208401610e7b565b600181811c9082168061101157607f821691505b60208210810361102f57634e487b7160e01b5f52602260045260245ffd5b50919050565b601f8211156109aa57805f5260205f20601f840160051c8101602085101561105a5750805b601f840160051c820191505b81811015611079575f8155600101611066565b5050505050565b815167ffffffffffffffff81111561109a5761109a610da4565b6110ae816110a88454610ffd565b84611035565b602080601f8311600181146110e1575f84156110ca5750858301515b5f19600386901b1c1916600185901b17855561056c565b5f85815260208120601f198616915b8281101561110f578886015182559484019460019091019084016110f0565b508582101561112c57878501515f19600388901b60f8161c191681555b5050505050600190811b01905550565b5f63ffffffff80831681810361116057634e487b7160e01b5f52601160045260245ffd5b6001019392505050565b5f6020828403121561117a575f80fd5b5051919050565b5f8251611192818460208701610ec7565b919091019291505056fea264697066735822122064ee28cde2dec1e883c9e1acba4657e98e8acfd296a7e56fe367014efa01440a64736f6c63430008180033';

  final Web3Client client;
  final DeployedContract contract;
  final EthPrivateKey? credentials;

  SignalingContract({
    required this.client,
    required this.contract,
    this.credentials,
  });

  /// Factory constructor to connect to existing contract
  static Future<SignalingContract> connect({
    required String rpcUrl,
    required EthereumAddress contractAddress,
    EthPrivateKey? credentials,
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
    );
  }

  /// Deploy new contract instance
  static Future<SignalingContract> deploy({
    required String rpcUrl,
    required EthPrivateKey credentials,
    List<dynamic> constructorParams = const [],
    int? chainId,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    
    // Prepare bytecode - remove 0x prefix if present
    final bytecodeData = hexToBytes(contractBytecode.startsWith('0x') 
        ? contractBytecode.substring(2) 
        : contractBytecode);
    
    // Use EIP-1559 transaction format for better compatibility with Ganache
    // Default gas price: 2 gwei (typical for Ganache)
    final gasPrice = EtherAmount.fromInt(EtherUnit.gwei, 2);
    
    final transaction = Transaction(
      from: credentials.address,
      data: bytecodeData,
      maxGas: 8000000, // Allow sufficient gas for contract deployment
      maxFeePerGas: gasPrice,
      maxPriorityFeePerGas: gasPrice,
    );

    // Send transaction with explicit chainId to avoid signature issues
    // Ganache default chainId is 1337, but can be overridden
    final txHash = await client.sendTransaction(
      credentials, 
      transaction,
      chainId: chainId ?? 1337,
    );
    
    // Wait for transaction receipt and get contract address
    TransactionReceipt? receipt;
    int attempts = 0;
    while (receipt == null && attempts < 60) {
      await Future.delayed(Duration(seconds: 1));
      receipt = await client.getTransactionReceipt(txHash);
      attempts++;
    }
    
    if (receipt == null) {
      throw Exception('Contract deployment failed: transaction receipt not found after 60 seconds');
    }
    
    if (receipt.contractAddress == null) {
      throw Exception('Contract deployment failed: no contract address in receipt');
    }
    
    // Return connected instance
    return connect(
      rpcUrl: rpcUrl,
      contractAddress: receipt.contractAddress!,
      credentials: credentials,
    );
  }


  /// UPGRADE_INTERFACE_VERSION - View function
  Future<String> upgradeInterfaceVersion() async {
    final function = contract.function('UPGRADE_INTERFACE_VERSION');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [],
    );
    
    return result.first as String;
  }

  /// getAnswer - View function
  Future<dynamic> getAnswer(EthereumAddress answerer, EthereumAddress offerer) async {
    final function = contract.function('getAnswer');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [answerer, offerer],
    );
    
    return result.first as dynamic;
  }

  /// getOffer - View function
  Future<dynamic> getOffer(EthereumAddress offerer) async {
    final function = contract.function('getOffer');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [offerer],
    );
    
    return result.first as dynamic;
  }

  /// initialize - Transaction function
  Future<String> initialize(EthereumAddress owner) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('initialize');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [owner],
    );

    final txHash = await client.sendTransaction(credentials!, transaction);
    return txHash;
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

  /// proxiableUUID - View function
  Future<dynamic> proxiableUUID() async {
    final function = contract.function('proxiableUUID');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [],
    );
    
    return result.first as dynamic;
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

    final txHash = await client.sendTransaction(credentials!, transaction);
    return txHash;
  }

  /// setAnswer - Transaction function
  Future<String> setAnswer(Uint8List answer, EthereumAddress offerer) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('setAnswer');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [answer, offerer],
    );

    final txHash = await client.sendTransaction(credentials!, transaction);
    return txHash;
  }

  /// setOffer - Transaction function
  Future<String> setOffer(Uint8List offer) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('setOffer');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [offer],
    );

    final txHash = await client.sendTransaction(credentials!, transaction);
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

    final txHash = await client.sendTransaction(credentials!, transaction);
    return txHash;
  }

  /// upgradeToAndCall - Transaction function
  Future<String> upgradeToAndCall(EthereumAddress newImplementation, Uint8List data) async {
    if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('upgradeToAndCall');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [newImplementation, data],
    );

    final txHash = await client.sendTransaction(credentials!, transaction);
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
