// GENERATED CODE - DO NOT MODIFY BY HAND
// Auto-generated exports for contract bindings
// NOTE: signaling_contract_extensions.dart is NOT included here (manually maintained in lib/)
// ignore: unused_import
import 'dart:typed_data';
// ignore: unused_import
import 'package:web3dart/web3dart.dart' as web3;

export 'signaling_contract.dart' hide hexToBytes;

// Re-export web3dart types with aliases to make them accessible
export 'package:web3dart/web3dart.dart';

/// Helper function to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) hex = hex.substring(2);
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}
