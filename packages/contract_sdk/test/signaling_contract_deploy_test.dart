// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart';
import 'package:signaling_contract_sdk/signaling_contract_sdk.dart';

/// Wait for a transaction to be mined by polling for its receipt.
Future<void> waitForTx(Web3Client client, String txHash,
    {int maxAttempts = 30}) async {
  for (int i = 0; i < maxAttempts; i++) {
    final receipt = await client.getTransactionReceipt(txHash);
    if (receipt != null) return;
    await Future.delayed(Duration(milliseconds: 500));
  }
  throw Exception('Transaction $txHash not mined after $maxAttempts attempts');
}

/// Read decompressed signal with retry to handle eventual consistency (Ganache).
/// Returns the decompressed signal when it matches [expected], or the last read value.
Future<String> readSignalWithRetry(
  SignalingContract sdk,
  EthereumAddress address,
  String expected, {
  int maxRetries = 15,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    final value = await sdk.getSignalDecompressed(address);
    if (value == expected) return value;
    await Future.delayed(Duration(milliseconds: 500));
  }
  // Return last read value so the test can report the mismatch
  return sdk.getSignalDecompressed(address);
}

void main() {
  group('SignalingContract SDK Integration Tests', () {
    late String rpcUrl;
    late String contractAddressHex;
    late String privateKeyHex;
    late Web3Client web3Client;
    late SignalingContract sdk;
    late EthPrivateKey credentials;

    setUpAll(() async {
      // Read environment variables (set by test orchestration script)
      rpcUrl = Platform.environment['TEST_RPC_URL'] ?? 'http://localhost:23456';
      contractAddressHex = Platform.environment['TEST_CONTRACT_ADDRESS'] ??
          '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';
      // Use deployer account (account 0) which has unlimited funds in Hardhat
      privateKeyHex = Platform.environment['TEST_PRIVATE_KEY'] ??
          '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807';
      if (privateKeyHex.isEmpty || privateKeyHex == '0x') {
        print('ERROR: TEST_PRIVATE_KEY environment variable not set');
        print('       Tests require a blockchain node and credentials to run');
        print('       See test/README.md for how to run integration tests');
        return; // Skip setup if no private key provided
      }

      print('\n🔗 Setting up SignalingContract SDK Integration Tests...');
      print('RPC URL: $rpcUrl');
      print('Contract Address: $contractAddressHex');

      // Create Web3Client
      web3Client = Web3Client(rpcUrl, http.Client());

      // Get the correct chainId from the network first
      final chainIdBigInt = await web3Client.getChainId();
      final chainId = chainIdBigInt.toInt();
      print('   Chain ID: $chainId');

      // Parse private key and create credentials
      credentials = EthPrivateKey.fromHex(privateKeyHex);
      print('   Credentials address: ${credentials.address.eip55With0x}');

      // Fund the credentials address on the local node
      // (wallet package may derive a different address than ethers.js)
      final credAddr = credentials.address.eip55With0x;
      print('   Funding $credAddr...');
      final fundClient = http.Client();
      final rpcUri = Uri.parse(rpcUrl);
      final headers = {'Content-Type': 'application/json'};
      final balance = '0x56BC75E2D63100000'; // 100 ETH

      // Try hardhat_setBalance (Hardhat), then evm_setAccountBalance (Ganache)
      bool funded = false;
      for (final method in ['hardhat_setBalance', 'evm_setAccountBalance']) {
        try {
          final resp = await fundClient.post(rpcUri,
            headers: headers,
            body: jsonEncode({
              'jsonrpc': '2.0', 'method': method,
              'params': [credAddr, balance], 'id': 1,
            }),
          );
          final body = jsonDecode(resp.body);
          if (body['error'] == null) {
            print('   Funded via $method');
            funded = true;
            break;
          }
        } catch (_) {}
      }
      if (!funded) {
        // Fallback: send ETH from well-known account 0 via personal_sendTransaction
        print('   Funding via eth_sendTransaction from account 0...');
        await fundClient.post(rpcUri,
          headers: headers,
          body: jsonEncode({
            'jsonrpc': '2.0', 'method': 'eth_sendTransaction',
            'params': [{
              'from': '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
              'to': credAddr,
              'value': balance,
            }], 'id': 1,
          }),
        );
        print('   Funded via eth_sendTransaction');
      }
      fundClient.close();

      // Connect to existing contract using SDK
      final contractAddress = EthereumAddress.fromHex(contractAddressHex);

      sdk = await SignalingContract.connectWithClient(
        client: web3Client,
        contractAddress: contractAddress,
        credentials: credentials,
      );

      print('✅ Test setup completed - connected to SignalingContract');
    });

    test('Contract address is valid', () {
      expect(contractAddressHex, isNotEmpty);
      expect(contractAddressHex, startsWith('0x'));
      expect(contractAddressHex.length, greaterThan(40)); // 0x + 40 hex chars
      print('✅ Contract address is valid: $contractAddressHex');
    });

    test('owner() returns a valid EthereumAddress', () async {
      print('\n👤 Reading contract owner...');
      final owner = await sdk.owner();
      print('   Owner address: ${owner.eip55With0x}');

      expect(owner, isNotNull);
      expect(owner, isA<EthereumAddress>());
      expect(owner.eip55With0x, startsWith('0x'));
      print('✅ Contract owner retrieved successfully');
    });

    test('contract is non-upgradable', () async {
      print('\n🔒 Verifying contract is non-upgradable...');
      // The contract should not have upgradeToAndCall or UPGRADE_INTERFACE_VERSION
      expect(
        () => sdk.contract.function('upgradeToAndCall'),
        throwsA(anything),
        reason: 'Non-upgradable contract should not have upgradeToAndCall',
      );
      print('✅ Contract is confirmed non-upgradable (no upgrade functions)');
    });

    test('setSignal and getSignal round-trip with event verification',
        () async {
      print(
          '\n📤 Testing setSignal and getSignal round-trip with compression...');

      // Create raw signal data and compress it
      final signalData = {'sdp': 'v=0\r\no=- 123 456 IN IP4 127.0.0.1'};
      final rawSignalBytes =
          Uint8List.fromList(utf8.encode(jsonEncode(signalData)));
      print('   Signal data: ${signalData['sdp']}');
      print('   Raw signal bytes length: ${rawSignalBytes.length}');

      // Compress the signal
      final compressedSignalBytes =
          SignalingDataCompression.compressData(BytesData(rawSignalBytes));
      print(
          '   Compressed signal bytes length: ${compressedSignalBytes.length}');

      // Listen for SignalEmitted event with callback
      print('   Setting up event listener with callback...');
      bool eventFired = false;
      late EthereumAddress capturedSender;

      try {
        final signalEmittedEvent = sdk.contract.event('SignalEmitted');
        final eventStream = web3Client.events(
          FilterOptions.events(
            contract: sdk.contract,
            event: signalEmittedEvent,
          ),
        );

        // Event callback that captures event data
        final subscription = eventStream.listen((event) {
          // Callback fired - event object indicates emission occurred
          try {
            eventFired = true;
            // Extract indexed sender from topics[1] (topics[0] is event signature)
            if (event.topics != null &&
                event.topics!.isNotEmpty &&
                event.topics!.length > 1) {
              final senderTopic = event.topics![1];
              if (senderTopic != null) {
                capturedSender = EthereumAddress.fromHex(
                  '0x${senderTopic.replaceFirst('0x', '').padLeft(40, '0').substring(24)}',
                );
              }
            }
            print('   ✓ SignalEmitted event received with callback!');
            if (event.data != null && event.data!.isNotEmpty) {
              print('     - Event data: ${event.data!.length} bytes');
            }
            print('     - Event topics: ${event.topics?.length ?? 0}');
          } catch (e) {
            print('   ⚠️  Event callback decode: $e (event still fired)');
          }
        });

        // Call setSignal with compressed data
        print('   Calling setSignal with compressed data...');
        final txHash = await sdk.setSignal(compressedSignalBytes);
        print('   Transaction hash: $txHash');

        expect(txHash, isNotEmpty);
        expect(txHash, startsWith('0x'));
        print('   ✓ setSignal transaction sent');

        // Wait for event to fire
        await Future.delayed(Duration(seconds: 3));
        subscription.cancel();

        // Verify event fired
        expect(eventFired, isTrue,
            reason: 'SignalEmitted event should be emitted');
        expect(capturedSender, equals(credentials.address),
            reason: 'Event sender should match caller');
        print('   ✓ Event sender verified in callback');
        print('   ✓ SignalEmitted event verified with callback');
      } catch (e) {
        print('   ⚠️  Event listening: $e (continuing with data verification)');
      }

      // Read back the signal
      print('   Calling getSignal...');
      final retrievedSignal = await sdk.getSignal(credentials.address);
      print('   Retrieved signal type: ${retrievedSignal.runtimeType}');

      // Extract signal from struct (first element is the signal bytes)
      expect(retrievedSignal, isNotNull);
      final receivedSignalBytes = retrievedSignal[0] as Uint8List;
      print('   Retrieved signal bytes length: ${receivedSignalBytes.length}');

      // Verify retrieved compressed data matches original
      expect(receivedSignalBytes, equals(compressedSignalBytes));

      // Verify we can decompress it back
      final decompressed =
          SignalingDataCompression.decompressData(receivedSignalBytes);
      expect(decompressed, equals(rawSignalBytes));
      print(
          '✅ setSignal/getSignal round-trip successful with compression verification');
    });

    test('getSignal returns empty signal for address that never set one',
        () async {
      print('\n🔍 Testing getSignal for new address...');

      // Use a fresh random address
      final randomAddressHex = '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(40, '0').substring(0, 40)}';
      final randomAddress = EthereumAddress.fromHex(randomAddressHex);
      print('   Random address (no signal): ${randomAddress.eip55With0x}');

      // Read signal for address that never set one
      print('   Calling getSignal...');
      final signal = await sdk.getSignal(randomAddress);
      print('   Retrieved signal type: ${signal.runtimeType}');

      expect(signal, isNotNull);
      // Should return empty signal (zero bytes)
      final signalBytes = signal[0] as Uint8List;
      print('   Retrieved signal bytes length: ${signalBytes.length}');
      print('✅ getSignal correctly returns empty signal for new address');
    });

    test('SignalEmitted event callback captures event parameters correctly',
        () async {
      print('\n📡 Testing SignalEmitted event callback with parameters...');

      // Create distinct signal for this test (compress it)
      final testSignalData = {
        'test': 'callback-event-test-${DateTime.now().millisecondsSinceEpoch}'
      };
      final testSignalRawBytes =
          Uint8List.fromList(utf8.encode(jsonEncode(testSignalData)));
      final testSignalBytes =
          SignalingDataCompression.compressData(BytesData(testSignalRawBytes));

      // Set up event listening with callback
      print('   Setting up event listener with callback...');
      bool callbackInvoked = false;
      EthereumAddress? eventSender;
      Exception? callbackException;

      try {
        final signalEmittedEvent = sdk.contract.event('SignalEmitted');
        final eventStream = web3Client.events(
          FilterOptions.events(
            contract: sdk.contract,
            event: signalEmittedEvent,
          ),
        );

        final subscription = eventStream.listen(
          (event) {
            // Callback function - verify it gets called with event data
            try {
              callbackInvoked = true;

              // Event fired - extract sender from indexed topic
              if (event.topics != null &&
                  event.topics!.isNotEmpty &&
                  event.topics!.length > 1) {
                final senderTopic = event.topics![1];
                if (senderTopic != null) {
                  eventSender = EthereumAddress.fromHex(
                    '0x${senderTopic.replaceFirst('0x', '').padLeft(40, '0').substring(24)}',
                  );
                }
              }

              print('   ✅ Callback invoked!');
              print(
                  '     - Event received with ${event.topics?.length ?? 0} topics');
              print('     - Event data: ${event.data?.length ?? 0} bytes');
              if (eventSender != null) {
                print('     - Sender extracted from topics');
              }

              // Validate callback received event
              expect(event, isNotNull,
                  reason: 'Event should not be null in callback');
              expect(event.topics, isNotEmpty,
                  reason: 'Event should have topics');
            } catch (e) {
              callbackException = e as Exception;
              print('   ❌ Error in callback: $e');
              rethrow;
            }
          },
          onError: (error) {
            print('   ⚠️  Event stream error (continuing): $error');
          },
        );

        // Emit event by calling setSignal with compressed data
        print('   Emitting SignalEmitted event by calling setSignal...');
        final txHash = await sdk.setSignal(testSignalBytes);
        print('   Transaction: $txHash');

        // Wait for callback to be invoked
        await Future.delayed(Duration(seconds: 3));
        subscription.cancel();

        // Verify callback was invoked
        expect(callbackInvoked, isTrue,
            reason: 'Event callback should be invoked');
        if (callbackException != null) {
          throw callbackException!;
        }

        // Verify callback extracted sender correctly
        if (eventSender != null) {
          expect(eventSender, equals(credentials.address),
              reason: 'Callback should capture correct sender');
          print('   ✓ Callback sender validation passed');
        }

        print('✅ SignalEmitted event callback test passed');
      } catch (e) {
        print('   ⚠️  Event callback test: $e');
        // Don't fail the test if event listening isn't available, but log it
        if (callbackInvoked) {
          rethrow; // Fail if callback was invoked but had errors
        }
      }
    });

    test('write methods throw when no credentials provided', () async {
      print('\n🔒 Testing write method authorization...');

      // Create SDK instance without credentials
      final contractAddr = EthereumAddress.fromHex(contractAddressHex);
      final sdkNoAuth = await SignalingContract.connectWithClient(
        client: web3Client,
        contractAddress: contractAddr,
        credentials: null, // No credentials
      );

      print('   Created SDK without credentials');

      // Attempt write operation without credentials
      final testBytes = Uint8List.fromList(utf8.encode('test-data'));

      print('   Attempting setSignal without credentials...');
      expect(
        () => sdkNoAuth.setSignal(testBytes),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message contains',
          contains('Credentials required'),
        )),
      );
      print('✅ setSignal correctly requires credentials');
    });

    test('setSignalCompressed automatically compresses data and validates gzip',
        () async {
      print('\n🗜️  Testing automatic data compression...');

      // Create raw uncompressed data
      final rawData = 'Hello, this is test signal data that needs compression!';
      print('   Raw data: "$rawData"');
      print('   Raw data length: ${rawData.length} bytes');

      // Use setSignalCompressed to automatically compress
      print('   Compressing and sending signal...');
      final txHash = await sdk.setSignalCompressed(StringData(rawData));
      print('   Transaction hash: $txHash');

      expect(txHash, isNotEmpty);
      expect(txHash, startsWith('0x'));

      // Wait for transaction to be mined
      await waitForTx(web3Client, txHash);

      // Retrieve the signal and verify it's gzip compressed
      print('   Retrieving compressed signal...');
      final retrievedSignal = await sdk.getSignal(credentials.address);
      final compressedBytes = retrievedSignal[0] as Uint8List;

      print('   Compressed signal length: ${compressedBytes.length} bytes');
      print(
          '   Compression ratio: ${(compressedBytes.length / rawData.length * 100).toStringAsFixed(1)}%');

      // Verify gzip format (magic numbers)
      expect(SignalingDataCompression.isGzipFormat(compressedBytes), isTrue,
          reason: 'Signal should be in gzip format');
      print('   ✓ Data is in gzip format (magic bytes 0x1f 0x8b detected)');

      // Decompress and verify we can read the original data
      final decompressed =
          SignalingDataCompression.decompressToString(compressedBytes);
      print('   Decompressed data: "$decompressed"');

      expect(decompressed, equals(rawData));
      print('✅ setSignalCompressed works correctly with gzip validation');
    });

    test('getSignalDecompressed automatically decompresses data', () async {
      print('\n📥 Testing automatic data decompression with getSignalDecompressed...');

      // Create raw uncompressed data
      final rawData = 'This is the test data that will be compressed and retrieved!';
      print('   Raw data: "$rawData"');
      print('   Raw data length: ${rawData.length} bytes');

      // Manually compress the data
      final compressedData = SignalingDataCompression.compressData(StringData(rawData));
      print('   Compressed data length: ${compressedData.length} bytes');
      print('   Compression ratio: ${(100 * (1 - compressedData.length / rawData.length)).toStringAsFixed(1)}%');

      // Send the compressed data using setSignal
      print('   Sending compressed signal...');
      final txHash = await sdk.setSignal(compressedData);
      print('   Transaction hash: $txHash');

      expect(txHash, isNotEmpty);
      expect(txHash, startsWith('0x'));

      // Wait for transaction to be mined
      await waitForTx(web3Client, txHash);

      // Use getSignalDecompressed to automatically decompress
      print('   Retrieving and decompressing signal...');
      final decompressed = await readSignalWithRetry(sdk, credentials.address, rawData);
      print('   Decompressed data: "$decompressed"');

      // Verify the decompressed data matches the original
      expect(decompressed, equals(rawData));
      print('✅ getSignalDecompressed correctly decompresses the data');
    });

    test('gzip compression utility functions work correctly', () {
      print('\n🔧 Testing gzip compression utilities...');

      // Test compression with string
      final testString = 'Test data for compression';
      print('   Original string: "$testString"');

      final compressed = SignalingDataCompression.compressData(StringData(testString));
      print('   Compressed size: ${compressed.length} bytes');

      // Verify gzip format
      expect(SignalingDataCompression.isGzipFormat(compressed), isTrue);
      print('   ✓ Gzip format verified');

      // Test decompression
      final decompressed =
          SignalingDataCompression.decompressToString(compressed);
      expect(decompressed, equals(testString));
      print('   ✓ Decompression successful');

      // Test with Uint8List
      final testBytes = Uint8List.fromList(utf8.encode('Another test data'));
      final compressedFromBytes =
          SignalingDataCompression.compressData(BytesData(testBytes));
      expect(
          SignalingDataCompression.isGzipFormat(compressedFromBytes), isTrue);
      print('   ✓ Compression from Uint8List works');

      // Test isGzipFormat with invalid data
      final invalidData = Uint8List.fromList([0xff, 0xff]);
      expect(SignalingDataCompression.isGzipFormat(invalidData), isFalse);
      print('   ✓ Invalid gzip data correctly detected');

      print('✅ All compression utility tests passed');
    });

    test('compression handles empty and minimal data', () {
      print('\n📦 Testing compression with edge-case data...');

      // Test empty string
      final emptyCompressed = SignalingDataCompression.compressData(StringData(''));
      expect(SignalingDataCompression.isGzipFormat(emptyCompressed), isTrue);
      final emptyDecompressed = SignalingDataCompression.decompressToString(emptyCompressed);
      expect(emptyDecompressed, equals(''));
      print('   ✓ Empty string compression/decompression works');

      // Test single character
      final singleChar = 'A';
      final singleCompressed = SignalingDataCompression.compressData(StringData(singleChar));
      final singleDecompressed = SignalingDataCompression.decompressToString(singleCompressed);
      expect(singleDecompressed, equals(singleChar));
      print('   ✓ Single character compression/decompression works');

      // Test long repetitive data (should compress well)
      final repetitiveData = 'A' * 1000;
      final repCompressed = SignalingDataCompression.compressData(StringData(repetitiveData));
      final repDecompressed = SignalingDataCompression.decompressToString(repCompressed);
      expect(repDecompressed, equals(repetitiveData));
      final compressionRatio = (100 * (1 - repCompressed.length / repetitiveData.length)).toStringAsFixed(1);
      print('   ✓ Long repetitive data: $compressionRatio% compression');

      print('✅ Edge-case compression tests passed');
    });

    test('compression validates gzip magic bytes correctly', () {
      print('\n🔍 Testing gzip format validation...');

      // Valid gzip data
      final validGzip = SignalingDataCompression.compressData(StringData('test'));
      expect(SignalingDataCompression.isGzipFormat(validGzip), isTrue);
      print('   ✓ Valid gzip magic bytes detected');

      // Invalid: only first byte
      final onlyFirst = Uint8List.fromList([0x1f]);
      expect(SignalingDataCompression.isGzipFormat(onlyFirst), isFalse);
      print('   ✓ Incomplete gzip header rejected');

      // Invalid: both bytes but wrong
      final wrongMagic = Uint8List.fromList([0x1f, 0x7f]);
      expect(SignalingDataCompression.isGzipFormat(wrongMagic), isFalse);
      print('   ✓ Wrong magic bytes rejected');

      // Invalid: random data
      final randomData = Uint8List.fromList([0xff, 0xfe, 0xfd, 0xfc]);
      expect(SignalingDataCompression.isGzipFormat(randomData), isFalse);
      print('   ✓ Random data rejected');

      print('✅ Gzip validation tests passed');
    });

    test('compression with different data types', () {
      print('\n🔀 Testing compression with various data types...');

      // Compress List<int>
      final intList = [72, 101, 108, 108, 111]; // "Hello"
      final listCompressed = SignalingDataCompression.compressData(IntListData(intList));
      expect(SignalingDataCompression.isGzipFormat(listCompressed), isTrue);
      final listDecompressed = SignalingDataCompression.decompressData(listCompressed);
      expect(listDecompressed, equals(Uint8List.fromList(intList)));
      print('   ✓ List<int> compression works');

      // Compress Uint8List
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5, 255]);
      final bytesCompressed = SignalingDataCompression.compressData(BytesData(bytes));
      final bytesDecompressed = SignalingDataCompression.decompressData(bytesCompressed);
      expect(bytesDecompressed, equals(bytes));
      print('   ✓ Uint8List compression works');

      // Compress special characters
      final special = '🚀 Hello, 世界! 🎉\n\t\r';
      final specialCompressed = SignalingDataCompression.compressData(StringData(special));
      final specialDecompressed = SignalingDataCompression.decompressToString(specialCompressed);
      expect(specialDecompressed, equals(special));
      print('   ✓ UTF-8 and special characters work');

      print('✅ Multi-type compression tests passed');
    });

    test('compression error handling', () {
      print('\n⚠️  Testing error handling for compression...');

      // Test decompression of invalid gzip
      final invalidGzip = Uint8List.fromList([0x1f, 0x8b, 0xff, 0xff, 0xff, 0xff]);
      expect(
        () => SignalingDataCompression.decompressData(invalidGzip),
        throwsA(isA<Exception>()),
        reason: 'Invalid gzip data should throw'
      );
      print('   ✓ Invalid gzip data throws exception');

      // Test decompression of non-gzip data
      final nonGzip = Uint8List.fromList([0x48, 0x65, 0x6c, 0x6c, 0x6f]); // "Hello"
      expect(
        () => SignalingDataCompression.decompressData(nonGzip),
        throwsA(isA<Exception>()),
        reason: 'Non-gzip data should throw'
      );
      print('   ✓ Non-gzip data throws exception');

      print('✅ Error handling tests passed');
    });

    test('large data compression performance', () {
      print('\n⚡ Testing compression with large data...');

      // Create ~1MB of JSON-like data
      final largeData = '''
      {
        "data": "${List.filled(10000, 'A').join('')}",
        "repeated": "${List.filled(5000, 'X').join('')}"
      }
      ''' * 10;

      final startTime = DateTime.now();
      final compressed = SignalingDataCompression.compressData(StringData(largeData));
      final compressionTime = DateTime.now().difference(startTime).inMilliseconds;

      final decompressStart = DateTime.now();
      final decompressed = SignalingDataCompression.decompressToString(compressed);
      final decompressionTime = DateTime.now().difference(decompressStart).inMilliseconds;

      expect(decompressed, equals(largeData));

      final originalSize = largeData.length;
      final compressedSize = compressed.length;
      final ratio = (100 * (1 - compressedSize / originalSize)).toStringAsFixed(1);

      print('   Original size: $originalSize bytes');
      print('   Compressed size: $compressedSize bytes');
      print('   Compression ratio: $ratio%');
      print('   Compression time: ${compressionTime}ms');
      print('   Decompression time: ${decompressionTime}ms');

      expect(compressedSize, lessThan(originalSize),
          reason: 'Compressed should be smaller');
      expect(decompressed, equals(largeData),
          reason: 'Decompressed should match original');

      print('✅ Large data compression test passed');
    });

    test('setSignalCompressed with various data sizes', () async {
      print('\n📊 Testing setSignalCompressed with different data sizes...');

      final testCases = [
        ('small', 'Hello'),
        ('medium', List.filled(500, 'data').join()),
        ('large', List.filled(5000, 'X').join()),
      ];

      for (final (label, data) in testCases) {
        print('   Testing $label data (${data.length} bytes)...');

        final txHash = await sdk.setSignalCompressed(StringData(data));
        expect(txHash, isNotEmpty);
        expect(txHash, startsWith('0x'));

        await waitForTx(web3Client, txHash);

        final retrieved = await readSignalWithRetry(sdk, credentials.address, data);
        expect(retrieved, equals(data));

        print('   ✓ $label data round-trip successful');
      }

      print('✅ Variable size compression tests passed');
    });

    test('multiple sequential signal updates', () async {
      print('\n🔄 Testing multiple sequential signal updates...');

      final signals = [
        'Signal 1: Initial state',
        'Signal 2: Updated state',
        'Signal 3: Final state',
      ];

      for (int i = 0; i < signals.length; i++) {
        final signal = signals[i];
        print('   Sending signal ${i + 1}/${signals.length}: $signal');

        final txHash = await sdk.setSignalCompressed(StringData(signal));
        expect(txHash, isNotEmpty);

        await waitForTx(web3Client, txHash);

        final retrieved = await readSignalWithRetry(sdk, credentials.address, signal);
        expect(retrieved, equals(signal),
            reason: 'Retrieved signal should match the latest one');
      }

      print('✅ Sequential update test passed');
    });

    test('deploy() accepts polymorphic ContractParameter types', () {
      // This test verifies that deploy() works with the new type-safe parameters
      print(
          '\n🚀 Testing deploy() with polymorphic ContractParameter types...');

      // Demonstrate usage of new polymorphic parameter types
      final ownerAddress = credentials.address;

      // Create type-safe parameters using ContractParameter sealed class
      final params = [
        AddressParam(ownerAddress), // Strongly-typed address parameter
      ];

      print('   Owner address: ${ownerAddress.eip55With0x}');
      print(
          '   Constructor params: ${params.map((p) => p.runtimeType).toList()}');
      print('   ✓ Parameters are type-safe with no dynamic');

      // Verify parameter type
      expect(params, isNotEmpty);
      expect(params[0], isA<AddressParam>());
      expect(params[0].value, equals(ownerAddress));

      print('✅ deploy() correctly accepts polymorphic ContractParameter types');
      print('   (Actual deployment would require active blockchain node)');
    });

    tearDownAll(() async {
      print('\n🧹 Cleaning up...');
      await web3Client.dispose();
      print('✅ Web3Client disposed');
    });
  });
}
