# THKX Token

## Overview
THKX Token is designed for **blockchain learning** and offers extensive functionality through **smart contracts**. It supports **faucets**, integrates seamlessly with **Web3**, and ensures **enhanced security** through **SolidityScan-audited smart contracts**.

With a focus on **efficiency, transparency, and scalability**, THKX Token serves as a powerful tool for both **educational and real-world blockchain applications**.

## Features
- ✅ **Smart Contract Functionality**: Supports a wide range of applications, including **faucets** and **staking**.
- ✅ **Web3 Integration**: Seamless connectivity with decentralized applications (DApps).
- ✅ **Enhanced Security**: Smart contracts have been analyzed through **SolidityScan** to ensure safety.
- ✅ **Educational Purpose**: Aimed at providing a learning platform for blockchain enthusiasts.
- ✅ **Scalability & Efficiency**: Optimized for real-world applications and blockchain ecosystems.

## Security Audit
All smart contracts associated with THKX Token have been audited using **SolidityScan**, ensuring a high level of security and trustworthiness.

## THKX Faucet Smart Contract
The **THKX Faucet Smart Contract** allows users to claim a limited amount of THKX tokens without a cooldown period. It is built using **OpenZeppelin's** security-enhanced libraries, ensuring safe transactions and preventing reentrancy attacks.

### Smart Contract Overview
- 📌 **Claim Tokens**: Users can request a predefined amount of THKX tokens.
- 🔐 **Non-Reentrant Protection**: Utilizes `ReentrancyGuard` to prevent multiple withdrawals in a single transaction.
- ⚙️ **Configurable Faucet Settings**: The owner can adjust the claim amount.
- 🛑 **Secure Withdrawals**: The owner can withdraw remaining tokens safely.
- 📊 **Faucet Balance Check**: Anyone can check the remaining balance of the faucet.

### Key Functions
#### `claimTokens()`
- Allows users to claim tokens from the faucet.
- Ensures the faucet has enough balance before transferring tokens.
- Emits a `TokensClaimed` event upon successful claims.

#### `setFaucetSettings(uint256 _claimAmount)`
- Only the contract owner can update the claim amount.
- Ensures the claim amount is greater than zero.
- Emits a `FaucetSettingsUpdated` event when updated.

#### `withdrawTokens(uint256 amount)`
- Allows the contract owner to withdraw tokens.
- Ensures sufficient balance before transferring.
- Emits a `TokensWithdrawn` event upon successful withdrawal.

#### `faucetBalance()`
- Returns the current balance of the faucet.

## THKX Token Smart Contract
The **THKX Token Smart Contract** is a highly secure ERC-20 token with built-in staking, minting, burning, and pausing functionalities. It features **timelock-based governance** and enhanced security mechanisms to prevent unauthorized actions.

### Key Features
- 🔐 **Access Control**: Uses `AccessControl` to manage roles and permissions.
- ⏳ **Timelock Governance**: Critical actions like minting and reward rate changes require time delays.
- 🔥 **Token Burning**: Supports token burning through `ERC20Burnable`.
- ⏸️ **Pausable Token Transfers**: The `ERC20Pausable` mechanism allows emergency stop functionality.
- 💰 **Staking & Rewards**: Users can stake THKX tokens and earn rewards over time.
- 🚨 **Emergency Withdrawals**: Admins can force withdrawals in critical situations.

### Staking System
#### `stake(uint256 amount)`
- Allows users to stake THKX tokens.
- Accumulates rewards based on a **reward rate**.
- Emits a `Staked` event.

#### `unstake(uint256 amount)`
- Allows users to withdraw their staked tokens along with earned rewards.
- Emits an `Unstaked` event.

#### `proposeRewardRate(uint256 newRate)` & `executeRewardRate(uint256 newRate)`
- **Timelock-protected** updates for reward rates to prevent abuse.
- Emits events for transparency.

### Security & Governance
- **Admin Roles**: `ADMIN_ROLE`, `STAKING_MANAGER_ROLE`, and `EMERGENCY_ROLE` manage different operations.
- **Emergency Stop**: Pauses token transfers and staking to mitigate risks.
- **Role Management**: Grants and revokes roles dynamically with timestamped events.

## Getting Started
### Prerequisites
To interact with the THKX token and smart contracts, ensure you have:
- A **Web3 wallet** (e.g., MetaMask)
- **Node.js** and **npm** (for development and integration)
- Solidity compiler (for smart contract development)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/ThemeHackers/THKX
   cd THKX-Token
   ```
2. Install dependencies:
   ```bash
   npm install  
   ```
3. Deploy smart contracts (if needed):
   ```bash
   npx hardhat run scripts/deploy.js --network holesky
   ```

## Contact & Support
For more information, visit our official channels or reach out to the development team.

## License
This project is licensed under the **GPL-3.0 license**.

