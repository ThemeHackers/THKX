const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const stakingContractAddress = process.env.stakingcontractaddress;
  const tokenAddress = process.env.tokenAddress;
  const amountToDeposit = ethers.utils.parseUnits("10000000", 18);

  const [owner] = await ethers.getSigners();
  console.log("Deploying from owner:", owner.address);

  const tokenABI = [
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function balanceOf(address account) external view returns (uint256)",
    "function allowance(address owner, address spender) external view returns (uint256)"
  ];
  const tokenContract = await ethers.getContractAt(tokenABI, tokenAddress, owner);

  const stakingABI = [
    "function depositRewards(uint256 amount) external",
    "function rewardPool() external view returns (uint256)"
  ];
  const stakingContract = await ethers.getContractAt(stakingABI, stakingContractAddress, owner);

  const ownerBalance = await tokenContract.balanceOf(owner.address);
  console.log("Owner THKX balance:", ethers.utils.formatUnits(ownerBalance, 18));
  if (ownerBalance.lt(amountToDeposit)) {
    throw new Error("Insufficient THKX balance in owner wallet");
  }

  console.log("Approving staking contract to spend THKX...");
  const approveTx = await tokenContract.approve(stakingContractAddress, amountToDeposit);
  await approveTx.wait();
  const allowance = await tokenContract.allowance(owner.address, stakingContractAddress);
  console.log("Allowance:", ethers.utils.formatUnits(allowance, 18));
  if (allowance.lt(amountToDeposit)) {
    throw new Error("Approval failed to set sufficient allowance");
  }
  console.log("Approval successful");

  try {
    await stakingContract.callStatic.depositRewards(amountToDeposit);
  } catch (e) {
    console.error("Simulation failed:", e);
    throw e;
  }

  console.log(`Depositing ${ethers.utils.formatUnits(amountToDeposit, 18)} THKX to rewardPool...`);
  const depositTx = await stakingContract.depositRewards(amountToDeposit, { gasLimit: 300000 });
  await depositTx.wait();
  console.log("Deposit successful");

  const updatedRewardPool = await stakingContract.rewardPool();
  console.log("Updated Reward Pool:", ethers.utils.formatUnits(updatedRewardPool, 18), "THKX");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });