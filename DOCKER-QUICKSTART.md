# Docker Quick Start - Signaling Contract

## 🚀 Start Immediato (tutto automatico)

```bash
docker-compose up --build
```

Questo:
1. ✅ Avvia nodo Vite
2. ✅ Deploya Signaling contract
3. ✅ Esegue test sul contract

Tutto in 2 minuti!

---

## 📊 Output Atteso

```
vite-node_1    | ✅ Vite node started at http://localhost:8483
deployer_1     | 🚀 Starting deployment...
deployer_1     | 📦 Compiling Signaling contract...
deployer_1     | ✅ Compilation successful
deployer_1     | 🔗 Deploying to Vite network...
deployer_1     | ✅ Contract deployed successfully!
deployer_1     | 📍 Contract Address: vite_abc123def456...
deployer_1     | 📄 Deployment saved
test-runner_1  | 🧪 Starting tests...
test-runner_1  | 📍 Testing contract at: vite_abc123def456...
test-runner_1  | ✅ Test 1 passed
test-runner_1  | ✅ Test 2 passed
test-runner_1  | ✅ All tests passed!
```

---

## 🔗 Blockchain Connection

Durante lo start, puoi connetterti al nodo Vite:

```
HTTP RPC: http://localhost:8483
WebSocket: ws://localhost:8484
```

Perfetto per sviluppare applicazioni client che interagiscono col contract!

---

## 📍 Dove trovare l'indirizzo del Contract

Dopo deploy:

```bash
cat packages/vite/deployments/latest-deployment.json
```

Output:
```json
{
  "timestamp": "2026-04-22T14:30:00.000Z",
  "contractAddress": "vite_abc123def456...",
  "network": "vite",
  "nodeUrl": "http://vite-node:8483",
  "contractType": "Signaling",
  "version": "1.0.0"
}
```

---

## 🛑 Stop

```bash
docker-compose down
```

---

## 🔧 Customizzazione

### Usa nodo Vite remoto

Edita `docker-compose.yml`:

```yaml
deployer:
  environment:
    - BLOCKCHAIN_URL=https://testnet-rpc.vite.org
test-runner:
  environment:
    - BLOCKCHAIN_URL=https://testnet-rpc.vite.org
```

Poi:
```bash
docker-compose up deployer test-runner
```

### Solo blockchain (senza deploy/test)

```bash
docker-compose up vite-node
```

Il nodo rimane attivo per sviluppo.

### Solo deploy (senza test)

```bash
docker-compose up vite-node deployer
```

---

## 📚 Documentazione Completa

Vedi `README.DOCKER.md` per guide complete, troubleshooting e casi avanzati.

---

## 💡 Flusso di Lavoro Consigliato

### 1️⃣ Sviluppo locale

```bash
docker-compose up vite-node
```

- Sviluppa il contract
- Modifica in real-time (volumi montati)
- Compila manualmente quando pronto

### 2️⃣ Testing locale

```bash
docker-compose up --build
```

- Automatic compile
- Automatic deploy
- Automatic testing

### 3️⃣ Test su blockchain remota

```bash
# Copia docker-compose.override.yml.example in docker-compose.override.yml
# Modifica BLOCKCHAIN_URL nel file
docker-compose up deployer test-runner
```

---

## ⚡ Comandi Veloci

```bash
# Start tutto
docker-compose up --build

# Rivedi deployment
cat packages/vite/deployments/latest-deployment.json | jq

# Logs deployer
docker-compose logs deployer -f

# Stop
docker-compose down

# Rebuild from scratch
docker-compose down -v --rmi all
docker-compose up --build
```

---

**Pronto!** 🎉 Il tuo contract è deployato e testato!
