// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../Interfaces/ITracker.sol";

import "./BedroomNft.sol";
import "../Utils/Upgrader.sol";

/// @title Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
contract UpgradeNft is ERC1155, Ownable, ERC1155URIStorage, ERC1155Supply {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    /// @dev Dex Contract address
    address public immutable dexAddress;

    /// @dev Dev Wallet
    address private devWallet;

    /// @dev Bedroom NFT Contract address
    BedroomNft public immutable bedroomNftInstance;

    /// @dev Tracker Contract address
    ITracker public immutable trackerInstance;

    /// @dev Upgrader Contract address
    Upgrader public immutable upgraderInstance;

    /// @dev Maps the Upgrade NFT Data to an NFT ID
    mapping(uint256 => uint96) private tokenIdToUpgradeNftData;

    /// @notice Upgrade NFT Minted Event
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

    /// @dev Constructor
    constructor(address _dexAddress, address _devWallet) ERC1155("") {
        dexAddress = _dexAddress;
        devWallet = _devWallet;
        bedroomNftInstance = BedroomNft(msg.sender);

        // Deploys Tracker and Upgrader contracts
        upgraderInstance = new Upgrader(
            msg.sender,
            _dexAddress
        );

        trackerInstance = ITracker(address(upgraderInstance.trackerInstance()));
    }

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
        )
    {
        uint96 data = tokenIdToUpgradeNftData[_tokenId];
        _data = uint24(data);
        _level = uint16(data >> 24);
        _levelMin = uint16(data >> 40);
        _value = uint16(data >> 56);
        _attributeIndex = uint8(data >> 64);
        _valueToAdd = uint8(data >> 72);
        _typeNft = uint8(data >> 80);
    }

    /// @notice Returns the concatenation of the _baseURI and the token-specific uri if the latter is set
    /// @param _tokenId Id of the NFT
    function uri(uint256 _tokenId)
        public
        view
        override (ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(_tokenId);
    }

    /// @notice Settles the URI of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _tokenURI Uri of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
        onlyOwner
    {
        _setURI(_tokenId, _tokenURI);
    }

    /// @notice Settles baseURI as the _baseURI for all tokens
    /// @param _baseURI Base URI of NFTs
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    /// @notice Settles dev wallet address
    /// @param _newDevWalletAddress New dev wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _newDevWalletAddress) external onlyOwner {
        devWallet = _newDevWalletAddress;
    }

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
    ) external {
        if (msg.sender != owner() && msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        tokenIdToUpgradeNftData[_tokenId] = _data + (_level << 24)
            + (_levelMin << 40) + (_value << 56) + (_attributeIndex << 64)
            + (_valueToAdd << 72) + (_typeNft << 80);
        _setURI(_tokenId, _designURI);
        trackerInstance.settleUpgradeNftData(_tokenId);
        emit UpgradeNftDataSettled(
            _tokenId,
            _designURI,
            uint24(_data),
            uint16(_level),
            uint16(_levelMin),
            uint16(_value),
            uint8(_attributeIndex),
            uint8(_valueToAdd),
            uint8(_typeNft)
            );
    }

    /// @notice Withdraws the money from the contract
    /// @param _token Address of the token to withdraw
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney(IERC20 _token) external {
        if (msg.sender != owner()) {
            revert RestrictedAccess(msg.sender);
        }
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(msg.sender, balance);
        emit WithdrawMoney(msg.sender, balance);
    }

    /// @notice Mints a new Upgrade Nft
    /// @param _tokenId NFT ID
    /// @param _amount Amount of tokens
    /// @param _account Upgrade Nft Owner
    /// @dev This function can only be called by the owner or the dev Wallet or the Dex contract
    function mint(uint256 _tokenId, uint256 _amount, address _account)
        external
    {
        if (
            msg.sender != owner() && msg.sender != dexAddress
                && msg.sender != devWallet
        ) {
            revert RestrictedAccess(msg.sender);
        }
        if (!trackerInstance.addUpgradeNft(_account, _tokenId, _amount)) {
            revert StateNotUpdated();
        }
        _mint(_account, _tokenId, _amount, "");
        emit UpgradeNftMinted(_account, _tokenId, _amount);
    }

    /// @notice Mints Upgrade Nfts per batch
    /// @param _tokenIds NFT IDs
    /// @param _amounts Amount of tokens
    /// @param _accounts Upgrade Nft Owners
    /// @dev This function can only be called by the owner or the dev Wallet or the Dex contract
    function mintBatch(
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        address[] calldata _accounts
    ) external {
        if (
            msg.sender != owner() && msg.sender != dexAddress
                && msg.sender != devWallet
        ) {
            revert RestrictedAccess(msg.sender);
        }
        if (
            _tokenIds.length != _amounts.length
                && _amounts.length != _accounts.length
        ) {
            revert DifferentLength();
        }
        for (uint256 i = 0; i < _accounts.length; ++i) {
            // Mints a Nft
            if (!trackerInstance.addUpgradeNft(_accounts[i], _tokenIds[i], _amounts[i])) {
                revert StateNotUpdated();
            }
            _mint(_accounts[i], _tokenIds[i], _amounts[i], "");
            emit UpgradeNftMinted(_accounts[i], _tokenIds[i], _amounts[i]);
        }
    }

    /// @notice Safe Transfer From
    /// @param _from Owner address
    /// @param _to Receiver address
    /// @param _id NFT Id
    /// @param _amount Amount to mint
    /// @param _data Data
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal virtual override {
        (uint256 amountOwned, uint256 amountUsed) =
            trackerInstance.getUpgradeNftAmounts(_from, _id);
        if (_amount > amountOwned - amountUsed) {
            revert UpgradeNftAlreadyLinked(_id);
        }
        if (!trackerInstance.removeUpgradeNft(_from, _id, _amount)) {
            revert StateNotUpdated();
        }
        if (!trackerInstance.addUpgradeNft(_to, _id, _amount)) {
            revert StateNotUpdated();
        }
        super._safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    /// @notice Safe Batch Transfer From
    /// @param _from Owner address
    /// @param _to Receiver address
    /// @param _ids NFT Ids
    /// @param _amounts Amounts to mint
    /// @param _data Data
    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal virtual override {
        for (uint256 i = 0; i < _ids.length; ++i) {
            (uint256 amountOwned, uint256 amountUsed) =
                trackerInstance.getUpgradeNftAmounts(_from, _ids[i]);
            if (_amounts[i] > amountOwned - amountUsed) {
                revert UpgradeNftAlreadyLinked(_ids[i]);
            }
            if (!trackerInstance.removeUpgradeNft(_from, _ids[i], _amounts[i])) {
                revert StateNotUpdated();
            }
            if (!trackerInstance.addUpgradeNft(_to, _ids[i], _amounts[i])) {
                revert StateNotUpdated();
            }
        }
        super._safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }

    /// @notice Before token transfer hook
    /// @param _operator Operator address
    /// @param _from Owner address
    /// @param _to Receiver address
    /// @param _ids NFT Ids
    /// @param _amounts Amounts to mint
    /// @param _data Data
    function _beforeTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal override (ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(
            _operator, _from, _to, _ids, _amounts, _data
        );
    }
}
