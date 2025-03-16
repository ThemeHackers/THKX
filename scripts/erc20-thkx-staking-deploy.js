const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const THKXStaking = await ethers.getContractFactory("THKXStaking");
    const thkxTokenAddress = process.env.tokenAddress; 
    const staking = await THKXStaking.deploy(thkxTokenAddress);

    await staking.deployed();
    console.log("THKXStaking deployed at:", staking.address);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
