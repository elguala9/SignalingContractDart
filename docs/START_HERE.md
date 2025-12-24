# 🚀 START HERE - Contract Build Pipeline

## ⚡ 30 Second Setup

```bash
# One time setup
melos run dev:setup

# Then build anytime
melos run contracts:build
```

Done! ✅

---

## What You Have

A **unified build pipeline with Melos** that:

- ✅ Compiles Solidity contracts (Hardhat)
- ✅ Generates TypeScript types (TypeChain)
- ✅ Automatically generates Dart bindings
- ✅ Validates everything is in sync
- ✅ Syncs on pre-commit (auto-generation)
- ✅ CI/CD ready (GitHub Actions)

---

## 🎯 Workflow

```
1. Modify Solidity contract
   ↓
2. melos run contracts:build
   ↓
3. Hardhat → TypeChain → Dart bindings → Validated
   ↓
✅ Commit (TS + Dart in sync)
```

---

## ✨ Features

✅ **Melos-powered** - Single unified tool
✅ **Automatic sync** - TS and Dart always together
✅ **Pre-commit hooks** - Auto Dart generation
✅ **CI/CD ready** - GitHub Actions validated
✅ **Built-in validation** - Consistency checks
✅ **Well documented** - Full guides included

---

## 📋 What to Do Next

1. **First time setup**
   ```bash
   melos run dev:setup
   ```

2. **Build after modifying contract**
   ```bash
   melos run contracts:build
   ```

3. **Commit changes**
   ```bash
   git add packages/
   git commit -m "Update contract"
   # Pre-commit hook auto-regenerates Dart
   ```

---

## 🔧 All Melos Commands

```bash
melos run contracts:build           # Full build (TS + Dart + validate)
melos run contracts:build:typechain # TypeScript types only
melos run contracts:build:dart      # Dart bindings only
melos run dev:setup                 # Initial setup
melos run analyze                   # Dart analysis
melos run test                      # Run tests
melos run clean                     # Clean artifacts
```
- **Detailed guide**: [BUILD_PIPELINE.md](BUILD_PIPELINE.md)  
- **Visual flows**: [VISUAL_GUIDE.md](VISUAL_GUIDE.md)
- **Architecture** (ITA): [PIPELINE_ARCHITECTURE.md](PIPELINE_ARCHITECTURE.md)
- **Setup info**: [SETUP_SUMMARY.md](SETUP_SUMMARY.md)
- **Checklist**: [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)

---

## ✨ The Result

You now have:

🔵 **One-Command Builds**
```bash
.\build.ps1          # Full build in one command
melos run contracts:build
npm run build
```

🔵 **Automatic Type Generation**
- Solidity → ABI (Hardhat)
- ABI → TypeScript types (TypeChain)
- ABI → Dart bindings (Custom script)

🔵 **Type Safety**
- Pre-commit validation
- GitHub Actions verification
- Build-time checks

🔵 **Developer Experience**
- Multiple execution methods
- Clear error messages
- Comprehensive documentation
- Platform support (Windows, Mac, Linux)

---

## 🚨 Important Notes

⚠️ **Do NOT manually edit:**
- `packages/contract_sdk/lib/generated/` - Auto-generated Dart
- `packages/typescript/signaling-sdk/src/typeschain/` - Auto-generated TypeScript

✅ **Always:**
- Run build after contract changes
- Commit both TS and Dart generated files together
- Validate before pushing

---

## 🎯 Common Commands

```bash
# Setup environment
melos run dev:setup          # All packages

# Build
melos run contracts:build    # Everything
melos run contracts:build:dart  # Dart only
npm run build:dart          # Direct

# Analysis
dart analyze                # Analyze Dart
melos run analyze          # All packages

# Clean
melos run clean            # Clean all artifacts
npm run clean              # Clean contracts

# Format
melos run format           # Format all code
```

---

## 📞 Troubleshooting

**Q: Types out of sync**
A: `melos run contracts:build`

**Q: Dart won't analyze**  
A: `cd packages/contract_sdk && dart pub get && dart analyze`

**Q: Pre-commit not working**  
A: `chmod +x .git/hooks/pre-commit` (Mac/Linux)

**Q: Still having issues**  
A: `melos run clean && melos run dev:setup`

---

## ✅ Verification Checklist

- [x] Pipeline files created
- [x] Melos configured
- [x] NPM scripts updated
- [x] Pre-commit hook installed
- [x] GitHub Actions configured
- [x] Validation script added
- [x] Documentation written
- [ ] **Local testing** ← Your turn!
- [ ] Commit changes
- [ ] Push to GitHub

---

## 🎊 Success Criteria

Your pipeline is working when:

✅ `.\build.ps1` completes without errors  
✅ Generated files appear in `contract_sdk/lib/generated/`  
✅ Pre-commit hook runs automatically  
✅ GitHub Actions workflow runs on push  
✅ Dart analysis passes  
✅ No type mismatches between TS and Dart  

---

**Ready? Start with:**
```bash
.\build.ps1 setup    # Windows
./build.sh setup     # Linux/Mac
```

**Questions? Check:**
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Commands
- [BUILD_PIPELINE.md](BUILD_PIPELINE.md) - Full guide
- [VISUAL_GUIDE.md](VISUAL_GUIDE.md) - Diagrams

---

**🎉 Your automated contract build pipeline is ready!**
