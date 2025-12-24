# 📖 Documentation Index

## Quick Links

### 🚀 Getting Started (Start Here)
1. **[START_HERE.md](START_HERE.md)** - 30-second setup with Melos
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Melos commands cheat sheet

### 📚 Comprehensive Guides
- **[BUILD_PIPELINE.md](BUILD_PIPELINE.md)** - Complete development workflow
- **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Architecture diagrams
- **[PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)** - Detailed architecture (Italian)
- **[SETUP_SUMMARY.md](SETUP_SUMMARY.md)** - Setup overview

### ✅ Reference
- **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - What was built

---

## By Use Case

### "I just want to build"
→ Start with [START_HERE.md](START_HERE.md)

```bash
melos run dev:setup       # First time
melos run contracts:build # Then this
```

### "I need Melos commands"  
→ See [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

### "I want to understand the system"
→ Read [PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)

### "I need diagrams"
→ Check [VISUAL_GUIDE.md](VISUAL_GUIDE.md)

### "I want full details"
→ Full guide in [BUILD_PIPELINE.md](BUILD_PIPELINE.md)

---

## Melos Commands (All You Need)

```bash
melos run contracts:build           # ← MAIN: Full build
melos run contracts:build:typechain # TypeScript types only
melos run contracts:build:dart      # Dart bindings only
melos run dev:setup                 # Initial setup
melos run analyze                   # Dart analysis
melos run test                      # Tests
melos run format                    # Format code
melos run clean                     # Clean artifacts
```

---

## Files Overview

### Documentation (*.md)

| File | Purpose | Read Time |
|------|---------|-----------|
| START_HERE.md | 30-second setup with Melos | 2 min |
| QUICK_REFERENCE.md | Melos commands cheat sheet | 3 min |
| BUILD_PIPELINE.md | Complete guide | 15 min |
| VISUAL_GUIDE.md | Diagrams and flows | 10 min |
| PIPELINE_ARCHITECTURE.md | Architecture (Italian) | 20 min |
| SETUP_SUMMARY.md | Setup overview | 8 min |

### Configuration Files

| File | Purpose |
|------|---------|
| melos.yaml | Monorepo config with build scripts |
| package.json | NPM scripts (enhanced) |
| .github/workflows/build-contracts.yml | GitHub Actions CI/CD |
| .git/hooks/pre-commit | Auto Dart generation |
| scripts/validate-bindings.js | Binding validation |

---

## Common Tasks

### Setup
```bash
melos run dev:setup
```

### Build Everything
```bash
melos run contracts:build
```

### Build Only Dart
```bash
melos run contracts:build:dart
```

### Understand the Pipeline
→ Read [VISUAL_GUIDE.md](VISUAL_GUIDE.md)

### Troubleshooting
```bash
melos run clean
melos run dev:setup
melos run contracts:build
```

---

## Technology Stack

- **Solidity** - Smart contracts
- **Hardhat** - Ethereum development framework
- **TypeChain** - TypeScript type generation
- **Dart/web3dart** - Blockchain interaction
- **Melos** - Monorepo management
- **GitHub Actions** - CI/CD automation

---

## Key Concepts

### ABI (Application Binary Interface)
- JSON specification of contract functions
- Used to generate TypeScript and Dart types

### TypeChain
- Generates TypeScript types from ABI
- Creates type-safe contract interaction code

### Dart Bindings
- Generated Dart code for contract interaction
- Wraps web3dart for communication

### Pre-commit Hook
- Automatically regenerates Dart when contracts change
- Prevents out-of-sync commits

### GitHub Actions
- Automated CI/CD on push/PR
- Validates type synchronization

### Melos
- Monorepo tool managing multiple packages
- Coordinates builds across packages

---

## Architecture

```
Modify .sol Contract
    ↓
melos run contracts:build
    ↓
Hardhat Compile → TypeChain → Dart Generation → Validation
    ↓
✅ TS + Dart types synchronized
```

---

## Next Steps

1. **Read**: [START_HERE.md](START_HERE.md)
2. **Setup**: `melos run dev:setup`
3. **Build**: `melos run contracts:build`
4. **Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
