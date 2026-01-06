# Signaling Contract SDK

[![Pub](https://img.shields.io/pub/v/signaling_contract_sdk.svg)](https://pub.dev/packages/signaling_contract_sdk)
[![License](https://img.shields.io/badge/license-LGPL--3.0-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/dart-3.0+-blue.svg)](https://dart.dev)

A type-safe Dart SDK for interacting with blockchain signaling smart contracts. This package provides auto-generated bindings for the Signaling contract, built on top of web3dart for seamless Ethereum/EVM compatibility.

## Features

- 🔐 **Type-safe contract bindings** - Auto-generated from Solidity ABIs
- 🚀 **Easy-to-use API** - Intuitive methods for contract interaction
- 📦 **EVM Compatible** - Works with Ethereum, Polygon, Arbitrum, and other EVM chains
- 🔄 **Auto-generated** - Bindings generated from TypeChain artifacts
- ✅ **Full deployment support** - Deploy and initialize contracts programmatically
- 📖 **Well-documented** - Comprehensive examples and API documentation
- 🧪 **Thoroughly tested** - 39+ test cases with full coverage

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  signaling_contract_sdk: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';
import 'dart:typed_data';

void main() async {
  // Create credentials
  final credentials = EthPrivateKey.fromHex('0x...');

  // Connect to existing contract
  final signaling = await SignalingContract.connect(
    rpcUrl: 'https://eth.public.blastapi.io',
    contractAddress: EthereumAddress.fromHex('0x...'),
    credentials: credentials,
  );

  // Set an offer (for WebRTC signaling)
  final offer = 'v=0\r\no=- ...'.codeUnits;
  final txHash = await signaling.setOffer(Uint8List.fromList(offer));
  print('Offer set! Tx: $txHash');

  // Retrieve an offer
  final storedOffer = await signaling.getOffer(credentials.address);
  print('Retrieved offer: $storedOffer');
}
```

## Contract Functions

### Main Functions

#### `setOffer(bytes offer)`
Store an offer for WebRTC signaling. Only callable by the offerer.

```dart
final offer = 'sdp_offer_data'.codeUnits;
await signaling.setOffer(Uint8List.fromList(offer));
```

#### `getOffer(address offerer)` 
Retrieve a stored offer from any user.

```dart
final offer = await signaling.getOffer(offererAddress);
print('Offer data: ${offer.signal}');
print('Created at: ${offer.creationTime}');
```

#### `setAnswer(bytes answer, address offerer)`
Set an answer in response to an offer.

```dart
final answer = 'sdp_answer_data'.codeUnits;
await signaling.setAnswer(Uint8List.fromList(answer), offererAddress);
```

#### `getAnswer(address answerer, address offerer)`
Retrieve a stored answer.

```dart
final answer = await signaling.getAnswer(answererAddress, offererAddress);
```

#### `initialize(address owner)`
Initialize the contract and set the owner (called after deployment).

```dart
await signaling.initialize(credentials.address);
```

### Admin Functions

- `transferOwnership(address newOwner)` - Transfer contract ownership
- `upgradeToAndCall(address newImplementation, bytes data)` - Upgrade contract (UUPS)

## Deployment

### Option 1: Deploy from Dart (Recommended for Testing)

```dart
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final credentials = EthPrivateKey.fromHex('0x...');
  
  // Deploy
  final contract = await SignalingContract.deploy(
    rpcUrl: 'http://localhost:8545',
    credentials: credentials,
  );
  
  print('Deployed to: ${contract.contract.address.eip55With0x}');
  
  // Initialize
  await contract.initialize(credentials.address);
  
  // Verify owner
  final owner = await contract.owner();
  print('Owner: ${owner.eip55With0x}');
}
```

### Option 2: Deploy with Hardhat (Production Recommended)

For production deployments with UUPS proxy support, use Hardhat from the TypeScript package:

```bash
cd packages/typescript/signaling-contract
npx hardhat run scripts/deploy.ts --network mainnet
```

## Events

The contract emits two events:

```dart
// Emitted when an offer is set
event proposeOffer(
  address indexed offerer,
  Signal offer
);

// Emitted when an answer is set  
event proposeAnswer(
  address indexed offerer,
  address indexed answerer,
  Signal answer
);
```

Listen to events:

```dart
final filter = FilterOptions.events(
  contract: DeployedContract(...),
  event: contractAbi.events.first,
);

client.events(filter).listen((event) {
  print('Event: $event');
});
```

## Supported Networks

This SDK works with any EVM-compatible blockchain:

- ✅ **Ethereum** (mainnet, Sepolia, Goerli)
- ✅ **Polygon** (mainnet, Mumbai)
- ✅ **Arbitrum** (mainnet, Sepolia)
- ✅ **Optimism** (mainnet, Sepolia)
- ✅ **Base** (mainnet)
- ✅ **BSC** (mainnet, testnet)
- ✅ **Ganache** (local development)

Just change the `rpcUrl` parameter to your target network's RPC endpoint.

## Development & Testing

### Setup

```bash
# Install dependencies
dart pub get

# Run analysis
dart analyze

# Run all tests
dart test
```

### Testing with Ganache (Local)

```bash
# Start Ganache
docker-compose up -d evm

# Run integration tests
dart test test/ganache_integration_test.dart
```

### Test Coverage

- 24 static validation tests (ABI & bytecode)
- 4 RPC connectivity tests
- 10 deployment & interaction tests
- 1 event test

All tests passing ✅

## API Documentation

Full API documentation is available on [pub.dev](https://pub.dev/documentation/signaling_contract_sdk/latest/).

## Examples

See the [example](example/) directory for complete working examples, including:

- Basic contract interaction
- Deployment and initialization
- Event listening
- Error handling

## License

This project is licensed under the **LGPL-3.0 License** - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or PR on [GitHub](https://github.com/gualandi/parresia-contract).

## Support

For issues, questions, or suggestions:

- 📝 Open an issue on [GitHub](https://github.com/gualandi/parresia-contract/issues)
- 💬 Check existing [discussions](https://github.com/gualandi/parresia-contract/discussions)
- 📧 Email: dev@parresia.dev

## Related Packages

- [`web3dart`](https://pub.dev/packages/web3dart) - Dart Ethereum client
- [`wallet`](https://pub.dev/packages/wallet) - Wallet utilities
