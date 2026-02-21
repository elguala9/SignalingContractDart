# 🚀 Quick Start: Running Integration Tests

## One Command to Rule Them All

### On Linux/Mac:
```bash
cd /path/to/Contract
chmod +x scripts/run-integration-tests.sh
./scripts/run-integration-tests.sh
```

### On Windows:
```cmd
cd C:\path\to\Contract
scripts\run-integration-tests.bat
```

This will:
1. ✅ Start Ganache blockchain in Docker
2. ✅ Compile smart contracts
3. ✅ Deploy contracts to Ganache
4. ✅ Run Dart unit tests (14 tests)
5. ✅ Run Dart integration tests with event callbacks
6. ✅ Stop Ganache automatically

## What Gets Tested

### Unit Tests (14 tests)
- ✅ hexToBytes utility function
- ✅ Contract ABI validation
- ✅ Contract bytecode format
- ✅ Event structure (SignalEmitted)

### Integration Tests (5+ tests)
- ✅ Contract deployment verification
- ✅ Reading owner address
- ✅ Setting and getting signals
- ✅ **Event callback verification** - Tests that SignalEmitted event fires with correct data
- ✅ Authorization (credentials required for writes)

## Event Callback Test

The integration tests verify that events are properly emitted and received:

```dart
test('setSignal and getSignal round-trip with event verification', () async {
  // 1. Listen for SignalEmitted event
  eventStream.listen((event) {
    eventFired = true;  // ✅ Callback triggered!
    print('✓ SignalEmitted event received!');
  });

  // 2. Call setSignal
  await sdk.setSignal(signalBytes);

  // 3. Wait for event
  await Future.delayed(Duration(seconds: 3));

  // 4. Verify event was received
  expect(eventFired, isTrue);
});
```

## Deployment Details

After deployment, you'll see:
```
✅ Proxy deployed at: 0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf
✅ Implementation: 0x...
✅ ProxyAdmin: 0x...
✅ Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

Environment file created at: `.env.ganache`
```
TEST_RPC_URL=http://localhost:8545
TEST_CONTRACT_ADDRESS=0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf
TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
TEST_CHAIN_ID=1337
```

## Timing

- **First run:** ~40 seconds (Docker startup + deployment)
- **Subsequent runs:** ~20 seconds
- **Unit tests:** ~2 seconds
- **Integration tests:** ~15 seconds

## Files Created

```
📁 Contract/
  ├── docker-compose.yml (updated)
  ├── .env.ganache (auto-generated)
  ├── INTEGRATION_TESTS.md (detailed guide)
  ├── RUN_TESTS_QUICK_START.md (this file)
  ├── scripts/
  │   ├── deploy-to-ganache.ts (new)
  │   ├── run-integration-tests.sh (new)
  │   └── run-integration-tests.bat (new - Windows)
  └── deployments/
      └── ganache-deployment.json (auto-generated)
```

## Requirements

- Docker Desktop running
- Node.js 18+ and npm
- Dart SDK
- Port 8545 available (Ganache RPC)

## Troubleshooting

**Port 8545 already in use?**
```bash
docker stop parresia-contract-ganache
docker rm parresia-contract-ganache
```

**Docker not running?**
- Start Docker Desktop

**Tests fail with RPC error?**
- Check: `curl http://localhost:8545`
- View logs: `docker logs parresia-contract-ganache`

**Event tests timeout?**
- Normal if Ganache is slow
- Tests continue with data verification

## Next Steps

1. Run the integration tests: `./scripts/run-integration-tests.sh`
2. View detailed guide: `INTEGRATION_TESTS.md`
3. Modify tests in: `packages/contract_sdk/test/signaling_contract_deploy_test.dart`

## Test Output Example

```
✅ Contract address is valid: 0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf
✅ owner() returns a valid EthereumAddress
✅ setSignal and getSignal round-trip successful
✓ SignalEmitted event received!
✅ getSignal correctly returns empty signal for new address
✅ write methods throw when no credentials provided

All tests passed! ✨
```

---

**Need more details?** See `INTEGRATION_TESTS.md` for comprehensive documentation.
