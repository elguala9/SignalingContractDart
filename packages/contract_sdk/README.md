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
  signaling_contract_sdk: ^2.0.0
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
// Method 1: Manually compress and set
final compressedData = SignalingDataCompression.compressData("raw data");
final txHash = await contract.setSignal(compressedData);

// Method 2: Automatic compression (recommended)
final txHash = await contract.setSignalCompressed("raw data");
```

### Get Signal

```dart
// Method 1: Get compressed signal
final signal = await contract.getSignal(offererAddress);
print('Compressed Data Length: ${(signal[0] as Uint8List).length}');
print('Creation Time: ${signal[1]}');

// Method 2: Get and automatically decompress
final decompressed = await contract.getSignalDecompressed(offererAddress);
print('Decompressed Data: $decompressed');
```

## Requirements

- Dart SDK >= 3.0.0
- web3dart >= 3.0.1

## Development

### Running Tests Locally

#### Prerequisites

1. **Start Hardhat Node** (in a separate terminal):
   ```bash
   cd ../typescript/signaling-contract
   npm run network
   ```

2. **Deploy Contract** (in another terminal):
   ```bash
   cd ../typescript/signaling-contract
   npm run deploySC | tee /tmp/deploy.log
   CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}')
   echo "Deployed at: $CONTRACT_ADDRESS"
   ```

3. **Run Tests**:
   ```bash
   export TEST_RPC_URL=http://localhost:8545
   export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
   export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
   dart test
   ```

### Running Tests in CI/CD

The contract SDK includes integration tests that require a deployed contract. To run tests in your CI/CD pipeline:

#### Step 1: Start Hardhat Node
```bash
cd packages/typescript/signaling-contract
npm run network > /tmp/hardhat.log 2>&1 &
sleep 8
```

#### Step 2: Deploy Contract
```bash
cd packages/typescript/signaling-contract
npm run deploySC 2>&1 | tee /tmp/deploy.log
```

#### Step 3: Extract Contract Address
```bash
CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | head -1)
echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS"
```

#### Step 4: Run Tests
```bash
cd packages/contract_sdk
export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
dart test -r expanded
```

#### GitHub Actions Example

Create `.github/workflows/dart-tests.yml`:

```yaml
name: Dart SDK Tests

on:
  push:
    branches: [ develop, main ]
    paths:
      - 'packages/contract_sdk/**'
      - 'packages/typescript/signaling-contract/**'
  pull_request:
    branches: [ develop, main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Setup Dart
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - name: Install Node dependencies
        run: |
          cd packages/typescript/signaling-contract
          npm install

      - name: Install Dart dependencies
        run: |
          cd packages/contract_sdk
          dart pub get

      - name: Start Hardhat network
        run: |
          cd packages/typescript/signaling-contract
          npm run network > /tmp/hardhat.log 2>&1 &
          sleep 8

      - name: Deploy contract
        run: |
          cd packages/typescript/signaling-contract
          npm run deploySC 2>&1 | tee /tmp/deploy.log
          CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | head -1)
          echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> $GITHUB_ENV

      - name: Run Dart tests
        run: |
          cd packages/contract_sdk
          export TEST_RPC_URL=http://localhost:8545
          export TEST_CONTRACT_ADDRESS=${{ env.CONTRACT_ADDRESS }}
          export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
          dart test -r expanded

      - name: Upload logs
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: test-logs
          path: /tmp/*.log
```

### Test Environment Variables

The following environment variables must be set to run integration tests:

| Variable | Required | Default | Example |
|----------|----------|---------|---------|
| `TEST_RPC_URL` | Yes | `http://localhost:8545` | RPC endpoint of test blockchain |
| `TEST_CONTRACT_ADDRESS` | Yes | `0x5FbDB2315678afecb333f8a9c91ff5f8b6e74aaf` | Deployed contract address |
| `TEST_PRIVATE_KEY` | Yes | None | Private key with sufficient balance |

**Default Values**: If environment variables are not set, the tests will use defaults for localhost Hardhat network. However, the private key must be provided or tests will be skipped.

### Test Structure

- `test/signaling_contract_deploy_test.dart` - Integration tests for deployed contracts
- `test/signaling_contract_deploy_method_test.dart` - Tests for the `deploy()` method

### Code Generation

Contract bindings are auto-generated from Solidity contracts. Do not modify generated files directly.

To regenerate bindings after contract changes:
```bash
cd ../typescript/signaling-contract
npm run build:dart
```

## License

See LICENSE file for details.

## Support

For issues and feature requests, visit the [GitHub repository](https://github.com/gualandi/parresia-contract/issues).
