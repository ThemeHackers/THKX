const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const tokenAddress = process.env.tokenAddress; 
    const rewardRate = ethers.utils.parseUnits("0.002114", "ether"); 

    console.log("Deploying THKXStaking contract...");

    const THKXStaking = await ethers.getContractFactory("THKXStaking");
    const stakingContract = await THKXStaking.deploy(tokenAddress, rewardRate);

    await stakingContract.deployed();

    console.log(`THKXStaking deployed at: ${stakingContract.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
