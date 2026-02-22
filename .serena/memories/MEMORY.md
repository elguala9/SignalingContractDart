# Parresia Contract - Project Memory

## GZip Compression Implementation (Feb 22, 2026) ✅ FULLY TESTED

### Implementation Summary
**All Tests Passing**: 15 unit tests + 9 integration tests ✅

**Solidity Contract (Signaling.sol)**:
- ✅ setSignal() validates gzip format (magic bytes 0x1f 0x8b)
- ✅ Requires minimum 2 bytes for gzip header
- ✅ Rejects non-gzip data with error

**Dart SDK Enhancements**:
1. **signaling_contract.dart** (auto-generated):
   - ✅ Now includes chainId field
   - ✅ connectWithClient() fetches chainId automatically from network
   - ✅ All write methods pass chainId for EIP-155 signing

2. **signaling_contract_extensions.dart**:
   - ✅ SignalingDataCompression utility class
   - ✅ setSignalCompressed() method for automatic compression
   - ✅ Compression/decompression utilities

3. **generate-dart-bindings.js** (updated):
   - ✅ Template now includes chainId field
   - ✅ connectWithClient() fetches and resolves chainId
   - ✅ All transaction calls pass chainId: chainId

### Test Coverage ✅
**Unit Tests (15/15 PASS)**:
- Contract utilities and binding validation
- Event structure validation

**Integration Tests (9/9 PASS)**:
1. Contract address validation ✅
2. owner() retrieval ✅
3. Non-upgradable verification ✅
4. **setSignal/getSignal round-trip with compression** ✅
5. getSignal for new address ✅
6. **SignalEmitted event callback capture** ✅
7. Write method authorization ✅
8. **setSignalCompressed with automatic gzip** ✅
9. **Compression utility functions** ✅

### Key Fixes Applied
- ✅ EIP-155 transaction signing (chainId passed to all write operations)
- ✅ Tests updated to use compressed data
- ✅ Generator script updated for chainId support
- ✅ Automatic chainId fetching from network

### Example Usage
```dart
// Automatic compression + validation
final txHash = await sdk.setSignalCompressed("raw data");

// Manual if needed
final compressed = SignalingDataCompression.compressData(data);
await sdk.setSignal(compressed);

// Decompress (client-side)
final decompressed = SignalingDataCompression.decompressToString(bytes);
```

## GZip Compression Implementation - DEPRECATED (Feb 22, 2026)
**Solidity Contract Updates**:
- `setSignal()` in Signaling.sol now validates gzip format (magic bytes 0x1f 0x8b)
- Requires minimum 2 bytes for gzip header
- Rejects data that doesn't match gzip format with descriptive error

**Dart Extensions (signaling_contract_extensions.dart)**:
- Added `SignalingDataCompression` utility class with:
  - `compressData(data)` - compress String/Uint8List/List<int> to gzip
  - `decompressData(compressedData)` - decompress gzip data
  - `decompressToString(compressedData)` - decompress to String
  - `isGzipFormat(data)` - validate gzip magic bytes (0x1f, 0x8b)
- Added `setSignalCompressed()` extension method on SignalingContract:
  - Takes uncompressed data (String or Uint8List)
  - Automatically compresses using gzip before sending
  - No manual compression needed by caller

**Tests Added** in signaling_contract_deploy_test.dart:
- `setSignalCompressed automatically compresses data and validates gzip` - end-to-end
- `gzip compression utility functions work correctly` - unit tests
- Verifies compression ratio, gzip format validation, and round-trip decompression

**Example Usage**:
```dart
// Automatic compression - simplest way
final txHash = await sdk.setSignalCompressed("raw uncompressed data");

// Manual compression if needed
final compressed = SignalingDataCompression.compressData(data);
await sdk.setSignal(compressed);

// Decompression (client-side only)
final decompressed = SignalingDataCompression.decompressToString(compressedBytes);
```

**Key Implementation Details**:
- Uses Dart's built-in `dart:io` GZipCodec for compression
- All compression happens client-side before sending to contract
- Contract validates format but doesn't decompress (saves gas)
- Backward compatible: setSignal() still works with pre-compressed data
- Updated example/main.dart with Example 4: compression usage demo

---

## Test Suite Updates - Integration Tests Implementation (✅ Completata - 2026-02-21)

### Step 1: Fixed Stale Unit Tests ✅

**File**: `packages/contract_sdk/test/signaling_contract_test.dart`

**Changes made**:
- Updated "Signaling Contract Binding" group:
  - `contains('getSignal')` → `contains('getOffer')`
  - `contains('setSignal')` → `contains('setOffer')`
  - Added checks for `getAnswer` and `setAnswer`
  
- Updated "Contract ABI contains required events":
  - `contains('signalSetted')` → `contains('proposeOffer')` and `contains('proposeAnswer')`
  
- Fixed "Event Listening" group:
  - Replaced stale `signalSetted` event checks with `proposeOffer` and `proposeAnswer`
  - Updated parameter checks: `compressedData` → `signal`
  - Added proper checks for offerer and answerer indexed parameters

**Result**: ✅ All 15 unit tests PASS

### Step 2: Rewrote Integration Tests ✅

**File**: `packages/contract_sdk/test/signaling_contract_deploy_test.dart`

**Key changes**:
- Rewritten to use `SignalingContract.connect()` SDK class instead of raw `DeployedContract`
- Added `package:wallet/wallet.dart` import (required for EthereumAddress type)
- Implemented 8 comprehensive round-trip tests using SDK methods

