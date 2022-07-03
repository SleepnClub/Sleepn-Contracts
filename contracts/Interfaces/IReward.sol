// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./IBedroomNft.sol";
import "./ISleepToken.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";

/// @title Interface of GetSleepn Reward Contract
/// @author Sleepn
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
    /// @param _indexReward Index of the reward
    /// @param _flowRate Flowrate of the stream reward
    /// @dev This function can only be called by the owner of the contract
    function setRewards(
        uint256 _indexReward,
        int96 _flowRate
    ) external;

    /// @notice Opens or Updates a reward stream
    /// @param _receiver Address of the receiver
    /// @param _tokenId ID of the NFT
    /// @param _rewardIndex Index of the reward flowrate
    /// @dev This function can only be called by the owner or the dev Wallet
    function createUpdateStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) external;

    /// @notice Closes a reward stream
    /// @param _receiver Address of the receiver
    /// @dev This function can only be called by the owner or the dev Wallet
    function closeStream(address _receiver) external;

    /// @notice Upgrades ERC20 to SuperToken
    /// @param _amount Number of tokens to be upgraded (in 18 decimals)
    /// @dev This function can only be called by the owner or the dev Wallet
    function wrapTokens(uint256 _amount) external;

    /// @notice Downgrades SuperToken to ERC20
    /// @param _amount Number of tokens to be downgraded (in 18 decimals)
    /// @dev This function can only be called by the owner or the dev Wallet
    function unwrapTokens(uint256 _amount) external;

    /// @notice Returns balance of contract
    /// @return _balance Balance of contract
    function returnBalance() external view returns (uint256);

    /// @notice Settles Sleep Token contract address 
    /// @param _sleepToken Address of the Sleep Token contract
    /// @dev This function can only be called by the owner of the contract
    function setSleepToken(ISleepToken _sleepToken) external;

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external;
}
