// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./SleepToken.sol";
import "./BedroomNft.sol";

interface SleepTokenInterface {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function investNft(address _owner, uint256 _amount) public;
}


contract Dex is Initializable, OwnableUpgradeable {
    SleepTokenInterface public sleepTokenInstance; 
    BedroomNFT public bedroomNftInstance;

    // NFT Categories 
    enum Category { Studio, Deluxe, Luxury }

    // Events 
    event BuyNft(Category category, uint256 sleepTokenAmount, address buyer);
    event UpgradeNft(Category category, uint256 sleepTokenAmount, address buyer);

    function initialize(SleepTokenInterface _sleepTokenInstance) public initializer {
        sleepTokenInstance = _sleepTokenInstance;
    }

    // Buy a Nft
    function buyNft(uint256 _amount, Category category) public {
        require(sleepTokenInstance != address(0), "sleepToken address is not configured");
        require(bedroomNftInstance != address(0), "bedroomNft address is not configured");
        // User must approve the transaction
        
        sleepTokenInstance.investNft(msg.sender, _amount);
    }
}