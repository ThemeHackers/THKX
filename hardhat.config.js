require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const GOOGLE_SEPOLIA_ENDPOINT = process.env.GOOGLE_SEPOLIA_ENDPOINT;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: "0.8.17",
  networks: {},
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
    customChains: [
      {
        network: "holesky",
        chainId: 17000,
        urls: {
          apiURL: process.env.ETHERSCAN_API_URL, 
          browserURL: process.env.GOOGLE_HOLESKY_ENDPOINT 
        }
      }
    ]
  }
};

if (GOOGLE_SEPOLIA_ENDPOINT && PRIVATE_KEY) {
  config.networks.sepolia = {
    url: GOOGLE_SEPOLIA_ENDPOINT,
    accounts: [PRIVATE_KEY]
  };
}

if (process.env.INFURA_GOERLI_ENDPOINT && PRIVATE_KEY) {
  config.networks.goerli = {
    url: process.env.INFURA_GOERLI_ENDPOINT,
    accounts: [PRIVATE_KEY]
  };
}

if (process.env.ETHEREUM_HOLESKY_GATEWAY_ENDPOINT && PRIVATE_KEY) {
  config.networks.holesky = {
    url: process.env.ETHEREUM_HOLESKY_GATEWAY_ENDPOINT,
    accounts: [PRIVATE_KEY]
  };
}

if (process.env.GOOGLE_MAINNET_ENDPOINT && PRIVATE_KEY) {
  config.networks.mainnet = {
    url: process.env.GOOGLE_MAINNET_ENDPOINT,
    accounts: [PRIVATE_KEY]
  };
}

module.exports = config;
