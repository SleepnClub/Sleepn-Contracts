// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract $Health is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable, ERC20Permit, ERC20Votes {
    /// @notice Reward Contract Address
    address immutable public rewardContract;

    /// @dev Dev Wallet 
    address private devWallet;

    /// @notice MintTo function state 
    bool public canMintTo; 

    /// @notice MintTo function state 
    uint256 immutable public maxSupply;

    // @dev Initializer
    /// @param _totalSupply Total Supply of $Sleep
    /// @param _rewardContract Reward Contract Address
    /// @param _teamWallet Team Wallet Address
    constructor(
        uint256 _totalSupply,
        address _rewardContract,
        address _teamWallet
    ) ERC20("$Health", "HLTH") ERC20Permit("$Health") {
        _mint(_teamWallet, _totalSupply * 10**decimals());
        rewardContract = _rewardContract;
        canMintTo = true;
        maxSupply = 10000000*1e18;
    }

    /// @notice Creates a new snapshot 
    /// @dev This function can only be called by the owner of the contract
    function snapshot() public onlyOwner {
        _snapshot();
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

    /// @notice Starts the contract
    /// @param _addr Address of the receiver
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner of the contract
    function mintTo(address _addr, uint256 _amount) external onlyOwner {
        require(canMintTo == true, "mintTo function is disabled");
        require(totalSupply() + _amount <= maxSupply, "Total Supply limit reached");
        _mint(_addr, _amount);
    }

    /// @notice Disables the mintTo function
    /// @dev This function can only be called by the owner of the contract
    function stopMintTo() external onlyOwner {
        canMintTo = false;
    }

    /// @notice Mints tokens for Reward Contract
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or the dev Wallet
    function mintTokens(uint256 _amount) external { 
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        require(totalSupply() + _amount <= maxSupply, "Total Supply limit reached");
        _mint(rewardContract, _amount);
    }

    /// @notice Burns tokens of Reward Contract
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner or the dev Wallet
    function burnTokens(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        _burn(rewardContract, _amount);
    }

    /// @dev Function called before each transfert
    /// @param _from Sender Address
    /// @param _to Receiver Address
    /// @param _amount Amount of tokens to send
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    /// @dev Function called after each transfert
    /// @param _from Sender Address
    /// @param _to Receiver Address
    /// @param _amount Amount of tokens to send
    function _afterTokenTransfer(address _from, address _to, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(_from, _to, _amount);
    }

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    /// @notice Mints tokens for this smart contract
    /// @param _to Tokens receiver
    /// @param _amount Amount of tokens to mint
    function _mint(address _to, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(_to, _amount);
    }

    /// @notice Burns tokens for this smart contract
    /// @param _account Tokens's owner to burn
    /// @param _amount Amount of tokens to burn
    function _burn(address _account, uint256 _amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(_account, _amount);
    }
}
