# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-24

### Added
- Initial release of Contract SDK
- Auto-generated Dart bindings for Solidity contracts
- SignalingContract with full UUPS upgrade pattern support
- Support for contract deployment and interaction
- Event listening capabilities
- Comprehensive test suite (38 tests)
  - Static validation tests (ABI and bytecode)
  - Integration tests with Ganache RPC
  - Deployment and interaction tests
- Example code demonstrating SDK usage
- Complete documentation

### Features
- Type-safe contract function calls
- Transaction sending with credentials
- View function calls with proper return type handling
- Helper utilities for hex-to-bytes conversion
- Factory methods for contract connection and deployment

### Testing
- 24 static validation tests
- 4 integration tests (RPC connectivity)
- 10 deployment and interaction tests
- All tests passing with 100% success rate

### Documentation
- Comprehensive README
- Example implementation
- Test documentation
- API reference

[1.0.0]: https://github.com/gualandi/parresia-contract/releases/tag/v1.0.0
