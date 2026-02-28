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

  // Fund test account (the private key from the test scripts)
  // This corresponds to: 0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
  const testAccountAddress = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1";
  const fundTx = await deployer.sendTransaction({
    to: testAccountAddress,
    value: ethers.parseEther("10"), // Send 10 ETH
  });
  console.log("✅ Test account funded:", testAccountAddress);

  fs.writeFileSync("../../token_info.txt", contractAddress);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
