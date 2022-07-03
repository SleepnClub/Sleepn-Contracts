// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";


/// @title $Sleep Token Contract
/// @author Sleepn
/// @notice $Sleep is the official token of Sleepn App
contract $Sleep is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable, ERC20Permit {
    /// @notice Reward Contract Address
    address immutable private rewardContract;

    /// @dev Dev Wallet 
    address private devWallet;

    /// @notice MintTo function state 
    bool public canMintTo; 

    /// @dev Initializer
    /// @param _totalSupply Total Supply of $Sleep
    /// @param _rewardContract Reward Contract Address
    /// @param _teamWallet Team Wallet Address
    constructor(
        uint256 _totalSupply,
        address _rewardContract,
        address _teamWallet
    ) ERC20("$Sleep", "SLP") ERC20Permit("$Sleep") {
        _mint(_teamWallet, _totalSupply * 10**decimals());
        rewardContract = _rewardContract;
        canMintTo = true;
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
        _mint(_addr, _amount);
    }

    /// @notice Disables the mintTo function
    /// @dev This function can only be called by the owner of the contract
    function stopMintTo() external onlyOwner {
        canMintTo = false;
    }

    /// @notice Mints tokens Reward Contract
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or the dev Wallet
    function mintTokens(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
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
    /// @param from Sender Address
    /// @param to Receiver Address
    /// @param amount Amount of tokens to send
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }
}
