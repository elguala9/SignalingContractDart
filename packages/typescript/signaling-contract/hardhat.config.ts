import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";      // Include Hardhat Ethers, Chai, etc.
import "@openzeppelin/hardhat-upgrades";          // Plugin OpenZeppelin Upgrades

// Validate PRIVATE_KEY if provided
const validatePrivateKey = () => {
  if (process.env.PRIVATE_KEY) {
    let pk = process.env.PRIVATE_KEY.trim();

    // Strip quotes if present
    pk = pk.replace(/^["']|["']$/g, '');

    // Validate: must be exactly 64 hex characters (32 bytes)
    if (pk.length !== 64) {
      throw new Error(
        `Invalid PRIVATE_KEY: expected 64 hex characters (32 bytes), got ${pk.length}. ` +
        `Make sure you're using the raw hex string without "0x" prefix.`
      );
    }

    // Validate: must be valid hex
    if (!/^[0-9a-fA-F]{64}$/.test(pk)) {
      throw new Error(
        `Invalid PRIVATE_KEY: must contain only hexadecimal characters (0-9, a-f, A-F)`
      );
    }

    return pk;
  }
  return undefined;
};

const privateKey = validatePrivateKey();

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
    hardhat: {
      chainId: 31337,
      allowUnlimitedContractSize: true,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      gas: 8000000,
      gasPrice: 1000000000, // 1 gwei
      timeout: 40000,
      allowUnlimitedContractSize: true,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20
      }
    },
    ganache: {
      url: process.env.RPC_URL || "http://127.0.0.1:8545",
      chainId: 1337,
      accounts: privateKey
        ? [privateKey]
        : {
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
