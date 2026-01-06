# web3dart 3.0.1 Compatibility Guide

## Problem: "Invalid signature v value" Error

### Symptoms
When calling `SignalingContract.deploy()` with web3dart 3.0.1 and Ganache, you may encounter:
```
FormatException: Invalid signature v value
Invalid signature v value: ...
```

### Root Cause
web3dart 3.0.1 requires explicit transaction configuration for Ganache compatibility:

1. **Legacy Transaction Format Issues**
   - Old code used simple `Transaction(from: addr, data: bytecode)`
   - This didn't specify gas pricing or chain ID
   - web3dart 3.0.1 defaults to legacy format, causing signature issues

2. **Missing Chain ID**
   - Transactions weren't signed with the correct chain ID (1337 for Ganache)
   - This causes signature v value mismatches

3. **Gas Configuration**
   - No explicit gas limit or pricing
   - Leads to unpredictable transaction validation

## Solution: Use EIP-1559 with Explicit Chain ID

### Changes Made

#### Before (Broken)
```dart
static Future<SignalingContract> deploy({
  required String rpcUrl,
  required EthPrivateKey credentials,
}) async {
  final transaction = Transaction(
    from: credentials.address,
    data: hexToBytes(contractBytecode),
  );
  
  final txHash = await client.sendTransaction(credentials, transaction);
  // ❌ Missing: chainId, gas params, EIP-1559 format
}
```

#### After (Fixed)
```dart
static Future<SignalingContract> deploy({
  required String rpcUrl,
  required EthPrivateKey credentials,
  int? chainId,  // ✅ New parameter for flexibility
}) async {
  final bytecodeData = hexToBytes(contractBytecode.startsWith('0x') 
      ? contractBytecode.substring(2) 
      : contractBytecode);
  
  // ✅ Use EIP-1559 format
  final gasPrice = EtherAmount.fromInt(EtherUnit.gwei, 2);
  
  final transaction = Transaction(
    from: credentials.address,
    data: bytecodeData,
    maxGas: 8000000,                    // ✅ Explicit gas limit
    maxFeePerGas: gasPrice,             // ✅ EIP-1559: base fee
    maxPriorityFeePerGas: gasPrice,     // ✅ EIP-1559: priority fee
  );

  // ✅ Send with explicit chainId
  final txHash = await client.sendTransaction(
    credentials, 
    transaction,
    chainId: chainId ?? 1337,  // Default to Ganache chain ID
  );
}
```

### Key Changes

| Aspect | Before | After |
|--------|--------|-------|
| **Transaction Type** | Legacy (implicit) | EIP-1559 (explicit) |
| **Gas Pricing** | None specified | `maxFeePerGas` + `maxPriorityFeePerGas` |
| **Chain ID** | Not specified | Explicit (default: 1337) |
| **Gas Limit** | Auto-estimated | Explicit (8M) |
| **Bytecode Handling** | Direct | 0x prefix stripped |

## Testing

### Test Coverage
The fix is validated by:
- ✅ `test/signaling_contract_deploy_test.dart` - Full integration test
- ✅ Ganache deployment to http://localhost:7545
- ✅ Transaction receipt verification
- ✅ Contract code verification
- ✅ Contract initialization

### Running Tests
```bash
# Start Ganache
docker-compose up -d evm

# Run deployment tests
cd packages/contract_sdk
dart test test/signaling_contract_deploy_test.dart
```

Expected output:
```
00:05 +8: All tests passed!
```

## Configuration for Different Networks

### Ganache (Local Development)
```dart
final contract = await SignalingContract.deploy(
  rpcUrl: 'http://localhost:7545',
  credentials: myCredentials,
  // chainId: 1337,  // Optional, this is the default
);
```

### Sepolia Testnet
```dart
final contract = await SignalingContract.deploy(
  rpcUrl: 'https://sepolia.infura.io/v3/YOUR_KEY',
  credentials: myCredentials,
  chainId: 11155111,  // Sepolia chain ID
);
```

### Mainnet
```dart
final contract = await SignalingContract.deploy(
  rpcUrl: 'https://mainnet.infura.io/v3/YOUR_KEY',
  credentials: myCredentials,
  chainId: 1,  // Ethereum mainnet
);
```

## Performance Notes

- **Gas Limit**: 8M is conservative for the Signaling contract (~1M used in tests)
- **Gas Price**: 2 gwei is appropriate for Ganache (can be adjusted for different networks)
- **Poll Interval**: 1 second waiting for receipt (60 second timeout)

## Migration from web3dart 2.x

If upgrading from web3dart 2.7.3 to 3.0.1:

### Changes in Address Handling
```dart
// Old (2.x)
print(address.hex);

// New (3.x)
print(address.eip55With0x);
```

### Changes in Ether Unit Conversion
```dart
// Old (2.x)
final balance = await client.getBalance(address);
final eth = balance.getValueInUnit(EtherUnit.ether);

// New (3.x) - Same API, works fine
final balance = await client.getBalance(address);
final eth = balance.getValueInUnit(EtherUnit.ether);
```

## Debugging

### If You Still Get "Invalid signature v value"

1. **Check Chain ID**
   ```dart
   final chainId = await client.getChainId();
   print('Chain ID: $chainId');
   ```

2. **Verify RPC Connection**
   ```dart
   final blockNumber = await client.blockNumber;
   print('Latest block: $blockNumber');
   ```

3. **Check Credentials**
   ```dart
   final credentials = EthPrivateKey.fromHex('0x...');
   print('Account: ${credentials.address.eip55With0x}');
   
   final balance = await client.getBalance(credentials.address);
   print('Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
   ```

4. **Enable Verbose Logging**
   Add a custom HTTP client wrapper to see request/response details

### Network-Specific Issues

| Network | Issue | Solution |
|---------|-------|----------|
| Ganache | "Invalid signature v value" | Ensure `chainId: 1337` is set |
| Sepolia | Transaction rejected | Verify account has testnet ETH |
| Mainnet | High gas prices | Adjust `maxFeePerGas` accordingly |

## References

- [web3dart Documentation](https://pub.dev/packages/web3dart)
- [EIP-1559: Dynamic Fee Market](https://eips.ethereum.org/EIPS/eip-1559)
- [Ganache Documentation](https://trufflesuite.com/ganache/)
- [Ethereum Chain IDs](https://chainlist.org/)

---

**Last Updated**: 2026-01-07
**web3dart Version**: 3.0.1+
**Tested On**: Ganache v7.9.2
