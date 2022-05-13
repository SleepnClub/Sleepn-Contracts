// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISuperfluid, ISuperToken, ISuperApp } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import "./SleepToken.sol";

contract reward is Initializable, OwnableUpgradeable {
    ISuperToken public superTokenAddress; 

    // Set Super Token Address
    function setSuperTokenAddress(address _superTokenAddress) public onlyOwner {
        superTokenAddress = ISuperToken(_superTokenAddress);
    }

    

}