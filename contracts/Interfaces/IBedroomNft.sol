// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./IUpgradeNft.sol";

/// @title Interface of the Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of GetSleepn app
interface IBedroomNft is IERC1155 {
    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        address owner;
        uint64 scores; 
        uint256 level;
    }

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinting(
        address indexed owner,
        uint256 tokenId,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Score is upgraded
    event BedroomNftScoreUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Score is downgraded
    event BedroomNftScoreDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Level is upgraded
    event BedroomNftLevelUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Level is downgraded
    event BedroomNftLevelDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Design is upgraded
    event BedroomNftDesignUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Design is downgraded
    event BedroomNftDesignDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level
    );

    /// @notice Returned Random Numbers Event
    event ReturnedRandomness(uint256[] randomWords);

    /// @notice Returns the data of a NFT 
    /// @param _tokenId The id of the NFT
    /// @return _ambiance Score 1
    /// @return _quality Score 2
    /// @return _luck Score 3
    /// @return _confortability Score 4
    /// @return _owner NFT Owner
    /// @return _level NFT Level
    function getScores(
        uint256 _tokenId
    ) external view returns(
        uint16 _ambiance, 
        uint16 _quality, 
        uint16 _luck, 
        uint16 _confortability,
        address _owner,
        uint256 _level
    );

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
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNft(
        address _owner
    ) external;

    /// Gets the name of a Nft
    /// @param _tokenId Id of the NFT
    /// @return _name Name of thr NFT
    function getName(uint256 _tokenId)
        external
        view
        returns (string memory _name);

    /// @notice Returns the owner of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _owner NFT owner address
    function getNftsOwner(uint256 _tokenId) external view returns(address _owner);

    /// @notice Returns the level of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _level NFT level
    function getNftsLevel(uint256 _tokenId) external view returns(uint256 _level);

    /// @notice Launches the procedure to update the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the attribute to upgrade
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _value Value to add to the attribute score
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateScores(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _newDesignId,
        uint256 _amount, 
        uint256 _level,
        uint16 _value,
        bool _action   
    ) external;

    /// @notice Launches the procedure to update the level of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateLevel(
        uint256 _tokenId, 
        uint256 _level,
        bool _action   
    ) external;

    /// @notice Launches the procedure to update the level of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateDesign(
        uint256 _tokenId, 
        uint256 _newDesignId,
        uint256 _amount,
        uint256 _level,
        bool _action
    ) external;

    /// @notice Settles Token URL
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    /// @notice Settles Base URL
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;

    /// @notice Returns the number of Nfts owned by an address
    /// @param _owner Owner address
    /// @return _number NFTs number
    function getNftsNumber(address _owner) 
        external
        view
        returns (uint256);

    /// @notice TransferOwnership
    /// @param _newOwner New Owner address
    function transferOwnership(address _newOwner) external;
}