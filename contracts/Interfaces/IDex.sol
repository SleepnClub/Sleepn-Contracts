// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IBedroomNft.sol";
import "./ISleepToken.sol";
import "./IUpgradeNft.sol";

/// @title Interface of GetSleepn Decentralized Exchange Contract
/// @author Alexis Balayre
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
interface IDex {
    /// @notice Informations about an upgrade
    struct upgradeInfos {
        uint256 indexAttribute;
        uint256 valueToAddMax;
        uint256 price;
    }

    /// @notice Purchase cost and Upgrade costs
    struct NftPrices {
        uint256 purchaseCost; // Initial Cost
        mapping(uint256 => upgradeInfos) upgradeCosts; // Upgrade Costs
    }

    /// @notice Received Money Event
    event ReceivedMoney(address indexed sender, uint256 price);

    /// @notice Buy NFT Event
    event BuyNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 designId
    );

    /// @notice Upgrade NFT Event
    event UpgradeNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 upgradeDesignId,
        uint256 upgradeIndex,
        uint256 price
    );

    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed receiver, uint256 price);

    /// @notice Settles Team Wallet contract address
    /// @param _newAddress New Team Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setTeamWallet(address _newAddress) external;

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft
    ) external;

    /// @notice Settles NFTs purchase prices
    /// @param _category Category of the NFT
    /// @param _price Purchase price of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setBuyingPrices(IBedroomNft.Category _category, uint256 _price)
        external;

    /// @notice Settles NFTs upgrade prices
    /// @param _category Category of the Bedroom NFT
    /// @param _upgradeIndex Index of the upgrade
    /// @param _indexAttribute Index of the attribute concerned by the upgrade
    /// @param _valueToAddMax Value max to add to the existing score
    /// @param _price Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner of the contract
    function setUpgradePrices(
        IBedroomNft.Category _category,
        uint256 _upgradeIndex,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        uint256 _price
    ) external;

    /// @notice Withdraws the money from the contract
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney() external;

    /// @notice Returns the balance of the contract
    /// @return _balance Balance of the contract
    function getBalance() external view returns (uint256);

    /// @notice Launches the mint procedure of a Bedroom NFT
    /// @param _category Category of the desired Bedroom NFT
    /// @param _designId Design Id of the NFT
    function buyNft(IBedroomNft.Category _category, uint256 _designId)
        external
        payable;

    /// @notice Launches the mint procedure of an Upgrade NFT
    /// @notice Update NFT minting will automatically update the Bedroom NFT
    /// @param _tokenId Category of the desired Bedroom NFT
    /// @param _newDesignId Design Id of the NFT
    /// @param _upgradeDesignId Category of the desired Bedroom NFT
    /// @param _upgradeIndex Index of the upgrade
    /// @param _price Price of the NFT
    function upgradeNft(
        uint256 _tokenId,
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _upgradeIndex,
        uint256 _price
    ) external;

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external;
}
