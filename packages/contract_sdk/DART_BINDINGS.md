# Dart Bindings Documentation

This document describes the auto-generated Dart bindings for the Signaling smart contract.

## Overview

The `signaling_contract_sdk` package provides Dart bindings for the Signaling smart contract with:
- Type-safe contract interactions
- Auto-generated code from Solidity ABI
- Support for contract deployment and connection
- Web3 integration with `web3dart`

## Generated Classes

### SignalingContract

Main class for interacting with the Signaling smart contract.

#### Static Methods

##### `connect()`

Connects to an existing contract instance on the blockchain.

```dart
static Future<SignalingContract> connect({
  required String rpcUrl,
  required EthereumAddress contractAddress,
  EthPrivateKey? credentials,
})
```

**Parameters:**
- `rpcUrl`: The RPC endpoint URL (e.g., `http://localhost:8545`)
- `contractAddress`: The Ethereum address of the deployed contract
- `credentials`: Optional private key for signing transactions

**Returns:** A `SignalingContract` instance

**Example:**
```dart
final contract = await SignalingContract.connect(
  rpcUrl: 'https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY',
  contractAddress: EthereumAddress.fromHex('0x1234...'),
);
```

##### `deploy()`

Deploys a new instance of the contract.

```dart
static Future<SignalingContract> deploy({
  required String rpcUrl,
  required EthPrivateKey credentials,
  List<dynamic> constructorParams = const [],
})
```

**Parameters:**
- `rpcUrl`: The RPC endpoint URL
- `credentials`: Private key of the account deploying the contract
- `constructorParams`: Constructor parameters (owner address as first parameter)

**Returns:** A `SignalingContract` instance pointing to the newly deployed contract

**Example:**
```dart
final ownerAddress = EthereumAddress.fromHex('0x1234...');
final contract = await SignalingContract.deploy(
  rpcUrl: 'http://localhost:8545',
  credentials: EthPrivateKey.fromHex('0xABCD...'),
  constructorParams: [ownerAddress],
);
```

#### Contract Methods

These methods correspond to smart contract functions:

##### `getSignal(offererAddress)`

Retrieves the signal for a given address.

```dart
Future<Signal> getSignal(EthereumAddress offererAddress)
```

**Parameters:**
- `offererAddress`: The Ethereum address of the offerer

**Returns:** A `Signal` object containing:
- `compressedData`: Compressed signal data (Uint8List)
- `creationTime`: Timestamp when the signal was created (int)

**Example:**
```dart
final signal = await contract.getSignal(
  EthereumAddress.fromHex('0x5678...'),
);
print('Data: ${signal.compressedData}');
print('Created at: ${signal.creationTime}');
```

##### `setSignal(compressedData)`

Sets a signal for the caller.

```dart
Future<String> setSignal(Uint8List compressedData)
```

**Parameters:**
- `compressedData`: The compressed signal data to store

**Returns:** Transaction hash as a string

**Example:**
```dart
final data = Uint8List.fromList([1, 2, 3, 4, 5]);
final txHash = await contract.setSignal(data);
print('Transaction hash: $txHash');
```

## Data Types

### Signal Struct

Represents a signal stored in the contract:

```dart
class Signal {
  final Uint8List compressedData;
  final int creationTime;
}
```

## Event Handling

The contract emits events that can be listened to:

### `signalSetted` Event

Emitted when a signal is set.

```
event signalSetted(address indexed offerer, Signal offer)
```

To listen to events:

```dart
final events = contract.contract.event('signalSetted');
subscription = client.onLogReceived(eventFilter)
  .listen((log) {
    // Handle event
  });
```

## Error Handling

Common errors from contract interactions:

- `OwnableInvalidOwner`: Invalid owner address provided
- `OwnableUnauthorizedAccount`: Account not authorized for the operation
- `TransactionException`: Error during transaction execution

Example error handling:

```dart
try {
  await contract.setSignal(data);
} catch (e) {
  print('Error setting signal: $e');
}
```

## Tips

1. **Always use checksummed addresses**: Convert addresses to checksum format
   ```dart
   final addr = EthereumAddress.fromHex('0x...');
   ```

2. **Handle async operations**: All contract operations are async
   ```dart
   final result = await contract.setSignal(data);
   ```

3. **Gas estimation**: Use web3dart's built-in gas estimation
   ```dart
   final gas = await contract.estimateGas('setSignal', [data]);
   ```

4. **Network selection**: Verify RPC URL matches your target network
   - Local: `http://localhost:8545`
   - Sepolia: `https://sepolia.infura.io/v3/YOUR_API_KEY`
   - Mainnet: `https://mainnet.infura.io/v3/YOUR_API_KEY`

## Code Generation

These bindings are auto-generated from the Solidity ABI. Do not manually modify:
- `lib/generated/signaling_contract.dart`
- `lib/generated/contracts.dart`

To regenerate bindings after contract changes, follow your build system's code generation process.
