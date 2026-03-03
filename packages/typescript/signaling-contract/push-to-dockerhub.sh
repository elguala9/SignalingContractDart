#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "🚀 Docker Hub Deployment Script"
echo "════════════════════════════════════════════"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get Docker Hub username
DOCKER_USERNAME=$(echo "${1}" | tr '[:upper:]' '[:lower:]')

if [ -z "$DOCKER_USERNAME" ]; then
  echo -e "${RED}❌ Error: Docker Hub username required${NC}"
  echo ""
  echo "Usage: ./push-to-dockerhub.sh <docker-hub-username>"
  echo ""
  echo "Examples:"
  echo "  ./push-to-dockerhub.sh parresia"
  echo "  ./push-to-dockerhub.sh john-doe"
  echo ""
  exit 1
fi

# Get version from package.json or use default
VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/')
if [ -z "$VERSION" ]; then
  VERSION="latest"
fi

IMAGE_NAME="signaling-contract-deployer"
LOCAL_IMAGE="$IMAGE_NAME:test"
REGISTRY="docker.io"
REMOTE_IMAGE_LATEST="$REGISTRY/$DOCKER_USERNAME/$IMAGE_NAME:latest"
REMOTE_IMAGE_VERSION="$REGISTRY/$DOCKER_USERNAME/$IMAGE_NAME:v$VERSION"
REMOTE_IMAGE_UNSTABLE="$REGISTRY/$DOCKER_USERNAME/$IMAGE_NAME:develop"

echo -e "${BLUE}Configuration:${NC}"
echo "  Docker Hub Username: $DOCKER_USERNAME"
echo "  Image Name: $IMAGE_NAME"
echo "  Version: $VERSION"
echo "  Remote Images:"
echo "    - $REMOTE_IMAGE_LATEST"
echo "    - $REMOTE_IMAGE_VERSION"
echo ""

# Step 1: Check Docker login
echo -e "${BLUE}[1/5] Checking Docker Hub login...${NC}"
if ! docker info 2>/dev/null | grep -q "Username"; then
  echo -e "${YELLOW}⚠️  Not logged in to Docker Hub${NC}"
  echo -e "${YELLOW}Please login:${NC}"
  docker login || {
    echo -e "${RED}❌ Docker login failed${NC}"
    exit 1
  }
fi
echo -e "${GREEN}✅ Logged in to Docker Hub${NC}"

# Step 2: Verify local image exists
echo -e "\n${BLUE}[2/5] Checking local image...${NC}"
if ! docker images | grep -q "$LOCAL_IMAGE"; then
  echo -e "${YELLOW}⚠️  Local image not found. Building...${NC}"
  docker build -t "$LOCAL_IMAGE" . || {
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
  }
fi
echo -e "${GREEN}✅ Local image ready: $LOCAL_IMAGE${NC}"

# Step 3: Tag image for Docker Hub
echo -e "\n${BLUE}[3/5] Tagging image for Docker Hub...${NC}"
docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE_LATEST" || {
  echo -e "${RED}❌ Tagging failed${NC}"
  exit 1
}
docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE_VERSION" || {
  echo -e "${RED}❌ Tagging version failed${NC}"
  exit 1
}
echo -e "${GREEN}✅ Tagged as:${NC}"
echo "  - $REMOTE_IMAGE_LATEST"
echo "  - $REMOTE_IMAGE_VERSION"

# Step 4: Push to Docker Hub
echo -e "\n${BLUE}[4/5] Pushing to Docker Hub...${NC}"
echo -e "${YELLOW}Pushing $REMOTE_IMAGE_LATEST...${NC}"
docker push "$REMOTE_IMAGE_LATEST" || {
  echo -e "${RED}❌ Push failed${NC}"
  exit 1
}
echo -e "${GREEN}✅ Pushed latest${NC}"

echo -e "${YELLOW}Pushing $REMOTE_IMAGE_VERSION...${NC}"
docker push "$REMOTE_IMAGE_VERSION" || {
  echo -e "${RED}❌ Push version failed${NC}"
  exit 1
}
echo -e "${GREEN}✅ Pushed version${NC}"

# Step 5: Verify on Docker Hub
echo -e "\n${BLUE}[5/5] Verifying on Docker Hub...${NC}"
docker pull "$REMOTE_IMAGE_LATEST" > /dev/null 2>&1 || {
  echo -e "${RED}❌ Verification failed${NC}"
  exit 1
}
echo -e "${GREEN}✅ Image verified on Docker Hub${NC}"

# Summary
echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Successfully pushed to Docker Hub!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Image URLs:${NC}"
echo "  Latest: docker pull $REMOTE_IMAGE_LATEST"
echo "  Version: docker pull $REMOTE_IMAGE_VERSION"
echo ""
echo -e "${BLUE}Usage in other projects:${NC}"
echo ""
echo "  docker run \\"
echo "    -e RPC_URL=http://ganache:8545 \\"
echo "    -e PRIVATE_KEY=0x... \\"
echo "    $REMOTE_IMAGE_LATEST"
echo ""
echo -e "${BLUE}Docker Hub URL:${NC}"
echo "  https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
echo ""
