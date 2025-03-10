// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title THKX Token with Maximum Security
 * @dev ERC-20 token with staking, minting, burning, pausing, and enhanced security features.
 */
contract THKXToken is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ReentrancyGuard
{
    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant STAKING_MANAGER_ROLE =
        keccak256("STAKING_MANAGER_ROLE");
    bytes32 private constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    uint256 private constant INITIAL_SUPPLY = 700000000 * 10 ** 18;
    uint256 private constant SECONDS_IN_YEAR = 365 * 24 * 60 * 60;
    uint256 private constant MIN_STAKE_AMOUNT = 1 * 10 ** 18;
    uint256 private constant MAX_REWARD_RATE = 1000;
    uint256 private constant TIMELOCK_DELAY = 24 * 60 * 60;

    struct StakeData {
        uint256 stakeAmount;
        uint256 lastClaimedTime;
        uint256 accumulatedRewards;
        bool isActive;
    }

    mapping(address => StakeData) public stakesData;
    mapping(bytes32 => uint256) public timelockActions;
    uint256 public rewardRate = 100;
    uint256 public totalStaked;
    bool public emergencyStop;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 reward,
        uint256 timestamp
    );
    event RewardRateUpdateProposed(uint256 newRate, uint256 unlockTime);
    event RewardRateUpdated(uint256 newRate, uint256 timestamp);
    event EmergencyWithdraw(
        address indexed admin,
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );
    event EmergencyStopTriggered(bool stopped, uint256 timestamp);
    event RoleGrantedWithTimestamp(
        bytes32 indexed role,
        address indexed account,
        uint256 timestamp
    );
    event RoleRevokedWithTimestamp(
        bytes32 indexed role,
        address indexed account,
        uint256 timestamp
    );
    event TokensMinted(address indexed to, uint256 amount, uint256 timestamp);

    modifier onlyEmergencyStopNotActive() {
        require(!emergencyStop);
        _;
    }

    modifier onlyValidAddress(address _addr) {
        require(_addr != address(0));
        require(_addr != address(this));
        _;
    }

    constructor(address initialAdmin) payable ERC20("THKX Token", "THKX") {
        require(initialAdmin != address(0));
        address admin = initialAdmin;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(STAKING_MANAGER_ROLE, admin);
        _grantRole(EMERGENCY_ROLE, admin);
        _mint(admin, INITIAL_SUPPLY);
        emit TokensMinted(admin, INITIAL_SUPPLY, block.timestamp);
    }

    function executeRewardRate(
        uint256 newRate
    ) external onlyRole(STAKING_MANAGER_ROLE) {
        bytes32 actionHash = keccak256(abi.encodePacked("rewardRate", newRate));

        uint256 timelockActionTime = timelockActions[actionHash];
        require(timelockActionTime != 0, "Timelock action not found");
        require(
            block.timestamp >= timelockActionTime,
            "Timelock not yet expired"
        );

        delete timelockActions[actionHash];
        rewardRate = newRate;
        emit RewardRateUpdated(newRate, block.timestamp);
    }

    function proposeMint(
        address to,
        uint256 amount
    ) external onlyRole(ADMIN_ROLE) onlyValidAddress(to) {
        require(amount != 0);
        bytes32 actionHash = keccak256(
            abi.encodePacked("mint", to, amount, block.timestamp)
        );

        timelockActions[actionHash] = block.timestamp + TIMELOCK_DELAY;
    }

    function executeMint(
        address to,
        uint256 amount
    ) external onlyRole(ADMIN_ROLE) nonReentrant onlyValidAddress(to) {
        bytes32 actionHash = keccak256(
            abi.encodePacked(
                "mint",
                to,
                amount,
                block.timestamp - TIMELOCK_DELAY
            )
        );
        uint256 timelockAction = timelockActions[actionHash];
        require(timelockAction != 0);
        require(block.timestamp > timelockAction);
        delete timelockActions[actionHash];
        _mint(to, amount);
        emit TokensMinted(to, amount, block.timestamp);
    }

    function pause() external onlyRole(EMERGENCY_ROLE) nonReentrant {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) nonReentrant {
        require(!emergencyStop);
        _unpause();
    }

    function triggerEmergencyStop(bool stop) external onlyRole(EMERGENCY_ROLE) {
        emergencyStop = stop;
        if (stop) _pause();
        emit EmergencyStopTriggered(stop, block.timestamp);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        require(!emergencyStop);
        super._beforeTokenTransfer(from, to, amount);
    }

    function proposeRewardRate(
        uint256 newRate
    ) external onlyRole(STAKING_MANAGER_ROLE) {
        require(newRate != 0, "New rate cannot be zero");
        require(newRate <= MAX_REWARD_RATE, "New rate exceeds max limit");

        bytes32 actionHash = keccak256(abi.encodePacked("rewardRate", newRate));

       
        timelockActions[actionHash] = block.timestamp + TIMELOCK_DELAY;
        emit RewardRateUpdateProposed(newRate, timelockActions[actionHash]);
    }

    function stake(
        uint256 amount
    )
        external
        nonReentrant
        whenNotPaused
        onlyEmergencyStopNotActive
        onlyValidAddress(msg.sender)
    {
        require(amount != MIN_STAKE_AMOUNT);
        require(balanceOf(msg.sender) > amount);

        StakeData storage userStake = stakesData[msg.sender];
        uint256 reward = _calculateRewards(msg.sender);
        if (reward != 0) {
            _mint(msg.sender, reward);
            userStake.accumulatedRewards += reward;
        }

        _transfer(msg.sender, address(this), amount);
        userStake.stakeAmount += amount;
        userStake.lastClaimedTime = block.timestamp;
        userStake.isActive = true;
        totalStaked = totalStaked + amount;

        emit Staked(msg.sender, amount, block.timestamp);
    }
    function unstake(
        uint256 amount
    ) external nonReentrant whenNotPaused onlyEmergencyStopNotActive {
        StakeData storage userStake = stakesData[msg.sender];
        require(userStake.isActive);
        require(userStake.stakeAmount >= amount, "Insufficient stake amount");
        require(amount != 0);

        uint256 reward = _calculateRewards(msg.sender);
        if (reward != 0) {
            _mint(msg.sender, reward);
            userStake.accumulatedRewards += reward;
        }

        _transfer(address(this), msg.sender, amount);
        userStake.stakeAmount -= amount;
        totalStaked = totalStaked - amount;
        userStake.lastClaimedTime = block.timestamp;
        if (userStake.stakeAmount == 0) {
            userStake.isActive = false;
        }

        emit Unstaked(msg.sender, amount, reward, block.timestamp);
    }
    function emergencyWithdraw(
        address user
    ) external onlyRole(EMERGENCY_ROLE) nonReentrant onlyValidAddress(user) {
        StakeData storage userStake = stakesData[user];
        require(userStake.isActive);

        uint256 stakeAmount = userStake.stakeAmount;
        uint256 reward = _calculateRewards(user);
        if (reward != 0) {
            _mint(user, reward);
            userStake.accumulatedRewards += reward;
        }

        _transfer(address(this), user, stakeAmount);
        totalStaked = totalStaked - stakeAmount;
        userStake.stakeAmount = 0;
        userStake.lastClaimedTime = 0;
        userStake.isActive = false;

        emit EmergencyWithdraw(msg.sender, user, stakeAmount, block.timestamp);
    }
    function _calculateRewards(address user) internal view returns (uint256) {
        StakeData storage userStake = stakesData[user];
        if (
            !userStake.isActive ||
            userStake.stakeAmount == 0 ||
            userStake.lastClaimedTime == 0
        ) {
            return 0;
        }

        uint256 stakedDuration = block.timestamp - userStake.lastClaimedTime;
        return
            (userStake.stakeAmount * rewardRate * stakedDuration) /
            (10000 * SECONDS_IN_YEAR);
    }

    function grantRole(
        bytes32 role,
        address account
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) onlyValidAddress(account) {
        _grantRole(role, account);
        emit RoleGrantedWithTimestamp(role, account, block.timestamp);
    }

    function revokeRole(
        bytes32 role,
        address account
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) onlyValidAddress(account) {
        require(account != msg.sender);
        _revokeRole(role, account);
        emit RoleRevokedWithTimestamp(role, account, block.timestamp);
    }
    function getStakeInfo(
        address user
    ) external view returns (StakeData memory) {
        return stakesData[user];
    }

    function calculatePendingRewards(
        address user
    ) external view returns (uint256) {
        return _calculateRewards(user);
    }
}
