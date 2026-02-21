import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";      // Include Hardhat Ethers, Chai, etc.
import "@openzeppelin/hardhat-upgrades";          // Plugin OpenZeppelin Upgrades

const config: HardhatUserConfig = {
  typechain: {
     outDir: "../signaling-sdk/src/typeschain"
  },
  solidity: {
    compilers: [
      {
        version: "0.8.24", // Or your specific Solidity version
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
          evmVersion: "shanghai", // Override Hardhat's default to Paris
        },
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      gas: 8000000,
      gasPrice: 1000000000, // 1 gwei
      timeout: 40000
    },
    ganache: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20
      },
      gas: "auto",
      timeout: 20000
    }
  }
    
};

  export default config;
