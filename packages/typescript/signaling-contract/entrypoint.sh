#!/bin/sh
set -e

echo "🚀 Starting smart contract deployment..."

# Debug: Print environment variables (safely)
echo ""
echo "📋 Environment Configuration:"
echo "Debug: RPC_URL=${RPC_URL:-not set}"
echo "Debug: PRIVATE_KEY length=${#PRIVATE_KEY}"
if [ ! -z "$PRIVATE_KEY" ]; then
  echo "Debug: PRIVATE_KEY first 10 chars: ${PRIVATE_KEY:0:10}..."
fi
echo ""

# Strip quotes from PRIVATE_KEY if present
if [ ! -z "$PRIVATE_KEY" ]; then
  PRIVATE_KEY="${PRIVATE_KEY%\"}"  # Remove trailing "
  PRIVATE_KEY="${PRIVATE_KEY#\"}"  # Remove leading "
  echo "✓ PRIVATE_KEY quotes stripped"
fi

# Validate PRIVATE_KEY if provided
if [ ! -z "$PRIVATE_KEY" ]; then
  PRIVATE_KEY_LEN=${#PRIVATE_KEY}
  if [ $PRIVATE_KEY_LEN -ne 64 ]; then
    echo "❌ ERROR: PRIVATE_KEY must be 64 hex characters (32 bytes), got $PRIVATE_KEY_LEN"
    exit 1
  fi
  echo "✓ PRIVATE_KEY validation passed (64 chars)"
fi
echo ""

# Run deployment and capture output
echo "📤 Deploying contract to $RPC_URL..."
DEPLOY_OUTPUT=$(npx hardhat run ./ignition/modules/DeploySignaling.ts --network ganache 2>&1)
DEPLOY_EXIT_CODE=$?

# Print deployment output
echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
  echo ""
  echo "❌ Deployment failed with exit code: $DEPLOY_EXIT_CODE"
  echo "📋 Full error output:"
  echo "$DEPLOY_OUTPUT"
  exit 1
fi

# Extract contract address from deployment output
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "deployed at:" | awk '{print $NF}')

if [ -z "$CONTRACT_ADDRESS" ]; then
  echo "❌ Failed to extract contract address"
  exit 1
fi

# Output address in a format that can be easily captured
echo ""
echo "✅ Deployment successful!"
echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS"

# If volume is mounted at /output, save the address there
if [ -d "/output" ]; then
  echo "$CONTRACT_ADDRESS" > /output/CONTRACT_ADDRESS
  echo "📁 Address also saved to /output/CONTRACT_ADDRESS"
fi

exit 0
