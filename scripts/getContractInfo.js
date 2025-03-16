const { ethers } = require("ethers");
require("dotenv").config();

const rpc_url = process.env.ETHEREUM_HOLESKY_GATEWAY_ENDPOINT;
const provider = new ethers.providers.JsonRpcProvider(rpc_url);
const stakingcontractaddress = process.env.stakingcontractaddress;
const abi = [
  "function getContractInfo() view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool)"
];

const contract = new ethers.Contract(stakingcontractaddress, abi, provider);

function formatTimestamp(ts) {
  const date = new Date(ts * 1000);
  return date.toLocaleString();
}

async function fetchContractInfo() {
  try {
    const [
      totalStaked,
      rewardRate,
      halvingInterval,
      lastHalvingTime,
      earlyUnstakeFee,
      contractBalance,
      stakersCount,
      isPaused
    ] = await contract.getContractInfo();

    console.log("=== THKXStaking Contract Info ===");
    console.log(`Total Staked: ${ethers.utils.formatUnits(totalStaked, 18)} THKX`);
    console.log(`Reward Rate: ${rewardRate.toString()}`);
    console.log(`Halving Interval: ${Math.floor(halvingInterval / (24 * 60 * 60))} days`);
    console.log(`Last Halving Time: ${formatTimestamp(lastHalvingTime.toString())}`);
    console.log(`Early Unstake Fee: ${earlyUnstakeFee}%`);
    console.log(`Contract Token Balance: ${ethers.utils.formatUnits(contractBalance, 18)} THKX`);
    console.log(`Total Stakers: ${stakersCount.toString()} users`);
    console.log(`Contract Status: ${isPaused ? "Paused 🔴" : "Active 🟢"}`);
  } catch (error) {
    console.error("Error fetching contract info:", error);
  }
}

fetchContractInfo();
