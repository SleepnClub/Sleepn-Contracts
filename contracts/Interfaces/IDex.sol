// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IBedroomNft.sol";
import "./ISleepToken.sol";
import "./IUpgradeNft.sol";

/// @title Interface of GetSleepn Decentralized Exchange Contract
/// @author Sleepn
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
interface IDex {
    /// @notice Upgrade costs
    struct Upgrade {
        bool isOwned; // is Owned
        uint256 price; // Upgrade Cost
    }

    /// @notice Buy Bedroom NFT Event
    event BuyBedroomNft(
        address indexed owner,
        uint256 designId,
        uint256 price
    );

    /// @notice Buy Upgrade NFT Event
    event BuyUpgradeNft(
        address indexed owner,
        uint256 upgradeNftId,
        uint256 price
    );

    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed receiver, uint256 price);

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @param _teamWallet New Team Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @param _tokenAddress New Payment Token contract address
    /// @dev This function can only be called by the owner of the contract
    function setAddresses(
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft,
        address _teamWallet,
        address _devWallet,
        IERC20 _tokenAddress
    ) external;

    /// @notice Settles NFTs purchase price
    /// @param _price Purchase price of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setBuyingPrice(uint256 _price)
        external;

    /// @notice Settles NFTs upgrade price
    /// @param _upgradeId Id of the upgrade
    /// @param _price Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner of the contract
    function setUpgradePrice(
        uint256 _upgradeId,
        uint256 _price
    ) external;

    /// @notice Withdraws the money from the contract
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney() external;

    /// @notice Settles NFTs upgrade prices
    /// @param _upgradeIds Id of the upgrade
    /// @param _prices Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner or the dev Wallet
    function setUpgradePriceBatch(
        uint256[] memory _upgradeIds,
        uint256[] memory _prices
    ) external;

    /// @notice Returns the price of an Upgrade Nft
    /// @param _id Id of the upgrade
    /// @return _price Price of the Upgrade Nft
    function getUpgradePrice(
        uint256 _id
    ) external view returns (uint256 _price);

    /// @notice Returns the balance of the contract
    /// @return _balance Balance of the contract
    function getBalance() external view returns (uint256 _balance);

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    function buyUpgradeNft(
        uint256 _upgradeNftId
    ) external;

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    function linkUpgradeNft(
        uint256 _upgradeNftId, 
        uint256 _bedroomNftId, 
        uint256 _newDesignId
    ) external;

}
