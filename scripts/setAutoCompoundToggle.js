const { ethers } = require("ethers");
require("dotenv").config();

const rpc_url = process.env.ETHEREUM_HOLESKY_GATEWAY_ENDPOINT;
const stakingcontractaddress = process.env.stakingcontractaddress;
const privateKey = process.env.PRIVATE_KEY; 

const provider = new ethers.providers.JsonRpcProvider(rpc_url);
const signer = new ethers.Wallet(privateKey, provider);
const abi = [
  "function setAutoCompoundToggle(bool _state) external"
];

const contract = new ethers.Contract(stakingcontractaddress, abi, signer);

async function toggleAutoCompound(newState) {
    try {
        const tx = await contract.setAutoCompoundToggle(newState);
        console.log("Transaction sent:", tx.hash);
        await tx.wait();
        console.log("Transaction confirmed");
    } catch (error) {
        console.error("Error:", error);
    }
}

// toggleAutoCompound(false);
toggleAutoCompound(true);