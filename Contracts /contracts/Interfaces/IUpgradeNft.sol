// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./IBedroomNft.sol";

/// @title Interface of the UpgradeNft Contract
/// @author Alexis Balayre
/// @notice Contains the external functions of the UpgradeNft Contract
interface IUpgradeNft is IERC1155Upgradeable {
    /// @notice Settles the Dex contract address
    /// @param _dexAddress Address of the Dex contract
    /// @dev This function can only be called by the owner of the contract
    function setDex(address _dexAddress) external;

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

    /// @notice Mints a new upgrade NFT
    /// @param _newDesignId Id of the new NFT design
    /// @param _upgradeDesignId Id of the new upgrade design
    /// @param _price Price of the upgrade
    /// @param _indexAttribute Index of upgrade attribute
    /// @param _valueToAddMax Value Max of the attribute
    /// @param _owner Owner of the NFT
    function mintingUpgradeNft(
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _price,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        address _owner
    ) external;

    /// @notice Settles the file format of the NFT Design
    /// @param _format Format of the design file
    /// @dev This function can only be called by the owner of the contract
    function setFileFormat(string memory _format) external;

    /// @notice Gets the name of an NFT
    /// @param _tokenId Id of the NFT
    function getName(uint256 _tokenId) external pure returns (string memory);

    /// @notice Settles Token URL
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    /// @notice Settles Base URL
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;
}
