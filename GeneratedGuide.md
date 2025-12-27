# Generated Code Guide

Questa guida spiega come il codice Dart viene generato automaticamente dai smart contract Solidity e come usarlo.

## 📋 Panoramica

Il monorepo ha una **pipeline di generazione automatica** che:
1. Compila i contratti Solidity (TypeScript)
2. Genera bindings Dart dal bytecode e dall'ABI
3. Crea file Dart pronti all'uso per interagire con i contratti

## 🔄 Flusso di Generazione

```
Solidity Contract (.sol)
        ↓
   Hardhat compila
        ↓
   Artefatti JSON
   (ABI + Bytecode)
        ↓
   Script di generazione JS
        ↓
   Binding Dart (.dart)
```

## 🛠️ Come Rigenerare il Codice

### 1. Modifica il contratto Solidity

Se cambi un contratto in `packages/typescript/signaling-contract/contracts/`:

```bash
cd packages/typescript/signaling-contract
```

### 2. Compila il contratto

```bash
npm run compile
```

Questo genera gli artefatti JSON in `artifacts/contracts/`.

### 3. Genera i bindings Dart

```bash
node scripts/generate-dart-bindings.js
```

Oppure direttamente dalla root:

```bash
cd packages/typescript/signaling-contract && node scripts/generate-dart-bindings.js
```

## 📄 File Generati

**Ubicazione:** `packages/contract_sdk/lib/generated/`

### Singoli Binding
- `signaling_contract.dart` - Classe `SignalingContract` con tutti i metodi

### File di Export
- `contracts.dart` - Esporta tutti i binding e le utility

## 💡 Come Usare i Binding

### 1. Connettere a un Contratto Esistente

```dart
import 'package:contract_sdk/generated/contracts.dart';

final contract = await SignalingContract.connect(
  rpcUrl: 'https://your-rpc-provider',
  contractAddress: EthereumAddress.fromHex('0x...'),
  credentials: privateKey, // opzionale se leggi solo
);
```

### 2. Deployare un Nuovo Contratto

```dart
final contract = await SignalingContract.deploy(
  rpcUrl: 'https://your-rpc-provider',
  credentials: privateKey,
);

print('Deployed at: ${contract.contract.address}');
```

Il metodo `deploy`:
- Invia la transazione
- Aspetta la ricevuta (polling max 60 secondi)
- Ritorna un'istanza pronta all'uso

### 3. Leggere Dati (View Functions)

```dart
final ownerAddress = await contract.owner();
final offer = await contract.getOffer(someAddress);
```

### 4. Scrivere Dati (Transaction Functions)

```dart
final txHash = await contract.setOffer(Uint8List.fromList([1, 2, 3]));
print('Transaction: $txHash');
```

## 📝 Struttura del Binding Generato

Ogni file di binding contiene:

```dart
class SignalingContract {
  // ABI e Bytecode come costanti
  static const String contractAbi = '...';
  static const String contractBytecode = '0x...';

  // Client e contratto
  final Web3Client client;
  final DeployedContract contract;
  final EthPrivateKey? credentials;

  // Factory per connettere
  static Future<SignalingContract> connect(...) async { ... }

  // Factory per deployare
  static Future<SignalingContract> deploy(...) async { ... }

  // Metodi generati da ogni funzione del contratto
  Future<String> setOffer(Uint8List offer) async { ... }
  Future<dynamic> getOffer(EthereumAddress offerer) async { ... }
  // ...
}
```

## 🔧 Script di Generazione

**File:** `packages/typescript/signaling-contract/scripts/generate-dart-bindings.js`

### Cosa fa:

1. **Legge gli artefatti** da `artifacts/contracts/*.json`
2. **Estrae ABI e bytecode** dal JSON
3. **Genera il template Dart** con:
   - Metodo `connect()` - per contratti già deployati
   - Metodo `deploy()` - per deployare nuovi contratti
   - Metodi per ogni funzione Solidity
4. **Crea il file di output** in `contract_sdk/lib/generated/`

### Mapping Solidity → Dart:

| Solidity | Dart |
|----------|------|
| `address` | `EthereumAddress` |
| `bytes` | `Uint8List` |
| `string` | `String` |
| `bool` | `bool` |
| `uint*` / `int*` | `BigInt` |
| `T[]` | `List<DartType>` |

### Funzioni generate:

- **View/Pure** → `Future<ReturnType>`
- **State-changing** → `Future<String>` (tx hash)

## ⚠️ Note Importanti

1. **NON MODIFICARE** i file generati direttamente
   - Vengono sovrascritti ad ogni rigenerazione
   - Apporta i cambiamenti al contratto Solidity

2. **Aggiungi credenziali per transazioni**
   ```dart
   final contract = await SignalingContract.connect(
     ...,
     credentials: myPrivateKey, // Necessario per write operations
   );
   ```

3. **Deploy aspetta la ricevuta**
   - Timeout: 60 secondi
   - Polling: ogni 1 secondo
   - Lanciala exception se fallisce

## 🚀 Workflow Consigliato

1. Modifica il contratto in `packages/typescript/signaling-contract/contracts/`
2. Testa con: `npm run test`
3. Compila: `npm run compile`
4. Genera Dart: `node scripts/generate-dart-bindings.js`
5. Usa il nuovo binding nel progetto Dart

## 📚 File Correlati

- [BUILD_PIPELINE.md](docs/BUILD_PIPELINE.md) - Dettagli sulla pipeline
- [IMPLEMENTATION_CHECKLIST.md](docs/IMPLEMENTATION_CHECKLIST.md) - Checklist di implementazione
- [README.md](packages/contract_sdk/README.md) - SDK Dart
