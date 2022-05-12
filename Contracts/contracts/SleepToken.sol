// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SleepToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    address public nftDexAddress;

    function initialize(address _nftDexAddress) initializer public {
        __ERC20_init("SleepToken", "SLP");
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        _mint(address(this), _totalSupply * 10 ** decimals());
    }

    // Access management for token management functions
    modifier onlyDex(){
        require(_isInitialized(), "Dex address not configured!");
        require(msg.sender == nftDexAddress, "Access forbidden");
        _;
    }

    // Verifies that DEX address has been configured
    function _isInitialized() internal returns(bool) {
        if (nftDexAddress != address(0)) {
            return true;
        }
        return false;
    }

    // set Dex address 
    function setDex(address _nftDexAddress) public onlyOwner {
        nftDexAddress = _nftDexAddress;
    }

    // Stop the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Start the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    // Mint tokens for this smart contract
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // Burn tokens of this smart contract
    function burn(uint256 _amount) public override onlyOwner {
        _burn(address(this), _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // NFT Investment : Buy, Upgrade
    function investNft(address _owner, uint256 _amount) public onlyDex {
        require(_amount > 0, "Incorrect amount");
        uint256 allowance = allowance(_owner, msg.sender);
        require(allowance >= _amount,"Check the token allowance")
        _burn(_owner, _amount);
    }

}