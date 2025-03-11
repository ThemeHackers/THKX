// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title THKX Token Faucet
 * @dev Allows users to claim a limited amount of THKX tokens at fixed intervals.
 */
contract ERC20THKXFaucet is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint256 public claimAmount;
    uint256 public claimCooldown;
    mapping(address => uint256) public lastClaimed;

    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event FaucetSettingsUpdated(uint256 newAmount, uint256 newCooldown);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _token) {
        require(_token != address(0), "Invalid token address");

        token = IERC20(_token);
        claimAmount = 100 * 10 ** 18; 
        claimCooldown = 30; 
    }

    function claimTokens() external {
        require(block.timestamp >= lastClaimed[msg.sender] + claimCooldown, "Cooldown active");
        require(token.balanceOf(address(this)) >= claimAmount, "Faucet empty");

        lastClaimed[msg.sender] = block.timestamp;
        token.safeTransfer(msg.sender, claimAmount);

        emit TokensClaimed(msg.sender, claimAmount, block.timestamp);
    }

    function setFaucetSettings(uint256 _claimAmount, uint256 _claimCooldown) external onlyOwner {
        require(_claimAmount > 0, "Claim amount must be > 0");
        require(_claimCooldown > 0, "Cooldown must be > 0");

        claimAmount = _claimAmount;
        claimCooldown = _claimCooldown;
        emit FaucetSettingsUpdated(_claimAmount, _claimCooldown);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        token.safeTransfer(owner(), amount);
        emit TokensWithdrawn(owner(), amount);
    }

    function faucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function canClaim(address user) external view returns (bool) {
        return block.timestamp >= lastClaimed[user] + claimCooldown &&
               token.balanceOf(address(this)) >= claimAmount;
    }  
}
