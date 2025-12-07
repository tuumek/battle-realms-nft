require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { PRIVATE_KEY, BASE_MAINNET_RPC, BASE_SEPOLIA_RPC, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {},
    base: {
      url: BASE_MAINNET_RPC || "https://mainnet.base.org",
      chainId: 8453,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : []
    },
    baseSepolia: {
      url: BASE_SEPOLIA_RPC || "https://sepolia.base.org",
      chainId: 84532,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      // optional: Base explorer (BaseScan) may use Etherscan-compatible API keys or custom;
      // For verification you might need to use Base's verification process or explorer-specific key
      base: ETHERSCAN_API_KEY || ""
    }
  }
};
