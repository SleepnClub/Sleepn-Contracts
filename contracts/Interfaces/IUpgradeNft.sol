// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IBedroomNft.sol";

/// @title Interface of the Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
interface IUpgradeNft is IERC1155 {
    //// @notice Upgrade NFT Minted Event
    event UpgradeNftMinted(
        address indexed owner, uint256 tokenId, uint256 amount
    );
    /// @notice Upgrade NFT Data Settled Event
    event UpgradeNftDataSettled(
        uint256 indexed tokenId,
        string _designURI,
        uint24 _data,
        uint16 _level,
        uint16 _levelMin,
        uint16 _value,
        uint8 _attributeIndex,
        uint8 _valueToAdd,
        uint8 _typeNft
    );
    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed owner, uint256 amount);

    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);
    /// @notice Different Length Error - Arrays length
    error DifferentLength();
    /// @notice Upgrade Nft already linked Error - Upgrade NFTs have to be unlinked before any transfer
    error UpgradeNftAlreadyLinked(uint256 tokenId);
    /// @notice State not updated Error - State is not updated in tracker contract
    error StateNotUpdated();

    /// @notice Returns the  data of a NFT
    /// @param _tokenId NFT ID
    /// @return _data NFT additionnal data
    /// @return _level NFT level
    /// @return _levelMin NFT level min required
    /// @return _value NFT value
    /// @return _attributeIndex Score attribute index
    /// @return _valueToAdd Value to add to the score
    /// @return _typeNft NFT Type
    function getData(uint256 _tokenId)
        external
        view
        returns (
            uint24 _data,
            uint16 _level,
            uint16 _levelMin,
            uint16 _value,
            uint8 _attributeIndex,
            uint8 _valueToAdd,
            uint8 _typeNft
        );

    /// @notice Settles the URI of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _tokenURI Uri of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    /// @notice Settles baseURI as the _baseURI for all tokens
    /// @param _baseURI Base URI of NFTs
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;

    /// @notice Settles dev wallet address
    /// @param _newDevWalletAddress New dev wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _newDevWalletAddress) external;

    /// @notice Settles the data of a NFT
    /// @param _tokenId NFT ID
    /// @param _designURI Upgrade Nft URI
    /// @param _data Additionnal data (optionnal)
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _value Upgrade Nft value
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type
    /// @dev This function can only be called by the owner or the dev Wallet
    function setData(
        uint256 _tokenId,
        string memory _designURI,
        uint96 _data,
        uint96 _level,
        uint96 _levelMin,
        uint96 _value,
        uint96 _attributeIndex,
        uint96 _valueToAdd,
        uint96 _typeNft
    ) external;

    /// @notice Mints a new Upgrade Nft
    /// @param _tokenId NFT ID
    /// @param _amount Amount of tokens
    /// @param _account Upgrade Nft Owner
    /// @dev This function can only be called by the owner or the dev Wallet or the Dex contract
    function mint(uint256 _tokenId, uint256 _amount, address _account)
        external;

    /// @notice Mints Upgrade Nfts per batch
    /// @param _tokenIds NFT IDs
    /// @param _amounts Amount of tokens
    /// @param _accounts Upgrade Nft Owners
    /// @dev This function can only be called by the owner or the dev Wallet or the Dex contract
    function mintBatch(
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        address[] calldata _accounts
    ) external;

    /// @notice Withdraws the money from the contract
    /// @param _token Address of the token to withdraw
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney(IERC20 _token) external;
}
