// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract THKXStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IERC20 public token;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastUpdated;
        uint256 lockEndTime;
    }

    mapping(address => StakeInfo) public stakers;
    uint256 public totalStaked;
    uint256 public rewardRatePerBlock;
    uint256 public lockPeriod = 7 days;
    uint256 public earlyWithdrawalFee = 5; 

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 fee);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);
    event Compounded(address indexed user, uint256 amount);

    constructor(address _token, uint256 _rewardRate) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
        rewardRatePerBlock = _rewardRate;
    }

    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        updateRewards(msg.sender);

        stakers[msg.sender].amount = stakers[msg.sender].amount.add(_amount);
        stakers[msg.sender].lastUpdated = block.number;
        stakers[msg.sender].lockEndTime = block.timestamp.add(lockPeriod);
        totalStaked = totalStaked.add(_amount);

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        require(stakers[msg.sender].amount >= _amount, "Not enough staked balance");
        updateRewards(msg.sender);

        uint256 fee = 0;
        if (block.timestamp < stakers[msg.sender].lockEndTime) {
            fee = _amount.mul(earlyWithdrawalFee).div(100);
        }

        uint256 finalAmount = _amount.sub(fee);
        stakers[msg.sender].amount = stakers[msg.sender].amount.sub(_amount);
        stakers[msg.sender].lastUpdated = block.number;
        totalStaked = totalStaked.sub(_amount);

        require(token.transfer(msg.sender, finalAmount), "Unstake transfer failed");
        if (fee > 0) require(token.transfer(owner(), fee), "Fee transfer failed");

        emit Unstaked(msg.sender, _amount, fee);
    }

    function emergencyUnstake() external nonReentrant {
        uint256 stakedAmount = stakers[msg.sender].amount;
        require(stakedAmount > 0, "No funds staked");

        totalStaked = totalStaked.sub(stakedAmount);
        stakers[msg.sender].amount = 0;
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdated = block.number;

        require(token.transfer(msg.sender, stakedAmount), "Transfer failed");
        emit Unstaked(msg.sender, stakedAmount, 0);
    }

    function claimRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards available");

        stakers[msg.sender].rewardDebt = 0;
        require(token.transfer(msg.sender, reward), "Reward transfer failed");

        emit RewardsClaimed(msg.sender, reward);
    }

    function compoundRewards() external nonReentrant {
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards available");

        stakers[msg.sender].amount = stakers[msg.sender].amount.add(reward);
        stakers[msg.sender].rewardDebt = 0;
        stakers[msg.sender].lastUpdated = block.number;
        totalStaked = totalStaked.add(reward);

        emit Compounded(msg.sender, reward);
    }

    function getStakedBalance(address _user) external view returns (uint256) {
        return stakers[_user].amount;
    }

    function updateRewards(address _user) internal {
        uint256 pending = calculatePendingRewards(_user);
        stakers[_user].rewardDebt = stakers[_user].rewardDebt.add(pending);
        stakers[_user].lastUpdated = block.number;
    }

    function calculatePendingRewards(address _user) public view returns (uint256) {
        StakeInfo storage user = stakers[_user];
        if (user.amount == 0) return 0;

        uint256 blocksPassed = block.number.sub(user.lastUpdated);
        uint256 reward = user.amount.mul(blocksPassed).mul(rewardRatePerBlock).div(1e18);
        return reward;
    }

    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRatePerBlock = _newRate;
        emit RewardRateUpdated(_newRate);
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(token.transfer(msg.sender, _amount), "Withdraw failed");
    }
}
