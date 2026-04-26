# Testing Instructions for Parresia Contract (Vite Blockchain)

## Overview

This project contains Signaling Contract tests for **Vite blockchain** (not EVM/Ethereum).

- **Vite Network Port**: `http://127.0.0.1:23456`
- **Build System**: 
  - TypeScript/Node.js for Vite smart contract (Solidity++)
  - Dart SDK for Vite integration

## Test Status

### ✅ Vite Tests (packages/vite)
```bash
npm test
```
**Status**: ✅ Passes compilation and structure validation
- Compiles Solidity++ contract successfully
- Validates ABI structure
- **Deployment tests**: Skipped when Vite node unavailable (show instructions instead)

**To run full tests with deployment**:
1. Start a local Vite node:
   ```bash
   npm run node
   ```
   Or set environment variable:
   ```bash
   export VITE_RPC_URL=http://your-vite-node:23456
   npm test
   ```

### ⚠️ Dart Tests (packages/contract_sdk)
```bash
cd packages/contract_sdk
dart test
```

**Status**: Tests configured for Vite (port 23456)
- **21/22 tests passing**
- 1 test skipped: Requires running Vite node at localhost:23456

**Note**: Dart tests use `web3dart` which is designed for Ethereum/EVM networks.
To run Dart tests against Vite, you need a **Vite node running**.

**To run Dart tests with Vite**:
1. Start Vite node from packages/vite:
   ```bash
   npm run node
   ```
2. Run Dart tests:
   ```bash
   cd packages/contract_sdk
   dart test
   ```

## Setup

### Prerequisites
- Node.js 14+
- Dart 3.0+
- Docker (optional, for Vite node)

### Install Dependencies

**Vite package**:
```bash
cd packages/vite
npm install
```

**Dart SDK**:
```bash
cd packages/contract_sdk
dart pub get
```

## Docker Support

To run Vite node in Docker (recommended on Windows):

```bash
# From project root or packages/vite
docker-compose up ganache  # or create appropriate Vite Docker setup
```

## File Structure

```
packages/
├── vite/                           # Vite smart contract
│   ├── contracts/Signaling.solpp  # Solidity++ contract
│   ├── scripts/
│   │   ├── test.js                # Vite compilation & tests
│   │   ├── deploy.js              # Deploy script
│   │   └── node.js                # Start local Vite node
│   └── package.json
│
└── contract_sdk/                   # Dart SDK for Vite
    ├── lib/                        # Generated Dart bindings
    ├── test/                       # Dart integration tests
    │   ├── signaling_contract_deploy_test.dart
    │   └── signaling_contract_deploy_method_test.dart
    └── pubspec.yaml
```

## Test Results Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Vite Compilation | ✅ Pass | Solidity++ compiles successfully |
| Vite Tests | ✅ Pass (with graceful fallback) | Shows instructions when node unavailable |
| Dart SDK Generation | ✅ Pass | Bindings auto-generated from ABI |
| Dart Integration Tests | ⚠️ Skipped | Requires Vite node at port 23456 |

## Troubleshooting

### "Vite node not available"
**Solution**: Start the Vite node first:
```bash
cd packages/vite
npm run node
```

### "Cannot connect to localhost:23456"
**Check**:
1. Is Vite node running? `npm run node` from packages/vite
2. On Windows? Try Docker: `docker-compose up`
3. Different machine? Set `VITE_RPC_URL` environment variable

### Dart test failures with "Can't connect"
**Cause**: web3dart expects EVM-compatible RPC endpoint
**Solution**: Ensure Vite node is running and reachable at configured URL

## Next Steps

1. **Run Vite tests**: `npm test` (from packages/vite)
2. **Start Vite node**: `npm run node` (from packages/vite)
3. **Run Dart tests**: `dart test` (from packages/contract_sdk)
4. **Deploy contract**: `npm run deploy-to-chain` (from packages/vite)
