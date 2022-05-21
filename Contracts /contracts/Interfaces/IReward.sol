// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IBedroomNft.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";

interface IReward {
    function setSuperToken(ISuperToken _superToken) external;

    function setRewards(
        IBedroomNft.Category _category,
        uint256 _indexReward,
        int96 _flowRate
    ) external;

    function createUpdateStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) external;

    function closeStream(address _receiver) external;
}