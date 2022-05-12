// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./SleepToken.sol";
import "./BedroomNft.sol";

interface SleepTokenInterface {
    
}


contract Dex is Initializable, OwnableUpgradeable {
    SleepToken public sleepTokenInstance; 
    BedroomNFT public bedroomNftInstance;

    // NFT Categories 
    enum Category { Studio, Deluxe, Luxury }

    // Events 
    event BuyNft(Category category, uint256 sleepTokenAmount, address buyer);
    event UpgradeNft(Category category, uint256 sleepTokenAmount, address buyer);

    function initialize(IERC20Upgradeable _token) public initializer {
        token = _token;
    }

    // Buy a Nft
    function buyNft(uint256 _amount, Category category) public {
        require(sleepTokenInstance != address(0), "sleepToken address is not configured");
        require(bedroomNftInstance != address(0), "bedroomNft address is not configured");
        // User must approve the transaction
        sleepTokenInstance.investNft(msg.sender, _amount);
    }
}