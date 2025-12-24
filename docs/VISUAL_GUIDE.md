# 📊 Pipeline Overview - Visual Guide

## 🎯 The Complete System

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CONTRACT BUILD PIPELINE                          │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                      TRIGGER EVENTS                              │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • Modify .sol contract file                                      │  │
│  │ • Run build command manually                                     │  │
│  │ • Git commit (pre-commit hook)                                  │  │
│  │ • Push to GitHub (GitHub Actions)                               │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │                                   │
│                                     ▼                                   │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                   BUILD EXECUTION (Choose One)                   │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │  $ .\build.ps1          (Windows)                               │  │
│  │  $ ./build.sh           (Linux/Mac)                             │  │
│  │  $ melos run contracts:build    (All platforms)                 │  │
│  │  $ npm run build        (Direct in signaling-contract/)         │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │                                   │
│                                     ▼                                   │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                  PIPELINE STAGES (Sequential)                    │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │                                                                  │  │
│  │  STAGE 1: Hardhat Compile                                       │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │ Input: Solidity contracts (*.sol)                          │ │  │
│  │  │ Process: $ hardhat compile                                 │ │  │
│  │  │ Output: artifacts/contracts/*.json (ABI + Bytecode)        │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                            ▼                                     │  │
│  │  STAGE 2: TypeChain Generation                                  │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │ Input: artifacts/contracts/*.json                          │ │  │
│  │  │ Process: $ hardhat + typechain plugin                      │ │  │
│  │  │ Output: signaling-sdk/src/typeschain/*.ts                  │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                            ▼                                     │  │
│  │  STAGE 3: Dart Binding Generation                               │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │ Input: artifacts/contracts/*.json                          │ │  │
│  │  │ Process: $ node scripts/generate-dart-bindings.js          │ │  │
│  │  │ Output: contract_sdk/lib/generated/*.dart                  │ │  │
│  │  │         contract_sdk/lib/generated/contracts.dart (export) │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                            ▼                                     │  │
│  │  STAGE 4: Validation                                             │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │ Process: $ node scripts/validate-bindings.js               │ │  │
│  │  │ Checks:                                                    │ │  │
│  │  │  ✓ All artifacts have bindings                            │ │  │
│  │  │  ✓ All bindings have correct class definitions            │ │  │
│  │  │  ✓ Exports file is complete                               │ │  │
│  │  │ Output: Success/Failure report                             │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                            ▼                                     │  │
│  │  STAGE 5: Dart Analysis                                          │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │ Process: $ dart analyze (in contract_sdk/)                │ │  │
│  │  │ Checks: Type correctness, imports, etc.                   │ │  │
│  │  │ Output: Success/Failure report                             │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  │                                                                  │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │                                   │
│                                     ▼                                   │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    POST-BUILD AUTOMATION                         │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │                                                                  │  │
│  │  IF Pre-Commit Hook:                                            │  │
│  │  ├─ Detect contract changes                                     │  │
│  │  ├─ Auto-regenerate Dart bindings                               │  │
│  │  └─ Add to commit                                               │  │
│  │                                                                  │  │
│  │  IF GitHub Actions:                                             │  │
│  │  ├─ Run full pipeline on server                                 │  │
│  │  ├─ Run additional tests & analysis                             │  │
│  │  ├─ Verify consistency                                          │  │
│  │  └─ Create PR if changes (on push)                              │  │
│  │                                                                  │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │                                   │
│                                     ▼                                   │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                         RESULT                                   │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ ✅ TypeScript Types Updated                                     │  │
│  │ ✅ Dart Bindings Generated                                      │  │
│  │ ✅ All Types Synchronized                                       │  │
│  │ ✅ Ready for Commit/Deploy                                      │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔀 Build Path Options

### Option 1: Windows PowerShell
```
┌─────────────────┐
│ .\build.ps1     │ ← Full build with all stages
│ .\build.ps1 ts  │ ← TypeScript only
│ .\build.ps1 dar │ ← Dart only
└─────────────────┘
```

### Option 2: Linux/Mac Bash
```
┌──────────────────┐
│ ./build.sh       │ ← Full build
│ ./build.sh ts    │ ← TypeScript only
│ ./build.sh dart  │ ← Dart only
└──────────────────┘
```

### Option 3: Melos (All Platforms)
```
┌────────────────────────────────────┐
│ melos run contracts:build          │ ← Full build
│ melos run contracts:build:typechain│ ← TypeScript only
│ melos run contracts:build:dart     │ ← Dart only
│ melos run dev:setup                │ ← Initial setup
└────────────────────────────────────┘
```

### Option 4: NPM Direct
```
┌────────────────────────────────────┐
│ cd packages/typescript/signaling-contract
│ npm run build                      │ ← Full build
│ npm run build:contracts            │ ← Contracts only
│ npm run build:dart                 │ ← Dart only
│ npm run validate                   │ ← Validate
└────────────────────────────────────┘
```

---

## 📂 File Organization

```
Contract Repository/
│
├── 📄 build.ps1 ............................ Windows build script
├── 📄 build.sh ............................ Linux/Mac build script
├── 📄 melos.yaml .......................... Monorepo config (UPDATED)
│
├── 📁 .github/workflows/
│   └── 📄 build-contracts.yml ............ GitHub Actions (NEW)
│
├── 📁 .git/hooks/
│   └── 📄 pre-commit ..................... Auto-generation hook (NEW)
│
├── 📁 packages/
│   ├── 📁 typescript/
│   │   └── 📁 signaling-contract/
│   │       ├── 📁 contracts/ ............ Solidity files (YOU EDIT)
│   │       ├── 📁 artifacts/ ........... Generated JSONs
│   │       ├── 📁 scripts/
│   │       │   ├── generate-dart-bindings.js
│   │       │   ├── validate-bindings.js (NEW)
│   │       │   └── fix-typechain-index.js
│   │       ├── 📄 package.json ......... (UPDATED)
│   │       └── 📄 hardhat.config.ts
│   │
│   ├── 📁 typescript/
│   │   └── 📁 signaling-sdk/
│   │       └── 📁 src/typeschain/ ..... Generated TS types
│   │
│   └── 📁 contract_sdk/
│       └── 📁 lib/
│           └── 📁 generated/ ......... Generated Dart files
│               ├── contracts.dart (EXPORT)
│               ├── signaling_contract.dart
│               ├── isignaling_contract.dart
│               └── ...
│
├── 📄 BUILD_PIPELINE.md ................. Detailed guide (NEW)
├── 📄 PIPELINE_ARCHITECTURE.md ......... Architecture doc (NEW)
├── 📄 SETUP_SUMMARY.md ................. Summary (NEW)
├── 📄 QUICK_REFERENCE.md .............. Quick commands (NEW)
└── 📄 IMPLEMENTATION_CHECKLIST.md ...... This checklist (NEW)
```

---

## 🔄 Data Flow Diagram

```
                    ┌─────────────────┐
                    │  Modify .sol     │
                    │  Contract        │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Run Build      │
                    │  Command        │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   .ps1 Script         Melos Scripts         npm run
   (Windows)           (All Platforms)       (Direct)
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                             ▼
                    ┌─────────────────────────────┐
                    │  Hardhat Compile            │
                    │  contracts/*.sol → ABI JSON │
                    └────────┬────────────────────┘
                             │
                             ▼
                    ┌─────────────────────────────┐
                    │  TypeChain Generation       │
                    │  ABI JSON → TS types        │
                    └────────┬────────────────────┘
                             │
                             ▼
                    ┌─────────────────────────────┐
                    │  Dart Binding Generation    │
                    │  ABI JSON → .dart files     │
                    └────────┬────────────────────┘
                             │
                             ▼
                    ┌─────────────────────────────┐
                    │  Validation                 │
                    │  Check consistency         │
                    └────────┬────────────────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
            ┌─────────────────┐ ┌─────────────────┐
            │  Ready to Commit│ │  Failure Report │
            │  All Types Sync │ │  Fix & Retry    │
            └─────────────────┘ └─────────────────┘
```

---

## 🎯 Command Cheat Sheet

| Goal | Command |
|------|---------|
| **First time setup** | `.\build.ps1 setup` |
| **Build everything** | `.\build.ps1` or `melos run contracts:build` |
| **Build Dart only** | `.\build.ps1 dart` or `npm run build:dart` |
| **Validate types** | `npm run validate` |
| **Run analysis** | `dart analyze` |
| **Clean artifacts** | `.\build.ps1 clean` or `melos run clean` |

---

## ⚙️ How Pre-Commit Hook Works

```
┌──────────────────────────────────────┐
│  User runs: git commit               │
└──────────────────────┬───────────────┘
                       │
                       ▼
          ┌────────────────────────┐
          │ Pre-commit Hook Runs   │
          │ (.git/hooks/pre-commit)│
          └────────────┬───────────┘
                       │
          ┌────────────┴────────────┐
          │ Check: Are contracts   │
          │ modified?              │
          └────────┬───────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
       YES                    NO
        │                     │
        ▼                     ▼
   ┌─────────────┐      ┌──────────┐
   │ Auto-regen  │      │ Skip     │
   │ Dart        │      │ Hook     │
   │ Add to      │      │ Pass     │
   │ commit      │      │          │
   └────┬────────┘      └────┬─────┘
        │                    │
        └────────┬───────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Commit Proceeds  │
        └──────────────────┘
```

---

## 🔄 Synchronization Points

```
LOCAL DEVELOPMENT
├─ Pre-commit hook
│  └─ Auto-regenerates Dart when committing contracts
├─ Build scripts (PS1/SH/NPM)
│  └─ Manual builds on demand
└─ Validation
   └─ Ensures types match

VERSION CONTROL
├─ Commit hooks
│  └─ Prevent out-of-sync commits
└─ Both TS and Dart committed together

CI/CD PIPELINE
├─ GitHub Actions trigger
│  ├─ Full rebuild
│  ├─ Run tests
│  └─ Create PR if changes
└─ Automated validation
   └─ Ensures consistency
```

---

## ✅ Quality Assurance

```
┌─────────────────────────────────────┐
│  Validation Layer 1: Local Build    │
├─────────────────────────────────────┤
│ ✓ Checks all artifacts exist        │
│ ✓ Verifies binding structure        │
│ ✓ Validates exports file            │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  Validation Layer 2: Pre-Commit     │
├─────────────────────────────────────┤
│ ✓ Detects contract changes          │
│ ✓ Auto-regenerates Dart             │
│ ✓ Ensures sync before commit        │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  Validation Layer 3: CI/CD          │
├─────────────────────────────────────┤
│ ✓ Rebuilds from scratch             │
│ ✓ Runs full analysis                │
│ ✓ Validates all platforms           │
│ ✓ Creates PR if needed              │
└─────────────────────────────────────┘
```

---

## 🎓 Key Concepts

- **ABI (Application Binary Interface)**: JSON description of contract functions
- **TypeChain**: Generates TypeScript types from ABI
- **Dart Bindings**: Generated Dart classes wrapping web3dart for contract interaction
- **Pre-commit Hook**: Automatic script that runs before git commits
- **GitHub Actions**: CI/CD automation platform
- **Melos**: Monorepo tool that manages multiple packages

---

**Ready to use? Start with:**
```bash
.\build.ps1 setup    # Windows
./build.sh setup     # Linux/Mac
melos run dev:setup  # Any platform
```
