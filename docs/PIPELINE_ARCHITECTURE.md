# Pipeline Architecture - Contract Building & Type Generation

## 📋 Sommario

Questo documento descrive la pipeline automatizzata per:
1. **Compilare i contratti smart Solidity** (TypeScript - Hardhat)
2. **Generare i tipi TypeScript** (TypeChain)
3. **Generare i binding Dart** automaticamente dalla repo Dart

---

## 🏗️ Architettura Generale

```
┌─────────────────────────────────────────────────────────┐
│                    MONOREPO (melos)                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  packages/typescript/signaling-contract/         │  │
│  │  • Contratti Solidity                            │  │
│  │  • Configurazione Hardhat                        │  │
│  │  • Script di compilazione                        │  │
│  └──────────────┬───────────────────────────────────┘  │
│                 │                                       │
│                 ▼                                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Build Pipeline:                                 │  │
│  │  1. Hardhat Compile → ABI + Bytecode            │  │
│  │  2. TypeChain → TypeScript Types                │  │
│  │  3. Dart Bindings Generator → Dart Files       │  │
│  │  4. Validation                                   │  │
│  └──────────────┬───────────────────────────────────┘  │
│                 │                                       │
│                 ▼                                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Outputs:                                        │  │
│  │  • artifacts/contracts/*.json (ABI+Bytecode)   │  │
│  │  • signaling-sdk/src/typeschain/ (TS types)     │  │
│  │  • contract_sdk/lib/generated/ (Dart binding)   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  packages/contract_sdk/                          │  │
│  │  • Dart SDK con binding generati                │  │
│  │  • Usato da app Flutter/Dart                    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Setup iniziale (Windows PowerShell)
```powershell
# Eseguire da root directory
.\build.ps1 setup

# Oppure manualmente:
melos run dev:setup
```

### Setup iniziale (Linux/Mac)
```bash
./build.sh setup

# Oppure manualmente:
melos run dev:setup
```

### Build completo
```bash
# Windows
.\build.ps1 full

# Linux/Mac
./build.sh full

# Oppure con melos
melos run contracts:build
```

---

## 📁 File Generati

### TypeScript Types (signaling-sdk)
```
packages/typescript/signaling-sdk/src/typeschain/
├── index.ts
├── common.ts
├── hardhat.d.ts
├── @openzeppelin/
│   ├── index.ts
│   ├── contracts/
│   │   ├── index.ts
│   │   ├── interfaces/
│   │   ├── proxy/
│   │   └── utils/
│   └── contracts-upgradeable/
│       ├── index.ts
│       ├── access/
│       ├── proxy/
│       └── utils/
└── contracts/
    ├── index.ts
    ├── ISignaling.ts
    ├── Signaling.ts
    └── factories/
```

**Generati da:** Hardhat TypeChain plugin
**Quando:** Durante compilazione Hardhat
**Usati da:** TypeScript SDK e deploy scripts

### Dart Bindings (contract_sdk)
```
packages/contract_sdk/lib/generated/
├── contracts.dart              ← Export principale
├── signaling_contract.dart     ← Binding per Signaling
├── isignaling_contract.dart    ← Binding per ISignaling
└── ...
```

**Generati da:** `scripts/generate-dart-bindings.js`
**Quando:** Fase build:dart
**Usati da:** Dart/Flutter apps

---

## 🔄 Flussi di Lavoro

### 1. Modificare un Contratto Solidity

```bash
# 1. Modifica il file .sol
# vim packages/typescript/signaling-contract/contracts/Signaling.sol

# 2. Compila e genera types
melos run contracts:build

# OPPURE:
cd packages/typescript/signaling-contract
npm run build

# 3. Verifica i cambiamenti
git status
# Vedrai cambiamenti in:
# - artifacts/contracts/*.json
# - signaling-sdk/src/typeschain/
# - contract_sdk/lib/generated/

# 4. Commit entrambi i tipi
git add packages/
git commit -m "feat: update Signaling contract"
```

### 2. Rigenerare Binding Dart (dai contratti esistenti)

```bash
# Se hanno cambiamenti solo gli artifacts:
melos run contracts:build:dart

