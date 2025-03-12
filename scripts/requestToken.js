const { ethers } = require("ethers");
require("dotenv").config();

const FAUCET_ADDRESS = process.env.faucetAddress;
const FAUCET_ABI = [
    "function claimTokens() external"
];

const provider = new ethers.providers.JsonRpcProvider(process.env.GOOGLE_HOLESKY_ENDPOINT);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const faucetContract = new ethers.Contract(FAUCET_ADDRESS, FAUCET_ABI, wallet);

async function requestTokens() {
    try {
        console.log("Requesting tokens from the faucet...");
        const tx = await faucetContract.claimTokens();
        await tx.wait();

        console.log("Tokens successfully claimed!");
    } catch (error) {
        console.error("Error requesting tokens:", error);
    }
}

requestTokens();
