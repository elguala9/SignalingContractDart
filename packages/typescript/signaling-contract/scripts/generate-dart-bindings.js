const fs = require('fs');
const path = require('path');

// Percorsi
const artifactsDir = path.join(__dirname, '..', 'artifacts', 'contracts');
// Percorso corretto: da signaling-contract vai a typescript, poi packages, poi contract_sdk
const contractSdkPath = path.resolve(__dirname, '..', '..', '..', 'contract_sdk');
const dartOutputDir = path.join(contractSdkPath, 'lib', 'generated');

// Assicurati che la directory di output esista
if (!fs.existsSync(dartOutputDir)) {
    fs.mkdirSync(dartOutputDir, { recursive: true });
}

function toCamelCase(str) {
    // Handle UPPER_SNAKE_CASE (e.g., UPGRADE_INTERFACE_VERSION)
    if (str === str.toUpperCase() && str.includes('_')) {
        return str.split('_')
            .map((word, index) => {
                if (index === 0) {
                    return word.toLowerCase();
                }
                return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
            })
            .join('');
    }
    // Handle regular camelCase
    return str.charAt(0).toLowerCase() + str.slice(1);
}

function toPascalCase(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function generateDartBinding(contractName, abi, bytecode) {
    const className = `${toPascalCase(contractName)}Contract`;
    const instanceName = toCamelCase(contractName);

    const template = `// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from ${contractName}.sol

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

/// Dart binding for ${contractName} smart contract
class ${className} {
  static const String contractAbi = '''${JSON.stringify(abi)}''';
  static const String contractBytecode = '${bytecode || ''}';

  final Web3Client client;
  final DeployedContract contract;
  final Credentials? credentials;
  final int? chainId;

  ${className}({
    required this.client,
    required this.contract,
    this.credentials,
    this.chainId,
  });

  /// Factory constructor to connect to existing contract
  static Future<${className}> connect({
    required String rpcUrl,
    required EthereumAddress contractAddress,
    Credentials? credentials,
  }) async {
    final client = Web3Client(rpcUrl, Client());

    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, '${contractName}'),
      contractAddress,
    );

    return ${className}(
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
  static Future<${className}> connectWithClient({
    required Web3Client client,
    required EthereumAddress contractAddress,
    Credentials? credentials,
    int? chainId,
  }) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, '${contractName}'),
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

    return ${className}(
      client: client,
      contract: contract,
      credentials: credentials,
      chainId: resolvedChainId,
    );
  }

  /// Deploy new contract instance
  static Future<${className}> deploy({
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
      print('Warning: Could not encode constructor params: \$e');
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
      print('Warning: Could not encode parameter of type \$paramType: \$e');
      return null;
    }
  }

${generateMethods(abi)}
}

/// Helper function to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) hex = hex.substring(2);
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}
`;

    return template;
}

function generateMethods(abi) {
    let methods = '';
    
    for (const item of abi) {
        if (item.type === 'function') {
            const methodName = toCamelCase(item.name);
            const isView = item.stateMutability === 'view' || item.stateMutability === 'pure';
            const params = item.inputs || [];
            const outputs = item.outputs || [];
            
            // Generate parameters
            const paramStrings = params.map((param, i) => {
                const dartType = solidityToDartType(param.type);
                return `${dartType} ${param.name || `param${i}`}`;
            });
            
            const paramNames = params.map((param, i) => param.name || `param${i}`);
            
            // Generate method
            methods += `
  /// ${item.name} - ${isView ? 'View function' : 'Transaction function'}
  Future<${isView ? getReturnType(outputs) : 'String'}> ${methodName}(${paramStrings.join(', ')}) async {
    ${isView ? generateViewCall(item.name, paramNames, outputs) : generateTransactionCall(item.name, paramNames)}
  }
`;
        }
    }
    
    return methods;
}

function generateViewCall(functionName, paramNames, outputs) {
    const returnType = getReturnType(outputs);
    return `final function = contract.function('${functionName}');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [${paramNames.join(', ')}],
    );
    
    ${outputs.length === 0 ? 'return null;' : 
      outputs.length === 1 ? `return result.first as ${solidityToDartType(outputs[0].type)};` : 
      'return result; // Multiple return values as List'}`;
}

function generateTransactionCall(functionName, paramNames) {
    return `if (credentials == null) {
      throw Exception('Credentials required for write operations');
    }

    final function = contract.function('${functionName}');
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [${paramNames.join(', ')}],
    );

    final txHash = await client.sendTransaction(credentials!, transaction, chainId: chainId);
    return txHash;`;
}

function solidityToDartType(solidityType) {
    if (solidityType === 'address') return 'EthereumAddress';
    if (solidityType === 'bool') return 'bool';
    if (solidityType === 'string') return 'String';
    if (solidityType === 'bytes') return 'Uint8List';
    if (solidityType.startsWith('bytes')) return 'Uint8List';
    if (solidityType.startsWith('uint') || solidityType.startsWith('int')) return 'BigInt';
    if (solidityType.endsWith('[]')) return `List<${solidityToDartType(solidityType.replace('[]', ''))}>`;
    // For tuple/struct types, use Map for flexibility
    if (solidityType === 'tuple') return 'Map<String, Object?>';
    // Unknown type - still Object? instead of dynamic for type safety
    return 'Object?';
}

function getReturnType(outputs) {
    if (outputs.length === 0) return 'void';
    if (outputs.length === 1) return solidityToDartType(outputs[0].type);
    // Multiple return values as list of unknown types
    return 'List<Object?>';
}

// Funzione principale
function generateBindings() {
    console.log('🔄 Generating Dart bindings...');
    console.log(`📁 Artifacts dir: ${artifactsDir}`);
    console.log(`📁 Output dir: ${dartOutputDir}`);
    
    // Verifica che la directory di destinazione esista
    if (!fs.existsSync(contractSdkPath)) {
        console.error(`❌ Contract SDK path not found: ${contractSdkPath}`);
        return;
    }
    
    // Trova tutti i file JSON degli artefatti
    function findContractArtifacts(dir) {
        let artifacts = [];
        const files = fs.readdirSync(dir);
        
        for (const file of files) {
            const filePath = path.join(dir, file);
            const stat = fs.statSync(filePath);
            
            if (stat.isDirectory()) {
                artifacts = artifacts.concat(findContractArtifacts(filePath));
            } else if (file.endsWith('.json') && !file.endsWith('.dbg.json')) {
                artifacts.push(filePath);
            }
        }
        
        return artifacts;
    }
    
    const artifacts = findContractArtifacts(artifactsDir);
    console.log(`📁 Found ${artifacts.length} contract artifacts`);
    
    for (const artifactPath of artifacts) {
        try {
            const artifactContent = JSON.parse(fs.readFileSync(artifactPath, 'utf-8'));
            const contractName = artifactContent.contractName;
            
            // Skip interface contracts (starting with I)
            if (contractName.startsWith('I')) {
                console.log(`↩️  Skipping interface contract: ${contractName}`);
                continue;
            }
            
            const abi = artifactContent.abi;
            const bytecode = artifactContent.bytecode;
            
            console.log(`⚡ Generating binding for ${contractName}...`);
            
            let dartCode = generateDartBinding(contractName, abi, bytecode);

            const outputPath = path.join(dartOutputDir, `${contractName.toLowerCase()}_contract.dart`);

            fs.writeFileSync(outputPath, dartCode);
            console.log(`✅ Generated ${contractName.toLowerCase()}_contract.dart`);
            
        } catch (error) {
            console.error(`❌ Error processing ${artifactPath}:`, error.message);
        }
    }
    
    // Genera il file di export
    generateExportFile();
    console.log('🎉 Dart bindings generated successfully!');
}

function generateExportFile() {
    const files = fs.readdirSync(dartOutputDir);
    const exports = files
        .filter(file => file.endsWith('_contract.dart'))
        .map(file => `export '${file}' hide hexToBytes;`)
        .join('\n');

    const exportContent = `// GENERATED CODE - DO NOT MODIFY BY HAND
// Auto-generated exports for contract bindings

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart' as web3;

${exports}

// Re-export web3dart types with aliases to make them accessible
export 'package:web3dart/web3dart.dart';

/// Helper function to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) hex = hex.substring(2);
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}
`;

    fs.writeFileSync(path.join(dartOutputDir, 'contracts.dart'), exportContent);
}

// Esegui la generazione
generateBindings();