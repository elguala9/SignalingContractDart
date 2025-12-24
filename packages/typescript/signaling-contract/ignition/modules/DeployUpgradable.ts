import { DeployProxyOptions } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";

// for more information see https://docs.openzeppelin.com/upgrades-plugins/1.x/hardhat-upgrades


const fs = require('fs');

export async function deploy(contract_name: string, args?: unknown[], opts?: DeployProxyOptions /*kind: string*/ ) {
  //if(type_json.type !== "")

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.provider.getBalance(deployer.getAddress())).toString());

  const Contract = await ethers.getContractFactory(contract_name);

  const implementation = await upgrades.deployProxy(Contract, args , opts);

  const token = await upgrades.deployProxy(Contract, args, {
      initializer: "initialize", // se necessario
      unsafeAllow: ["constructor"],
      ...opts
  });
  //const deploy_info = await token.deployed();
  console.log("Token address:", await token.getAddress());

  fs.writeFileSync('../../token_info.txt', await token.getAddress());
}