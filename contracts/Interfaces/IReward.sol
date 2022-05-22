// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IBedroomNft.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";

/// @title Interface of GetSleepn Reward Contract
/// @author Alexis Balayre
/// @notice This contract is used to stream $Sleep to GetSleepn users
interface IReward {
    /// @notice Open or Update Stream Event
    event OpenUpdateStream(address receiver, int96 flowRate);

    /// @notice Close Stream Event
    event CloseStream(address receiver);

    /// @notice Settles Super Token Address
    /// @param _superToken Super Token Contract Address
    /// @dev This function can only be called by the owner of the contract
    function setSuperToken(ISuperToken _superToken) external;

    /// @notice Settles rewards flowrat
    /// @notice Rewards flowrate : (Number of tokens / 60) * 10^18
    /// @param _category Category of the NFT
    /// @param _indexReward Index of the reward
    /// @param _flowRate Flowrate of the stream reward
    /// @dev This function can only be called by the owner of the contract
    function setRewards(
        IBedroomNft.Category _category,
        uint256 _indexReward,
        int96 _flowRate
    ) external;

    /// @notice Opens or Updates a reward stream
    /// @param _receiver Address of the receiver
    /// @param _tokenId ID of the NFT
    /// @param _rewardIndex Index of the reward flowrate
    /// @dev This function can only be called by Dex Contract
    function createUpdateStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) external;

    /// @notice Closes a reward stream
    /// @param _receiver Address of the receiver
    /// @dev This function can only be called by Dex Contract
    function closeStream(address _receiver) external;
}
