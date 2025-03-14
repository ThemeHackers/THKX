const { ethers } = require("hardhat");

require("dotenv").config();
async function main() {

  const stakingContractAddress = process.env.stakingcontractaddress; 
  const tokenAddress = process.env.tokenAddress; 
  const amountToWithdraw = ethers.utils.parseUnits("9999800", 18); 


  const [owner] = await ethers.getSigners();
  console.log("Withdrawing from owner:", owner.address);


  const stakingABI = [
    "function withdrawRewards(uint256 amount) external",
    "function rewardPool() external view returns (uint256)",
    "function lastOwnerWithdrawal() external view returns (uint256)"
  ];
  const stakingContract = await ethers.getContractAt(stakingABI, stakingContractAddress, owner);


  const currentRewardPool = await stakingContract.rewardPool();
  console.log("Current Reward Pool:", ethers.utils.formatUnits(currentRewardPool, 18), "THKX");


  const maxWithdrawable = currentRewardPool.mul(20).div(100);
  if (amountToWithdraw.gt(maxWithdrawable)) {
    throw new Error(`Amount exceeds 20% limit: ${ethers.utils.formatUnits(maxWithdrawable, 18)} THKX`);
  }

  const lastWithdrawal = await stakingContract.lastOwnerWithdrawal();
  const thirtyDaysInSeconds = 30 * 24 * 60 * 60;
  const currentTime = Math.floor(Date.now() / 1000); 
  if (currentTime < lastWithdrawal.add(thirtyDaysInSeconds)) {
    const waitUntil = new Date((lastWithdrawal.add(thirtyDaysInSeconds)) * 1000).toLocaleString();
    throw new Error(`Cannot withdraw yet. Wait until: ${waitUntil}`);
  }


  console.log(`Withdrawing ${ethers.utils.formatUnits(amountToWithdraw, 18)} THKX from rewardPool...`);
  const withdrawTx = await stakingContract.withdrawRewards(amountToWithdraw, { gasLimit: 300000 });
  await withdrawTx.wait();
  console.log("Withdrawal successful");

  const updatedRewardPool = await stakingContract.rewardPool();
  console.log("Updated Reward Pool:", ethers.utils.formatUnits(updatedRewardPool, 18), "THKX");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });