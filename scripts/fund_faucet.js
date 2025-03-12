const { ethers } = require("ethers");
require("dotenv").config();

const FAUCET_ADDRESS = process.env.faucetAddress; 
const TOKEN_ADDRESS = process.env.tokenAddress; 
const AMOUNT = ethers.utils.parseUnits("100000000", 18); 

const provider = new ethers.providers.JsonRpcProvider(process.env.GOOGLE_HOLESKY_ENDPOINT);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const tokenContract = new ethers.Contract(TOKEN_ADDRESS, [
    "function approve(address spender, uint256 amount) public returns (bool)",
    "function transfer(address recipient, uint256 amount) public returns (bool)"
], wallet);

async function fundFaucet() {
    try {
        console.log(`Approving ${ethers.utils.formatUnits(AMOUNT, 18)} THKX for transfer...`);
        const approveTx = await tokenContract.approve(FAUCET_ADDRESS, AMOUNT);
        await approveTx.wait();
        console.log("Approval successful.");

        console.log(`Funding Faucet with ${ethers.utils.formatUnits(AMOUNT, 18)} THKX...`);
        const transferTx = await tokenContract.transfer(FAUCET_ADDRESS, AMOUNT);
        await transferTx.wait();

        console.log("Faucet funded successfully!");
    } catch (error) {
        console.error("Error funding faucet:", error);
    }
}

fundFaucet();
