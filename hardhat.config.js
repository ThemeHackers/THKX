require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    sepolia: {
      url: process.env.GOOGLE_SEPOLIA_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY]
    },
    goerli: {
      url: process.env.INFURA_GOERLI_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY]
    },
    holesky: {
      url: process.env.GOOGLE_HOLESKY_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY]
    },
    mainnet: {
      url: process.env.GOOGLE_MAINNET_ENDPOINT,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
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
