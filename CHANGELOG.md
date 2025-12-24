# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-23

### Added
- Initial release of contract_sdk
- SignalingContract SDK for WebRTC signaling on-chain
  - `setOffer()` - Publish WebRTC offers
  - `setAnswer()` - Publish WebRTC answers
  - `getOffer()` - Retrieve offers
  - `getAnswer()` - Retrieve answers
  - Event listeners for real-time updates
- CryptoAlgorithmRegistry SDK for trustless algorithm storage
  - `storeAlgorithm()` - Upload algorithms on-chain
  - `getAlgorithm()` - Download algorithms
  - `verifyIntegrity()` - Verify code integrity via hash
  - `listAlgorithms()` - List all available algorithms
  - `downloadAndVerify()` - Download with automatic verification
- Signal data model
- Algorithm data model
- Comprehensive examples and documentation
- Unit tests for core functionality
- Melos monorepo configuration
- Complete README with usage examples
- Deployment guide (DEPLOY.md)

### Security
- Keccak256 hash verification for code integrity
- No external dependencies for core trustless features
- Private key handling best practices documented

## [Unreleased]

### Planned
- Compression support for algorithms (zlib)
- Automatic chunking for large algorithms
- WASM binary support
- Web UI for browsing algorithms
- Marketplace with rating system
- Multi-chain support (Polygon, Arbitrum, BSC)
- Enhanced error handling and retry logic
- Offline mode with cached algorithms
- Algorithm versioning and migration tools
