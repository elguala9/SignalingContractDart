# Deploy Guide

## CryptoAlgorithmRegistry Deployment

### Using Hardhat (TypeScript)

1. **Setup Hardhat Project** (se non già fatto)

```bash
cd packages/typescript/signaling-contract
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox
```

2. **Create Deployment Script**

Create `ignition/modules/DeployCryptoRegistry.ts`:

```typescript
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CryptoRegistryModule = buildModule("CryptoRegistryModule", (m) => {
  const registry = m.contract("CryptoAlgorithmRegistry");
  return { registry };
});

export default CryptoRegistryModule;
```

3. **Deploy**

```bash
# Deploy to local network
npx hardhat node  # In una terminal
npx hardhat ignition deploy ./ignition/modules/DeployCryptoRegistry.ts --network localhost

# Deploy to testnet (Sepolia)
npx hardhat ignition deploy ./ignition/modules/DeployCryptoRegistry.ts --network sepolia

# Deploy to mainnet
npx hardhat ignition deploy ./ignition/modules/DeployCryptoRegistry.ts --network mainnet
```

4. **Get Contract Address**

After deployment, note the contract address from the output:
```
Deployed CryptoAlgorithmRegistry to: 0x...
```

5. **Get Contract ABI**

The ABI will be in:
```
artifacts/contracts/CryptoAlgorithmRegistry.sol/CryptoAlgorithmRegistry.json
```

Copy the `abi` array from this file.

## Using with Dart SDK

```dart
import 'package:contract_sdk/contract_sdk.dart';
import 'package:web3dart/web3dart.dart';

void main() async {
  // Replace with your deployed contract address
  final contractAddress = EthereumAddress.fromHex('0x...');
  
  // Replace with your contract ABI (from artifacts)
  final contractAbi = '''[...]''';
  
  // Connect
  final registry = await CryptoAlgorithmRegistry.connect(
    rpcUrl: 'https://sepolia.infura.io/v3/YOUR_PROJECT_ID',
    contractAddress: contractAddress,
    contractAbi: contractAbi,
    credentials: EthPrivateKey.fromHex('YOUR_PRIVATE_KEY'),
  );
  
  // Use it!
  await registry.storeAlgorithm(
    name: 'RSA',
    version: '1.0',
    language: 'python',
    sourceCode: 'def encrypt(): pass',
  );
}
```

## Cost Estimates

### Ethereum Mainnet (at 50 gwei, ETH @ $3,500)

| Operation | Gas | Cost (USD) |
|-----------|-----|------------|
| Deploy Contract | ~2,000,000 | ~$350 |
| Store Small Algorithm (1KB) | ~625,000 | ~$110 |
| Store Medium Algorithm (5KB) | ~3,125,000 | ~$550 |
| Store Large Algorithm (10KB) | ~6,250,000 | ~$1,100 |
| Get Algorithm | ~100,000 | Free (read-only) |
| List Algorithms | ~50,000 | Free (read-only) |
| Verify Integrity | ~30,000 | Free (read-only) |

### Layer 2 (Arbitrum/Optimism)

Costs are typically 10-100x cheaper:
- Store 5KB algorithm: ~$5-50 USD
- Deploy contract: ~$3-35 USD

### Recommendations

1. **Use Layer 2** for lower costs while maintaining security
2. **Compress code** before uploading to reduce size
3. **Split large algorithms** into multiple smaller contracts
4. **Use IPFS + hash** for very large codebases (trade-off: not fully on-chain)

## Network Configuration

### Testnet (Sepolia)

```typescript
// hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY]
    }
  }
};
```

### Mainnet

```typescript
mainnet: {
  url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
  accounts: [PRIVATE_KEY],
  gasPrice: 50000000000, // 50 gwei
}
```

### Layer 2 (Arbitrum)

```typescript
arbitrum: {
  url: "https://arb1.arbitrum.io/rpc",
  accounts: [PRIVATE_KEY]
}
```

## Security Best Practices

⚠️ **NEVER commit private keys to git!**

Use environment variables:
```bash
export PRIVATE_KEY="0x..."
export INFURA_API_KEY="..."
```

Or use `.env` file (add to .gitignore):
```
PRIVATE_KEY=0x...
INFURA_API_KEY=...
```

## Verify Contract on Etherscan

```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```

## Getting Free Testnet ETH

- Sepolia: https://sepoliafaucet.com/
- Goerli: https://goerlifaucet.com/

## Next Steps

1. Deploy to testnet first
2. Test all functionality
3. Get contract audited (for mainnet)
4. Deploy to mainnet
5. Verify on Etherscan
6. Update your Dart apps with the new contract address
