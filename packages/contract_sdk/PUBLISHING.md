# Publishing Guide

This document explains how to publish the `signaling_contract_sdk` package to pub.dev.

## Prerequisites

1. Have a pub.dev account (register at https://pub.dev)
2. Have `dart` installed and configured
3. Ensure you have the required credentials

## Pre-Publishing Checklist

- [x] Update version in `pubspec.yaml` - Version 1.0.2 ready
- [x] Update CHANGELOG.md with changes - Complete with full release history
- [x] Run `dart format .` to format code - Code formatted and committed
- [x] Run `dart analyze` to check for issues - Analyzed (minor issues in generated code only)
- [x] Ensure all generated code is up-to-date - Verified and formatted
- [x] Review README.md for accuracy - Documentation is complete and accurate
- [x] Check that no sensitive information is included - Verified

## Publishing Steps

1. **Verify your pub.dev credentials**:
   ```bash
   dart pub login
   ```

2. **Run pre-publish checks**:
   ```bash
   dart pub publish --dry-run
   ```

3. **Publish to pub.dev**:
   ```bash
   dart pub publish
   ```

## After Publishing

1. Create a release on GitHub with the same version number
2. Update documentation links if necessary
3. Announce the new release in relevant channels

## Version Management

Follow [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for new features (backward compatible)
- PATCH version for bug fixes (backward compatible)

## Troubleshooting

### Published version not showing up

Wait up to 5 minutes for pub.dev to index the new version.

### Need to unpublish?

Use:
```bash
dart pub unpublish signaling_contract_sdk:VERSION
```

This can only be done within 24 hours of publishing.

## Documentation

After publishing, documentation will be automatically generated at:
https://pub.dev/documentation/signaling_contract_sdk/latest/

Ensure your code has proper dartdoc comments for best results.
