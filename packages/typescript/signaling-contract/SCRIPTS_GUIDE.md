# Docker Deployment Scripts Guide

Two automated scripts are provided to simplify testing and Docker Hub deployment.

## 📁 Files Created

```
packages/typescript/signaling-contract/
├── test-docker.sh              # Test script
├── push-to-dockerhub.sh        # Docker Hub push script
├── Dockerfile                  # Container definition
├── entrypoint.sh               # Deployment entrypoint
├── .dockerignore               # Ignore patterns
├── DOCKER.md                   # Usage documentation
└── DEPLOYMENT.md               # Detailed deployment guide
```

---

## 🚀 Quick Start

### Make Scripts Executable

```bash
cd packages/typescript/signaling-contract
chmod +x test-docker.sh
chmod +x push-to-dockerhub.sh
```

### Run Tests

```bash
./test-docker.sh
```

This will:
- ✅ Build the Docker image
- ✅ Start Ganache (if needed)
- ✅ Test deployment with default config
- ✅ Test deployment with custom private key
- ✅ Test volume mount functionality
- ✅ Verify everything works

### Push to Docker Hub

```bash
./push-to-dockerhub.sh your-docker-username
```

Example:
```bash
./push-to-dockerhub.sh parresia
```

---

## 📋 Script Details

### `test-docker.sh`

**Purpose**: Validate the Docker image works correctly before publishing

**Steps**:
1. Builds the Docker image
2. Verifies/starts Ganache
3. Tests deployment with default mnemonic
4. Tests deployment with custom private key
5. Tests volume mount for address output
6. Checks image size
7. Cleans up test containers

**Usage**:
```bash
# Default (localhost:8545)
./test-docker.sh

# Custom image name
./test-docker.sh my-image:test

# Custom RPC URL
./test-docker.sh signaling-contract-deployer:test http://my-ganache:8545
```

**Exit Codes**:
- `0` = All tests passed
- `1` = Test failed

---

### `push-to-dockerhub.sh`

**Purpose**: Automatically tag and push image to Docker Hub

**Steps**:
1. Verifies Docker Hub login
2. Builds image if needed
3. Tags with `latest` and version tags
4. Pushes both tags to Docker Hub
5. Verifies images are accessible

**Usage**:
```bash
./push-to-dockerhub.sh <docker-username>
```

**Required**:
- Docker Hub account
- Public repository: `signaling-contract-deployer`
- Logged in: `docker login`

**Tags Created**:
- `<username>/signaling-contract-deployer:latest`
- `<username>/signaling-contract-deployer:v<version>` (from package.json)

---

## 🔄 Complete Workflow

### Step 1: Prepare (one-time)

```bash
# Create Docker Hub account
# https://hub.docker.com/signup

# Create public repo named: signaling-contract-deployer

# Login locally
docker login

# Make scripts executable
chmod +x test-docker.sh
chmod +x push-to-dockerhub.sh
```

### Step 2: Test Locally

```bash
./test-docker.sh

# Wait for completion...
# Should see: ✅ All tests passed!
```

### Step 3: Push to Docker Hub

```bash
./push-to-dockerhub.sh your-username

# Wait for completion...
# Should see: ✅ Successfully pushed to Docker Hub!
```

### Step 4: Verify on Docker Hub

```bash
# Check your Docker Hub profile
https://hub.docker.com/r/your-username/signaling-contract-deployer

# Pull and test
docker pull your-username/signaling-contract-deployer:latest
```

### Step 5: Use in Other Projects

```bash
docker run \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=0x... \
  your-username/signaling-contract-deployer:latest
```

---

## 🐛 Troubleshooting

### Test Script Issues

**Port 8545 already in use:**
```bash
docker stop ganache-test 2>/dev/null || true
./test-docker.sh
```

**Build fails:**
```bash
docker system prune -f
./test-docker.sh
```

**Tests timeout:**
```bash
# Increase sleep in script or check Ganache
docker logs ganache-test
./test-docker.sh
```

### Push Script Issues

**Not logged in to Docker Hub:**
```bash
docker login
./push-to-dockerhub.sh your-username
```

**Repository doesn't exist:**
1. Go to Docker Hub: https://hub.docker.com
2. Create new repository: `signaling-contract-deployer`
3. Make it public
4. Try pushing again

**Permission denied:**
```bash
# Ensure you have access to the repository
# Or create a new one with your name
./push-to-dockerhub.sh your-username
```

---

## 📊 What Gets Tested

| Test | Checks |
|------|--------|
| **Build** | Docker image compiles correctly |
| **Ganache** | Connection to blockchain network |
| **Default Config** | Deploy with mnemonic account |
| **Custom Key** | Deploy with private key env var |
| **Volume Mount** | Address saved to mounted volume |
| **Output** | Contract address extracted correctly |

---

## 💡 Environment Variables

When running the deployed image:

```bash
# Ganache RPC endpoint
-e RPC_URL=http://ganache:8545

# Private key (optional, uses mnemonic if not set)
-e PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

---

## 📝 Checking Progress

### After Test Script
```bash
docker images | grep signaling-contract-deployer:test
# Should show the built image
```

### After Push Script
```bash
# On Docker Hub
https://hub.docker.com/r/your-username/signaling-contract-deployer

# Via Docker CLI
docker pull your-username/signaling-contract-deployer:latest
```

---

## 🎯 Success Indicators

### Test Script ✅
```
════════════════════════════════════════════
✅ All tests passed!
════════════════════════════════════════════

Next steps:
  1. Run: ./push-to-dockerhub.sh <username>
```

### Push Script ✅
```
════════════════════════════════════════════
✅ Successfully pushed to Docker Hub!
════════════════════════════════════════════

Image URLs:
  Latest: docker pull your-username/signaling-contract-deployer:latest
```

---

## 📚 Additional Resources

- **Docker Documentation**: https://docs.docker.com/
- **Docker Hub**: https://hub.docker.com/
- **Full Guide**: See `DEPLOYMENT.md`
- **Usage Examples**: See `DOCKER.md`

