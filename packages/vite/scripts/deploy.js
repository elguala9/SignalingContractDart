// Deployment script per Signaling contract su Vite blockchain
const path = require('path');

async function deploy() {
  try {
    console.log('🚀 Starting Signaling contract deployment...\n');

    // Import vuilder
    const { localProvider, deployContract, compile } = require('@vite/vuilder');

    const provider = localProvider();

    // Compile contract
    console.log('📦 Compiling Signaling contract...');
    const compiledContract = await compile(path.join(__dirname, '../contracts/Signaling.solpp'));
    console.log('✅ Compilation successful\n');

    // Deploy contract
    console.log('🔗 Deploying to Vite network...');
    const contractAddress = await deployContract(
      compiledContract,
      provider,
      {
        params: [], // Add constructor params if needed
      }
    );

    console.log(`\n✅ Contract deployed successfully!`);
    console.log(`📍 Contract Address: ${contractAddress}\n`);

    // Save deployment info
    const fs = require('fs');
    const deploymentInfo = {
      timestamp: new Date().toISOString(),
      contractAddress,
      network: 'vite-local',
      version: require('../package.json').version,
    };

    const deploymentPath = path.join(__dirname, '../deployments', new Date().toISOString().split('T')[0]);
    fs.mkdirSync(deploymentPath, { recursive: true });
    fs.writeFileSync(
      path.join(deploymentPath, `deployment-${Date.now()}.json`),
      JSON.stringify(deploymentInfo, null, 2)
    );

    console.log(`📄 Deployment info saved`);
    return contractAddress;
  } catch (error) {
    console.error('❌ Deployment failed:');
    console.error(error);
    process.exit(1);
  }
}

// Run deployment
deploy().catch(error => {
  console.error(error);
  process.exit(1);
});

module.exports = { deploy };
