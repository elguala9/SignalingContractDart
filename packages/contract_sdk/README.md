# Signaling Contract SDK

Type-safe Dart SDK for blockchain signaling smart contracts with auto-generated bindings, Ethereum/EVM support, and comprehensive deployment utilities.

## Features

- 🔐 **Type-Safe Bindings**: Auto-generated Dart bindings for Signaling smart contracts
- 🌐 **EVM Compatible**: Full Ethereum Virtual Machine (EVM) support
- 🚀 **Easy Deployment**: Simplified contract deployment utilities
- 📦 **Web3 Integration**: Built on top of `web3dart` for seamless Web3 interactions
- ✨ **Auto-Generated Code**: Contract bindings automatically generated from Solidity ABIs

## Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  signaling_contract_sdk: ^1.0.2
```

## Quick Start

### Connect to Existing Contract

```dart
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';

final contract = await SignalingContract.connect(
  rpcUrl: 'http://localhost:8545',
  contractAddress: EthereumAddress.fromHex('0x...'),
);
```

### Deploy New Contract

```dart
import 'package:web3dart/web3dart.dart';
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';

final contract = await SignalingContract.deploy(
  rpcUrl: 'http://localhost:8545',
  credentials: EthPrivateKey.fromHex('0x...'),
  constructorParams: [ownerAddress],
);
```

### Set Signal

```dart
final txHash = await contract.setSignal(
  compressedData: Uint8List.fromList([...]),
);
```

### Get Signal

```dart
final signal = await contract.getSignal(offererAddress);
print('Compressed Data: ${signal.compressedData}');
print('Creation Time: ${signal.creationTime}');
```

## Requirements

- Dart SDK >= 3.0.0
- web3dart >= 3.0.1

## Development

### Running Tests

```bash
dart test
```

### Code Generation

Contract bindings are auto-generated from Solidity contracts. Do not modify generated files directly.

## License

See LICENSE file for details.

## Support

For issues and feature requests, visit the [GitHub repository](https://github.com/gualandi/parresia-contract/issues).
