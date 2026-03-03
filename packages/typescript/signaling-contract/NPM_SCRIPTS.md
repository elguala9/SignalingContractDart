# NPM Scripts per Docker Deployment

Gli script Docker sono ora integrati nel `package.json`. Puoi usarli direttamente con `npm run`.

---

## 📋 Script Disponibili

### Testing & Building

#### `npm run docker:test`
Testa l'immagine Docker con la configurazione standard.

```bash
npm run docker:test
```

**Cosa fa**:
- Builds the Docker image
- Starts Ganache (if needed)
- Runs 6 validation tests
- Tests default config + custom private key
- Tests volume mounting
- ✅ Output: All tests passed!

---

#### `npm run docker:test:custom`
Testa con image name e RPC URL personalizzati.

```bash
# Set environment variables
export IMAGE_NAME="my-custom-image:test"
export RPC_URL="http://my-ganache:8545"

npm run docker:test:custom
```

---

### Deployment

#### `npm run docker:push`
Pushes image to Docker Hub.

```bash
# Requires: bash ./push-to-dockerhub.sh <username>
npm run docker:push -- parresia
```

**Prerequisiti**:
- Docker Hub account
- Public repository: `signaling-contract-deployer`
- `docker login` già eseguito

---

#### `npm run docker:build`
Builds the Docker image locally.

```bash
npm run docker:build
```

**Output**: `signaling-contract-deployer:latest`

---

### Running

#### `npm run docker:run`
Runs the deployed container.

```bash
# With environment variables
export RPC_URL="http://ganache:8545"
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

npm run docker:run
```

**Output**:
```
✅ Deployment successful!
CONTRACT_ADDRESS=0x5fbdb2315678afccb333f8a9fcff40444b0a74b5e
```

---

#### `npm run docker:help`
Displays Docker script information.

```bash
npm run docker:help
```

---

## 🚀 Workflow Completo

### Step 1: Test Locally
```bash
npm run docker:test
```

### Step 2: Build Image
```bash
npm run docker:build
```

### Step 3: Push to Docker Hub
```bash
npm run docker:push -- your-username
```

### Step 4: Use Image
```bash
export RPC_URL="http://ganache:8545"
export PRIVATE_KEY="0x..."
npm run docker:run
```

---

## 🔧 Environment Variables

### For `docker:test:custom`
```bash
export IMAGE_NAME="signaling-contract-deployer:test"
export RPC_URL="http://127.0.0.1:8545"
npm run docker:test:custom
```

### For `docker:run`
```bash
export RPC_URL="http://ganache:8545"
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
npm run docker:run
```

---

## 📊 Script Reference

| Script | Command | Purpose |
|--------|---------|---------|
| `docker:test` | `npm run docker:test` | Test image (localhost:8545) |
| `docker:test:custom` | `npm run docker:test:custom` | Test with custom config |
| `docker:push` | `npm run docker:push -- user` | Push to Docker Hub |
| `docker:build` | `npm run docker:build` | Build image locally |
| `docker:run` | `npm run docker:run` | Run deployed container |
| `docker:help` | `npm run docker:help` | Show script info |

---

## 💡 Examples

### Quick Test
```bash
npm run docker:test
```

### Build and Push
```bash
npm run docker:build
npm run docker:push -- parresia
```

### Run with Custom Config
```bash
RPC_URL="http://my-ganache:8545" PRIVATE_KEY="0x..." npm run docker:run
```

### Test with Custom RPC
```bash
IMAGE_NAME="my-image:v1" RPC_URL="http://custom:8545" npm run docker:test:custom
```

---

## 🎯 Shortcuts in Scripts

All npm scripts are shortcuts to the bash scripts:

```bash
# Instead of:
bash ./test-docker.sh

# Use:
npm run docker:test
```

```bash
# Instead of:
bash ./push-to-dockerhub.sh parresia

# Use:
npm run docker:push -- parresia
```

---

## ✅ Benefits

✅ Consistent with npm ecosystem
✅ Easy to remember (docker:*)
✅ Works on all platforms (bash compatibility)
✅ Environment variables support
✅ Chainable with other npm scripts

---

## 🔗 Related

- Bash scripts: `test-docker.sh`, `push-to-dockerhub.sh`
- Documentation: `DOCKER.md`, `DEPLOYMENT.md`
- Setup guide: `README_DOCKER_SETUP.md`

