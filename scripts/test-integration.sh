#!/bin/bash

# Script di integrazione automatico: avvia Hardhat node, deploya e testa

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TS_CONTRACT_DIR="$PROJECT_ROOT/packages/typescript/signaling-contract"
DART_SDK_DIR="$PROJECT_ROOT/packages/contract_sdk"
RPC_URL="http://localhost:8545"
HARDHAT_PID=""

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione di cleanup
cleanup() {
  if [ ! -z "$HARDHAT_PID" ] && kill -0 "$HARDHAT_PID" 2>/dev/null; then
    echo -e "${YELLOW}Terminando Hardhat node (PID: $HARDHAT_PID)...${NC}"
    kill "$HARDHAT_PID" 2>/dev/null || true
    wait "$HARDHAT_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT

# 1. Avviare Hardhat node in background
echo -e "${YELLOW}[1/4] Avviando Hardhat node...${NC}"
cd "$TS_CONTRACT_DIR"
npm run network > /tmp/hardhat.log 2>&1 &
HARDHAT_PID=$!
echo "Hardhat PID: $HARDHAT_PID"

# 2. Aspettare che Hardhat sia pronto
echo -e "${YELLOW}[2/4] Aspettando che Hardhat sia pronto...${NC}"
MAX_RETRIES=30
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
  if curl -s -X POST "$RPC_URL" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' | grep -q "0x"; then
    echo -e "${GREEN}Hardhat è pronto!${NC}"
    break
  fi
  RETRY=$((RETRY + 1))
  echo "Tentativo $RETRY/$MAX_RETRIES..."
  sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
  echo -e "${RED}Errore: Hardhat non ha risposto dopo $MAX_RETRIES secondi${NC}"
  exit 1
fi

# 3. Deployare il contratto
echo -e "${YELLOW}[3/4] Deployando il contratto...${NC}"
npm run deploySC 2>&1 | tee /tmp/deploy.log

# Estrarre l'indirizzo dal file token_info.txt
CONTRACT_ADDRESS=$(cat "$PROJECT_ROOT/packages/token_info.txt" | tr -d '\n\r')
echo -e "${GREEN}Contratto deployato a: $CONTRACT_ADDRESS${NC}"

# Ottenere una private key da Hardhat (primo account)
# Hardhat usa sempre: 0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078
PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078"

# 4. Eseguire i test Dart
echo -e "${YELLOW}[4/4] Eseguendo i test Dart...${NC}"
cd "$DART_SDK_DIR"

# Passare le variabili d'ambiente ai test
export TEST_RPC_URL="$RPC_URL"
export TEST_CONTRACT_ADDRESS="$CONTRACT_ADDRESS"
export TEST_PRIVATE_KEY="$PRIVATE_KEY"

echo "TEST_RPC_URL=$TEST_RPC_URL"
echo "TEST_CONTRACT_ADDRESS=$TEST_CONTRACT_ADDRESS"
echo "TEST_PRIVATE_KEY=$TEST_PRIVATE_KEY"

dart test test/signaling_contract_deploy_test.dart -v

echo -e "${GREEN}✓ Test completati con successo!${NC}"
