# Signaling Contract SDK - Tests

This directory contains the test suite for the Signaling Contract SDK.

## Test Structure

### Unit Tests

- **signaling_contract_test.dart**: Tests for utility functions and contract bindings
  - Hex to bytes conversion
  - Contract ABI validation
  - Contract bytecode validation

### Integration Tests

- **signaling_contract_deploy_test.dart**: Integration tests for contract deployment and interaction
  - Requires a running blockchain node (Ganache, Hardhat, or testnet)
  - Tests are commented out by default
  - Uncomment to run against a live blockchain

## Running Tests

### Run all tests

```bash
dart test
```

### Run specific test file

```bash
dart test test/signaling_contract_test.dart
```

### Run with verbose output

```bash
dart test -v
```

### Run with code coverage

```bash
dart pub global activate coverage
dart pub global run coverage:test_with_coverage
```

## Integration Testing Setup

### Automated Integration Testing (Recommended)

The integration tests are now **fully automated**! A single command will:
1. Start Hardhat node
2. Deploy the contract
3. Run all integration tests
4. Clean up automatically

**Run all tests with:**
```bash
melos run test:integration
```

Or directly with bash:
```bash
bash scripts/test-integration.sh
```

### Manual Integration Testing

If you prefer to run tests manually:

1. **Start a local blockchain node**

   ```bash
   cd packages/typescript/signaling-contract
   npm run network
   ```

2. **In another terminal, deploy the contract**

   ```bash
   cd packages/typescript/signaling-contract
   npm run deploySC
   ```

3. **Run the tests** (the contract address is auto-detected from `token_info.txt`)

   ```bash
   cd packages/contract_sdk
   TEST_RPC_URL=http://localhost:8545 dart test test/signaling_contract_deploy_test.dart
   ```

## Test Coverage

Current test coverage includes:

- ✅ Hex to bytes conversion
- ✅ Contract ABI structure
- ✅ Contract bytecode format
- ✅ Function signatures (compile-time checks)
- ⏳ Contract deployment (requires running node)
- ⏳ Contract connection (requires running node)
- ⏳ Signal read/write operations (requires running node)

## Debugging Tests

To debug a specific test:

```bash
dart test --pause-after-load test/signaling_contract_test.dart
```

Then open the VM debugging interface in your IDE.

## CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Dart tests
  run: dart test
```

## Notes

- Unit tests run without external dependencies
- Integration tests require a running blockchain node
- Test timeouts may need adjustment based on block time
- Some tests may fail on slow networks or when nodes are congested
