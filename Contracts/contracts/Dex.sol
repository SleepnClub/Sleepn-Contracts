// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./SleepToken.sol";


contract Dex is Initializable, OwnableUpgradeable {
    enum Category { Studio, Deluxe, Luxury }

    mapping(Category => uint256) public prices;

    event ReceivedMoney(address indexed _from, uint _amount);

    function setPrice(
        Category _categorie
    ) public onlyOwner {
        prices[categorie] = _amount;
    }

    function withdrawMoney(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        _to.transfer(_amount);
    }

    function buyNft(Category _categorie) public payable {
        require("")
    }

    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}