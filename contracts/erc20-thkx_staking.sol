// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract THKXStaking is Ownable, ReentrancyGuard {
    IERC20 public immutable token;
    uint256 public rewardPool;
    uint256 public lastOwnerWithdrawal;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastUpdated;
        uint256 lockEndTime;
    }

    mapping(address => StakeInfo) public stakers;
    mapping(address => bool) public autoCompoundEnabled;
    uint256 public totalStaked;
    uint256 public rewardRatePerSecond;
    uint256 public lockPeriod = 7 days;
    uint256 public lastRewardTimestamp;
    bool public autoCompoundToggleEnabled = true;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 fee);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 newRate);
    event Compounded(address indexed user, uint256 amount);
    event RewardsDeposited(uint256 amount);
    event RewardsWithdrawn(uint256 amount);
    event AutoCompoundToggleDisabled();
    event AutoCompoundToggleUpdated(bool newState);

    constructor(address _token, uint256 _rewardRatePerSecond) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
        rewardRatePerSecond = _rewardRatePerSecond;
        lastRewardTimestamp = block.timestamp;
    }

    function disableToggleAutoCompound() external onlyOwner {
        require(
            autoCompoundToggleEnabled,
            "Auto-compound toggle already disabled"
        );
        autoCompoundToggleEnabled = true;
        emit AutoCompoundToggleDisabled();
    }

    function toggleAutoCompound() external {
        require(autoCompoundToggleEnabled, "Auto-compound toggle is disabled");
        autoCompoundEnabled[msg.sender] = !autoCompoundEnabled[msg.sender];
    }
    function setAutoCompoundToggle(bool _state) external onlyOwner {
        require(autoCompoundToggleEnabled != _state, "State is already set");
        autoCompoundToggleEnabled = _state;
        emit AutoCompoundToggleUpdated(_state);
    }
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        updateRewards(msg.sender);

        stakers[msg.sender].amount += _amount;
        stakers[msg.sender].lastUpdated = block.timestamp;
        stakers[msg.sender].lockEndTime = block.timestamp + lockPeriod;
        totalStaked += _amount;

        updateRewardRate();
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        require(
            stakers[msg.sender].amount >= _amount,
            "Not enough staked balance"
        );
        updateRewards(msg.sender);

        uint256 stakedTime = block.timestamp - stakers[msg.sender].lastUpdated;
        uint256 feePercent = calculateEarlyWithdrawalFee(stakedTime);
        uint256 fee = (_amount * feePercent) / 100;
        uint256 finalAmount = _amount - fee;

        stakers[msg.sender].amount -= _amount;
        totalStaked -= _amount;
        require(token.transfer(msg.sender, finalAmount), "Transfer failed");
        if (fee > 0)
            require(token.transfer(owner(), fee), "Fee transfer failed");

        updateRewardRate();
        emit Unstaked(msg.sender, _amount, fee);
    }

    function calculateEarlyWithdrawalFee(
        uint256 _stakedTime
    ) public pure returns (uint256) {
        if (_stakedTime < 1 days) return 20;
        if (_stakedTime < 3 days) return 15;
        if (_stakedTime < 7 days) return 5;
        return 0;
    }

    function claimRewards() external nonReentrant {
        require(
            block.timestamp >= stakers[msg.sender].lastUpdated + 1 days,
            "Must stake at least 1 day before claiming"
        );
        updateRewards(msg.sender);

        uint256 reward = stakers[msg.sender].rewardDebt;
        require(reward > 0, "No rewards available");
        reward = reward > rewardPool ? rewardPool : reward;

        stakers[msg.sender].rewardDebt = 0;
        rewardPool -= reward;
        require(token.transfer(msg.sender, reward), "Transfer failed");

        emit RewardsClaimed(msg.sender, reward);
    }

    function updateRewards(address _user) internal {
        StakeInfo storage user = stakers[_user];
        uint256 pending = calculatePendingRewards(_user);

        if (pending > 0) {
            rewardPool -= pending;

            if (autoCompoundEnabled[_user]) {
                unchecked {
                    uint256 fee = (pending * 1) / 100;
                    uint256 finalReward = pending - fee;

                    user.amount += finalReward;
                    totalStaked += finalReward;
                    user.rewardDebt = 0;

                    emit Compounded(_user, finalReward);
                }
            } else {
                unchecked {
                    user.rewardDebt += pending;
                }
            }
        }

        user.lastUpdated = block.timestamp;
    }

    function withdrawRewards(uint256 _amount) external onlyOwner {
        require(
            block.timestamp >= lastOwnerWithdrawal + 30 days,
            "Owner can withdraw only once every 30 days"
        );
        require(
            _amount <= (rewardPool * 20) / 100,
            "Cannot withdraw more than 20% of the pool"
        );

        rewardPool -= _amount;
        lastOwnerWithdrawal = block.timestamp;
        require(token.transfer(owner(), _amount), "Withdraw failed");

        emit RewardsWithdrawn(_amount);
    }

    function calculatePendingRewards(
        address _user
    ) public view returns (uint256) {
        StakeInfo storage user = stakers[_user];
        if (user.amount == 0 || totalStaked == 0 || rewardPool == 0) return 0;

        unchecked {
            uint256 timePassed = block.timestamp - user.lastUpdated;
            uint256 reward = (user.amount * timePassed * rewardRatePerSecond) /
                1e30;
            return reward > rewardPool ? rewardPool : reward;
        }
    }

    function updateRewardRate() public {
        if (totalStaked == 0 || rewardPool == 0) {
            rewardRatePerSecond = 0;
        } else {
            rewardRatePerSecond =
                ((rewardPool * 1e36) / totalStaked) /
                (30 days);
        }
        emit RewardRateUpdated(rewardRatePerSecond);
    }

    function depositRewards(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        rewardPool += _amount;
        updateRewardRate();
        emit RewardsDeposited(_amount);
    }
}
