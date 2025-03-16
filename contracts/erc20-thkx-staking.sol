// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract THKXStaking is ReentrancyGuard, Ownable, Pausable {
    IERC20 public immutable thkxToken; 
    uint256 public rewardRate = 10000;  
    uint256 public totalStaked;
    uint256 public constant halvingInterval = 180 days;
    uint256 public lastHalvingTime;
    uint256 public constant earlyUnstakeFee = 10;  
    
    struct StakeInfo {
        uint256 amount;
        uint256 lastUpdated;
        uint256 lockUntil;
    }

    mapping(address => StakeInfo) public stakes;
    mapping(address => bool) private stakerExists;
    address[] public stakersList;

    event Staked(address indexed user, uint256 amount, uint256 lockUntil);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event RewardRateUpdated(uint256 newRate);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AirdropDistributed(uint256 totalAmount);
    event RewardHalved(uint256 newRate);

    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        thkxToken = IERC20(_token);
        lastHalvingTime = block.timestamp;
    }

    function getContractInfo() external view returns (
        uint256 _totalStaked,
        uint256 _rewardRate,
        uint256 _halvingInterval,
        uint256 _lastHalvingTime,
        uint256 _earlyUnstakeFee,
        uint256 _contractBalance,
        uint256 _stakersCount,
        bool _isPaused
    ) {
        return (
            totalStaked,
            rewardRate,
            halvingInterval,
            lastHalvingTime,
            earlyUnstakeFee,
            thkxToken.balanceOf(address(this)),
            stakersList.length,
            paused()
        );
    }

    function getUserInfo(address user) external view returns (
        uint256 _stakedAmount,
        uint256 _lastUpdated,
        uint256 _lockUntil,
        uint256 _pendingRewards,
        uint256 _unstakeFeePercentage,
        uint256 _timeUntilUnlock
    ) {
        StakeInfo memory userStake = stakes[user];
        uint256 currentTime = block.timestamp;
        
        uint256 timeUntilUnlock = userStake.lockUntil > currentTime
            ? userStake.lockUntil - currentTime
            : 0;

        return (
            userStake.amount,
            userStake.lastUpdated,
            userStake.lockUntil,
            _calculateRewards(user),
            _calculateUnstakeFee(user),
            timeUntilUnlock
        );
    }

    function stake(uint256 amount, uint256 duration) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        require(amount > 0, "Amount must be greater than 0");
        require(duration >= 1 days && duration <= 365 days, "Invalid lock duration");
        
        _autoHalveRewards();
        uint256 reward = _calculateRewards(msg.sender);
        
        require(
            thkxToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        StakeInfo storage userStake = stakes[msg.sender];
        uint256 bonusMultiplier = 100 + (duration / 30 days) * 5;
        uint256 totalAmount = ((amount + reward) * bonusMultiplier) / 100;

        if (userStake.amount == 0) {
            if (!stakerExists[msg.sender]) {
                stakersList.push(msg.sender);
                stakerExists[msg.sender] = true;
            }
            userStake.lastUpdated = block.timestamp;
            userStake.lockUntil = block.timestamp + duration;
        }
        
        userStake.amount += totalAmount;
        userStake.lastUpdated = block.timestamp;
        totalStaked += totalAmount;

        emit Staked(msg.sender, amount, userStake.lockUntil);
    }

    function unstakePartial(uint256 amount) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "Insufficient staked amount");
        require(amount > 0, "Amount must be greater than 0");

        _autoHalveRewards();
        uint256 reward = (_calculateRewards(msg.sender) * amount) / userStake.amount;
        uint256 fee = block.timestamp < userStake.lockUntil
            ? (amount * _calculateUnstakeFee(msg.sender)) / 100
            : 0;

        userStake.amount -= amount;
        userStake.lastUpdated = block.timestamp;
        totalStaked -= amount;

        if (userStake.amount == 0) {
            userStake.lockUntil = 0;
        }

        require(
            thkxToken.transfer(msg.sender, amount + reward - fee),
            "Transfer failed"
        );
        emit Unstaked(msg.sender, amount, reward);
    }

    function compoundRewards() external nonReentrant whenNotPaused {
        _autoHalveRewards();
        StakeInfo storage userStake = stakes[msg.sender];
        uint256 reward = _calculateRewards(msg.sender);
        require(reward > 0, "No rewards available");

        userStake.amount += reward;
        userStake.lastUpdated = block.timestamp;
        totalStaked += reward;

        emit Staked(msg.sender, reward, userStake.lockUntil);
    }

    function emergencyWithdraw() external nonReentrant {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked tokens");

        uint256 amount = userStake.amount;
        userStake.amount = 0;
        userStake.lastUpdated = 0;
        userStake.lockUntil = 0;
        totalStaked -= amount;

        require(thkxToken.transfer(msg.sender, amount), "Transfer failed");
        emit EmergencyWithdraw(msg.sender, amount);
    }

    function emergencyWithdrawAll() external onlyOwner {
        uint256 contractBalance = thkxToken.balanceOf(address(this));
        require(contractBalance > 0, "No tokens in contract");

        require(thkxToken.transfer(owner(), contractBalance), "Transfer failed");
    }

    function distributeAirdrop(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(
            thkxToken.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );

        uint256 totalDistributed;
        for (uint256 i = 0; i < stakersList.length; i++) {
            address user = stakersList[i];
            if (stakes[user].amount > 0) {
                uint256 userShare = (stakes[user].amount * amount) / totalStaked;
                if (userShare > 0) {
                    totalDistributed += userShare;
                    require(thkxToken.transfer(user, userShare), "Transfer failed");
                }
            }
        }
        emit AirdropDistributed(totalDistributed);
    }

    function setRewardRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Rate must be greater than 0");
        _autoHalveRewards();
        rewardRate = newRate;
        emit RewardRateUpdated(newRate);
    }

    function _autoHalveRewards() internal {
        while (block.timestamp >= lastHalvingTime + halvingInterval) {
            rewardRate = rewardRate / 2;
            lastHalvingTime += halvingInterval;
            if (rewardRate <= 1) {
                rewardRate = 1; 
                break;
            }
            emit RewardHalved(rewardRate);
        }
    }

    function _calculateUnstakeFee(address user) public view returns (uint256) {
        StakeInfo memory userStake = stakes[user];
        if (block.timestamp >= userStake.lockUntil) return 0;
        
        uint256 monthsStaked = (block.timestamp - userStake.lastUpdated) / 30 days;
        return monthsStaked >= 5 ? 0 : earlyUnstakeFee - (monthsStaked * 2);
    }

    function _calculateRewards(address user) public view returns (uint256) {
        StakeInfo memory userStake = stakes[user];
        if (userStake.amount == 0) return 0;
        
        uint256 stakingDuration = block.timestamp - userStake.lastUpdated;
        return (userStake.amount * rewardRate * stakingDuration) / (10000 * 365 days);
    }
}