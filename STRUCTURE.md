# Struttura del Progetto

## Directory Principali

### Root

```
├── docs/                      # Tutta la documentazione
│   ├── START_HERE.md
│   ├── QUICK_REFERENCE.md
│   ├── BUILD_PIPELINE.md
│   ├── PIPELINE_ARCHITECTURE.md
│   ├── VISUAL_GUIDE.md
│   ├── README_PIPELINE.md
│   ├── MELOS_ONLY.md
│   ├── SETUP_SUMMARY.md
│   └── IMPLEMENTATION_CHECKLIST.md
│
├── packages/                  # Monorepo packages
│   ├── contract_sdk/          # SDK Dart
│   └── typescript/            # Smart contracts
│
├── .github/workflows/         # GitHub Actions
│   └── build-contracts.yml    # CI/CD pipeline
│
├── melos.yaml                 # Configurazione Melos (monorepo)
├── pubspec.yaml               # Root pubspec (Dart)
├── README.md                  # Questo file
└── CHANGELOG.md               # Changelog
```

### packages/contract_sdk (SDK Dart)

```
contract_sdk/
├── lib/
│   ├── contract_sdk.dart              # Entry point
│   ├── generated/                     # ⚠️ AUTO-GENERATED
│   │   ├── contracts.dart             # Esporta tutti i binding
│   │   ├── signaling_contract.dart    # Binding auto-generato
│   │   └── isignaling_contract.dart   # Binding auto-generato
│   └── src/                           # Codice sorgente
│       ├── signaling_contract.dart
│       └── models/
│           ├── signal.dart
│           └── algorithm.dart
├── test/
│   ├── contract_sdk_test.dart
│   ├── signaling_contract_test.dart   # ✨ Test nuovi
│   └── generated_contracts_test.dart
├── example/
│   └── main.dart
└── pubspec.yaml
```

### packages/typescript/signaling-contract (Smart Contracts)

```
signaling-contract/
├── contracts/                         # Codice sorgente Solidity
│   ├── ISignaling.sol
│   └── Signaling.sol
├── ignition/
│   └── modules/                       # Deployment scripts
│       ├── DeploySignaling.ts
│       └── DeployUpgradable.ts
├── scripts/
│   ├── generate-dart-bindings.js      # 🔧 Generator Dart
│   ├── validate-bindings.js           # 🔍 Validatore
│   └── fix-typechain-index.js
├── artifacts/                         # ⚠️ AUTO-GENERATED
│   ├── contracts/                     # ABI JSON dei contratti
│   ├── @openzeppelin/                 # Dipendenze
│   └── build-info/
├── cache/                             # ⚠️ AUTO-GENERATED (Hardhat)
│   └── solidity-files-cache.json
├── package.json                       # NPM scripts
└── hardhat.config.ts                  # Configurazione Hardhat
```

## Directory Auto-Generate (in .gitignore)

⚠️ Questi file **NON** devono essere committati, vengono rigenerati da `melos run contracts:build`

### Dart
- `packages/contract_sdk/.dart_tool/` - Cache Dart
- `packages/contract_sdk/build/` - Build output
- `packages/contract_sdk/lib/generated/` - Binding auto-generati

### TypeScript
- `packages/typescript/signaling-contract/artifacts/` - ABI JSON e build info
- `packages/typescript/signaling-contract/cache/` - Cache Hardhat
- `packages/typescript/signaling-contract/node_modules/` - Dipendenze NPM
- `packages/typescript/signaling-contract/typechain-types/` - TypeChain generato

## Directory da Gestire Manualmente

✅ Questi file dovrebbero essere committati:

### Documenti Sorgente
- `contracts/` - Codice sorgente Solidity
- `ignition/` - Deployment scripts
- `scripts/` - Build e generation scripts
- `lib/src/` - Codice sorgente Dart
- `test/` - Test

### Configurazione
- `melos.yaml` - Configurazione monorepo
- `pubspec.yaml` - Configurazione Dart
- `package.json` - Configurazione NPM
- `hardhat.config.ts` - Configurazione Hardhat
- `.gitignore` - File da ignorare
- `.env.example` - Template variabili d'ambiente

### Documentazione
- `README.md` - Documentazione principale
- `docs/` - Documentazione dettagliata
- `CHANGELOG.md` - Changelog

## Flusso di Build

```
melos run contracts:build
    ├── 1. Build TypeScript/Solidity
    │   ├── npx hardhat compile
    │   └── Genera: artifacts/*.json (ABI)
    │
    ├── 2. Genera Dart bindings
    │   ├── generate-dart-bindings.js
    │   └── Genera: lib/generated/*.dart
    │
    └── 3. Validazione
        ├── validate-bindings.js
        └── Verifica: coherenza ABI ↔️ Dart
```

## Clean Directories

Per pulire le directory auto-generate:

```bash
# Rimuovi tutti i file auto-generati
melos run clean

# Oppure manualmente
rm -rf packages/contract_sdk/.dart_tool packages/contract_sdk/build
rm -rf packages/typescript/signaling-contract/artifacts cache node_modules
```

## Tips di Organizzazione

### Aggiungere nuovo contratto

1. Crea `packages/typescript/signaling-contract/contracts/NewContract.sol`
2. Esegui `melos run contracts:build`
3. Verificherà e genererà il binding Dart automaticamente

### Aggiungere nuovi test

1. Crea file test in `packages/contract_sdk/test/new_contract_test.dart`
2. Esegui `melos run test`

### Aggiungere documentazione

1. Crea file in `docs/`
2. Linea dal README.md

## File Critici

| File | Ruolo | Tipo |
|------|-------|------|
| `melos.yaml` | Orchestrazione monorepo | Config |
| `generate-dart-bindings.js` | Genera SDK Dart da ABI | Script |
| `validate-bindings.js` | Valida coerenza | Script |
| `.github/workflows/build-contracts.yml` | CI/CD automation | Workflow |
| `lib/generated/*` | Binding Dart | Auto-gen |
| `artifacts/contracts/*` | ABI contratti | Auto-gen |
