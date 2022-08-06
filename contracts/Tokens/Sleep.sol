// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title $Sleepn Contract
/// @author Sleepn
/// @notice $Sleep is the official token of Sleepn App
contract Sleep is ERC20, ERC20Burnable, Ownable, Pausable, ERC20Permit {
    /// @dev Initializer
    /// @param _totalSupply Total Supply of $Sleep
    constructor(
        uint256 _totalSupply
    ) ERC20("$Sleep", "SLP") ERC20Permit("$Sleep") {
        _mint(msg.sender, _totalSupply * 10**decimals());
    }

    /// @notice Stops the contract
    /// @dev This function can only be called by the owner of the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Starts the contract
    /// @dev This function can only be called by the owner of the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Mints tokens 
    /// @param _to Tokens receiver address
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner 
    function mint(address _to, uint256 _amount) external onlyOwner { 
        _mint(_to, _amount);
    }

    /// @dev Function called before each transfert
    /// @param _from Sender Address
    /// @param _to Receiver Address
    /// @param _amount Amount of tokens to send
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(_from, _to, _amount);
    }
}
