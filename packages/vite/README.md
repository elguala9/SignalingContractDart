# Signaling Contract for Vite Blockchain (Solidity++)

This package contains the Signaling smart contract ported to the **Vite blockchain** using **Solidity++ 0.8.x** (`.solpp`).

## Overview

The Signaling contract allows users to store and retrieve compressed (gzip) signal data on-chain. Each address can store one signal at a time, with a creation timestamp.

### Key Features
- **Non-upgradable**: Direct deployment, no proxy pattern
- **Ownership**: Simple onlyOwner pattern (no OpenZeppelin dependency)
- **Gzip Validation**: Enforces proper gzip format (magic bytes: `0x1f 0x8b`)
- **Vite-native**: Uses Soliditypp 0.8.x syntax (compatible with Vite blockchain)

## Structure

```
contracts/
├── ISignaling.solpp    - Interface definition with Signal struct
└── Signaling.solpp     - Implementation contract
```

## Differences from Ethereum Version

| Feature | Ethereum (Solidity 0.8) | Vite (Soliditypp 0.8) |
|---|---|---|
| File extension | `.sol` | `.solpp` |
| Pragma | `pragma solidity ^0.8.24;` | `pragma soliditypp >=0.8.0;` |
| OpenZeppelin | ✅ Available | ❌ Not available (reimplemented) |
| Owner pattern | `Ownable` from OZ | Manual `_owner` + `onlyOwner()` |
| Gas model | ✅ Present | ❌ Removed |
| Transfer syntax | `payable(addr).transfer(amount)` | `payable(addr).transfer(tokenId, amount)` |

## Build

### Install dependencies
```bash
npm install
```

### Compile contracts
```bash
npm run compile
```

Output: ABI and bytecode for `Signaling` contract.

### Start local Vite node
```bash
npm run node
```

## Interface

### `ISignaling.solpp`

```solidity
struct Signal {
    bytes signal;           // Compressed signal data
    uint256 creationTime;   // Timestamp of creation
}

interface ISignaling {
    event SignalEmitted(address indexed sender, bytes signal, uint256 timestamp);

    function setSignal(bytes memory compressedSignal) external;
    function getSignal(address offerer) external view returns (Signal memory);
}
```

## Contract Functions

### `setSignal(bytes memory compressedSignal)`

Sets a signal for the caller (msg.sender).

**Requirements:**
- Signal must be at least 2 bytes long
- Signal must be in gzip format (magic bytes: `0x1f 0x8b`)

**Emits:** `SignalEmitted(msg.sender, compressedSignal, block.timestamp)`

### `getSignal(address offerer) view`

Retrieves the signal for a given address.

**Returns:** `Signal` struct (signal data + creation timestamp)

### `owner() view`

Returns the current owner address.

## Deployment

See the Ethereum version in `packages/typescript/signaling-contract` for deployment patterns. Adapt as needed for Vite's deployment model with `@vite/vuilder`.

## Solidity++ Documentation

- [Vite Docs - Solidity++ 0.8](https://docs.vite.org/soliditypp/index/)
- [GitHub - vitelabs/vuilder](https://github.com/vitelabs/vuilder)
- [GitHub - soliditypp-examples](https://github.com/vitelabs/soliditypp-examples)

## Notes

⚠️ **Alpha Status**: The Soliditypp 0.8.x toolchain (`@vite/vuilder`, `@vite/solppc`) is in active development. Do not use in production environments.
