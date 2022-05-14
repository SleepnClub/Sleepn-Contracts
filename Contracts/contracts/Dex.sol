// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./SleepToken.sol";


contract Dex is Initializable, OwnableUpgradeable {
    // NFT Categories
    enum Category { Studio, Deluxe, Luxury }

    // Prices
    mapping(Category => uint256) public prices;

    // Events
    event ReceivedMoney(address indexed sender, uint256 amount);
    event BuyNft(address indexed owner, Category categorie);
    event WithdrawMoney(address indexed receiver, uint256 amount);

    // Set NFT prices
    function setPrice(
        Category _categorie,
        uint256 _amount
    ) public onlyOwner {
        prices[_categorie] = _amount;
    }

    // WithdrawMoney
    function withdrawMoney(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        _to.transfer(_amount);
        emit WithdrawMoney(_to, _amount);
    }

    // Buy NFT
    function buyNft(Category _categorie) public payable {
        require(msg.value >= prices[_categorie], "Not enough money was sent");
    }
 
    // Receive Money fallback function
    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}