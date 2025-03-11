const { ethers } = require("hardhat");

async function main() {
    const faucetAddress = process.env.faucetAddress; 
    const walletAddress = process.env.walletAddress; 

    try {
        const [signer] = await ethers.getSigners();
        const faucet = await ethers.getContractAt("ERC20THKXFaucet", faucetAddress, signer);

        console.log(`Requesting tokens for address: ${walletAddress}`);
        const tx = await faucet.claimTokens();
        await tx.wait();

        console.log("Tokens requested successfully!");
    } catch (error) {
        if (error.code === "NETWORK_ERROR") {
            console.error("❌ Please check your network connection.");
        } else {
            console.error("An error occurred:", error);
        }
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("An error occurred:", error);
        process.exit(1);
    });
