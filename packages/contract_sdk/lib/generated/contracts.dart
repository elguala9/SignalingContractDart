// GENERATED CODE - DO NOT MODIFY BY HAND
// Auto-generated exports for contract bindings

export 'signaling_contract.dart' hide hexToBytes;

// Shared utility functions
import 'dart:typed_data';

/// Helper function to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) hex = hex.substring(2);
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16))
  );
}
