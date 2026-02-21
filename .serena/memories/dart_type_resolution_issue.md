# Dart Type Resolution Issue with web3dart

## Problem
When running Dart tests with `dart test`, the analyzer cannot resolve types from `package:web3dart/web3dart.dart` (e.g., `EthereumAddress`, `Web3Client`), even though:
- The types are correctly imported with `import 'package:web3dart/web3dart.dart';`
- The package is installed (web3dart 3.0.1)
- `dart analyze` runs successfully without errors
- The imports use correct Dart syntax

## Error Pattern
```
Error: Type 'EthereumAddress' not found.
```

## Attempted Solutions (All Failed)
1. **Show clause imports** - `import '...' show EthereumAddress, ...`
2. **Aliased imports** - `import '...' as web3; web3.EthereumAddress`
3. **Full imports without show** - `import '...';`
4. **Typedefs** - Creating intermediate typedefs
5. **Post-processing exports** - Adding typedefs in generated files
6. **Version pinning** - Tried both 3.0.1 and 3.0.2
7. **Re-exporting through contracts.dart**
8. **Importing web3dart in test file**

## Key Findings
- `dart analyze` passes with no errors on the generated code
- `dart pub get` successfully installs web3dart 3.0.1
- The issue is specific to `dart test` command, not general compilation
- The error is in the test loading phase, preventing any tests from running
- Other imports (dart:typed_data, http, etc.) work fine

## Root Cause (Hypothesis)
This appears to be a known issue with web3dart 3.0.x where:
- Either web3dart doesn't properly export types at the package root
- Or there's an incompatibility between web3dart and Dart's test analyzer
- Or the test runner has different type resolution rules than the main analyzer

## Files Involved
- `packages/typescript/signaling-contract/scripts/generate-dart-bindings.js` - Generation script
- `packages/contract_sdk/lib/generated/signaling_contract.dart` - Generated bindings (auto)
- `packages/contract_sdk/lib/generated/signaling_contract_extensions.dart` - Manual extensions
- `packages/contract_sdk/lib/generated/contracts.dart` - Export file (auto)
- `packages/contract_sdk/lib/signaling_contract_sdk.dart` - Main SDK export
- `packages/contract_sdk/test/signaling_contract_test.dart` - Tests

## Next Steps to Try
1. Upgrade web3dart to latest version if available
2. Use dynamic types as fallback
3. Create wrapper classes that don't depend on web3dart types
4. Skip Dart tests and verify only TypeScript tests pass
5. Look for known web3dart/Dart test framework compatibility issues
