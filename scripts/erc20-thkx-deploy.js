const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] Starting deployment process...`);
  console.log(`[${timestamp}] Deployer account: ${deployer.address}`);

  console.log(`[${timestamp}] Fetching the contract factory for THKXToken...`);
  const THKXToken = await hre.ethers.getContractFactory("THKXToken");

  console.log(`[${timestamp}] Deploying contract with deployer as owner...`);

  const gasPrice = await hre.ethers.provider.getGasPrice();
  console.log(`[${timestamp}] Current gas price: ${hre.ethers.utils.formatUnits(gasPrice, "gwei")} Gwei`);

  console.log(`[${timestamp}] Starting contract deployment...`);
  const thkx = await THKXToken.deploy(deployer.address, {
    gasPrice: gasPrice,
  });

  console.log(`[${timestamp}] Waiting for the contract to be deployed...`);
  await thkx.deployed();
  console.log(`[${timestamp}] Contract successfully deployed!`);
  console.log(`[${timestamp}] Contract Address: ${thkx.address}`);
  console.log(`[${timestamp}] Gas used: ${thkx.deployTransaction.gasLimit.toString()}`);
  console.log(`[${timestamp}] Gas price: ${hre.ethers.utils.formatUnits(thkx.deployTransaction.gasPrice, "gwei")} Gwei`);

  console.log(`[${timestamp}] Deployment process completed!`);
  console.log(`[${timestamp}] Contract deploy transaction hash: ${thkx.deployTransaction.hash}`);
}

main().catch((error) => {
  const timestamp = new Date().toISOString();
  console.error(`[${timestamp}] Error during deployment:`, error);
  process.exitCode = 1;
});
