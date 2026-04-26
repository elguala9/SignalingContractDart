# Signaling Contract - Docker Setup

Infrastruttura containerizzata per sviluppo, deploy e testing dello Signaling smart contract sulla blockchain Vite.

## Architettura 🏗️

```
┌─────────────────────────────────────────────────────┐
│              Docker Compose Network                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────┐     ┌──────────────┐             │
│  │  vite-node   │────▶│  deployer    │             │
│  │              │     │              │             │
│  │ Blockchain   │     │ Deploy       │             │
│  │ Port: 8483   │     │ smart        │             │
│  │ Port: 8484   │     │ contract     │             │
│  └──────────────┘     └──────────────┘             │
│                              │                      │
│                              ▼                      │
│                       ┌──────────────┐             │
│                       │ test-runner  │             │
│                       │              │             │
│                       │ Run tests    │             │
│                       │ on deployed  │             │
│                       │ contract     │             │
│                       └──────────────┘             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Tre Servizi

### 1️⃣ **vite-node** - Blockchain Vite
- Avvia un nodo Vite locale completo
- HTTP RPC: `http://localhost:8483`
- WebSocket: `ws://localhost:8484`
- Serve come provider per deployer e test-runner

### 2️⃣ **deployer** - Smart Contract Deployment
- Compila il contratto Signaling
- Deploya su blockchain (Vite)
- Salva indirizzo deployment in `packages/vite/deployments/latest-deployment.json`
- Dipende da: `vite-node` (healthy)
- Accetta parametri tramite env var:
  - `BLOCKCHAIN_TYPE`: vite (default) / ethereum
  - `BLOCKCHAIN_URL`: http://vite-node:8483 (default)

### 3️⃣ **test-runner** - Test Suite
- Legge indirizzo contract dal file deployment
- Esegue test su contract deployato
- Usa SDK per interagire con contratto
- Dipende da: `deployer` (completato) + `vite-node` (healthy)
- Accetta stessi parametri di blockchain di deployer

## Utilizzo

### Start Completo (Node + Deploy + Test)

```bash
docker-compose up --build
```

Output:
```
vite-node         | ✅ Node ready at http://localhost:8483
deployer          | 🚀 Compiling contract...
deployer          | ✅ Deployed to vite_abc123...
test-runner       | 🧪 Testing contract...
test-runner       | ✅ All tests passed!
```

### Solo Nodo Blockchain (Sviluppo)

```bash
docker-compose up vite-node
```

Il nodo rimane attivo. Puoi connetterti da altre applicazioni:
```javascript
const nodeUrl = "http://localhost:8483";
// Usa per sviluppo/debugging
```

### Deploy Solo

```bash
docker-compose up vite-node deployer --build
```

Il contract verrà deployato. Indirizzo salvato in:
```
packages/vite/deployments/YYYY-MM-DD/deployment-TIMESTAMP.json
packages/vite/deployments/latest-deployment.json
```

### Test Solo (se già deployato)

```bash
docker-compose up vite-node test-runner --build
```

Legge indirizzo dal `latest-deployment.json` e esegue test.

## Parametrizzazione - Blockchain

Puoi cambiare blockchain editando `docker-compose.yml`:

```yaml
deployer:
  environment:
    - BLOCKCHAIN_TYPE=vite              # vite o ethereum
    - BLOCKCHAIN_URL=http://vite-node:8483
```

O da CLI:

```bash
docker-compose run --rm -e BLOCKCHAIN_TYPE=ethereum deployer npm run deploy
```

## File Importanti

```
.
├── docker-compose.yml          # Orchestrazione 3 servizi
├── Dockerfile.vite             # Immagine nodo Vite
├── Dockerfile.deployer         # Immagine deployer
├── Dockerfile.test             # Immagine test-runner
├── packages/vite/
│   ├── contracts/              # Solidity++ smart contracts
│   ├── scripts/
│   │   ├── deploy-to-chain.js  # Deploy script (accetta blockchain)
│   │   └── test-on-chain.js    # Test script (accetta blockchain)
│   ├── deployments/            # Deployment history
│   │   └── latest-deployment.json
│   └── package.json
└── packages/contract_sdk/      # SDK Dart per testing
```

## Logs e Debugging

### Visualizza log di un servizio

```bash
# Log deployer
docker-compose logs deployer -f

# Log test-runner
docker-compose logs test-runner -f

# Log vite-node
docker-compose logs vite-node -f
```

### Accedi a container in esecuzione

```bash
docker exec -it deployer sh
docker exec -it test-runner sh
docker exec -it vite-node sh
```

### Verifica indirizzo deployment

```bash
cat packages/vite/deployments/latest-deployment.json
```

## Pulizia

### Stop tutti i servizi

```bash
docker-compose down
```

### Remove images

```bash
docker-compose down --rmi all
```

### Remove everything (volumi inclusi)

```bash
docker-compose down -v --rmi all
rm -rf packages/vite/deployments/*
```

## Troubleshooting

### Porta già in uso (8483, 8484)

```bash
# Cambia in docker-compose.yml
ports:
  - "9483:8483"
  - "9484:8484"
```

### Deployer fallisce

```bash
# Check logs
docker-compose logs deployer

# Prova build separato
docker-compose build deployer
docker-compose up vite-node deployer
```

### Test fallisce perché non trova contract

Il test-runner legge l'indirizzo da `latest-deployment.json`. Assicurati che:
1. Deployer ha girato: `docker-compose logs deployer`
2. File esiste: `ls packages/vite/deployments/latest-deployment.json`

### Container rimane in attesa

Se un container rimane bloccato, probabilmente aspetta una dipendenza:
- deployer aspetta vite-node healthy
- test-runner aspetta deployer completato

Check:
```bash
docker-compose logs vite-node | grep healthcheck
docker-compose ps  # Guarda stato
```

## Prossimi Passi

- [ ] Aggiungere test più robusti in `scripts/test-on-chain.js`
- [ ] Supporto Ethereum (scripg già preparati)
- [ ] Integrazione con GitHub Actions
- [ ] Metriche e monitoring

## Comandi Veloci

```bash
# Start tutto
docker-compose up --build

# Stop
docker-compose down

# Rebuild immagini
docker-compose build --no-cache

# Solo blockchain
docker-compose up vite-node

# Deploy + test
docker-compose up deployer test-runner

# Check deployment
cat packages/vite/deployments/latest-deployment.json | jq
```
