// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./SleepToken.sol";


contract Dex is Initializable, OwnableUpgradeable {
    enum Category { Studio, Deluxe, Luxury }
    
    uint256 public studioPrice;
    uint256 public deluxePrice;
    uint256 public luxuryPrice;

    event ReceivedMoney(address indexed _from, uint _amount);

    function setPrices(
        uint256 _studioPrice, 
        uint256 _deluxePrice, 
        uint256 _luxuryPrice
    ) public onlyOwner {
        studioPrice = _studioPrice;
        deluxePrice = _deluxePrice;
        luxuryPrice = _luxuryPrice;
    }

    function withdrawMoney(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        _to.transfer(_amount);
    }

    function buyNft(Category _categorie) external {

    }

    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}