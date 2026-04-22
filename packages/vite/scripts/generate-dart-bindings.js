const fs = require('fs');
const path = require('path');

// Paths
const buildDir = path.join(__dirname, '..', 'build');
const abiFile = path.join(buildDir, 'Signaling.abi.json');
const bytecodeFile = path.join(buildDir, 'Signaling.bin');
const viteContractSdkPath = path.resolve(__dirname, '..', '..', 'vite_contract_sdk');
const dartOutputDir = path.join(viteContractSdkPath, 'lib', 'generated');

// Check artifacts exist
if (!fs.existsSync(abiFile) || !fs.existsSync(bytecodeFile)) {
  console.error('❌ Artifacts not found. Run "npm run compile" first.');
  process.exit(1);
}

const abi = JSON.parse(fs.readFileSync(abiFile, 'utf-8'));
const bytecodeHex = fs.readFileSync(bytecodeFile, 'utf-8').trim();

// Create output directory
if (!fs.existsSync(dartOutputDir)) {
  fs.mkdirSync(dartOutputDir, { recursive: true });
}

const abiJsonString = JSON.stringify(abi);

const dartTemplate = `// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from Signaling.solpp (Vite Blockchain)

import 'dart:async';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

/// Signal struct returned from getSignal
class Signal {
  final Uint8List signal;
  final BigInt creationTime;

  Signal({required this.signal, required this.creationTime});

  factory Signal.fromList(List<dynamic> list) {
    return Signal(
      signal: list[0] as Uint8List,
      creationTime: list[1] as BigInt,
    );
  }
}

/// Dart binding for Signaling smart contract (Vite Blockchain)
class SignalingContract {
  static const String _contractName = 'Signaling';
  static const String _abiJson = '''${abiJsonString}''';
  static const String _bytecode = '${bytecodeHex}';

  final Web3Client client;
  final EthereumAddress contractAddress;
  late final DeployedContract contract;
  final Credentials? credentials;
  final int? chainId;

  SignalingContract({
    required this.client,
    required this.contractAddress,
    this.credentials,
    this.chainId,
  }) {
    _initContract();
  }

  void _initContract() {
    final abi = ContractAbi.fromJson(_abiJson, _contractName);
    contract = DeployedContract(abi, contractAddress);
  }

  // View Methods

  /// Get the owner address
  Future<EthereumAddress> getOwner() async {
    final function = contract.function('owner');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [],
    );
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
    return Signal.fromList(result.first as List<dynamic>);
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

    final from = creds.address;

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [compressedSignal],
      from: from,
      maxGas: 200000,
    );

    return client.sendTransaction(creds, transaction, chainId: chainId);
  }

  // Deployment

  /// Deploy Signaling contract with initial owner
  static Future<String> deploy({
    required Web3Client client,
    required Credentials credentials,
    required EthereumAddress initialOwner,
    int? chainId,
  }) async {
    final from = credentials.address;

    final transaction = Transaction(
      to: null,
      from: from,
      maxGas: 5000000,
      data: _hexToBytes(_bytecode),
    );

    return client.sendTransaction(credentials, transaction, chainId: chainId);
  }

  // Helper methods

  static Uint8List _hexToBytes(String hex) {
    final cleanHex = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = <int>[];
    for (int i = 0; i < cleanHex.length; i += 2) {
      bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }
}
`;

fs.writeFileSync(
  path.join(dartOutputDir, 'signaling_contract.dart'),
  dartTemplate,
);

console.log('✅ Dart bindings generated at: packages/vite_contract_sdk/lib/generated/signaling_contract.dart');
