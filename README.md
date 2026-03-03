# Parresia Contract - Project Overview

A complete blockchain integration toolkit for **Signaling Smart Contracts**, built with TypeScript (Hardhat) and Dart SDK bindings.

## What This Project Does

This monorepo provides:

1. **Solidity Smart Contract** - A non-upgradable Signaling contract for storing/retrieving compressed signal data
2. **TypeScript Deployment Layer** - Hardhat scripts for contract compilation and deployment
3. **Dart SDK** - Type-safe bindings to interact with the contract from Dart applications
4. **Docker Support** - Containerized deployment for automation

---

## Project Structure

```
packages/
├── typescript/
│   └── signaling-contract/
│       ├── contracts/              # Solidity smart contracts
│       │   └── Signaling.sol
│       ├── ignition/modules/        # Hardhat deployment modules
│       │   └── DeploySignaling.ts
│       ├── scripts/                 # Build & deployment scripts
│       │   └── generate-dart-bindings.js
│       ├── test/                    # TypeScript tests
│       ├── hardhat.config.ts        # Hardhat configuration
│       ├── Dockerfile               # Docker container definition
│       └── package.json
│
└── contract_sdk/                    # Dart SDK for contract interaction
    ├── lib/
    │   ├── signaling_contract_extensions.dart    # Manual extensions (NOT generated)
    │   ├── signaling_contract_sdk.dart          # Main SDK export
    │   └── generated/                            # Auto-generated bindings
    │       ├── signaling_contract.dart
    │       ├── types.dart
    │       └── contracts.dart
    ├── test/                        # Integration tests
    ├── example/                     # Usage examples
    └── pubspec.yaml
```

---

## Key Features

### 1. Smart Contract (`Signaling.sol`)
- **Non-upgradable** - Fixed implementation (no proxy pattern)
- **Owner-based access** - Contract owner can set/retrieve signals
- **Data compression** - Supports storing compressed data (gzip)
- **Event logging** - Emits `SignalEmitted` events for on-chain monitoring

**Main Functions:**
- `setSignal(bytes calldata _signal)` - Store signal data
- `getSignal() → bytes` - Retrieve stored signal
- `owner() → address` - Get contract owner

### 2. Dart SDK
Provides type-safe Dart bindings to interact with the contract:

**Core Classes:**
- `SignalingContract` - Main contract binding
- `Web3Client` - Blockchain RPC connection
- `EthereumAddress` - Address type handling

**Extension Methods:**
- `setSignalCompressed(data)` - Compress data before storing
- `getSignalCompressed()` - Decompress retrieved data automatically
- `watchSignalEmitted()` - Listen to SignalEmitted events in real-time

### 3. Deployment
- Hardhat deployment module (`DeploySignaling.ts`)
- Automatic Dart binding generation from contract ABI
- Docker containerization for CI/CD pipelines

---

## Development Workflow

### Deploy the Contract

```bash
cd packages/typescript/signaling-contract

# Compile contract
npx hardhat compile

# Deploy to testnet/mainnet
npx hardhat ignition deploy ./ignition/modules/DeploySignaling.ts --network <network>
```

### Generate Dart Bindings

Bindings are auto-generated from the contract ABI:

```bash
npm run generate:dart
# Or via Docker
npm run docker:build
npm run docker:push -- <docker-username>
```

### Run Tests

**Dart Unit Tests:**
```bash
cd packages/contract_sdk
dart test
```

**TypeScript Tests:**
```bash
cd packages/typescript/signaling-contract
npm test
```

---

## Architecture Decisions

### Non-Upgradable Contract
- ✅ Simplifies security auditing
- ✅ Reduces complexity
- ❌ Cannot fix bugs after deployment
- **Status**: Stable as of Feb 2026

### Dart SDK Structure
- **Generated Code** (`lib/generated/`) - Auto-created from ABI, regenerated on contract changes
- **Manual Extensions** (`lib/signaling_contract_extensions.dart`) - Custom utilities, preserved across regenerations
- **Separation of Concerns** - Clear boundary between generated and manual code

### Type Safety
- ✅ Full web3dart integration
- ✅ No `dynamic` types (uses sealed classes, interfaces, generics)
- ✅ Compile-time type checking
- ✅ Better IDE support and autocomplete

---

## File Descriptions

| File | Purpose |
|------|---------|
| `Signaling.sol` | Core smart contract logic |
| `DeploySignaling.ts` | Deployment configuration |
| `generate-dart-bindings.js` | ABI → Dart code generation |
| `signaling_contract.dart` | Auto-generated contract binding |
| `signaling_contract_extensions.dart` | Manual helper methods & utilities |
| `signaling_contract_sdk.dart` | Main SDK export (public API) |
| `hardhat.config.ts` | Hardhat network & compiler settings |
| `Dockerfile` | Container definition for automation |

---

## Status (March 2026)

| Component | Status | Notes |
|-----------|--------|-------|
| Solidity Contract | ✅ Stable | Non-upgradable, fully tested |
| Deployment Scripts | ✅ Working | Hardhat Ignition configured |
| Dart SDK | ✅ Stable | Type-safe, auto-generated |
| Docker Build | ✅ Working | Builds and tags successfully |
| Docker Push | ⚠️ In Progress | Network issues, retry-able |

---

## Next Steps

1. **Contract Deployment** - Deploy to target network via Hardhat
2. **SDK Integration** - Use Dart SDK in applications
3. **Docker Distribution** - Push to Docker Hub for CI/CD use
4. **Documentation** - Add deployment guides per network

---

## Resources

- 📚 **Hardhat Docs**: https://hardhat.org/
- 📚 **web3dart Docs**: https://github.com/xclud/web3dart
- 📚 **Solidity Docs**: https://docs.soliditylang.org/
- 📦 **Contract ABI**: Auto-generated at `artifacts/contracts/Signaling.sol/Signaling.json`

---

*Last Updated: March 3, 2026*
