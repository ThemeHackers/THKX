// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 

/**
 * @title THKX Token Faucet
 * @dev Allows users to claim a limited amount of THKX tokens without cooldown.
 */
contract ERC20THKXFaucet is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint256 public claimAmount;
    
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event FaucetSettingsUpdated(uint256 newAmount);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _token) {
        if (_token == address(0)) revert("Invalid token address");

        token = IERC20(_token);
        claimAmount = 100 * 10 ** 18; 
    }

    function claimTokens() external nonReentrant {
        address user = msg.sender;
        uint256 balance = token.balanceOf(address(this));
        if (balance < claimAmount) revert("Faucet empty");

        token.safeTransfer(user, claimAmount);
        emit TokensClaimed(user, claimAmount, block.timestamp);
    }

    function setFaucetSettings(uint256 _claimAmount) external onlyOwner {
        if (_claimAmount == 0) revert("Claim amount must be > 0");
        
        claimAmount = _claimAmount;
        emit FaucetSettingsUpdated(_claimAmount);
    }

    function withdrawTokens(uint256 amount) external onlyOwner nonReentrant {
        uint256 balance = token.balanceOf(address(this));
        if (balance < amount) revert("Insufficient balance");

        token.safeTransfer(owner(), amount);
        emit TokensWithdrawn(owner(), amount);
    }

    function faucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}