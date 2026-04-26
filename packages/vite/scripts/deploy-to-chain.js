#!/usr/bin/env node
// Deploy script per Signaling contract su blockchain specificata
const path = require('path');
const fs = require('fs');

async function deployToChain() {
  try {
    // Get blockchain endpoint from env
    const BLOCKCHAIN_URL = process.env.BLOCKCHAIN_URL || 'http://localhost:8483';
    const BLOCKCHAIN_TYPE = process.env.BLOCKCHAIN_TYPE || 'vite';

    console.log(`\n🚀 Starting Signaling contract deployment`);
    console.log(`📍 Blockchain: ${BLOCKCHAIN_TYPE}`);
    console.log(`🔗 Node URL: ${BLOCKCHAIN_URL}\n`);

    if (BLOCKCHAIN_TYPE === 'vite') {
      await deployToVite(BLOCKCHAIN_URL);
    } else if (BLOCKCHAIN_TYPE === 'ethereum') {
      await deployToEthereum(BLOCKCHAIN_URL);
    } else {
      throw new Error(`Unsupported blockchain type: ${BLOCKCHAIN_TYPE}`);
    }

  } catch (error) {
    console.error('\n❌ Deployment failed:');
    console.error(error.message);
    process.exit(1);
  }
}

async function deployToVite(nodeUrl) {
  try {
    const { newProvider, newAccount, compile, defaultViteNetwork } = require('@vite/vuilder');

    console.log('📦 Compiling Signaling contract...');
    const compiledContracts = await compile(
      path.join(__dirname, '../contracts/Signaling.solpp')
    );
    console.log('✅ Compilation successful\n');

    // Pick the Signaling contract from compile output
    const contract = compiledContracts.Signaling || Object.values(compiledContracts)[0];
    if (!contract) {
      throw new Error('Signaling contract not found in compilation output');
    }

    const provider = newProvider(nodeUrl);
    const deployer = newAccount(defaultViteNetwork.mnemonic, 0, provider);

    contract.setProvider(provider).setDeployer(deployer);

    console.log('🔗 Deploying to Vite network...');
    console.log(`   Owner (deployer): ${deployer.address}`);
    await contract.deploy({
      params: [deployer.address],
      responseLatency: 1,
      quotaMultiplier: 10,
      randomDegree: 0,
    });
    const contractAddress = contract.address;

    console.log(`\n✅ Contract deployed successfully!`);
    console.log(`📍 Contract Address: ${contractAddress}\n`);

    // Save deployment info
    const deploymentInfo = {
      timestamp: new Date().toISOString(),
      contractAddress,
      network: 'vite',
      nodeUrl,
      contractType: 'Signaling',
      version: require('../package.json').version,
    };

    saveDeploymentInfo(deploymentInfo);
    return contractAddress;

  } catch (error) {
    throw new Error(`Vite deployment failed: ${error && error.message ? error.message : JSON.stringify(error)}`);
  }
}

async function deployToEthereum(nodeUrl) {
  try {
    console.log('📦 Compiling Signaling contract...');

    // For Ethereum, would use ethers or web3.js
    // This is a placeholder for future Ethereum support
    throw new Error('Ethereum deployment not yet implemented');

  } catch (error) {
    throw new Error(`Ethereum deployment failed: ${error.message}`);
  }
}

function saveDeploymentInfo(deploymentInfo) {
  const dateFolder = new Date().toISOString().split('T')[0];
  const deploymentDir = path.join(__dirname, '../deployments', dateFolder);

  fs.mkdirSync(deploymentDir, { recursive: true });

  const filename = `deployment-${Date.now()}.json`;
  const filepath = path.join(deploymentDir, filename);

  fs.writeFileSync(filepath, JSON.stringify(deploymentInfo, null, 2));
  console.log(`📄 Deployment info saved: ${filepath}`);

  // Also save to a 'latest' file for easy access
  const latestPath = path.join(__dirname, '../deployments', 'latest-deployment.json');
  fs.writeFileSync(latestPath, JSON.stringify(deploymentInfo, null, 2));
  console.log(`📄 Latest deployment: ${latestPath}\n`);
}

// Run deployment
deployToChain().catch(error => {
  console.error(error);
  process.exit(1);
});

module.exports = { deployToChain };
