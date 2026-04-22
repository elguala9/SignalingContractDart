# Vite Contract SDK

Dart SDK for interacting with the Signaling smart contract on the Vite blockchain.

## Overview

This package provides type-safe Dart bindings for the Signaling contract deployed on Vite. It's automatically generated from the contract ABI and bytecode.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vite_contract_sdk:
    path: ../vite_contract_sdk
```

Then run:

```bash
dart pub get
```

## Usage

### Connect to Contract

```dart
import 'package:vite_contract_sdk/vite_contract_sdk.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

final client = Web3Client('https://vite-rpc.com', http.Client());

final contract = await SignalingContract.connectWithClient(
  client: client,
  contractAddress: EthereumAddress.fromHex('0x...'),
);
```

### Read Methods

```dart
// Get signal for an address
final signal = await contract.getSignal(offerer);
print(signal.signal);      // Uint8List
print(signal.creationTime); // BigInt
```

### Write Methods

```dart
// Set a signal (requires credentials)
final txHash = await contract.setSignal(
  compressedSignal,
  credentials: credentials,
);
```

### Deploy Contract

```dart
final deployTxHash = await SignalingContract.deploy(
  client: client,
  credentials: deployerCredentials,
  initialOwner: ownerAddress,
);
```

## Generated Code

The Dart bindings are **auto-generated** from the Solidity contract. To regenerate after contract changes:

```bash
cd packages/vite
npm run build:sdk
```

## Dependencies

- `web3dart` - Ethereum/blockchain client for Dart
- `wallet` - Wallet utilities
- `http` - HTTP client

## License

LGPL-3.0-or-later
