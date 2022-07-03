// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./IBedroomNft.sol";

/// @title Interface of the Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
interface IUpgradeNft is IERC1155Upgradeable {
    /// @notice Upgrade Specifications
    struct UpgradeSpecifications {
        address owner;
        uint256 bedroomNftId;
        uint256 attributeIndex;
        uint256 attributeValue;
        uint256 levelToAdd;
        uint256 levelMin;
        bool isUsed;
    }

    /// @notice Upgrade NFT Minting Event
    event UpgradeNftMinting(
        address indexed owner,
        uint256 tokenId,
        string tokenURI,
        UpgradeSpecifications specifications
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

    /// @notice Settles contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _devWallet Address of the Dev Wallet
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, address _devWallet, IBedroomNft _bedroomNft)
        external;

    /// @notice Returns informations about a NFT
    /// @param _tokenId The id of the NFT
    /// @return _nftSpecifications Informations about the NFT
    function getUpgradeNftSpecifications(uint256 _tokenId)
        external
        view
        returns (UpgradeSpecifications memory _nftSpecifications);

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
    /// @param _account Upgrade Nft Owner
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _attribute Score involved (optionnal)
    /// @param _value Value to add to the score (optionnal)
    /// @param _levelToAdd Level to add to the Bedroom Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _levelMin Bedroom Nft Level min required
    /// @dev This function can only be called by the owner or the dev Wallet
    function mint(
        address _account, 
        uint256 _amount,
        uint256 _attribute, 
        uint256 _value,
        uint256 _levelToAdd,
        uint256 _designId,
        uint256 _levelMin
    )
        external;

    /// @notice Mints Upgrade Nfts per batch
    /// @param _amounts Amount of tokens to add to the Upgrade Nft
    /// @param _attributes Score involved (optionnal)
    /// @param _values Value to add to the score (optionnal)
    /// @param _levels Level to add to the Bedroom Nft
    /// @param _designIds Upgrade Nft URI 
    /// @param _levelsMin Bedroom Nft Level min required
    /// @dev This function can only be called by the owner or the dev Wallet
    function mintBatch(
        uint256[] memory _amounts, 
        uint256[] memory _attributes, 
        uint256[] memory _values,
        uint256[] memory _levels,
        uint256[] memory _designIds,
        uint256[] memory _levelsMin
    )
        external;
    
    /// @notice Transfers an Upgrade Nft
    /// @param _tokenId Id of the NFT
    /// @param _newOwner Receiver address 
    function transferUpgradeNft(uint256 _tokenId, address _newOwner) external;
}
