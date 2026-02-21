import { ethers, upgrades } from "hardhat";
import * as fs from "fs";

async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying Signaling with account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  const Signaling = await ethers.getContractFactory("Signaling");

  // Deploy as UUPS proxy
  const signalingContract = await upgrades.deployProxy(Signaling, [deployer.address], {
    initializer: "initialize",
    unsafeAllow: ["constructor"],
    kind: "uups",
  });

  await signalingContract.waitForDeployment();

  const contractAddress = await signalingContract.getAddress();
  console.log("Signaling deployed at:", contractAddress);

  // Fund test account (the private key from the test scripts)
  const testAccountAddress = "0x754a08c41591E6C06Bd4DEBc67a630b79119A7B7";
  const fundTx = await deployer.sendTransaction({
    to: testAccountAddress,
    value: ethers.parseEther("10"), // Send 10 ETH
  });
  console.log("Test account funded:", testAccountAddress);

  fs.writeFileSync("../../token_info.txt", contractAddress);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
