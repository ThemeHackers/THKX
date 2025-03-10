# THKX Token Contract 🚀

## Overview 🌐

The `THKXToken` contract is an ERC-20 token with enhanced features including staking, minting, burning, pausing, emergency stop functionality, and reward management. It is designed with high security and operational flexibility, enabling staking and rewards while also allowing administrators to manage minting, pausing, and emergency actions. 🔒

### Features:
- **ERC-20 Token:** Standard token functionality including transfers and approvals. 💸
- **Burnable:** Allows token holders to burn their tokens. 🔥
- **Pausable:** The contract can be paused in case of an emergency. ⏸️
- **Access Control:** Different roles for admins, staking managers, and emergency management. 👮
- **Staking:** Users can stake tokens and earn rewards. 💰
- **Emergency Stop:** Ability to halt all transactions in an emergency. 🚨
- **Timelocks:** Certain actions require a timelock before they can be executed. ⏳
- **Minting & Reward Rate:** Flexible minting process with timelocks and adjustable reward rates. 🏅

## Contract Details 🔍

### Token Name and Symbol:
- Name: **THKX Token** 🚀
- Symbol: **THKX** 💎
- Initial Supply: **700,000,000 THKX** (minted to the initial admin address)

### Roles:
- **ADMIN_ROLE:** Role for managing critical functions like minting. 👑
- **STAKING_MANAGER_ROLE:** Role for managing staking-related functionality, such as setting reward rates. 🏋️
- **EMERGENCY_ROLE:** Role to manage emergency stop and withdraw functions. 🚑
- **DEFAULT_ADMIN_ROLE:** The default admin role can grant and revoke other roles. 🛠️

### Constants:
- **INITIAL_SUPPLY:** The total initial supply of the token (700,000,000). 💎
- **SECONDS_IN_YEAR:** Number of seconds in a year used for reward calculations. 📅
- **MIN_STAKE_AMOUNT:** Minimum amount required to stake (1 THKX). 💡
- **MAX_REWARD_RATE:** Maximum reward rate allowed. 🏆
- **TIMELOCK_DELAY:** Delay for timelock actions (24 hours). ⏳

## Functions ⚙️

### Staking Functions:
- **stake(uint256 amount):** Allows users to stake tokens in the contract. 🏦
- **unstake(uint256 amount):** Allows users to unstake tokens and withdraw rewards. 💸
- **calculatePendingRewards(address user):** Calculates the pending rewards for a user. 🏅

### Emergency and Control Functions:
- **triggerEmergencyStop(bool stop):** Allows the admin to stop or resume all token transfers. 🚨
- **pause():** Pauses token transfers (only by emergency role). ⏸️
- **unpause():** Resumes token transfers (only by admin). ▶️
- **emergencyWithdraw(address user):** Allows emergency withdrawal of a user's staked tokens and rewards. 🆘

### Minting and Reward Rate Functions:
- **proposeMint(address to, uint256 amount):** Proposes a mint action for timelock. 💳
- **executeMint(address to, uint256 amount):** Executes a mint action after timelock expires. ✅
- **proposeRewardRate(uint256 newRate):** Proposes a new reward rate for staking (requires timelock). 📈
- **executeRewardRate(uint256 newRate):** Executes the new reward rate after timelock expires. 🔄

### Role Management Functions:
- **grantRole(bytes32 role, address account):** Grants a role to an account. 🛠️
- **revokeRole(bytes32 role, address account):** Revokes a role from an account. 🚫

### Utility Functions:
- **getStakeInfo(address user):** Retrieves information about a user's staked tokens and rewards. 📊
- **_calculateRewards(address user):** Internal function that calculates staking rewards for a user. 💎

## Events 📢:
- **Staked(address indexed user, uint256 amount, uint256 timestamp):** Emitted when a user stakes tokens. 🌱
- **Unstaked(address indexed user, uint256 amount, uint256 reward, uint256 timestamp):** Emitted when a user unstakes tokens and withdraws rewards. 💸
- **RewardRateUpdateProposed(uint256 newRate, uint256 unlockTime):** Emitted when a new reward rate is proposed. 📉
- **RewardRateUpdated(uint256 newRate, uint256 timestamp):** Emitted when a reward rate is updated. 🏆
- **EmergencyWithdraw(address indexed admin, address indexed user, uint256 amount, uint256 timestamp):** Emitted during an emergency withdrawal of staked tokens. 🚑
- **EmergencyStopTriggered(bool stopped, uint256 timestamp):** Emitted when the emergency stop is triggered. 🛑
- **RoleGrantedWithTimestamp(bytes32 indexed role, address indexed account, uint256 timestamp):** Emitted when a role is granted to an account. 🎉
- **RoleRevokedWithTimestamp(bytes32 indexed role, address indexed account, uint256 timestamp):** Emitted when a role is revoked from an account. ❌
- **TokensMinted(address indexed to, uint256 amount, uint256 timestamp):** Emitted when new tokens are minted. 🪙

## Constructor 🛠️:
The constructor accepts an `initialAdmin` address, which is assigned the roles of ADMIN, STAKING_MANAGER, and EMERGENCY_ROLE. The initial supply of the token is minted to this address.

```solidity
constructor(address initialAdmin) payable ERC20("THKX Token", "THKX")

