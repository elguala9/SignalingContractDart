# Quick Start Guide

Get started with the Contract SDK in 5 minutes!

## Prerequisites

- Dart SDK 3.0 or higher
- An Ethereum wallet with some test ETH (for testnet)
- Infura or Alchemy API key (optional, for remote RPC)

## Installation

### 1. Clone the repository

```bash
cd /path/to/your/project
```

### 2. Add dependency

In your `pubspec.yaml`:

```yaml
dependencies:
  contract_sdk:
    path: ../Contract/packages/contract_sdk
  web3dart: ^2.7.3
```

### 3. Install dependencies

```bash
dart pub get
```

## Quick Example: Signaling Contract

```dart
import 'package:contract_sdk/contract_sdk.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

void main() async {
  // 1. Setup connection
  final signaling = await SignalingContract.connect(
    rpcUrl: 'http://localhost:8545', // or use Infura
    contractAddress: EthereumAddress.fromHex('0xYourContractAddress'),
    contractAbi: '''
    [
      {
        "inputs": [{"internalType": "bytes","name": "offer","type": "bytes"}],
        "name": "setOffer",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [{"internalType": "address","name": "offerer","type": "address"}],
        "name": "getOffer",
        "outputs": [{"components": [{"internalType": "bytes","name": "signal","type": "bytes"},{"internalType": "uint256","name": "creationTime","type": "uint256"}],"internalType": "struct Signal","name": "","type": "tuple"}],
        "stateMutability": "view",
        "type": "function"
      }
    ]
    ''',
    credentials: EthPrivateKey.fromHex('0xYourPrivateKey'),
  );

  // 2. Send an offer
  final offerData = Uint8List.fromList('Hello Blockchain!'.codeUnits);
  final txHash = await signaling.setOffer(offerData);
  print('✅ Offer sent! TX: $txHash');

  // 3. Read an offer
  final offer = await signaling.getOffer(
    EthereumAddress.fromHex('0xSomeAddress'),
  );
  
  if (offer != null) {
    print('📨 Offer received: ${offer.signalAsString}');
  }

  // 4. Cleanup
  signaling.dispose();
}
```

## Quick Example: Algorithm Registry

```dart
import 'package:contract_sdk/contract_sdk.dart';
import 'package:web3dart/web3dart.dart';

void main() async {
  // 1. Connect to registry
  final registry = await CryptoAlgorithmRegistry.connect(
    rpcUrl: 'http://localhost:8545',
    contractAddress: EthereumAddress.fromHex('0xYourRegistryAddress'),
    contractAbi: '[...]', // Get from artifacts
    credentials: EthPrivateKey.fromHex('0xYourPrivateKey'),
  );

  // 2. Upload an algorithm
  final pythonCode = '''
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
  ''';

  print('📤 Uploading Fibonacci algorithm...');
  final txHash = await registry.storeAlgorithm(
    name: 'Fibonacci',
    version: '1.0',
    language: 'python',
    sourceCode: pythonCode,
  );
  print('✅ Uploaded! TX: $txHash');

  // Wait for confirmation (in production, use proper block confirmation)
  await Future.delayed(Duration(seconds: 15));

  // 3. Download and verify
  print('\n📥 Downloading Fibonacci algorithm...');
  final algorithm = await registry.downloadAndVerify('Fibonacci');
  
  if (algorithm != null) {
    print('✅ Algorithm verified!');
    print('Name: ${algorithm.name}');
    print('Version: ${algorithm.version}');
    print('Language: ${algorithm.language}');
    print('Author: ${algorithm.author.hex}');
    print('\nCode:\n${algorithm.sourceCode}');
  }

  // 4. List all algorithms
  print('\n📚 All algorithms:');
  final allAlgorithms = await registry.listAlgorithms();
  for (final name in allAlgorithms) {
    print('  - $name');
  }

  registry.dispose();
}
```

## Environment Setup

### Local Development (Hardhat)

1. Start local blockchain:
```bash
cd packages/typescript/signaling-contract
npx hardhat node
```

2. Deploy contracts:
```bash
npx hardhat ignition deploy ./ignition/modules/DeploySignaling.ts --network localhost
```

3. Use the deployed address in your Dart code

### Testnet (Sepolia)

1. Get free test ETH: https://sepoliafaucet.com/

2. Update your code:
```dart
rpcUrl: 'https://sepolia.infura.io/v3/YOUR_PROJECT_ID'
```

3. Deploy to Sepolia:
```bash
npx hardhat ignition deploy ./ignition/modules/DeploySignaling.ts --network sepolia
```

## Common Issues

### Issue: "Insufficient funds"
**Solution:** Make sure your wallet has enough ETH (or test ETH for testnets)

### Issue: "Contract ABI not found"
**Solution:** Compile contracts first with `npx hardhat compile`, then get ABI from `artifacts/`

### Issue: "Transaction reverted"
**Solution:** Check if:
- You're calling the right function
- Parameters are correct
- You have enough gas
- Contract is deployed on the network you're using

### Issue: "Connection timeout"
**Solution:** Check your RPC URL and internet connection. Try Infura or Alchemy if local node is down.

## Next Steps

- Read the [full documentation](README.md)
- Check [deployment guide](DEPLOY.md) for production
- Explore [examples](packages/contract_sdk/lib/src/example.dart)
- Review [smart contracts](contracts/)
- Join our community for support

## Getting Help

- Create an issue on GitHub
- Check existing issues and discussions
- Read the FAQ in README.md

## Security Notes

⚠️ **IMPORTANT:**
- Never commit private keys to git
- Use environment variables for sensitive data
- Test on testnet before mainnet
- Always verify code integrity after download
- Use hardware wallets for high-value operations

Happy coding! 🚀