**New test suite includes**:

1. ✅ Contract address validation
2. ✅ `owner()` read method - returns valid EthereumAddress
3. ✅ `upgradeInterfaceVersion()` - returns "5.0.0"
4. ✅ `proxiableUUID()` - returns ERC1967 slot hash
5. ✅ **setOffer/getOffer round-trip** - write→read cycle with signal bytes
6. ✅ **setAnswer/getAnswer round-trip** - write→read cycle with answer bytes  
7. ✅ **Error handling** - setAnswer throws when no prior offer exists
8. ✅ **Authorization** - write methods throw when no credentials provided

**Setup requirements**:
- `TEST_RPC_URL` - environment variable (defaults to http://localhost:8545)
- `TEST_CONTRACT_ADDRESS` - environment variable (required)
- `TEST_PRIVATE_KEY` - environment variable (required) 

**Key features**:
- Uses `SignalingContract.connect()` from SDK to connect to existing contract
- Credentials are required for write operations (checked by SDK)
- Tests include detailed debug output with emoji indicators
- Graceful skip of setup when private key not provided
- Proper async/await handling with delays for transaction mining

### SDK Library Changes ✅

**File**: `packages/contract_sdk/lib/generated/signaling_contract.dart`

Added re-exports for web3dart types:
```dart
export 'package:web3dart/web3dart.dart' show Web3Client, EthereumAddress, EthPrivateKey;
```

This enables proper type resolution in tests.

### Test Coverage

- **Unit tests**: 15 tests ✅ PASSING
- **Integration tests**: 8 tests (require blockchain)
  - Can be run with: `TEST_RPC_URL=... TEST_CONTRACT_ADDRESS=... TEST_PRIVATE_KEY=... dart test test/signaling_contract_deploy_test.dart`
- **All stale references fixed**: No more references to getSignal/setSignal/signalSetted/compressedData

### How to Run Tests

```bash
# Unit tests (no blockchain needed)
cd packages/contract_sdk
dart test test/signaling_contract_test.dart

# Integration tests (requires blockchain + environment variables)
TEST_RPC_URL=http://localhost:8545 \
TEST_CONTRACT_ADDRESS=<deployed_contract_address> \
TEST_PRIVATE_KEY=<hardhat_account_0_key> \
dart test test/signaling_contract_deploy_test.dart

# Or use the automated script from root
melos run test:integration
```

### Stack

- **Blockchain**: Hardhat node (via automated script)
- **Test Framework**: Dart test package
- **SDK**: web3dart 3.0.1 + wallet 0.0.14
- **Imports Required**: 
  - `package:web3dart/web3dart.dart` 
  - `package:wallet/wallet.dart` (provides EthereumAddress)
  - `package:signaling_contract_sdk/generated/contracts.dart`

### Testing Notes

- Tests use `late` variables initialized in `setUpAll()`
- Async operations (write methods) include 1-2 second delays for transaction mining
- Error testing verifies both contract reverts and SDK credential checks
- All debug output uses print() with emoji indicators for easy troubleshooting

## Test Suite Enhancements - SignalEmitted Event Callback Testing (✅ 2026-02-21)

### Changes Made:

**File**: `packages/contract_sdk/test/signaling_contract_deploy_test.dart`

#### 1. **Enhanced Event Callback in setSignal/getSignal Test**
- Now properly captures event parameters in callback:
  - `capturedSender` (EthereumAddress)
  - `capturedSignal` (Uint8List)
  - `capturedTimestamp` (BigInt)
- Validates all parameters match expected values:
  - Sender matches caller address
  - Signal matches input bytes
  - Timestamp is positive
- Better error handling in callback with try-catch

#### 2. **Added Dedicated SignalEmitted Event Callback Test**
New test: `'SignalEmitted event callback captures event parameters correctly'`
- Focuses exclusively on event callback testing
- Verifies callback is invoked for each event emission
- Validates all three indexed/non-indexed parameters captured correctly
- Tests callback error handling and error stream
- Provides detailed debug output showing callback invocation

### Test Coverage Now Includes:

✅ **Unit tests (15 tests)** - All PASS
- Contract utilities
- Contract binding validation
- Event structure validation

✅ **Integration tests (9 tests)** - With enhanced event testing:
1. Contract address validation
2. `owner()` function
3. `upgradeInterfaceVersion()`
4. `proxiableUUID()` 
5. **setSignal/getSignal with enhanced event callback**
6. **NEW: SignalEmitted event callback parameter capture**
7. getSignal for new address
8. Error handling (no prior offer)
9. Authorization checks

### How to Run Tests:

```bash
# Unit tests only (no blockchain needed)
cd packages/contract_sdk
dart test test/signaling_contract_test.dart

# Integration tests (requires blockchain)
./scripts/run-integration-tests.sh

# Or manually with environment variables
cd packages/contract_sdk
TEST_RPC_URL=http://localhost:8545 \
TEST_CONTRACT_ADDRESS=0x... \
TEST_PRIVATE_KEY=0x... \
dart test test/signaling_contract_deploy_test.dart
```

### Event Callback Testing Details:

**SignalEmitted Event Structure:**
```solidity
event SignalEmitted(address indexed sender, bytes signal, uint256 timestamp)
```

**Callback Implementation:**
- Uses web3dart's `events()` filter with event listener
- Callback receives `event.parameters[0]` (sender), `[1]` (signal), `[2]` (timestamp)
- Validates all parameters in callback before recording success
- Tests include proper cleanup with subscription.cancel()
