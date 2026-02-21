# Integration Tests Guide

This guide explains how to run integration tests for the Signaling Contract using Docker and Ganache.

## Prerequisites

- Docker and Docker Compose installed
- Node.js 18+ and npm installed
- Dart SDK installed
- Bash shell (for running scripts)

## Quick Start

### Option 1: Run Everything with One Script (Recommended)

```bash
cd /path/to/Contract
chmod +x scripts/run-integration-tests.sh
./scripts/run-integration-tests.sh
```

This script will:
1. ✅ Start Ganache in Docker
2. ✅ Compile smart contracts
3. ✅ Deploy contracts to Ganache
4. ✅ Run Dart unit tests
5. ✅ Run Dart integration tests
6. ✅ Stop Ganache

### Option 2: Manual Setup

#### Step 1: Start Ganache

```bash
cd /path/to/Contract
docker-compose up -d ganache
```

Verify Ganache is running:
```bash
curl http://localhost:8545
# Should return a JSON response
```

#### Step 2: Compile and Deploy Contracts

```bash
cd packages/typescript/signaling-contract

# Compile contracts
npx hardhat compile

# Deploy to Ganache
npx hardhat run ../../scripts/deploy-to-ganache.ts --network ganache
```

This will output:
```
✅ Proxy deployed at: 0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf
📝 Environment file created: .env.ganache
```

#### Step 3: Setup Dart Environment

```bash
cd packages/contract_sdk
dart pub get
```

#### Step 4: Run Tests

Load environment variables and run tests:

```bash
# Load environment variables
export $(cat ../../.env.ganache | xargs)

# Run unit tests
dart test test/signaling_contract_test.dart

# Run integration tests
dart test test/signaling_contract_deploy_test.dart
```

#### Step 5: Stop Ganache

```bash
cd /path/to/Contract
docker-compose down
```

## Environment Variables

The deployment script creates a `.env.ganache` file with:

```bash
TEST_RPC_URL=http://localhost:8545
TEST_CONTRACT_ADDRESS=0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf
TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
TEST_CHAIN_ID=1337
```

## Ganache Details

- **RPC URL:** http://localhost:8545
- **Chain ID:** 1337
- **Accounts:** 20 pre-funded test accounts
- **Mnemonic:** `test test test test test test test test test test test junk`
- **Default Balance:** 1000 ETH per account
- **Network Name:** parresia-contract-network

### First Test Account (Deployer)

- **Address:** 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
- **Private Key:** 0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807

## Testing Events

The integration tests include event listener tests for the `SignalEmitted` event:

```dart
test('setSignal and getSignal round-trip with event verification', () async {
  // 1. Sets up event listener for SignalEmitted
  // 2. Calls setSignal to trigger the event
  // 3. Verifies the event was emitted with correct parameters
  // 4. Reads back the signal to verify data persistence
});
```

### Event Details

**SignalEmitted Event:**
```solidity
event SignalEmitted(
  address indexed sender,
  bytes signal,
  uint256 timestamp
);
```

**Test Flow:**
1. Creates test signal data
2. Subscribes to SignalEmitted event
3. Calls `setSignal()`
4. Waits for event (timeout: 3 seconds)
5. Verifies event was received with correct data
6. Reads signal back via `getSignal()` to confirm persistence

## Troubleshooting

### Ganache Won't Start

```bash
# Check if port 8545 is already in use
lsof -i :8545

# Stop the existing container
docker stop parresia-contract-ganache
docker rm parresia-contract-ganache

# Try again
docker-compose up -d ganache
```

### Contract Deployment Fails

```bash
# Check Ganache logs
docker logs parresia-contract-ganache

# Ensure contracts compile
cd packages/typescript/signaling-contract
npx hardhat compile
```

### Tests Fail with "Cannot reach RPC"

```bash
# Verify Ganache is running
docker ps | grep ganache

# Check RPC connectivity
curl http://localhost:8545 -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'

# Should return: {"jsonrpc":"2.0","result":"0x539","id":1}
```

### Event Listener Times Out

The event listener test has a 3-second wait period. This can happen if:
- Ganache is slow
- Network is congested
- Transaction is not being mined

The test will output a warning but continue with data verification:
```
⚠️  Event listening: timeout (continuing with data verification)
```

If this persists, check:
1. Ganache logs: `docker logs parresia-contract-ganache`
2. RPC connectivity: `curl http://localhost:8545`
3. Contract deployment: Ensure contract was deployed successfully

## Test Results

### Successful Run

```
✅ Unit tests (14 tests):
   - hexToBytes utility tests (6)
   - Contract binding tests (4)
   - Constants validation tests (2)
   - Event structure tests (2)

✅ Integration tests (5 tests):
   - Contract address validation
   - owner() function read
   - upgradeInterfaceVersion() read
   - proxiableUUID() read
   - setSignal/getSignal round-trip with event verification
   - getSignal for new address
   - Authorization checks
```

## Debugging

### Enable More Verbose Output

```bash
# Run tests with stack traces
dart test test/signaling_contract_deploy_test.dart --chain-stack-traces

# Run Ganache with debug logging
docker-compose up ganache  # (don't use -d to see logs)
```

### Inspect Contract State

```bash
# Connect to contract and inspect
npx hardhat console --network ganache

# In Hardhat console:
> const Signaling = await ethers.getContractFactory("Signaling");
> const sig = Signaling.attach("0x...");
> await sig.owner()
```

## Performance Notes

- First run: ~30-40 seconds (including Docker startup)
- Subsequent runs: ~15-20 seconds
- Unit tests: ~2 seconds
- Integration tests: ~15 seconds (includes blockchain interactions)

## CI/CD Integration

For GitHub Actions or similar CI systems:

```yaml
- name: Run Blockchain and Integration Tests
  run: |
    cd ${{ github.workspace }}
    chmod +x scripts/run-integration-tests.sh
    ./scripts/run-integration-tests.sh
```

## Additional Resources

- [Ganache Documentation](https://www.trufflesuite.com/ganache)
- [Hardhat Documentation](https://hardhat.org)
- [Dart Test Documentation](https://pub.dev/packages/test)
- [web3dart Documentation](https://pub.dev/packages/web3dart)
