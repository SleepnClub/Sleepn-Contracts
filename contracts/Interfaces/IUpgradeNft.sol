// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./IBedroomNft.sol";

/// @title Interface of the Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
interface IUpgradeNft is IERC1155 {
    /// @notice Upgrade Specifications
    struct UpgradeSpecifications {
        uint256 bedroomNftId;
        uint64 data;
        bool isUsed;
        address owner;
    }

    /// @notice Upgrade NFT Minting Event
    event UpgradeNftMinting(
        address indexed owner,
        uint256 tokenId,
        uint256 designId,
        uint16 level, 
        uint16 levelMin, 
        uint16 data,
        uint8 attributeIndex, 
        uint8 valueToAdd,
        uint8 typeNft
    );

    /// @notice Upgrade Nft linked
    event UpgradeNftLinked(
        address indexed owner,
        uint256 upgradeNftId,
        uint256 bedroomNftId
    );

    /// @notice Upgrade Nft unlinked
    event UpgradeNftUnlinked(
        address indexed owner,
        uint256 upgradeNftId,
        uint256 bedroomNftId
    );

    /// @notice Returns the  data of a NFT
    /// @param _tokenId NFT ID
    /// @return _bedroomNftId NFT ID
    /// @return _level NFT level
    /// @return _levelMin NFT level min required
    /// @return _data NFT additionnal data
    /// @return _attributeIndex Score attribute index
    /// @return _valueToAdd Value to add to the score
    /// @return _typeNft NFT Type 
    /// @return _isUsed Is linked to a Bedroom NFT
    /// @return _owner NFT Owner
    function getNftData(uint256 _tokenId) 
        external 
        view 
        returns (
            uint256 _bedroomNftId,
            uint16 _level, 
            uint16 _levelMin, 
            uint16 _data,
            uint8 _attributeIndex, 
            uint8 _valueToAdd,
            uint8 _typeNft,
            bool _isUsed,
            address _owner
    );

    /// @notice Links an upgrade Nft to a bedroom Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract or Owner
    function linkUpgradeNft(
        uint256 _upgradeNftId,
        uint256 _bedroomNftId,
        uint256 _newDesignId,
        address _owner
    ) external;

    /// @notice Unlinks an upgrade Nft to a bedroom Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _owner Owner of the NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    /// @dev This function can only be called by Dex Contract
    function unlinkUpgradeNft(
        uint256 _upgradeNftId,
        address _owner,
        uint256 _newDesignId
    ) external;

    /// @notice Settles File format
    /// @param _format New file format
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

    /// @notice Mints an Upgrade Nft
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _account Upgrade Nft Owner
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner or the dev Wallet
    function mint(
        uint256 _amount,
        uint256 _designId,
        address _account, 
        uint64 _level,
        uint64 _levelMin,
        uint64 _attributeIndex,
        uint64 _valueToAdd,
        uint64 _typeNft,
        uint64 _data
    )
        external;

    /// @notice Mints Upgrade Nfts per batch
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _accounts Upgrade Nft Owner
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner or the dev Wallet
    function mintBatch(
        uint256 _amount,
        uint256 _designId,
        address[] memory _accounts, 
        uint64 _level,
        uint64 _levelMin,
        uint64 _attributeIndex,
        uint64 _valueToAdd,
        uint64 _typeNft,
        uint64 _data
    )
        external;
    
    /// @notice Transfers an Upgrade Nft
    /// @param _tokenId Id of the NFT
    /// @param _newOwner Receiver address 
    function transferUpgradeNft(uint256 _tokenId, address _newOwner) external;

    /// @notice TransferOwnership
    /// @param _newOwner New Owner address
    function transferOwnership(address _newOwner) external;
}
