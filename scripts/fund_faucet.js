const { ethers } = require("hardhat");

async function main() {
    const faucetAddress = process.env.faucetAddress;
    const tokenAddress = process.env.tokenAddress; 
    const amount = ethers.utils.parseUnits("100000000", 18); 

    const [signer] = await ethers.getSigners();
    const token = await ethers.getContractAt("IERC20", tokenAddress, signer);

    console.log(`Funding Faucet at ${faucetAddress} with ${amount.toString()} THKX...`);
    const tx = await token.transfer(faucetAddress, amount);
    await tx.wait();

    console.log("Faucet funded successfully!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
