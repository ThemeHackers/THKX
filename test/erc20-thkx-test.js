const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("THKXToken", function () {
  let THKXToken, thkxToken, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    THKXToken = await ethers.getContractFactory("THKXToken");
    thkxToken = await THKXToken.deploy(owner.address);
    await thkxToken.deployed();
  });

  it("Should deploy with correct initial supply", async function () {
    const totalSupply = await thkxToken.totalSupply();
    expect(totalSupply).to.equal(ethers.utils.parseEther("700000000"));
  });

  it("Should allow staking", async function () {
    await thkxToken.transfer(addr1.address, ethers.utils.parseEther("100"));
    await thkxToken.connect(addr1).stake(ethers.utils.parseEther("50"));
    const stakeInfo = await thkxToken.getStakeInfo(addr1.address);
    expect(stakeInfo.stakeAmount).to.equal(ethers.utils.parseEther("50"));
  });

  it("Should allow unstaking with rewards", async function () {
    await thkxToken.transfer(addr1.address, ethers.utils.parseEther("100"));
    await thkxToken.connect(addr1).stake(ethers.utils.parseEther("50"));
    await ethers.provider.send("evm_increaseTime", [3600 * 24 * 365]); 
    await ethers.provider.send("evm_mine");
    await thkxToken.connect(addr1).unstake(ethers.utils.parseEther("50"));
    const balance = await thkxToken.balanceOf(addr1.address);
    expect(balance).to.be.above(ethers.utils.parseEther("100")); 
  });

  it("Should pause and unpause by emergency role", async function () {
    await thkxToken.connect(owner).pause();
    expect(await thkxToken.paused()).to.be.true;
    await thkxToken.connect(owner).unpause();
    expect(await thkxToken.paused()).to.be.false;
  });

  it("Should allow emergency withdrawal", async function () {
    await thkxToken.transfer(addr1.address, ethers.utils.parseEther("100"));
    await thkxToken.connect(addr1).stake(ethers.utils.parseEther("50"));
    await thkxToken.connect(owner).emergencyWithdraw(addr1.address);
    const stakeInfo = await thkxToken.getStakeInfo(addr1.address);
    expect(stakeInfo.stakeAmount).to.equal(0);
  });

  it("Should correctly set and execute timelocked reward rate update", async function () {
    await thkxToken.connect(owner).proposeRewardRate(500);

    await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]); 
    await ethers.provider.send("evm_mine");
  

    await thkxToken.connect(owner).executeRewardRate(500);
    expect(await thkxToken.rewardRate()).to.equal(500);
  });
  
  
});