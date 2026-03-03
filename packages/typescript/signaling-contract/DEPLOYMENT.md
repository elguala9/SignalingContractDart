# Docker Deployment & Testing Guide

This guide covers testing and deploying the Signaling Contract Docker image.

## 📋 Quick Start

```bash
cd packages/typescript/signaling-contract

# 1. Test the image
chmod +x test-docker.sh
./test-docker.sh

# 2. Push to Docker Hub
chmod +x push-to-dockerhub.sh
./push-to-dockerhub.sh your-username
```

---

## 🧪 Testing Script: `test-docker.sh`

### What It Does

1. **Builds** the Docker image
2. **Starts** a Ganache instance (if not running)
3. **Tests** deployment with default mnemonic
4. **Tests** deployment with custom private key
5. **Tests** volume mount functionality
6. **Verifies** contract address output
7. **Cleans up** test containers

### Usage

```bash
# Basic test (uses localhost:8545)
./test-docker.sh

# Test with custom image name
./test-docker.sh my-custom-image:test

# Test with custom RPC URL
./test-docker.sh signaling-contract-deployer:test http://my-ganache:8545
```

### What to Expect

```
════════════════════════════════════════════
🧪 Testing Signaling Contract Docker Image
════════════════════════════════════════════

[1/6] Building Docker image...
✅ Build successful

[2/6] Checking Ganache...
⏳ Waiting for Ganache to be ready...
✅ Ganache ready at http://127.0.0.1:8545

[3/6] Testing deployment with default config...
✅ Deployment completed
✅ Contract address: 0x5fbdb2315678afccb333f8a9fcff40444b0a74b5e

[4/6] Testing deployment with custom private key...
✅ Private key deployment successful
✅ Contract address: 0x...

[5/6] Testing volume mount output...
✅ Address saved to file: 0x...

[6/6] Checking image size...
✅ Image size: 450MB

════════════════════════════════════════════
✅ All tests passed!
════════════════════════════════════════════
```

### Troubleshooting Tests

**Port already in use:**
```bash
# Stop existing containers
docker stop ganache-test 2>/dev/null || true
./test-docker.sh
```

**Build fails:**
```bash
# Clean and rebuild
docker system prune -f
./test-docker.sh
```

**RPC connection error:**
Make sure Ganache is running and accessible:
```bash
docker logs ganache-test
```

---

## 🚀 Docker Hub Push Script: `push-to-dockerhub.sh`

### Prerequisites

1. Create a [Docker Hub account](https://hub.docker.com/signup)
2. Create a public repository named `signaling-contract-deployer`
3. Login locally:
   ```bash
   docker login
   ```

### Usage

```bash
# Push to Docker Hub
./push-to-dockerhub.sh your-docker-username

# Example
./push-to-dockerhub.sh parresia
```

### What It Does

1. **Verifies** Docker Hub login
2. **Builds** image if needed
3. **Tags** image with:
   - `latest` (for current version)
   - `v1.0.0` (version from package.json)
4. **Pushes** both tags to Docker Hub
5. **Verifies** images are accessible

### Output

```
════════════════════════════════════════════
🚀 Docker Hub Deployment Script
════════════════════════════════════════════

Configuration:
  Docker Hub Username: parresia
  Image Name: signaling-contract-deployer
  Version: 1.0.0

✅ Logged in to Docker Hub
✅ Local image ready: signaling-contract-deployer:test
✅ Tagged as:
  - parresia/signaling-contract-deployer:latest
  - parresia/signaling-contract-deployer:v1.0.0

Pushing parresia/signaling-contract-deployer:latest...
✅ Pushed latest

Pushing parresia/signaling-contract-deployer:v1.0.0...
✅ Pushed version

════════════════════════════════════════════
✅ Successfully pushed to Docker Hub!
════════════════════════════════════════════

Image URLs:
  Latest: docker pull parresia/signaling-contract-deployer:latest
  Version: docker pull parresia/signaling-contract-deployer:v1.0.0
```

---

## 🔄 Complete Workflow

### For Local Testing

```bash
# 1. Make sure Ganache is running
docker run -d --name ganache -p 8545:8545 trufflesuite/ganache --chain.chainId 1337

# 2. Build and test
cd packages/typescript/signaling-contract
./test-docker.sh

# 3. Use the image
docker run \
  --network host \
  -e RPC_URL=http://127.0.0.1:8545 \
  signaling-contract-deployer:test
```

### For Docker Hub Release

```bash
# 1. Test locally
./test-docker.sh

# 2. If tests pass, push to Docker Hub
./push-to-dockerhub.sh your-username

# 3. Verify it's available
docker pull your-username/signaling-contract-deployer:latest

# 4. Use in other projects
docker run \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=0x... \
  your-username/signaling-contract-deployer:latest
```

---

## 📝 Using the Image in CI/CD

### GitHub Actions Example

```yaml
name: Deploy Smart Contract

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    services:
      ganache:
        image: trufflesuite/ganache
        options: --chain.chainId 1337
        ports:
          - 8545:8545

    steps:
      - uses: actions/checkout@v3

      - name: Deploy Contract
        run: |
          docker run \
            --network host \
            -e RPC_URL=http://127.0.0.1:8545 \
            -e PRIVATE_KEY=${{ secrets.DEPLOY_PRIVATE_KEY }} \
            parresia/signaling-contract-deployer:latest > deploy.log

          CONTRACT_ADDRESS=$(grep "CONTRACT_ADDRESS=" deploy.log | cut -d'=' -f2)
          echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> $GITHUB_ENV

      - name: Upload Address
        uses: actions/upload-artifact@v3
        with:
          name: contract-address
          path: deploy.log
```

### GitLab CI Example

```yaml
deploy_contract:
  image: docker:latest
  services:
    - docker:dind

  script:
    - docker run \
        -e RPC_URL=http://ganache:8545 \
        -e PRIVATE_KEY=$DEPLOY_PRIVATE_KEY \
        parresia/signaling-contract-deployer:latest > deploy.log
    - export CONTRACT_ADDRESS=$(grep "CONTRACT_ADDRESS=" deploy.log | cut -d'=' -f2)
    - echo "Contract deployed at: $CONTRACT_ADDRESS"

  artifacts:
    paths:
      - deploy.log
```

---

## 🐛 Debugging

### View build logs
```bash
docker build -t signaling-contract-deployer:test . --progress=plain
```

### Check image contents
```bash
docker run -it signaling-contract-deployer:test /bin/sh
```

### View deployment logs
```bash
docker run \
  -e RPC_URL=http://127.0.0.1:8545 \
  signaling-contract-deployer:test 2>&1 | tee deployment.log
```

### Inspect Docker Hub image
```bash
docker inspect parresia/signaling-contract-deployer:latest
```

---

## 📊 Image Information

- **Base Image**: `node:18-alpine`
- **Size**: ~450MB (compressed)
- **Build Time**: ~2-3 minutes
- **Deploy Time**: ~1-2 minutes

---

## ✅ Checklist Before Release

- [ ] Run `./test-docker.sh` successfully
- [ ] All 6 test steps pass
- [ ] Docker Hub account created
- [ ] Repository created on Docker Hub
- [ ] Run `docker login`
- [ ] Run `./push-to-dockerhub.sh your-username`
- [ ] Verify image on Docker Hub
- [ ] Document image URL in team docs

