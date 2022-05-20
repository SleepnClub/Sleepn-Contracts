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
    function updateChainlink(
        uint32 _callbackGasLimit,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) external;

    /// @notice Updates Nft Multipliers
    /// @param _category Category of the NFT
    /// @param _multiplier Value of the category reward multiplier
    function setNftMultiplier(Category _category, uint256 _multiplier) external;

    /// @notice Settles File format
    /// @param _format New file format
    function setFileFormat(string memory _format) external;

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

    function getName(uint256 _tokenId) external view returns (string memory);

    function upgradeBedroomNft(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _valueToAdd,
        uint256 _newDesignId,
        uint256 _amount
    ) external;

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    function setBaseURI(string memory _baseURI) external;
}
