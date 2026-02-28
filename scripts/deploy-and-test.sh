#!/bin/bash

# Script per deployare il contratto e eseguire i test Dart
# Uso: ./scripts/deploy-and-test.sh

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funzioni di log
log_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Cleanup function
cleanup() {
  if [ ! -z "$HARDHAT_PID" ]; then
    log_info "Killing Hardhat network (PID: $HARDHAT_PID)..."
    kill $HARDHAT_PID 2>/dev/null || true
    wait $HARDHAT_PID 2>/dev/null || true
  fi
}

trap cleanup EXIT

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "  Smart Contract Deploy & Test Script"
echo "=========================================="
echo ""

# Step 1: Check prerequisites
log_info "Checking prerequisites..."

if ! command -v node &> /dev/null; then
  log_error "Node.js not found. Please install Node.js."
  exit 1
fi

if ! command -v dart &> /dev/null; then
  log_error "Dart not found. Please install Dart."
  exit 1
fi

log_success "Prerequisites OK (Node.js, Dart)"
echo ""

# Step 2: Install dependencies
log_info "Installing Node.js dependencies..."
cd "$PROJECT_ROOT/packages/typescript/signaling-contract"
npm install --silent
log_success "Node.js dependencies installed"

log_info "Installing Dart dependencies..."
cd "$PROJECT_ROOT/packages/contract_sdk"
dart pub get --quiet
log_success "Dart dependencies installed"
echo ""

# Step 3: Start Hardhat network
log_info "Starting Hardhat network..."
cd "$PROJECT_ROOT/packages/typescript/signaling-contract"
npm run network > /tmp/hardhat-node.log 2>&1 &
HARDHAT_PID=$!
echo "PID: $HARDHAT_PID"

# Wait for Hardhat to be ready
log_info "Waiting for Hardhat to start (max 15 seconds)..."
for i in {1..15}; do
  if curl -s http://localhost:8545 -X POST \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' &> /dev/null; then
    log_success "Hardhat network is ready!"
    break
  fi
  if [ $i -eq 15 ]; then
    log_error "Hardhat network failed to start"
    log_error "Check /tmp/hardhat-node.log for details"
    exit 1
  fi
  sleep 1
done
echo ""

# Step 4: Build contracts
log_info "Building contracts..."
npm run build:contracts --silent
log_success "Contracts built"
echo ""

# Step 5: Deploy contract
log_info "Deploying contract..."
npm run deploySC 2>&1 | tee /tmp/deploy.log

# Extract contract address
CONTRACT_ADDRESS=$(grep "deployed at:" /tmp/deploy.log | grep -oE '0x[a-fA-F0-9]{40}' | head -1)

if [ -z "$CONTRACT_ADDRESS" ]; then
  log_error "Failed to extract contract address from deployment log"
  cat /tmp/deploy.log
  exit 1
fi

log_success "Contract deployed at: $CONTRACT_ADDRESS"
echo ""

# Step 6: Run Dart tests
log_info "Running Dart integration tests..."
cd "$PROJECT_ROOT/packages/contract_sdk"

export TEST_RPC_URL=http://localhost:8545
export TEST_CONTRACT_ADDRESS=$CONTRACT_ADDRESS
export TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807

dart test -r expanded --timeout 120s

if [ $? -eq 0 ]; then
  log_success "All tests passed!"
else
  log_error "Tests failed"
  exit 1
fi

echo ""
echo "=========================================="
echo "  ✅ Deployment and Tests Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  • Hardhat network: http://localhost:8545"
echo "  • Contract address: $CONTRACT_ADDRESS"
echo "  • Tests: PASSED"
echo ""
echo "Note: Hardhat network will be stopped when this script exits."
