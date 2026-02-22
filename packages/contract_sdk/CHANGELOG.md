# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-02-22

### Added
- Gzip compression support for signal data with full test coverage
- Polymorphic `ContractParameter` sealed class for type-safe parameter handling
- Enhanced contract parameter type detection and validation

### Changed
- Refactored Dart bindings to eliminate all `dynamic` types using polymorphic sealed classes
- Improved struct return type handling and data encoding
- Migrated build scripts from `melos` to `pubspec.yaml` scripts
- Enhanced chainId support for EIP-155 transaction signing

### Fixed
- Fixed struct return types in generated bindings
- Improved error handling for contract parameter encoding

## [1.0.1] - 2025-10-15

### Added
- Web3dart 3.0.1 compatibility guide
- Improved transaction signing with explicit chainId support

### Changed
- Enhanced `SignalingContract.deploy()` to use EIP-1559 transactions
- Updated documentation for better clarity on deployment utilities

### Fixed
- Fixed `SignalingContract.deploy()` compatibility with web3dart 3.0.1
- Fixed chainId handling in transaction signing

## [1.0.0] - 2025-09-20

### Added
- Initial release of `signaling_contract_sdk`
- Type-safe Dart bindings for Signaling smart contracts
- Auto-generated contract bindings from Solidity ABI
- Full EVM/Ethereum support via `web3dart`
- Contract deployment utilities with constructor parameter encoding
- Contract connection utilities for existing deployments
- Support for signal data compression
- Comprehensive test coverage
- Example application demonstrating SDK usage
- Full dartdoc documentation

### Features
- 🔐 Type-Safe Bindings: Auto-generated Dart bindings for smart contracts
- 🌐 EVM Compatible: Full Ethereum Virtual Machine (EVM) support
- 🚀 Easy Deployment: Simplified contract deployment utilities
- 📦 Web3 Integration: Built on top of `web3dart` for seamless Web3 interactions
- ✨ Auto-Generated Code: Contract bindings automatically generated from Solidity ABIs
