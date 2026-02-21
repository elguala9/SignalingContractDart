#!/bin/bash

# Integration Tests Runner for Signaling Contract
# This script:
# 1. Starts Ganache in Docker
# 2. Deploys the contract
# 3. Runs Dart integration tests

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
CONTRACTS_DIR="$PROJECT_ROOT/packages/typescript/signaling-contract"
SDK_DIR="$PROJECT_ROOT/packages/contract_sdk"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
  echo -e "${BLUE}=== $1 ===${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Step 1: Start Ganache
print_header "Step 1: Starting Ganache"

GANACHE_CONTAINER="parresia-contract-ganache"

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${GANACHE_CONTAINER}$"; then
  print_info "Ganache container exists, checking if it's running..."
  if docker ps --format '{{.Names}}' | grep -q "^${GANACHE_CONTAINER}$"; then
    print_success "Ganache is already running"
  else
    print_info "Starting existing Ganache container..."
    docker start "$GANACHE_CONTAINER"
    sleep 5
    print_success "Ganache started"
  fi
else
  print_info "Starting Docker Compose..."
  cd "$PROJECT_ROOT"
  docker-compose up -d ganache
  sleep 10
  print_success "Ganache started in Docker"
fi

# Wait for Ganache to be ready
print_info "Waiting for Ganache to be ready..."
for i in {1..30}; do
  if curl -s http://localhost:8545 > /dev/null 2>&1; then
    print_success "Ganache is ready!"
    break
  fi
  if [ $i -eq 30 ]; then
    print_error "Ganache failed to start"
    exit 1
  fi
  sleep 1
done

# Step 2: Compile and deploy contracts
print_header "Step 2: Compiling and Deploying Contracts"

cd "$CONTRACTS_DIR"

print_info "Compiling contracts..."
npx hardhat compile

print_info "Deploying to Ganache..."
npx hardhat run "$SCRIPTS_DIR/deploy-to-ganache.ts" --network ganache

# Step 3: Setup Dart environment
print_header "Step 3: Setting up Dart environment"

cd "$SDK_DIR"

print_info "Installing Dart dependencies..."
dart pub get

# Step 4: Run integration tests
print_header "Step 4: Running Integration Tests"

# Load environment variables from deployment
if [ -f "$PROJECT_ROOT/.env.ganache" ]; then
  print_info "Loading environment variables..."
  export $(cat "$PROJECT_ROOT/.env.ganache" | xargs)
else
  print_error "Environment file not found at $PROJECT_ROOT/.env.ganache"
  exit 1
fi

print_info "Environment variables:"
echo "  TEST_RPC_URL: $TEST_RPC_URL"
echo "  TEST_CONTRACT_ADDRESS: $TEST_CONTRACT_ADDRESS"
echo "  TEST_CHAIN_ID: $TEST_CHAIN_ID"
echo ""

print_info "Running unit tests first..."
dart test test/signaling_contract_test.dart

print_info "Running integration tests..."
dart test test/signaling_contract_deploy_test.dart

# Step 5: Cleanup
print_header "Cleanup"

print_info "Stopping Ganache..."
docker-compose down

print_success "All tests completed!"

echo ""
echo -e "${GREEN}📊 Test Summary:${NC}"
echo "   ✅ Unit tests passed"
echo "   ✅ Integration tests passed"
echo "   ✅ Contract deployed to Ganache"
echo ""
