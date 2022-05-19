// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract SleepToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    address private rewardContract;
    
    // Init 
    function initialize(uint256 _totalSupply, address _rewardContract) initializer public {
        __ERC20_init("Sleep Token", "$SLEEP");
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        rewardContract = _rewardContract;

        _mint(msg.sender, _totalSupply * 10 ** decimals());
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
    function mintTokens(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // Burn tokens of this smart contract
    function burnTokens(uint256 _amount) public onlyOwner {
        _burn(address(this), _amount);
    }

    // Send tokens to reward Contract
    function supplyRewardContract(uint256 _amount) public onlyOwner {  
        _transfer(address(this), rewardContract, _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}