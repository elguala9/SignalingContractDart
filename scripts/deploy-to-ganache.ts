/**
 * Deployment script for Signaling Contract to Ganache
 *
 * Usage:
 *   npx hardhat run scripts/deploy-to-ganache.ts --network ganache
 */

import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
  console.log("🚀 Deploying Signaling Contract to Ganache...\n");

  // Get the contract factory
  const SignalingContractFactory = await ethers.getContractFactory("Signaling");
  const ProxyFactory = await ethers.getContractFactory("TransparentUpgradeableProxy");

  // Get signers
  const [owner] = await ethers.getSigners();
  console.log(`📍 Deploying from account: ${owner.address}`);

  const balance = await ethers.provider.getBalance(owner.address);
  console.log(`💰 Account balance: ${ethers.formatEther(balance)} ETH\n`);

  try {
    // Deploy implementation
    console.log("1️⃣  Deploying Signaling implementation...");
    const implementation = await SignalingContractFactory.deploy();
    await implementation.waitForDeployment();
    const implAddress = await implementation.getAddress();
    console.log(`   ✅ Implementation deployed at: ${implAddress}\n`);

    // Deploy proxy admin
    console.log("2️⃣  Deploying ProxyAdmin...");
    const ProxyAdminFactory = await ethers.getContractFactory("ProxyAdmin");
    const proxyAdmin = await ProxyAdminFactory.deploy();
    await proxyAdmin.waitForDeployment();
    const proxyAdminAddress = await proxyAdmin.getAddress();
    console.log(`   ✅ ProxyAdmin deployed at: ${proxyAdminAddress}\n`);

    // Deploy proxy
    console.log("3️⃣  Deploying TransparentUpgradeableProxy...");
    const initializeData = SignalingContractFactory.interface.encodeFunctionData(
      "initialize",
      [owner.address]
    );

    const proxy = await ProxyFactory.deploy(
      implAddress,
      proxyAdminAddress,
      initializeData
    );
    await proxy.waitForDeployment();
    const proxyAddress = await proxy.getAddress();
    console.log(`   ✅ Proxy deployed at: ${proxyAddress}\n`);

    // Get proxy instance
    const signalingContract = SignalingContractFactory.attach(proxyAddress);

    // Verify deployment
    console.log("4️⃣  Verifying deployment...");
    const contractOwner = await signalingContract.owner();
    console.log(`   ✅ Contract owner: ${contractOwner}`);
    const isOwner = contractOwner.toLowerCase() === owner.address.toLowerCase();
    console.log(`   ✅ Owner verification: ${isOwner ? "✓" : "✗"}\n`);

    // Save deployment info
    const deploymentInfo = {
      timestamp: new Date().toISOString(),
      network: "ganache",
      chainId: 1337,
      deployer: owner.address,
      implementation: implAddress,
      proxyAdmin: proxyAdminAddress,
      proxy: proxyAddress,
      owner: contractOwner,
      abi: SignalingContractFactory.interface.format("json"),
    };

    const outputDir = path.join(__dirname, "..", "deployments");
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    const outputFile = path.join(outputDir, "ganache-deployment.json");
    fs.writeFileSync(outputFile, JSON.stringify(deploymentInfo, null, 2));
    console.log(`📄 Deployment info saved to: ${outputFile}\n`);

    // Export environment variables for tests
    const envFile = path.join(__dirname, "..", ".env.ganache");
    const envContent = `# Ganache Deployment Configuration
TEST_RPC_URL=http://localhost:8545
TEST_CONTRACT_ADDRESS=${proxyAddress}
TEST_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807
TEST_CHAIN_ID=1337
`;

    fs.writeFileSync(envFile, envContent);
    console.log(`📝 Environment file created: ${envFile}\n`);

    console.log("✅ Deployment completed successfully!");
    console.log("\n📋 Deployment Summary:");
    console.log(`   Proxy Address: ${proxyAddress}`);
    console.log(`   Implementation: ${implAddress}`);
    console.log(`   ProxyAdmin: ${proxyAdminAddress}`);
    console.log(`   Owner: ${contractOwner}`);
    console.log("\n🧪 To run integration tests:");
    console.log(`   export $(cat .env.ganache | xargs)`);
    console.log(`   dart test packages/contract_sdk/test/signaling_contract_deploy_test.dart`);

  } catch (error) {
    console.error("❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
