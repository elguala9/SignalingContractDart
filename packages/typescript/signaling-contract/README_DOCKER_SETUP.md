# 🐳 Docker Setup for Signaling Smart Contract

Complete Docker containerization with automated testing and Docker Hub deployment.

## ✨ What's Included

### Core Docker Files
- **`Dockerfile`** - Builds a containerized deployment environment
- **`entrypoint.sh`** - Smart script that deploys contract and outputs address
- **`.dockerignore`** - Optimizes image size by excluding unnecessary files

### Configuration
- **`hardhat.config.ts`** - Updated to support `RPC_URL` and `PRIVATE_KEY` env vars
  - Ganache network now configurable via environment variables
  - Falls back to defaults if env vars not set

### Automation Scripts
- **`test-docker.sh`** - Validates Docker image before release
  - Builds image, starts Ganache, runs 6 validation tests
  - Tests default config, custom keys, volume mounts
  - Ensures quality before pushing to Docker Hub

- **`push-to-dockerhub.sh`** - Automates Docker Hub deployment
  - Verifies Docker Hub login
  - Tags image with latest + version
  - Pushes to Docker Hub
  - Verifies accessibility

### Documentation
- **`DOCKER.md`** - Usage guide for running the container
- **`DEPLOYMENT.md`** - Detailed deployment workflows & CI/CD examples
- **`SCRIPTS_GUIDE.md`** - How to use the automation scripts
- **`README_DOCKER_SETUP.md`** - This file

---

## 🚀 Quick Start (30 seconds)

```bash
cd packages/typescript/signaling-contract

# 1. Make scripts executable
chmod +x test-docker.sh push-to-dockerhub.sh

# 2. Test the image
./test-docker.sh

# 3. If tests pass, push to Docker Hub
./push-to-dockerhub.sh your-docker-username
```

---

## 📋 Detailed Setup

### Prerequisites
- Docker installed locally
- Docker Hub account (for push)
- `docker login` already run

### Step-by-Step

#### 1. Test Locally

```bash
cd packages/typescript/signaling-contract
chmod +x test-docker.sh
./test-docker.sh
```

Expected output:
```
[1/6] Building Docker image...
[2/6] Checking Ganache...
[3/6] Testing deployment with default config...
[4/6] Testing deployment with custom private key...
[5/6] Testing volume mount output...
[6/6] Checking image size...
✅ All tests passed!
```

#### 2. Create Docker Hub Repository

1. Go to https://hub.docker.com
2. Sign in or create account
3. Create new repository:
   - Name: `signaling-contract-deployer`
   - Visibility: Public
4. Create repository

#### 3. Push to Docker Hub

```bash
chmod +x push-to-dockerhub.sh
./push-to-dockerhub.sh your-docker-username
```

Example:
```bash
./push-to-dockerhub.sh parresia
```

Expected output:
```
Configuration:
  Docker Hub Username: parresia
  Image Name: signaling-contract-deployer
  Version: 1.0.0

✅ Logged in to Docker Hub
✅ Local image ready
✅ Tagged as: parresia/signaling-contract-deployer:latest
✅ Pushed latest
✅ Pushed version
✅ Successfully pushed to Docker Hub!
```

#### 4. Verify on Docker Hub

```bash
# Visit your repository
https://hub.docker.com/r/your-username/signaling-contract-deployer

# Or pull locally
docker pull your-username/signaling-contract-deployer:latest
```

---

## 🎯 Using the Image

### From Docker Hub

```bash
docker run \
  --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  parresia/signaling-contract-deployer:latest
```

### Output

```
🚀 Starting smart contract deployment...
Deploying Signaling with account: 0x...
✅ Signaling (non-upgradable) deployed at: 0x5fbdb2315678afccb333f8a9fcff40444b0a74b5e
✅ Test account funded: 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1
✅ Deployment successful!
CONTRACT_ADDRESS=0x5fbdb2315678afccb333f8a9fcff40444b0a74b5e
```

### Capture Address in Script

```bash
#!/bin/bash
OUTPUT=$(docker run \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=$PRIVATE_KEY \
  parresia/signaling-contract-deployer:latest)

CONTRACT_ADDRESS=$(echo "$OUTPUT" | grep "CONTRACT_ADDRESS=" | cut -d'=' -f2)
echo "Contract deployed at: $CONTRACT_ADDRESS"
```

---

## 📦 Environment Variables

