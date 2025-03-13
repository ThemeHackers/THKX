const hre = require("hardhat");

async function main() {
    console.log("🚀 Deploying THKX Staking Contract...");

    const THKX_TOKEN = process.env.tokenAddress;
    const REWARD_RATE = 1000;

    console.log(`🔗 Using THKX Token Address: ${THKX_TOKEN}`);
    console.log(`💰 Reward Rate per Block: ${REWARD_RATE} THKX`);

    const THKXStaking = await hre.ethers.getContractFactory("THKXStaking");
    const staking = await THKXStaking.deploy(THKX_TOKEN, REWARD_RATE);

    console.log("⏳ Waiting for deployment confirmation...");
    await staking.deployed();

    console.log(`✅ Staking Contract Successfully Deployed!`);
    console.log(`📍 Contract Address: ${staking.address}`);
    console.log(`🔍 View on Explorer: https://holesky.etherscan.io/address/${staking.address}`);
    console.log(`📜 Transaction Hash: ${staking.deployTransaction.hash}`);
    console.log(`🌐 Network: Holesky Testnet`);

}

main().catch((error) => {
    console.error("❌ Deployment Failed:", error);
    process.exitCode = 1;
});