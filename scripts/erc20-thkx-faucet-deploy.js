const hre = require("hardhat");

async function main() {
    const tokenAddress = process.env.tokenAddress; 

    try {
        console.log("Deploying Faucet contract...");
        const Faucet = await hre.ethers.getContractFactory("ERC20THKXFaucet");
        const faucet = await Faucet.deploy(tokenAddress);

        await faucet.deployed();
        console.log("Faucet deployed to:", faucet.address);
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
