# Contract SDK

A Dart SDK for interacting with blockchain smart contracts using web3dart. This package provides auto-generated type-safe bindings for Solidity contracts.

## Features

- 🔐 Type-safe contract bindings generated from Solidity ABIs
- 🚀 Easy-to-use API for contract interaction
- 📦 Built with web3dart for Ethereum/EVM compatibility
- 🔄 Auto-generated from TypeChain artifacts
- ✅ Comprehensive test coverage
- 📖 Well-documented examples

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  contract_sdk: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Create credentials
  final credentials = EthPrivateKey.fromHex('0x...');

  // Connect to contract
  final signaling = await SignalingContract.connect(
    rpcUrl: 'http://localhost:7545',
    contractAddress: EthereumAddress.fromHex('0x...'),
    credentials: credentials,
  );

  // Call contract functions
  final txHash = await signaling.setOffer(Uint8List.fromList(data));
  final offer = await signaling.getOffer(credentials.address);
}
```

## Contract Bindings

### SignalingContract

The main contract binding for the Signaling smart contract with UUPS upgrade pattern.

**Functions:**
- `setOffer(bytes offer)` - Set an offer
- `getOffer(address offerer)` - Get an offer
- `setAnswer(bytes answer, address offerer)` - Set an answer
- `getAnswer(address answerer, address offerer)` - Get an answer
- `initialize(address owner)` - Initialize the contract
- `transferOwnership(address newOwner)` - Transfer ownership
- `upgradeToAndCall(address newImplementation, bytes data)` - Upgrade contract

**Events:**
- `proposeOffer(address indexed offerer, Signal offer)`
- `proposeAnswer(address indexed offerer, address indexed answerer, Signal answer)`

## Development

### Setup

```bash
# Install dependencies
melos bootstrap

# Build contracts and generate bindings
melos run contracts:build

# Run tests
melos run test
```

### Testing

The SDK includes comprehensive tests:

- **Static Tests**: Validate ABI and bytecode structure
- **Integration Tests**: Test RPC connectivity with Ganache
- **Deployment Tests**: Test contract deployment and interaction

Run tests with:

```bash
dart test
```

## Testing with Ganache

Start a local Ganache instance with:

```bash
docker-compose up -d evm
```

Then run integration tests:

```bash
dart test test/ganache_integration_test.dart
dart test test/signaling_contract_deploy_test.dart
```

## License

This project is licensed under the LGPL-3.0 License - see [LICENSE](LICENSE) file for details.

## Support

For issues and questions, please open an issue on [GitHub](https://github.com/gualandi/parresia-contract/issues).
