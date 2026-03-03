#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "🧪 Testing Signaling Contract Docker Image"
echo "════════════════════════════════════════════"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="${1:-signaling-contract-deployer:test}"
RPC_URL="${2:-http://127.0.0.1:8545}"
GANACHE_PORT="8545"

# Step 1: Build
echo -e "\n${BLUE}[1/6] Building Docker image...${NC}"
echo "Image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" . || {
  echo -e "${RED}❌ Build failed${NC}"
  exit 1
}
echo -e "${GREEN}✅ Build successful${NC}"

# Step 2: Check if Ganache is already running
echo -e "\n${BLUE}[2/6] Checking Ganache...${NC}"
GANACHE_RUNNING=$(docker ps --filter "name=ganache" --filter "status=running" -q)

if [ -z "$GANACHE_RUNNING" ]; then
  echo -e "${YELLOW}⚠️  Starting Ganache...${NC}"
  docker run -d \
    --name ganache-test \
    -p $GANACHE_PORT:8545 \
    trufflesuite/ganache \
    --chain.chainId 1337 \
    > /dev/null 2>&1

  echo -e "${YELLOW}⏳ Waiting for Ganache to be ready...${NC}"
  sleep 4
else
  echo -e "${YELLOW}⚠️  Using existing Ganache instance${NC}"
fi

echo -e "${GREEN}✅ Ganache ready at $RPC_URL${NC}"

# Step 3: Test with default config
echo -e "\n${BLUE}[3/6] Testing deployment with default config...${NC}"
OUTPUT=$(docker run \
  --network host \
  -e RPC_URL=$RPC_URL \
  "$IMAGE_NAME" 2>&1) || {
  echo -e "${RED}❌ Deployment failed${NC}"
  echo "$OUTPUT"
  exit 1
}

# Verify output
if echo "$OUTPUT" | grep -q "✅ Deployment successful"; then
  echo -e "${GREEN}✅ Deployment completed${NC}"
else
  echo -e "${RED}❌ Deployment output unexpected${NC}"
  echo "$OUTPUT"
  exit 1
fi

# Extract address
CONTRACT_ADDRESS=$(echo "$OUTPUT" | grep "CONTRACT_ADDRESS=" | cut -d'=' -f2)
if [ -z "$CONTRACT_ADDRESS" ]; then
  echo -e "${RED}❌ Failed to extract contract address${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Contract address: $CONTRACT_ADDRESS${NC}"

# Step 4: Test with private key
echo -e "\n${BLUE}[4/6] Testing deployment with custom private key...${NC}"
OUTPUT2=$(docker run \
  --network host \
  -e RPC_URL=$RPC_URL \
  -e PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  "$IMAGE_NAME" 2>&1) || {
  echo -e "${RED}❌ Deployment with private key failed${NC}"
  echo "$OUTPUT2"
  exit 1
}

if echo "$OUTPUT2" | grep -q "✅ Deployment successful"; then
  ADDR2=$(echo "$OUTPUT2" | grep "CONTRACT_ADDRESS=" | cut -d'=' -f2)
  echo -e "${GREEN}✅ Private key deployment successful${NC}"
  echo -e "${GREEN}✅ Contract address: $ADDR2${NC}"
else
  echo -e "${RED}❌ Private key deployment failed${NC}"
  exit 1
fi

# Step 5: Test volume mount
echo -e "\n${BLUE}[5/6] Testing volume mount output...${NC}"
rm -rf test-output
mkdir -p test-output

docker run \
  --network host \
  -e RPC_URL=$RPC_URL \
  -v $(pwd)/test-output:/output \
  "$IMAGE_NAME" > /dev/null 2>&1

if [ -f "test-output/CONTRACT_ADDRESS" ]; then
  SAVED_ADDRESS=$(cat test-output/CONTRACT_ADDRESS)
  echo -e "${GREEN}✅ Address saved to file: $SAVED_ADDRESS${NC}"
else
  echo -e "${RED}❌ Address file not found${NC}"
  exit 1
fi

# Step 6: Verify image size
echo -e "\n${BLUE}[6/6] Checking image size...${NC}"
IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "{{.Size}}")
echo -e "${GREEN}✅ Image size: $IMAGE_SIZE${NC}"

# Cleanup
echo -e "\n${YELLOW}Cleaning up...${NC}"
rm -rf test-output
docker rm ganache-test 2>/dev/null || true

echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All tests passed!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Run: ./push-to-dockerhub.sh <username>"
echo "  2. Or manually tag and push:"
echo "     docker tag signaling-contract-deployer:test <username>/signaling-contract-deployer:latest"
echo "     docker push <username>/signaling-contract-deployer:latest"
echo ""
