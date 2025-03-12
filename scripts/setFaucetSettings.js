const { ethers } = require("ethers");
require("dotenv").config(); 
const readline = require("readline");

const provider = new ethers.providers.JsonRpcProvider(process.env.GOOGLE_HOLESKY_ENDPOINT);
const privateKey = process.env.PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey, provider);

const faucetAddress = process.env.faucetAddress;
const faucetABI = [
    "function setFaucetSettings(uint256 _claimAmount, uint256 _claimCooldown) external",
    "function claimCooldown() external view returns (uint256)",
    "function claimAmount() external view returns (uint256)" 
];

const contract = new ethers.Contract(faucetAddress, faucetABI, wallet);

async function updateClaimCooldown(newCooldown) {
    try {
        const claimAmount = await contract.callStatic.claimAmount();
        const tx = await contract.setFaucetSettings(claimAmount, newCooldown);
        console.log(`⏳ Transaction sent: ${tx.hash}`);
        await tx.wait();
        console.log(`✅ Claim cooldown updated to: ${newCooldown} seconds`);
    } catch (error) {
        console.error("❌ Error updating claim cooldown:", error);
    }
}

async function checkCooldown() {
    try {
        const cooldown = await contract.claimCooldown();
        console.log(`🔄 Current claim cooldown: ${cooldown.toString()} seconds`);
    } catch (error) {
        console.error("❌ Error fetching claim cooldown:", error);
    }
}


function getUserInput(question) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    return new Promise((resolve) => {
        rl.question(question, (answer) => {
            rl.close();
            resolve(answer);
        });
    });
}

async function main() {
    const inputCooldown = await getUserInput("⏳ Enter new claim cooldown (seconds): ");
    const newCooldown = parseInt(inputCooldown, 10);

    if (isNaN(newCooldown) || newCooldown <= 0) {
        console.error("❌ Invalid cooldown value. Please enter a valid number.");
        process.exit(1);
    }

    await updateClaimCooldown(newCooldown);
    await checkCooldown();
}

main();
