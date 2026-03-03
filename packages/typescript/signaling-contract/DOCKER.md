# Docker Deployment Guide

## Building the Image

```bash
cd packages/typescript/signaling-contract
docker build -t signaling-contract-deployer .
```

## Running the Deployment

### Basic Usage (stdout output)

```bash
docker run \
  --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  signaling-contract-deployer
```

**Output:**
```
🚀 Starting smart contract deployment...
[deployment logs...]
✅ Deployment successful!
CONTRACT_ADDRESS=0x5fbdb2315678afccb333f8a9fcff40444b0a74b5e
📁 Address also saved to /output/CONTRACT_ADDRESS
```

### Capturing the Address in a Script

```bash
#!/bin/bash

# Run the container and capture output
OUTPUT=$(docker run \
  --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=$PRIVATE_KEY \
  signaling-contract-deployer)

# Extract the address
CONTRACT_ADDRESS=$(echo "$OUTPUT" | grep "CONTRACT_ADDRESS=" | cut -d'=' -f2)

echo "Contract deployed at: $CONTRACT_ADDRESS"
# Use the address in your tests or other processes
```

### Saving Address to a File (with Volume Mount)

```bash
# Create output directory
mkdir -p ./contract-output

# Run deployment with volume mount
docker run \
  --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=$PRIVATE_KEY \
  -v $(pwd)/contract-output:/output \
  signaling-contract-deployer

# Read the address
CONTRACT_ADDRESS=$(cat ./contract-output/CONTRACT_ADDRESS)
echo "Contract address: $CONTRACT_ADDRESS"
```

## Environment Variables

- **`RPC_URL`** (optional): RPC endpoint for the Ganache network
  - Default: `http://127.0.0.1:8545`
  - Example: `http://ganache:8545`

- **`PRIVATE_KEY`** (optional): Private key for deployment account
  - Default: Uses mnemonic `test test test test test test test test test test test junk`
  - Example: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

## Docker Network Setup

If using Docker Compose or connecting multiple containers:

```bash
# Create a network
docker network create parresia-network

# Start Ganache on the network
docker run \
  --name ganache \
  --network parresia-network \
  -p 8545:8545 \
  trufflesuite/ganache --chain.chainId 1337

# Deploy contract to Ganache
docker run \
  --network parresia-network \
  -e RPC_URL=http://ganache:8545 \
  -e PRIVATE_KEY=0x... \
  signaling-contract-deployer
```

## Using in CI/CD

```yaml
# Example GitHub Actions
- name: Deploy Signaling Contract
  run: |
    docker build -t signaling-contract-deployer ./packages/typescript/signaling-contract

    OUTPUT=$(docker run \
      -e RPC_URL=${{ secrets.GANACHE_RPC_URL }} \
      -e PRIVATE_KEY=${{ secrets.DEPLOY_PRIVATE_KEY }} \
      signaling-contract-deployer)

    CONTRACT_ADDRESS=$(echo "$OUTPUT" | grep "CONTRACT_ADDRESS=" | cut -d'=' -f2)
    echo "SIGNALING_CONTRACT=$CONTRACT_ADDRESS" >> $GITHUB_ENV
```

## Troubleshooting

### Connection Refused
- Ensure Ganache is running and accessible at `RPC_URL`
- For local testing: `http://127.0.0.1:8545`
- For Docker container: Use network name like `http://ganache:8545`

### Invalid Private Key
- Private key should be in hex format: `0x...` (66 chars including 0x)
- Ensure it's enclosed in quotes in shell commands

### Address Extraction Failed
- Check that deployment completed successfully (look for ✅ message)
- The address format is always: `CONTRACT_ADDRESS=0x...`
