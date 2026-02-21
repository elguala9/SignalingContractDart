// ⚠️ DEPRECATED - Non utilizzare più
// Il contratto Signaling è stato modificato per essere standard (non upgradeable)
// Usa DeploySignaling.ts per il deploy
//
// Questo file è mantenuto per compatibilità storica
// Per informazioni sui proxy upgradeable vedi: https://docs.openzeppelin.com/upgrades-plugins/1.x/hardhat-upgrades

import { DeployProxyOptions } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";

const fs = require('fs');

export async function deploy(contract_name: string, args?: unknown[], opts?: DeployProxyOptions) {
  console.warn("⚠️  DEPRECATED: Usa DeploySignaling.ts per il deploy standard");

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.getAddress())).toString());

  const Contract = await ethers.getContractFactory(contract_name);

  const token = await upgrades.deployProxy(Contract, args, {
      initializer: "initialize",
      unsafeAllow: ["constructor"],
      ...opts
  });

  console.log("Token address:", await token.getAddress());
  fs.writeFileSync('../../token_info.txt', await token.getAddress());
}