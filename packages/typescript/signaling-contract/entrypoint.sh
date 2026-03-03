#!/bin/sh
set -e

echo "🚀 Starting smart contract deployment..."

# Run deployment and capture output
DEPLOY_OUTPUT=$(npx hardhat run ./ignition/modules/DeploySignaling.ts --network ganache 2>&1)
DEPLOY_EXIT_CODE=$?

# Print deployment output
echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
  echo "❌ Deployment failed"
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
