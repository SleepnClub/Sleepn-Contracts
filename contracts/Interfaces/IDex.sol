// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IBedroomNft.sol";
import "./ISleep.sol";
import "./IHealth.sol";
import "./IUpgradeNft.sol";

/// @title Interface of GetSleepn Decentralized Exchange Contract
/// @author Sleepn
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
interface IDex {
    /// @notice Upgrade costs
    struct Upgrade {
        uint256 designId; // Design Id
        uint256 data; // NFT Data
    }

    /// @notice Buy Bedroom NFT Event
    event BuyBedroomNft(
        address indexed owner,
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
    /// @param _healthToken Address of the Health Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @param _teamWallet New Team Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @param _tokenAddress New Payment Token contract address
    /// @dev This function can only be called by the owner of the contract
    function setAddresses(
        ISleep _sleepToken,
        IHealth _healthToken,
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

    /// @notice Settles NFTs Upgrade data
    /// @param _price Purchase price of the Upgrade NFT
    /// @param _upgradeId Id of the upgrade
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner of the contract
    function setUpgradeData(
        uint256 _price,
        uint256 _upgradeId,
        uint256 _amount,
        uint256 _designId,
        uint256 _level,
        uint256 _levelMin,
        uint256 _attributeIndex,
        uint256 _valueToAdd,
        uint256 _typeNft,
        uint256 _data
    ) external;

    /// @notice Settles NFTs Upgrade data - Batch transaction
    /// @param _price Purchase price of the Upgrade NFT
    /// @param _upgradeId Id of the upgrade
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner or the dev Wallet
    function setUpgradeDataBatch(
        uint256[] memory _price,
        uint256[] memory _upgradeId,
        uint256[] memory _amount,
        uint256[] memory _designId,
        uint256[] memory _level,
        uint256[] memory _levelMin,
        uint256[] memory _attributeIndex,
        uint256[] memory _valueToAdd,
        uint256[] memory _typeNft,
        uint256[] memory _data
    ) external;

    /// @notice Withdraws the money from the contract
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney() external;

    /// @notice Returns the data of an Upgrade Nft
    /// @param _upgradeId Id of the upgrade
    /// @return designId Upgrade Nft URI 
    /// @return price Purchase price of the Upgrade NFT
    /// @return amount Amount of tokens to add to the Upgrade Nft
    /// @return level Level to add to the Bedroom Nft
    /// @return levelMin Bedroom Nft Level min required
    /// @return attributeIndex Score involved (optionnal)
    /// @return valueToAdd Value to add to the score (optionnal)
    /// @return typeNft NFT Type 
    /// @return data Additionnal data (optionnal)
    function getUpgradeData(uint256 _upgradeId) 
        external 
        view 
        returns (
            uint256 designId,
            uint16 price,
            uint16 amount,
            uint16 level,
            uint16 levelMin,
            uint16 attributeIndex,
            uint16 valueToAdd,
            uint16 typeNft,
            uint16 data
    );


    /// @notice Launches the mint procedure of a Bedroom NFT
    function buyBedroomNft()
        external;
    
    /// @notice Buy an Upgrade Nft
    /// @param _upgradeId Id of the Upgrade 
    function buyUpgradeNft(
        uint256 _upgradeId
    ) external;

    /// @notice Links an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    function linkUpgradeNft(
        uint256 _upgradeNftId, 
        uint256 _bedroomNftId, 
        uint256 _newDesignId
    ) external;

    /// @notice Unlinks an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    function unlinkUpgradeNft(
        uint256 _upgradeNftId, 
        uint256 _newDesignId
    ) external;

    /// @notice Buy a Pack
    /// @param _packId Id of the Pack
    function buyPack(
        uint256 _packId
    ) external;

    /// @notice Returns the data of a Pack
    /// @param _packId Id of the Pack
    /// @return _designId Upgrade Nft URI 
    /// @return _price Purchase price of the Upgrade NFT
    /// @return _upgradeIds Upgrade Nfts ID
    function getPackData(uint256 _packId) 
        external 
        view 
        returns (
            uint256 _designId, // Design Id
            uint256 _price, // Price
            uint256[10] memory _upgradeIds // UpgradeIds
    );

    /// @notice Settles Packs data
    /// @param _upgradeIds Ids of the Upgrade Nfts
    /// @param _designId Bedroom NFT Design Id
    /// @param _price Purchase price of the Pack
    /// @param _packId Pack ID
    /// @dev This function can only be called by the owner of the contract
    function setPackPrice(
        uint256[10] memory _upgradeIds, 
        uint256 _designId,
        uint256 _price,
        uint256 _packId
    )
        external;

}