# OPPURE:
cd packages/typescript/signaling-contract
npm run build:dart
```

### 3. Workflow Completo in CI/CD

Automaticamente su push:
1. GitHub Actions legge il file `.github/workflows/build-contracts.yml`
2. Compila i contratti
3. Genera binding Dart
4. Esegue validazione
5. Crea PR se ci sono cambiamenti

---

## 📦 NPM Scripts (signaling-contract)

```bash
npm run build          # Full: compile + typechain + dart + validate
npm run build:contracts  # Compile Solidity (Hardhat + TypeChain)
npm run build:typechain  # TypeChain types only
npm run build:dart     # Dart bindings only  
npm run validate       # Validate generated bindings
npm run deploySC       # Deploy to localhost
npm run deploySC:ganache  # Deploy to Ganache
npm run network        # Start local Hardhat node
npm run clean          # Clean artifacts
```

---

## 🛠️ Melos Scripts (Root)

```bash
melos run contracts:build           # Full pipeline
melos run contracts:build:typechain  # TypeChain only
melos run contracts:build:dart      # Dart generation only
melos run dev:setup                 # Setup environment
melos run analyze                   # Dart analysis
melos run test                      # Run tests
melos run format                    # Format code
melos run clean                     # Clean all artifacts
```

---

## 🧬 Generazione Dart Binding - Come Funziona

### Fase 1: Lettura Artifacts
```javascript
// scripts/generate-dart-bindings.js legge:
artifacts/contracts/
├── ISignaling.json (ABI + bytecode)
├── Signaling.json
└── ...
```

### Fase 2: Generazione Classe Dart
Per ogni contratto, genera:
```dart
// signaling_contract.dart
class SignalingContract {
  static const String contractAbi = '...';
  static const String contractBytecode = '...';
  
  // Metodi per view functions
  Future<bool> isPaused() async { ... }
  
  // Metodi per write functions  
  Future<String> emit(...) async { ... }
}
```

### Fase 3: Export File
```dart
// contracts.dart - aggregazione di tutti i binding
export 'signaling_contract.dart';
export 'isignaling_contract.dart';
// ...
```

### Fase 4: Validazione
Lo script `validate-bindings.js` verifica:
- ✅ Tutti gli artifacts hanno un binding Dart
- ✅ Ogni binding contiene la classe corretta
- ✅ Export file esiste e è completo

---

## 🔗 Sincronizzazione Automatica

### Pre-Commit Hook
File: `.git/hooks/pre-commit`

Se modifichi un contratto e provi a committare:
```bash
git add packages/typescript/signaling-contract/contracts/Signaling.sol
git commit -m "Update contract"

# Hook automaticamente:
# 1. Rileva cambio in contracts/
# 2. Esegue: npm run build:dart
# 3. Aggiunge generated files al commit
```

### GitHub Actions
File: `.github/workflows/build-contracts.yml`

Trigger:
- Push a `main` o `develop`
- PR che modifica contratti
- Trigger manuale

Azioni:
```
Build Contracts → Generate Bindings → Validate → Analyze → Create PR (se necessario)
```

---

## 🐛 Troubleshooting

### Binding Dart fuori sincronia

```bash
# Rigenerare tutto da zero
melos run contracts:build

# Se ancora problemi:
melos run clean
melos run dev:setup
```

### Errori TypeScript

```bash
# Ripulire e ricompilare
cd packages/typescript/signaling-contract
npm run clean
npm install
npm run build
```

### Errori Dart Analysis

```bash
cd packages/contract_sdk
dart pub get
dart analyze
```

### File generati corrotti

```bash
# Reset totale
melos run clean
rm -rf packages/contract_sdk/lib/generated/*
npm run build
```

---

## ✅ Checklist per Modifche

Quando modifichi un contratto:

- [ ] Modifica il file `.sol`
- [ ] Esegui `melos run contracts:build`
- [ ] Verifica che non ci siano errori
- [ ] Controlla i generated files cambiati
- [ ] Esegui `dart analyze` in contract_sdk
- [ ] Commit sia TS che Dart changes
- [ ] Pushen (GitHub Actions verificherà tutto)

---

## 📚 Link Utili

- [Hardhat Docs](https://hardhat.org/)
- [TypeChain](https://github.com/dethcrypto/TypeChain)
- [web3dart](https://pub.dev/packages/web3dart)
- [Solidity Docs](https://docs.soliditylang.org/)
- [Dart Language](https://dart.dev/guides)
- [Melos](https://melos.invertase.dev/)

---

## 📝 Note Importanti

⚠️ **Non modificare manualmente:**
- `packages/contract_sdk/lib/generated/` 
- `packages/typescript/signaling-sdk/src/typeschain/`

✅ **Sempre eseguire build dopo:**
- Modifche ai contratti Solidity
- Modifche a `hardhat.config.ts`
- Modifche a `package.json` (dipendenze)

✅ **Best practices:**
- Committo sempre entrambi i generated files (TS e Dart)
- Usa gli script melos per consistenza
- Valida prima di committare
- Usa CI/CD per verifiche automatiche
