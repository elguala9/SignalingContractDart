// Custom extensions for SignalingContract
// This file is NOT auto-generated and can be safely modified

library signaling_contract_extensions;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:wallet/wallet.dart' show EthereumAddress;

// Import generated file and make types available
import 'generated/signaling_contract.dart';

/// Utility functions for data compression and validation
class SignalingDataCompression {
  /// Compress data using gzip format
  ///
  /// Takes raw data (as String or Uint8List) and returns gzip-compressed bytes
  static Uint8List compressData(dynamic data) {
    List<int> rawBytes;

    if (data is String) {
      rawBytes = utf8.encode(data);
    } else if (data is Uint8List) {
      rawBytes = data;
    } else if (data is List<int>) {
      rawBytes = data;
    } else {
      throw ArgumentError('Data must be String, Uint8List, or List<int>');
    }

    final codec = GZipCodec();
    final compressed = codec.encode(rawBytes);

    return Uint8List.fromList(compressed);
  }

  /// Validate if data is in gzip format
  ///
  /// Gzip format starts with magic numbers: 0x1f 0x8b
  static bool isGzipFormat(Uint8List data) {
    if (data.length < 2) {
      return false;
    }
    return data[0] == 0x1f && data[1] == 0x8b;
  }

  /// Decompress gzip data (if needed for reading)
  ///
  /// Note: This is for client-side decompression. The contract
  /// expects pre-compressed data and doesn't decompress on-chain.
  static Uint8List decompressData(Uint8List compressedData) {
    final codec = GZipCodec();
    return Uint8List.fromList(codec.decode(compressedData));
  }

  /// Convert decompressed bytes to string
  static String decompressToString(Uint8List compressedData) {
    final decompressed = decompressData(compressedData);
    return utf8.decode(decompressed);
  }
}

/// Extension to provide Web3Client-based connect method
extension SignalingContractExtension on SignalingContract {
  /// Connect to existing contract with pre-configured Web3Client
  ///
  /// This method allows using an existing Web3Client instance,
  /// which is useful for connection pooling and management.
  static Future<SignalingContract> connectWithClient({
    required dynamic client,
    required dynamic contractAddress,
    dynamic credentials,
  }) async {
    // Use DeployedContract and ContractAbi from web3dart
    final contract = web3.DeployedContract(
      web3.ContractAbi.fromJson(SignalingContract.contractAbi, 'Signaling'),
      contractAddress,
    );

    return SignalingContract(
      client: client,
      contract: contract,
      credentials: credentials,
    );
  }

  /// Set signal with automatic gzip compression
  ///
  /// This method takes raw data (String or Uint8List) and automatically
  /// compresses it using gzip before sending to the contract.
  ///
  /// Example:
  /// ```dart
  /// final dataToCompress = "Hello, World!";
  /// final txHash = await sdk.setSignalCompressed(dataToCompress);
  /// print('Transaction: $txHash');
  /// ```
  Future<String> setSignalCompressed(dynamic data) async {
    final compressedData = SignalingDataCompression.compressData(data);
    return setSignal(compressedData);
  }

  /// Get signal with automatic gzip decompression
  ///
  /// This method retrieves the compressed signal for an offerer address
  /// and automatically decompresses it before returning.
  ///
  /// Returns: A Future that resolves to a String containing the decompressed signal
  /// Throws: FormatException if the data is not valid gzip format
  ///
  /// Example:
  /// ```dart
  /// final decompressed = await sdk.getSignalCompressed(offererAddress);
  /// print('Decompressed signal: $decompressed');
  /// ```
  Future<String> getSignalCompressed(EthereumAddress offerer) async {
    final signalData = await getSignal(offerer);

    // Extract signal bytes from struct (first element of the tuple)
    if (signalData.isEmpty) {
      throw StateError('No signal found for this offerer');
    }

    final signalBytes = signalData[0];
    if (signalBytes is! Uint8List) {
      throw FormatException('Signal data is not in expected format');
    }

    // Validate gzip format
    if (!SignalingDataCompression.isGzipFormat(signalBytes)) {
      throw FormatException('Signal data is not in gzip format');
    }

    // Decompress and return as string
    return SignalingDataCompression.decompressToString(signalBytes);
  }

  /// Listen to SignalEmitted events with optional sender filter
  ///
  /// Returns a Stream of [FilterEvent] that emits when SignalEmitted is triggered.
  /// When [senderFilter] is provided, only events emitted by that address are returned.
  ///
  /// Example:
  /// ```dart
  /// // Listen to all SignalEmitted events
  /// final allEvents = sdk.watchSignalEmitted();
  ///
  /// // Listen only to events from a specific sender
  /// final userEvents = sdk.watchSignalEmitted(
  ///   senderFilter: EthereumAddress.fromHex('0x...')
  /// );
  ///
  /// final subscription = userEvents.listen((event) {
  ///   print('SignalEmitted event received from filtered sender');
  /// });
  /// subscription.cancel(); // Don't forget to cancel when done
  /// ```
  Stream<web3.FilterEvent> watchSignalEmitted({EthereumAddress? senderFilter}) {
    final signalEmittedEvent = contract.event('SignalEmitted');
    final eventStream = client.events(
      web3.FilterOptions.events(
        contract: contract,
        event: signalEmittedEvent,
      ),
    );

    // If no sender filter is provided, return all events
    if (senderFilter == null) {
      return eventStream;
    }

    // Filter by sender address (extracted from topics[1])
    return eventStream.where((event) {
      if (event.topics != null && event.topics!.length > 1) {
        final senderTopic = event.topics![1];
        if (senderTopic != null) {
          try {
            // Extract EthereumAddress from the topic
            final extractedSender = EthereumAddress.fromHex(
              '0x${senderTopic.replaceFirst('0x', '').padLeft(40, '0').substring(24)}',
            );
            return extractedSender == senderFilter;
          } catch (_) {
            return false;
          }
        }
      }
      return false;
    });
  }
}
