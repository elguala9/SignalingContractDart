# Deploy Smart Contract in CI/CD per i Test

Questa guida spiega come configurare il deployment automatico del contratto Signaling in una pipeline CI/CD per testare il contratto deployato.

## 📋 Panoramica

Il flusso è:
1. **Start**: Avvia un nodo Hardhat locale
2. **Build**: Compila i contratti Solidity
3. **Deploy**: Deploya il contratto e cattura l'indirizzo
4. **Test**: Esegui i test Dart contro il contratto deployato
5. **Cleanup**: Arresta il nodo

## 🚀 Opzione 1: Script Bash Automatico (Consigliato)

La maniera più semplice è usare lo script fornito:

```bash
./scripts/deploy-and-test.sh
```

Lo script fa tutto automaticamente:
- ✅ Installa dipendenze Node e Dart
- ✅ Avvia Hardhat network
- ✅ Deploya il contratto
- ✅ Esegue i test Dart
- ✅ Mostra il risultato
- ✅ Arresta il nodo

### Output Atteso

```
==========================================
  Smart Contract Deploy & Test Script
==========================================

ℹ️  Checking prerequisites...
✅ Prerequisites OK (Node.js, Dart)

ℹ️  Installing Node.js dependencies...
✅ Node.js dependencies installed

ℹ️  Installing Dart dependencies...
✅ Dart dependencies installed

ℹ️  Starting Hardhat network...
✅ Hardhat network is ready!

ℹ️  Building contracts...
✅ Contracts built

ℹ️  Deploying contract...
✅ Contract deployed at: 0x0165878A594ca255338adfa4d48449f69242Eb8F

ℹ️  Running Dart integration tests...
00:00 +0: loading test/signaling_contract_deploy_test.dart
...
✅ All tests passed!

==========================================
  ✅ Deployment and Tests Complete!
==========================================
```

## 🐙 Opzione 2: GitHub Actions CI/CD

Se usi GitHub, il workflow è già configurato. Basta committare e pushare:

```bash
# Il workflow si attiva automaticamente su push/PR a develop o main
git add .
git commit -m "Enable CI/CD for contract tests"
git push origin develop
```

Vai su **GitHub → Actions** per vedere lo stato dei test.

### Workflow File

Il workflow è in `.github/workflows/test-contract-deploy.yml` e:
- Installa Node e Dart
- Avvia Hardhat
- Deploya il contratto
- Esegue i test Dart
- Upload i log in caso di fallimento

## 📝 Opzione 3: Setup Manuale

Se preferisci fare il setup manualmente in un altro CI/CD (GitLab CI, CircleCI, ecc.):

### Terminal 1: Start Hardhat
```bash
cd packages/typescript/signaling-contract
npm install
npm run network
```

### Terminal 2: Deploy Contract
```bash
cd packages/typescript/signaling-contract
npm run deploySC 2>&1 | tee /tmp/deploy.log
CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}')
echo "Contract deployed at: $CONTRACT_ADDRESS"
```

### Terminal 3: Run Tests
```bash
cd packages/contract_sdk
export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
dart test -r expanded
```

## 🔧 Configurazione per altri CI/CD

### GitLab CI

Crea `.gitlab-ci.yml`:

```yaml
test:contract:
  image: node:18
  before_script:
    - apt-get update && apt-get install -y curl
    - curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o chrome.deb
    - dpkg -i chrome.deb
    - curl https://storage.googleapis.com/dart-archive/channels/stable/release/latest/linux_packages/dart_3.0.6-1_amd64.deb -o dart.deb
    - dpkg -i dart.deb
  script:
    - ./scripts/deploy-and-test.sh
  artifacts:
    when: always
    paths:
      - /tmp/hardhat-node.log
      - /tmp/deploy.log
```

### CircleCI

Crea `.circleci/config.yml`:

```yaml
version: 2.1

jobs:
  test-contract:
    docker:
      - image: cimg/node:18.14
    steps:
      - checkout
      - run:
          name: Install Dart
          command: |
            curl https://storage.googleapis.com/dart-archive/channels/stable/release/latest/linux_packages/dart_3.0.6-1_amd64.deb -o dart.deb
            sudo dpkg -i dart.deb
      - run:
          name: Run deploy and tests
          command: ./scripts/deploy-and-test.sh
      - store_artifacts:
          path: /tmp/deploy.log
      - store_artifacts:
          path: /tmp/hardhat-node.log

workflows:
  test:
    jobs:
      - test-contract
```

## 🔐 Variabili di Ambiente

Questi valori sono usati nei test:

| Variabile | Valore | Descrizione |
|-----------|--------|-------------|
| `TEST_RPC_URL` | `http://localhost:8545` | URL del nodo Hardhat |
| `TEST_CONTRACT_ADDRESS` | `0x...` | Indirizzo del contratto deployato |
| `TEST_PRIVATE_KEY` | `0xac0974bec...` | Chiave privata del deployer (Account #0) |

**Nota**: Per la produzione, usa secrets nel tuo CI/CD provider invece di valori hardcoded.

## 🐳 Alternativa: Docker Compose

Se preferisci usare Docker per il nodo blockchain:

```bash
# Avvia Ganache con Docker
docker-compose up -d

# Deploy
cd packages/typescript/signaling-contract
npm run deploySC:ganache

# Test
cd packages/contract_sdk
export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=0x...
dart test
```

## ❌ Troubleshooting

### "Hardhat network failed to start"
```bash
# Controlla i log
cat /tmp/hardhat-node.log

# Assicurati che la porta 8545 sia disponibile
lsof -i :8545
```

### "Contract deployment failed"
```bash
# Verifica che Hardhat sia in esecuzione
curl http://localhost:8545 -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}'
```

### "TEST_PRIVATE_KEY not found"
```bash
# Verifica che la variabile di ambiente sia settata
echo $TEST_PRIVATE_KEY

# Se non è settata, usala in CI/CD:
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
```

## 📚 Risorse

- [Hardhat Documentation](https://hardhat.org/)
- [Web3dart Documentation](https://pub.dev/packages/web3dart)
- [Signaling Contract SDK README](./packages/contract_sdk/README.md)
- [Smart Contract README](./packages/typescript/signaling-contract/README.md)

## ✅ Checklist

- [ ] Node.js 18+ installato
- [ ] Dart 3.0+ installato
- [ ] Repository clonato
- [ ] Script `deploy-and-test.sh` eseguibile
- [ ] Prima run dello script completata con successo
- [ ] GitHub Actions workflow abilitato (se usi GitHub)
- [ ] Test passano localmente

## 💡 Tips

- **Fast Testing**: Lo script riusa il Hardhat node, non ricompila ogni volta
- **Debugging**: Controlla `/tmp/hardhat-node.log` e `/tmp/deploy.log` per i dettagli
- **Parallel Jobs**: In CI/CD, puoi parallelizzare test su diversi rami del contratto
- **Caching**: GitHub Actions cache automaticamente `node_modules` e `pub-cache`

---

**Per domande**: Vedi [GitHub Issues](https://github.com/gualandi/parresia-contract/issues)
