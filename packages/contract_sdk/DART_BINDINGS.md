# Contract SDK - Dart Bindings Generation

Questo progetto ora supporta la **generazione automatica di binding Dart** dai contratti Solidity!

## Come Funziona

1. **Hardhat compila** i contratti Solidity → Genera ABI e bytecode
2. **Script personalizzato** legge gli artifacts → Genera classi Dart automaticamente
3. **SDK Dart** espone le classi generate → Pronto per l'uso!

## Utilizzo

### Compilazione Completa (TypeScript + Dart)
```bash
npm run build
```
Questo comando:
- Compila i contratti Solidity
- Genera TypeChain per TypeScript
- **Genera binding Dart automatici** 

### Solo Binding Dart
```bash
npm run build:dart
```

### Solo TypeChain
```bash
npm run build:typechain
```

## Struttura Generata

I binding Dart vengono generati in:
```
packages/contract_sdk/lib/src/generated/
├── signaling_contract.dart          # Classe SignalingContract
├── signalingmultioffer_contract.dart # Classe SignalingMultiOfferContract
└── contracts.dart                    # Export di tutti i contratti
```

## Esempio d'Uso dei Binding Generati

```dart
import 'package:contract_sdk/contract_sdk.dart';
import 'package:web3dart/web3dart.dart';

// Connessione a contratto esistente
final signaling = await SignalingContract.connect(
  rpcUrl: 'http://localhost:8545',
  contractAddress: EthereumAddress.fromHex('0x...'),
  credentials: myPrivateKey,
);

// Chiamata a funzione view
final offer = await signaling.getOffer(BigInt.from(123));

// Chiamata a funzione transaction
final txHash = await signaling.setOffer(myOfferBytes);
```

## Vantaggi

✅ **Type Safety**: Classi Dart tipizzate generate automaticamente  
✅ **Sync automatico**: I binding si aggiornano ad ogni compilazione  
✅ **IntelliSense**: Autocompletamento completo nell'IDE  
✅ **Documentazione**: JSDoc dei contratti → Commenti Dart  
✅ **Deploy**: Support per deploy automatico di nuovi contratti  

## Personalizzazione

Lo script di generazione è in `scripts/generate-dart-bindings.js` e può essere modificato per:
- Cambiare i tipi di mapping Solidity → Dart
- Aggiungere validazioni custom
- Modificare il template delle classi generate
- Aggiungere utility functions specifiche