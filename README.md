# Contract Monorepo

Monorepo contenente smart contracts Solidity e SDK Dart per interagire con la blockchain.

## Quick Start

```bash
# 1. Installa Melos (una sola volta)
dart pub global activate melos

# 2. Bootstrap il monorepo
melos bootstrap

# 3. Compila i contratti e genera i binding Dart
melos run contracts:build
```

## Documentazione

La documentazione completa è disponibile nella cartella [docs/](docs/):

- **[docs/START_HERE.md](docs/START_HERE.md)** - Guida 30 secondi per iniziare
- **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** - Cheat sheet dei comandi Melos
- **[docs/BUILD_PIPELINE.md](docs/BUILD_PIPELINE.md)** - Guida dettagliata della pipeline
- **[docs/PIPELINE_ARCHITECTURE.md](docs/PIPELINE_ARCHITECTURE.md)** - Architettura del sistema
- **[docs/VISUAL_GUIDE.md](docs/VISUAL_GUIDE.md)** - Diagrammi e flowchart

## Struttura del Progetto

Vedi [STRUCTURE.md](STRUCTURE.md) per una spiegazione dettagliata della struttura dei directory.

```
Contract/
├── docs/                      # Tutta la documentazione
├── packages/                  # Monorepo packages
│   ├── contract_sdk/          # SDK Dart
│   └── typescript/            # Smart contracts
├── .github/workflows/         # GitHub Actions CI/CD
├── melos.yaml                 # Configurazione Melos
└── README.md                  # Questo file
```

## Comandi Principais

```bash
# Build completo (TypeScript + Dart + Validazione)
melos run contracts:build

# Build solo TypeScript
melos run contracts:build:typechain

# Build solo Dart
melos run contracts:build:dart

# Setup iniziale (con install dipendenze)
melos run dev:setup

# Format codice
melos run format

# Analisi codice
melos run analyze

# Test
melos run test

# Pulizia
melos run clean
```

## Smart Contracts Disponibili

### Signaling Contract

Contract per WebRTC signaling on-chain.

**Funzionalità:**
- `setOffer`: Pubblica un'offerta WebRTC
- `setAnswer`: Pubblica una risposta a un'offerta
- `getOffer`: Recupera un'offerta
- `getAnswer`: Recupera una risposta
- `initialize`: Inizializza il contratto
- `transferOwnership`: Trasferisce la proprietà
- Eventi: `proposeOffer`, `proposeAnswer`

## SDK Dart (contract_sdk)

### Utilizzo Base

```dart
import 'package:contract_sdk/generated/signaling_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:typed_data';

void main() async {
  // Connessione al contratto
  final signaling = await SignalingContract.connect(
    rpcUrl: 'https://localhost:8545',
    contractAddress: EthereumAddress.fromHex('0x...'),
  );

  // Pubblica un'offerta
  final offerData = Uint8List.fromList('WebRTC Offer SDP'.codeUnits);
  final txHash = await signaling.setOffer(offerData);
  print('Offerta pubblicata: $txHash');

  // Recupera un'offerta
  final offer = await signaling.getOffer(
    EthereumAddress.fromHex('0x...'),
  );
  print('Offerta: $offer');
}
```

## Features

✅ Pipeline automatica: TypeScript → TypeChain → Dart binding generation  
✅ Validazione automatica dei binding generati  
✅ Pre-commit hooks per sincronizzazione  
✅ CI/CD con GitHub Actions  
✅ Melos per orchestrazione monorepo  
✅ Test automatici  

## Sviluppo

### Prerequisiti

- Dart SDK >=3.0.0
- Node.js (per i contratti TypeScript)
- Melos: `dart pub global activate melos`

### Test

```bash
melos run test
```

### Build Contratti

```bash
melos run contracts:build
```

## Licenza

UNLICENSED
