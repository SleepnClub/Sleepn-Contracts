// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./IUpgradeNft.sol";

/// @title Interface of the Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of GetSleepn app
interface IBedroomNft is IERC1155Upgradeable {
    // @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        uint256 lightIsolationScore; // Index 0
        uint256 thermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 humidityScore; // Index 3
        uint256 temperatureScore; // Index 4
        uint256 ventilationScore; // Index 5
        uint256 surfaceScore; // Index 6
        uint256 furnitureScore; // Index 7
        uint256 sleepAidMachinesScore; // Index 8
        uint256 bedScore; // Index 9
        address owner;
        uint256 designId;
        uint256 level;
    }

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinting(
        address indexed owner,
        uint256 tokenId,
        string tokenURI,
        NftSpecifications specifications
    );

    /// @notice Emits an event when a Bedroom NFT is upgraded
    event BedroomNftUpgrading(
        address indexed owner,
        uint256 tokenId,
        string newTokenURI,
        NftSpecifications specifications
    );

    /// @notice Returned Random Numbers Event
    event ReturnedRandomness(uint256[] randomWords);

    /// @notice Settles contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _upgradeNftAddress Address of the Upgrade NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, IUpgradeNft _upgradeNftAddress)
        external;


    /// @notice Returns the scores of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _scores Scores of the NFT
    function getNftSpecifications(uint256 _tokenId)
        external
        view
        returns (NftSpecifications memory);

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

    /// @notice Settles File format
    /// @param _format New file format
    /// @dev This function can only be called by the owner of the contract
    function setFileFormat(string memory _format) external;

    /// @notice Launches the procedure to create an NFT
    /// @param _designId Design Id the NFT
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintingBedroomNft(
        uint256 _designId,
        address _owner
    ) external;

    /// Gets the name of a Nft
    /// @param _tokenId Id of the NFT
    /// @return _name Name of thr NFT
    function getName(uint256 _tokenId)
        external
        view
        returns (string memory _name);

    /// @notice Launches the procedure to update an NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the attribute to upgrade
    /// @param _value Value to add to the attribute score
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateBedroomNft(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _value,
        uint256 _newDesignId,
        uint256 _amount, 
        uint256 _level,
        uint256 _action
    ) external;

    /// @notice Settles Token URL
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    /// @notice Settles Base URL
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;
}
