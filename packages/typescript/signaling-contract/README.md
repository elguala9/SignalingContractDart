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
