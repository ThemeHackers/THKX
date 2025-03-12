# 🚀 THKX Smart Contracts

This repository contains smart contracts and scripts for the **THKX Token Ecosystem**:
1. **THKX Faucet Contract** - A faucet that allows users to claim free THKX tokens.
2. **THKX Token Contract** - An ERC-20 token with staking, minting, burning, and pausing functionalities.
3. **Web3 Integration (`web3-thkx-faucets`)** - Frontend scripts to interact with the faucet.
4. **Scripts and Tests** - Deployment, interaction scripts, and smart contract tests.

---

## 📜 THKX Faucet Contract (`ERC20THKXFaucet.sol`)

### 📌 Features
- Users can claim free THKX tokens using `claimTokens()`.
- The owner can adjust the claim amount via `setFaucetSettings()`.
- The owner can withdraw remaining tokens with `withdrawTokens()`.
- **Security Features:** Uses **ReentrancyGuard** and **SafeERC20** for safety.

### ⚙️ Setup Before Use
1. **Deploy the contract**, specifying the address of the THKX token.
2. **Transfer THKX tokens** to the faucet contract to provide liquidity.
3. **Set the claim amount** using `setFaucetSettings()`.

### 🚀 How to Use
1. Users call `claimTokens()` to receive free tokens.
2. The owner can check the faucet balance using `faucetBalance()`.
3. The owner can withdraw remaining tokens using `withdrawTokens()`.

---

## 🔥 THKX Token Contract (`THKXToken.sol`)

### 📌 Features
- **Standard ERC-20 Token** with burning, pausing, and minting capabilities.
- **Staking System** allowing users to lock tokens and earn rewards.
- **Timelock Security** for modifying the reward rate safely.
- **Emergency Stop** to pause all operations if needed.

### ⚙️ Setup Before Use
1. **Deploy the contract**, specifying the initial admin address.
2. **Assign Roles** (`ADMIN_ROLE`, `STAKING_MANAGER_ROLE`, `EMERGENCY_ROLE`).
3. **Mint tokens** to supply initial liquidity.
4. **Set the staking reward rate** using `proposeRewardRate()`.

### 🚀 How to Use
1. Users can **stake tokens** using `stake(amount)`.
2. Users can **unstake tokens** using `unstake(amount)`, receiving rewards.
3. Admin can **propose & execute reward rate updates** with a timelock.
4. Use `calculatePendingRewards()` to check pending staking rewards.

---

## 🌐 Web3 Integration (`web3-thkx-faucets`)

### 📌 Overview
- This project includes a **frontend integration** for the faucet using **Web3.js**.
- Allows users to interact with the **Faucet Contract** via a **React-based UI**.
- Uses **MetaMask** or other Web3 wallets for transactions.


