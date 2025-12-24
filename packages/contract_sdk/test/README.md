# SignalingContract Test Files

## Test Files Overview

### 1. `signaling_contract_test.dart` (Validazione Statica)
- 24 test
- Validano ABI, bytecode e utility functions
- **Non richiedono Ganache**
- Esecuzione: `dart test test/signaling_contract_test.dart`

### 2. `ganache_integration_test.dart` (Connettività)
- 4 test
- Testano la connessione a Ganache su localhost:7545
- Verificano chain ID e disponibilità RPC
- **Richiedono Ganache in esecuzione**
- Esecuzione: `dart test test/ganache_integration_test.dart`

### 3. `signaling_contract_deploy_test.dart` (Full Integration - Deploy)
- 10 test
- Tentano il deploy del contratto su Ganache
- Testano interazioni blockchain reali
- **Richiedono Ganache con account finanziati**
- Esecuzione: `dart test test/signaling_contract_deploy_test.dart`

## Setup Ganache

```bash
# Riavvia Ganache con la mnemonic corretta
docker-compose up evm -d

# Verifica che sia in esecuzione
docker ps | grep contract-evm
```

## Eseguire i Test

```bash
# Tutti i test
melos run test

# Solo validazione statica (veloce, non richiede Ganache)
melos exec -- "dart test test/signaling_contract_test.dart"

# Solo connettività
melos exec -- "dart test test/ganache_integration_test.dart"

# Solo deploy e interazioni
melos exec -- "dart test test/signaling_contract_deploy_test.dart"
```

## Stato Attuale

- ✅ Test statici: **24/24 passano**
- ✅ Test integrazione (connettività): **4/4 passano**
- ⚠️ Test deploy: Richiedono Ganache correttamente configurato con ETH

## Note

La private key usata nei test di deploy è derivata dalla mnemonic Ganache:
```
test test test test test test test test test test test junk
```

Ganache genera 20 account con 10000 ETH ciascuno. La prima chiave è:
```
0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
```
