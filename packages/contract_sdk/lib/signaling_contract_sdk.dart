/// Dart SDK for Signaling smart contracts
///
/// This package provides type-safe Dart bindings for Signaling smart contracts
/// with auto-generated code, Ethereum/EVM support, and comprehensive deployment utilities.
library signaling_contract_sdk;

export 'generated/contracts.dart';
export 'signaling_contract_extensions.dart'
    show
        SignalingDataCompression,
        CompressibleData,
        StringData,
        BytesData,
        IntListData,
        SignalingContractExtension;
