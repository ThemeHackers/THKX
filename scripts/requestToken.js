const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
    const faucetAddress = process.env.faucetAddress; 
    const walletAddress = process.env.walletAddress; 

    try {
        const [signer] = await ethers.getSigners();
        const faucet = await ethers.getContractAt("ERC20THKXFaucet", faucetAddress, signer);

        const lastClaimedTimestamp = await faucet.lastClaimed(walletAddress);
        const claimCooldown = await faucet.claimCooldown();

        const lastClaimedTime = new Date(lastClaimedTimestamp.toNumber() * 1000);
        const nextClaimTime = new Date((lastClaimedTimestamp.toNumber() + claimCooldown.toNumber()) * 1000);
        const now = new Date();

        if (now < nextClaimTime) {
            console.log(`❌ You already claimed tokens on: ${lastClaimedTime.toLocaleString()}`);
            console.log(`⏳ You can claim again at: ${nextClaimTime.toLocaleString()}`);
            return;
        }

        console.log(`✅ Requesting tokens for address: ${walletAddress}...`);
        const tx = await faucet.claimTokens();
        console.log(`⏳ Transaction sent: ${tx.hash}`);

        await tx.wait();
        console.log("🎉 Tokens requested successfully!");
    } catch (error) {
        if (error.code === "NETWORK_ERROR") {
            console.error("❌ Please check your network connection.");
        } else if (error.data?.message) {
            console.error(`❌ Smart Contract Error: ${error.data.message}`);
        } else {
            console.error("❌ An unexpected error occurred:", error);
        }
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Script Execution Error:", error);
        process.exit(1);
    });
