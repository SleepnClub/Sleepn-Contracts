// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title $Health Contract
/// @author Sleepn
/// @notice $Health is the governance token of Sleepn
contract Health is
    ERC20,
    ERC20Burnable,
    Ownable,
    Pausable,
    ERC20Permit,
    ERC20Votes
{
    /// @notice Max supply
    uint256 public immutable maxSupply;

    /// @notice Total Supply limit reached Error
    error TotalSupplyLimitReached();

    // @dev Initializer
    /// @param _totalSupply Total Supply of $Health
    constructor(uint256 _totalSupply)
        ERC20("$Health", "HLTH")
        ERC20Permit("$Health")
    {
        maxSupply = 10000000 * 1 ether;
        if (_totalSupply > 10000000) {
            revert TotalSupplyLimitReached();
        }
        _mint(msg.sender, _totalSupply * 10 ** decimals());
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
        if (totalSupply() + _amount > maxSupply) {
            revert TotalSupplyLimitReached();
        }
        _mint(_to, _amount);
    }

    /// @dev Function called before each transfert
    /// @param _from Sender Address
    /// @param _to Receiver Address
    /// @param _amount Amount of tokens to send
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        override
        whenNotPaused
    {
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    /// @dev Function called after each transfert
    /// @param _from Sender Address
    /// @param _to Receiver Address
    /// @param _amount Amount of tokens to send
    function _afterTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        override (ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(_from, _to, _amount);
    }

    /// @notice Mints tokens for this smart contract
    /// @param _to Tokens receiver
    /// @param _amount Amount of tokens to mint
    function _mint(address _to, uint256 _amount)
        internal
        override (ERC20, ERC20Votes)
    {
        super._mint(_to, _amount);
    }

    /// @notice Burns tokens for this smart contract
    /// @param _account Tokens's owner to burn
    /// @param _amount Amount of tokens to burn
    function _burn(address _account, uint256 _amount)
        internal
        override (ERC20, ERC20Votes)
    {
        super._burn(_account, _amount);
    }
}