| Variable | Default | Example |
|----------|---------|---------|
| `RPC_URL` | `http://127.0.0.1:8545` | `http://ganache:8545` |
| `PRIVATE_KEY` | Mnemonic account | `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` |

---

## 🔄 Docker Compose Example

```yaml
version: '3.8'

services:
  ganache:
    image: trufflesuite/ganache
    ports:
      - "8545:8545"
    command: --chain.chainId 1337
    networks:
      - parresia

  deployer:
    image: parresia/signaling-contract-deployer:latest
    environment:
      RPC_URL: http://ganache:8545
      PRIVATE_KEY: ${DEPLOY_PRIVATE_KEY}
    depends_on:
      - ganache
    networks:
      - parresia

networks:
  parresia:
    driver: bridge
```

Run with:
```bash
DEPLOY_PRIVATE_KEY=0x... docker-compose up
```

---

## 📊 File Structure

```
signaling-contract/
├── Dockerfile                    # Container definition
├── entrypoint.sh                # Smart deployment script
├── .dockerignore                # Optimize image size
├── test-docker.sh               # Validation script (⭐ run first)
├── push-to-dockerhub.sh         # Push to Docker Hub (⭐ run second)
├── hardhat.config.ts            # Updated with env var support
├── ignition/
│   └── modules/
│       └── DeploySignaling.ts   # Deployment logic
├── contracts/
│   └── Signaling.sol            # Smart contract
├── DOCKER.md                    # Usage documentation
├── DEPLOYMENT.md                # Detailed guides
├── SCRIPTS_GUIDE.md             # Script documentation
└── README_DOCKER_SETUP.md       # This file
```

---

## ✅ Checklist

### Before First Deployment
- [ ] Read this README
- [ ] Run `./test-docker.sh` successfully
- [ ] All 6 tests pass
- [ ] Create Docker Hub repository
- [ ] Run `docker login`

### Before Pushing to Docker Hub
- [ ] Tests pass locally
- [ ] Private repository settings (if needed)
- [ ] Version number in `package.json` is correct
- [ ] Reviewed `DOCKER.md` for usage

### After Docker Hub Push
- [ ] Verify image on Docker Hub
- [ ] Test pull: `docker pull your-username/signaling-contract-deployer:latest`
- [ ] Share image URL with team
- [ ] Update project documentation

---

## 🚀 Next Steps

1. **Run Tests**
   ```bash
   ./test-docker.sh
   ```

2. **Push to Docker Hub**
   ```bash
   ./push-to-dockerhub.sh your-username
   ```

3. **Use in Projects**
   ```bash
   docker run -e RPC_URL=... -e PRIVATE_KEY=... your-username/signaling-contract-deployer:latest
   ```

4. **Integrate with CI/CD**
   - GitHub Actions example in `DEPLOYMENT.md`
   - GitLab CI example in `DEPLOYMENT.md`

---

## 📚 Documentation Reference

| Document | Purpose |
|----------|---------|
| **DOCKER.md** | Running the container, environment setup |
| **DEPLOYMENT.md** | Detailed deployment, CI/CD integration |
| **SCRIPTS_GUIDE.md** | Using test and push scripts |
| **README_DOCKER_SETUP.md** | This guide - overview and setup |

---

## 🐛 Common Issues

### "Port 8545 already in use"
```bash
docker stop ganache-test 2>/dev/null || true
./test-docker.sh
```

### "Not logged in to Docker Hub"
```bash
docker login
./push-to-dockerhub.sh your-username
```

### "Repository not found on Docker Hub"
1. Create public repository: `signaling-contract-deployer`
2. Run push script again

### "RPC connection refused"
```bash
# Make sure Ganache is running
docker ps | grep ganache

# Or use Docker network
docker run --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  your-username/signaling-contract-deployer:latest
```

---

## 💡 Tips

- **Image Size**: ~450MB (compressed), includes all dependencies
- **Build Time**: ~2-3 minutes (faster on subsequent builds due to caching)
- **Deploy Time**: ~1-2 minutes per deployment
- **Versions**: Automatically tagged with `latest` and semantic version

---

## 📞 Support

For detailed information:
- Docker usage: See `DOCKER.md`
- Deployment workflows: See `DEPLOYMENT.md`
- Script usage: See `SCRIPTS_GUIDE.md`

---

## 🎉 Ready to Deploy!

```bash
# Start here
./test-docker.sh

# Then
./push-to-dockerhub.sh your-username
```

Your Docker image will be available at:
```
https://hub.docker.com/r/your-username/signaling-contract-deployer
```

Good luck! 🚀
