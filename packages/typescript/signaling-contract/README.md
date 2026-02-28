# `signaling-contract`

Smart contract per il signaling che sostituisce il server di signaling tradizionale.

## Prerequisiti

- Node.js
- Docker e Docker Compose (per Ganache)

## Setup

### 1. Installare le dipendenze

```bash
npm install
```

### 2. Avviare Ganache (blockchain locale)

```bash
# Dalla directory root del progetto
docker-compose up -d evm
```

Questo avvierà Ganache con le seguenti configurazioni:
- RPC URL: `http://localhost:8545`
- Chain ID: `1337`
- Accounts: 20 account con 10,000 ETH ciascuno
- Gas price: 0 (transazioni gratuite)

### 3. Compilare i contratti

```bash
npm run build
```

## Deploy

### Deploy su Ganache

```bash
# Deploy del contratto Signaling principale
npm run deploySC:ganache

# Deploy del contratto SignalingMultiOffer
npm run deployMultiOfferSC:ganache
```

### Deploy su localhost (Hardhat network)

```bash
# Avviare la rete locale Hardhat in un terminale separato
npm run network

# Poi deployare
npm run deploySC
npm run deployMultiOfferSC
```

## Reti Supportate

- **localhost**: Rete Hardhat locale (Chain ID: 31337)
- **ganache**: Ganache via Docker (Chain ID: 1337)

## Account di Test

Quando usi Ganache, puoi usare il mnemonic configurato:
```
test test test test test test test test test test test junk
```

Gli account derivati avranno tutti 10,000 ETH per i test.

## Deploy Automatico per Test in CI/CD

Per testare il contratto deployato in una pipeline CI/CD, segui questi step:

### 1. Avviare il nodo Hardhat

Nel tuo CI/CD (GitHub Actions, GitLab CI, ecc.), avvia il nodo Hardhat:

```bash
cd packages/typescript/signaling-contract
npm run network > /tmp/hardhat.log 2>&1 &
sleep 8  # Aspetta che il nodo sia pronto
```

### 2. Deploy del contratto

```bash
npm run deploySC 2>&1 | tee /tmp/deploy.log
```

### 3. Estrai l'indirizzo deployato

```bash
CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | head -1)
echo "Contract deployed at: $CONTRACT_ADDRESS"
```

### 4. Esporta variabili di ambiente per i test

```bash
export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
```

### 5. Esegui i test Dart

```bash
cd packages/contract_sdk
dart test
```

### Esempio GitHub Actions

Crea `.github/workflows/test-contract.yml`:

```yaml
name: Test Smart Contract Deployment

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Setup Dart
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable

      - name: Install Node dependencies
        run: |
          cd packages/typescript/signaling-contract
          npm install

      - name: Install Dart dependencies
        run: |
          cd packages/contract_sdk
          dart pub get

      - name: Start Hardhat node
        run: |
          cd packages/typescript/signaling-contract
          npm run network > /tmp/hardhat.log 2>&1 &
          sleep 8
          echo "Hardhat node started"

      - name: Deploy contract
        run: |
          cd packages/typescript/signaling-contract
          npm run deploySC 2>&1 | tee /tmp/deploy.log
          CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | head -1)
          echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> $GITHUB_ENV
          echo "✅ Contract deployed at: $CONTRACT_ADDRESS"

      - name: Run SDK tests
        run: |
          cd packages/contract_sdk
          export TEST_RPC_URL=http://localhost:8545
          export TEST_CONTRACT_ADDRESS=${{ env.CONTRACT_ADDRESS }}
          export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
          dart test -r expanded

      - name: Upload deployment logs
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: deployment-logs
          path: /tmp/*.log
```

### Test Locali Pre-CI/CD

Per testare localmente prima di pushare:

```bash
# Terminal 1: Avvia il nodo
cd packages/typescript/signaling-contract
npm run network

# Terminal 2: Deploy e test
cd packages/typescript/signaling-contract
npm run deploySC | tee /tmp/deploy.log
CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}')

# Terminal 3: Esegui i test
cd packages/contract_sdk
export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
dart test
```

### Variabili di Ambiente Necessarie

| Variabile | Valore | Descrizione |
|-----------|--------|-------------|
| `TEST_RPC_URL` | `http://localhost:8545` | URL del nodo Hardhat locale |
| `TEST_CONTRACT_ADDRESS` | `0x...` | Indirizzo del contratto deployato |
| `TEST_PRIVATE_KEY` | `0xac0974...` | Chiave privata del deployer (account Hardhat #0) |

### Account Disponibili (Mnemonic Hardhat)

```
Mnemonic: test test test test test test test test test test test junk
Chain ID: 31337

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
Balance: 10,000 ETH
```

### Troubleshooting

**Il contratto non viene trovato nei test**
- Verifica che `TEST_CONTRACT_ADDRESS` sia settato correttamente
- Assicurati che il nodo Hardhat sia in esecuzione (aspetta 8+ secondi)

**Errore "not enough balance"**
- Usa l'account #0 del mnemonic (ha 10,000 ETH)
- Non derivare altri account, usano la key dalla variabile di ambiente

**Nodo non risponde**
- Verifica che il file `/tmp/deploy.log` esista
- Controlla gli errori in `/tmp/hardhat.log`
