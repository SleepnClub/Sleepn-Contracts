// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

/// @title Interface of the BedroomNft Contract
/// @author Alexis Balayre
/// @notice Contains the external functions of the BedroomNft Contract
interface IBedroomNft is IERC1155Upgradeable {
    /// @notice Enumeration of the different categories of a Bedroom NFT
    enum Category {
        Studio,
        Deluxe,
        Luxury
    }

    /// @notice Administration informations of a Bedroom NFT
    struct NftOwnership {
        address owner;
        uint256 price;
        uint256 designId;
        uint256 level;
        Category category;
    }

    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        uint256 lightIsolationScore; // Index 0
        uint256 bedroomThermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 temperatureScore; // Index 3
        uint256 humidityScore; // Index 4
        uint256 sleepAidMachinesScore; // Index 5
        uint256 circadianRhythmRegulation; // Index 6
        uint256 sizeScore; // Index 7
        uint256 heightScore; // Index 8
        uint256 bedBaseScore; // Index 9
        uint256 mattressTechnologyScore; // Index 10
        uint256 mattressThicknessScore; // Index 11
        uint256 mattressDeformationScore; // Index 12
        uint256 thermalIsolationScore; // Index 13
        uint256 hygrometricRegulationScore; // Index 14
        uint256 comforterComfortabilityScore; // Index 15
        uint256 pillowComfortabilityScore; // Index 16
    }

    /// @notice Returns the administration informations of a Bedroom NFT
    /// @param _tokenId The id of the NFT
    /// @return _struct NftOwnership struct of the Nft
    function tokenIdToNftOwnership(uint256 _tokenId)
        external
        returns (NftOwnership memory _struct);

    /// @notice Returns the score of a Bedroom NFT attribute
    /// @param _tokenId The id of the NFT
    /// @param _indexAttribute The index of the desired attribute
    /// @return _score Score of the desired attribute
    function getNftSpecifications(uint256 _tokenId, uint256 _indexAttribute)
        external
        view
        returns (uint256 _score);

    /// @notice Updates chainlink variables
    /// @param _callbackGasLimit Callback Gas Limit
    /// @param _subscriptionId Chainlink subscription Id
    /// @param _keyHash Chainlink Key Hash
    /// @dev This function can only be called by the owner of the contract
    function updateChainlink(
        uint32 _callbackGasLimit,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) external;

    /// @notice Updates Nft Multipliers
    /// @param _category Category of the NFT
    /// @param _multiplier Value of the category reward multiplier
    /// @dev This function can only be called by the owner of the contract
    function setNftMultiplier(Category _category, uint256 _multiplier) external;

    /// @notice Settles File format
    /// @param _format New file format
    /// @dev This function can only be called by the owner of the contract
    function setFileFormat(string memory _format) external;

    /// @notice BedroomNft minting event
    event BedroomNftMinting(
        uint256 tokenId,
        string tokenURI,
        NftSpecifications specifications
    );

    /// @notice Mints a Bedroom NFT
    /// @param _designId Design If the NFT
    /// @param _price Price of the NFT
    /// @param _category Category of the NFT
    /// @param _owner Owner of the NFT
    function mintingBedroomNft(
        uint256 _designId,
        uint256 _price,
        Category _category,
        address _owner
    ) external;

    /// @notice Mints a Bedroom NFT
    function getName(uint256 _tokenId) external view returns (string memory);

    /// @notice Mints a Bedroom NFT
    event BedroomNftUpgrading(
        uint256 tokenId,
        string newTokenURI,
        NftSpecifications specifications
    );

    /// @notice Upgrades a Bedroom NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the upgrading attribute
    /// @param _valueToAdd Value to add to the upgrading attribute
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @dev This function can only be called by the Dex contract
    function upgradeBedroomNft(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _valueToAdd,
        uint256 _newDesignId,
        uint256 _amount
    ) external;

    /// @notice Settles Token URL
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    /// @notice Settles Base URL
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;
}
