// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./IBedroomNft.sol";

/// @title Interface of the Upgrade Nft Contract
/// @author Alexis Balayre
/// @notice An update NFT is used to upgrade a Bedroom NFT
interface IUpgradeNft is IERC1155Upgradeable {
    /// @notice Informations of an Upgrade NFT
    struct UpgradeSpecifications {
        uint256 bedroomNftId;
        uint256 attributeIndex;
        uint256 valueToAdd;
        uint256 valueToAddMax;
        address owner;
        uint256 price;
        uint256 newDesignId;
        uint256 upgradeDesignId;
    }

    /// @notice Upgrade NFT Minting Event
    event UpgradeNftMinting(
        uint256 tokenId,
        string tokenURI,
        UpgradeSpecifications specifications
    );

    /// @notice Returned Random Numbers Event
    event ReturnedRandomness(uint256[] randomWords);

    /// @notice Settles the address of contracts
    /// @param _dexAddress Address of the Dex contract
    /// @param _bedroomNft Address of the Bedroom NFT Contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, IBedroomNft _bedroomNft)
        external;

    /// @notice Returns some informations about a NFT
    /// @param _tokenId Id of the NFT
    /// @return _infos Informations of the NFT
    function getUpgradeNftSpecifications(uint256 _tokenId)
        external
        view
        returns (UpgradeSpecifications memory _infos);

    /// @notice Updates chainlink variables
    /// @param _callbackGasLimit Callback Gas Limit
    /// @param _subscriptionId Chainlink subscription Id
    /// @param _keyHash Chainlink Key Hash
    /// @param _requestConfirmations Number of request confirmations
    /// @dev This function can only be called by the owner of the contract
    function updateChainlink(
        uint32 _callbackGasLimit,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint16 _requestConfirmations
    ) external;

    /// @notice Mints a new upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignId Id of the new NFT design
    /// @param _upgradeDesignId Id of the new upgrade design
    /// @param _price Price of the upgrade
    /// @param _indexAttribute Index of upgrade attribute
    /// @param _valueToAddMax Value Max of the attribute
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintingUpgradeNft(
        uint256 _bedroomNftId,
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
