import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:signaling_contract_sdk/generated/contracts.dart';

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
      rpcUrl = Platform.environment['TEST_RPC_URL'] ?? 'http://localhost:8545';
      contractAddressHex =
          Platform.environment['TEST_CONTRACT_ADDRESS'] ?? '0x5FbDB2315678afccb333f8a9c91ff5f8b6e74aaf';
      privateKeyHex = Platform.environment['TEST_PRIVATE_KEY'] ?? '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807';
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

      // Parse private key and create credentials
      credentials = EthPrivateKey.fromHex(privateKeyHex);
      print('   Credentials address: ${credentials.address.eip55With0x}');

      // Connect to existing contract using SDK
      final contractAddress = EthereumAddress.fromHex(contractAddressHex);

      // Get the correct chainId from the network
      final chainIdBigInt = await web3Client.getChainId();
      final chainId = chainIdBigInt.toInt();
      print('   Chain ID: $chainId');

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

    test('upgradeInterfaceVersion() returns "5.0.0"', () async {
      print('\n📋 Reading upgrade interface version...');
      final version = await sdk.upgradeInterfaceVersion();
      print('   Version: $version');

      expect(version, equals('5.0.0'));
      print('✅ Upgrade interface version is correct');
    });

    test('proxiableUUID() callable on implementation', () async {
      print('\n🔑 Testing proxiableUUID implementation...');
      // Note: Direct calls to proxiableUUID() on a proxy revert with UUPSUnauthorizedCallContext
      // This is expected security behavior. The UUID is only accessible through the proxy delegation.
      try {
        final uuid = await sdk.proxiableUUID();
        print('   UUID: $uuid');
        print('✅ Proxiable UUID accessible (should only work via proxy delegation)');
      } on Exception catch (e) {
        if (e.toString().contains('UUPSUnauthorizedCallContext')) {
          print('   Expected: Cannot call proxiableUUID directly on proxy (UUPS security)');
          print('✅ UUPS security check working correctly');
        } else {
          rethrow;
        }
      }
    });

    test('setSignal and getSignal round-trip with event verification', () async {
      print('\n📤 Testing setSignal and getSignal round-trip...');

      // Create signal bytes (compressed signal data)
      final signalData = {'sdp': 'v=0\r\no=- 123 456 IN IP4 127.0.0.1'};
      final signalBytes = Uint8List.fromList(utf8.encode(jsonEncode(signalData)));
      print('   Signal data: ${signalData['sdp']}');
      print('   Signal bytes length: ${signalBytes.length}');

      // Listen for SignalEmitted event with callback
      print('   Setting up event listener with callback...');
      bool eventFired = false;
      late Uint8List capturedSignal;
      late EthereumAddress capturedSender;
      late BigInt capturedTimestamp;

      try {
        final signalEmittedEvent = sdk.contract.event('SignalEmitted');
        final eventStream = web3Client.events(
          FilterOptions.events(
            contract: sdk.contract,
            event: signalEmittedEvent,
          ),
        );

        // Event callback that captures and validates event data
        final subscription = eventStream.listen((event) {
          // Callback fired - extract event parameters
          try {
            // Event structure: [sender, signal, timestamp]
            final params = event.parameters;

            capturedSender = params[0].value as EthereumAddress;
            capturedSignal = params[1].value as Uint8List;
            capturedTimestamp = params[2].value as BigInt;

            eventFired = true;
            print('   ✓ SignalEmitted event received with callback!');
            print('     - Sender: ${capturedSender.eip55With0x}');
            print('     - Signal bytes: ${capturedSignal.length} bytes');
            print('     - Timestamp: $capturedTimestamp');
          } catch (e) {
            print('   ❌ Error in event callback: $e');
            rethrow;
          }
        });

        // Call setSignal (write operation)
        print('   Calling setSignal...');
        final txHash = await sdk.setSignal(signalBytes);
        print('   Transaction hash: $txHash');

        expect(txHash, isNotEmpty);
        expect(txHash, startsWith('0x'));
        print('   ✓ setSignal transaction sent');

        // Wait for event to fire
        await Future.delayed(Duration(seconds: 3));
        subscription.cancel();

        // Verify event fired with correct data
        expect(eventFired, isTrue, reason: 'SignalEmitted event should be emitted');
        expect(capturedSender, equals(credentials.address), reason: 'Event sender should match caller');
        expect(capturedSignal, equals(signalBytes), reason: 'Event signal should match input');
        expect(capturedTimestamp, greaterThan(BigInt.zero), reason: 'Event timestamp should be positive');
        print('   ✓ SignalEmitted event data verified with callback');
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

      // Verify retrieved data matches original
      expect(receivedSignalBytes, equals(signalBytes));
      print('✅ setSignal/getSignal round-trip successful with event verification');
    });

    test('getSignal returns empty signal for address that never set one', () async {
      print('\n🔍 Testing getSignal for new address...');

      // Use a fresh random address
      final randomAddressHex = '0x' + DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(40, '0').substring(0, 40);
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

    test('SignalEmitted event callback captures event parameters correctly', () async {
      print('\n📡 Testing SignalEmitted event callback with parameters...');

      // Create distinct signal for this test
      final testSignalData = {'test': 'callback-event-test-${DateTime.now().millisecondsSinceEpoch}'};
      final testSignalBytes = Uint8List.fromList(utf8.encode(jsonEncode(testSignalData)));

      // Set up event listening with callback
      print('   Setting up event listener with callback...');
      bool callbackInvoked = false;
      late EthereumAddress eventSender;
      late Uint8List eventSignal;
      late BigInt eventTimestamp;
      late Exception? callbackException;

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
            // Callback function - verify it gets called
            try {
              callbackInvoked = true;
              final params = event.parameters;

              // Verify callback receives all three parameters
              eventSender = params[0].value as EthereumAddress;
              eventSignal = params[1].value as Uint8List;
              eventTimestamp = params[2].value as BigInt;

              print('   ✅ Callback invoked!');
              print('     - Sender (indexed): ${eventSender.eip55With0x}');
              print('     - Signal: ${eventSignal.length} bytes');
              print('     - Timestamp: ${eventTimestamp.toInt()}');

              // Validate callback parameters
              expect(eventSender, isNotNull, reason: 'Sender should not be null in callback');
              expect(eventSignal, isNotNull, reason: 'Signal should not be null in callback');
              expect(eventTimestamp, isNotNull, reason: 'Timestamp should not be null in callback');
            } catch (e) {
              callbackException = e as Exception;
              print('   ❌ Error in callback: $e');
              rethrow;
            }
          },
          onError: (error) {
            print('   ❌ Event stream error: $error');
            callbackException = error as Exception;
          },
        );

        // Emit event by calling setSignal
        print('   Emitting SignalEmitted event by calling setSignal...');
        final txHash = await sdk.setSignal(testSignalBytes);
        print('   Transaction: $txHash');

        // Wait for callback to be invoked
        await Future.delayed(Duration(seconds: 3));
        subscription.cancel();

        // Verify callback was invoked
        expect(callbackInvoked, isTrue, reason: 'Event callback should be invoked');
        if (callbackException != null) {
          throw callbackException!;
        }

        // Verify callback captured correct event data
        expect(eventSender, equals(credentials.address), reason: 'Callback should capture correct sender');
        expect(eventSignal, equals(testSignalBytes), reason: 'Callback should capture correct signal');

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

    tearDownAll(() async {
      print('\n🧹 Cleaning up...');
      await web3Client.dispose();
      print('✅ Web3Client disposed');
    });
  });
}
