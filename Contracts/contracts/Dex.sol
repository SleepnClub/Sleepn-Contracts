// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./SleepToken.sol";
import "./BedroomNft.sol";

interface SleepTokenInterface {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function investNft(address _owner, uint256 _amount) external;
}


contract Dex is Initializable, OwnableUpgradeable {
    SleepTokenInterface public sleepTokenInstance; 
    BedroomNft public bedroomNftInstance;

    // Events 
    event BuyNft(uint256 category, uint256 sleepTokenAmount, address buyer);
    event UpgradeNft(uint256 category, uint256 sleepTokenAmount, address buyer);

    function initialize(SleepTokenInterface _sleepTokenInstance) public initializer {
        sleepTokenInstance = _sleepTokenInstance;
    }

    // Buy a Nft
    function buyNft(uint256 _amount, uint256 category) public {
        require(address(sleepTokenInstance) != address(0), "sleepToken address is not configured");
        require(address(bedroomNftInstance) != address(0), "bedroomNft address is not configured");
        // User must approve the transaction

        sleepTokenInstance.investNft(msg.sender, _amount);
    }
}