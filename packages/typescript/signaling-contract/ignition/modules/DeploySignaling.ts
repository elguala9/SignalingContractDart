import { ethers } from "hardhat";
import * as fs from "fs";

async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying Signaling with account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  const Signaling = await ethers.getContractFactory("Signaling");

  // Deploy contract directly (non-upgradable) - pass owner to constructor
  const signalingContract = await Signaling.deploy(deployer.address);

  await signalingContract.waitForDeployment();

  const contractAddress = await signalingContract.getAddress();
  console.log("✅ Signaling (non-upgradable) deployed at:", contractAddress);

  // Deployer account already has unlimited funds in Hardhat
  // No need to send funds to another account
  console.log("✅ Deployer account has unlimited funds for testing");

  fs.writeFileSync("../../token_info.txt", contractAddress);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
