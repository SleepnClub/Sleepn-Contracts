// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./BedroomNft.sol";

/// @title Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
contract UpgradeNft is ERC1155, Ownable, ERC1155URIStorage {
    /// @dev Dex Contract address
    address public immutable dexAddress;

    /// @dev Dev Wallet
    address private immutable devWallet;

    /// @dev Bedroom NFT Contract address
    BedroomNft public immutable bedroomNftInstance;

    /// @notice Upgrade Specifications
    struct UpgradeSpecifications {
        uint256 bedroomNftId;
        uint64 data;
        bool isUsed;
        address owner;
    }

    /// @dev File format
    string private fileFormat;

    /// @notice Number of NFT
    uint256 public tokenId;

    /// @dev Maps the Upgrade NFT specifications to an NFT ID
    mapping(uint256 => UpgradeSpecifications)
        private tokenIdToUpgradeSpecifications;

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

    /// @dev Constructor
    constructor(
        address _dexAddress, 
        address _devWallet
    ) ERC1155("") {
        tokenId = 0;
        fileFormat = ".png";
        dexAddress = _dexAddress;
        devWallet = _devWallet;
        bedroomNftInstance = BedroomNft(msg.sender);
    }

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
    ) {
        UpgradeSpecifications memory spec = tokenIdToUpgradeSpecifications[_tokenId];
        _bedroomNftId = spec.bedroomNftId;
        _level = uint16(spec.data);
        _levelMin = uint16(spec.data >> 16); 
        _data = uint16(spec.data >> 32);
        _attributeIndex = uint8(spec.data >> 40); 
        _valueToAdd = uint8(spec.data >> 48);
        _typeNft = uint8(spec.data >> 56);
        _isUsed = spec.isUsed;
        _owner = spec.owner;
    }

    /// @notice Settles File format
    /// @param _format New file format
    /// @dev This function can only be called by the owner of the contract
    function setFileFormat(string memory _format) external onlyOwner {
        fileFormat = _format;
    }

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
    ) external {
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");

        // Get Upgrade NFT Informations
        UpgradeSpecifications memory upgradeNft = tokenIdToUpgradeSpecifications[_upgradeNftId];

        require(upgradeNft.owner == _owner && bedroomNftInstance.getNftsOwner(_bedroomNftId) == _owner, "Wrong owner");
        require(upgradeNft.isUsed == false, "Nft already linked");
        require(uint16(upgradeNft.data >> 16) <= bedroomNftInstance.getNftsLevel(_bedroomNftId), "Level too low"); 

        if (uint8(upgradeNft.data >> 56) == 0) {
            bedroomNftInstance.updateScores(
                _bedroomNftId,
                uint8(upgradeNft.data >> 40),
                _newDesignId,
                balanceOf(_owner, _upgradeNftId), 
                uint16(upgradeNft.data),
                uint8(upgradeNft.data >> 48),
                true  
            );
        } else if (uint8(upgradeNft.data >> 56) == 1) {
            bedroomNftInstance.updateLevel(
                _bedroomNftId, 
                uint16(upgradeNft.data),
                true 
            );
        } else if (uint8(upgradeNft.data >> 56) == 2) {
            bedroomNftInstance.updateDesign(
                _bedroomNftId, 
                _newDesignId,
                balanceOf(_owner, _upgradeNftId), 
                uint16(upgradeNft.data),
                true
            );
        }
        
        tokenIdToUpgradeSpecifications[_upgradeNftId].bedroomNftId = _bedroomNftId;
        tokenIdToUpgradeSpecifications[_upgradeNftId].isUsed = true;

        emit UpgradeNftLinked(_owner, _upgradeNftId, _bedroomNftId);
    }

    /// @notice Unlinks an upgrade Nft to a bedroom Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _owner Owner of the NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    /// @dev This function can only be called by Dex Contract
    function unlinkUpgradeNft(
        uint256 _upgradeNftId,
        address _owner,
        uint256 _newDesignId
    ) external {
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");

        // Get Upgrade NFT Informations
        UpgradeSpecifications memory upgradeNft = tokenIdToUpgradeSpecifications[_upgradeNftId];

        require(upgradeNft.isUsed == true, "Nft not linked");
        require(_owner == upgradeNft.owner, "Wrong owner");

        uint256 bedroomNftId = upgradeNft.bedroomNftId;

        if (uint8(upgradeNft.data >> 56) == 0) {
            bedroomNftInstance.updateScores(
                bedroomNftId,
                uint8(upgradeNft.data >> 40),
                _newDesignId,
                balanceOf(_owner, _upgradeNftId), 
                uint16(upgradeNft.data),
                uint8(upgradeNft.data >> 48),
                false 
            );
        } else if (uint8(upgradeNft.data >> 56) == 1) {
            bedroomNftInstance.updateLevel(
                bedroomNftId, 
                uint16(upgradeNft.data),
                false 
            );
        } else if (uint8(upgradeNft.data >> 56) == 2) {
            bedroomNftInstance.updateDesign(
                bedroomNftId, 
                _newDesignId,
                balanceOf(_owner, _upgradeNftId), 
                uint16(upgradeNft.data),
                false 
            );
        }

        emit UpgradeNftUnlinked(
            tokenIdToUpgradeSpecifications[_upgradeNftId].owner, 
            _upgradeNftId, 
            tokenIdToUpgradeSpecifications[_upgradeNftId].bedroomNftId
        );

        tokenIdToUpgradeSpecifications[_upgradeNftId].isUsed = false;
        tokenIdToUpgradeSpecifications[_upgradeNftId].bedroomNftId = 0;
    } 

    /// @notice Gets the name of a NFT
    /// @param _tokenId Id of the NFT
    /// @return _name Name of the NFT
    function getName(uint256 _tokenId) external pure returns (string memory) {
        return string(abi.encodePacked("Token #", Strings.toString(_tokenId)));
    }

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
        external
    {
        require(
            msg.sender == owner() || msg.sender == dexAddress,
            "Access Forbidden"
        );

        tokenIdToUpgradeSpecifications[tokenId] = UpgradeSpecifications(
            0,
            _level + (_levelMin << 16) + (_data << 32) + (_attributeIndex << 40) + (_valueToAdd << 48) + (_typeNft << 56),
            false,
           _account
        );

        _mint(_account, tokenId, _amount, "");

        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(
                    _designId
                ),
                fileFormat
            )
        );

        _setURI(tokenId, DesignName);

        emit UpgradeNftMinting(
            _account,
            tokenId,
            _designId,
            uint16(_level), 
            uint16(_levelMin), 
            uint16(_data),
            uint8(_attributeIndex), 
            uint8(_valueToAdd),
            uint8(_typeNft)
        );

        ++tokenId;
    }

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
        external
    {   
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );

        for(uint256 i = 0; i < _accounts.length; i++) {
            // Specifications
            tokenIdToUpgradeSpecifications[tokenId] = UpgradeSpecifications(
                0,
                _level + (_levelMin << 16) + (_data << 32) + (_attributeIndex << 40) + (_valueToAdd << 48) + (_typeNft << 56),
                false,
                _accounts[i]
            );

            // Mints a Nft
            _mint(_accounts[i], tokenId, _amount, "");

            // Settles Metadata
            string memory DesignName = string(
                abi.encodePacked(
                    Strings.toString(
                        _designId
                    ),
                    fileFormat
                )
            );
            _setURI(tokenId, DesignName);

            emit UpgradeNftMinting(
                _accounts[i],
                tokenId,
                _designId,
                uint16(_level), 
                uint16(_levelMin), 
                uint16(_data),
                uint8(_attributeIndex), 
                uint8(_valueToAdd),
                uint8(_typeNft)
            );

            // Increases Id 
            ++tokenId;
        }
        
    }

    /// @notice Returns the concatenation of the _baseURI and the token-specific uri if the latter is set
    /// @param _tokenId Id of the NFT
    function uri(uint256 _tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
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

    /// @notice Transfers an Upgrade Nft
    /// @param _tokenId Id of the NFT
    /// @param _newOwner Receiver address 
    function transferUpgradeNft(uint256 _tokenId, address _newOwner) external {
        UpgradeSpecifications memory spec = tokenIdToUpgradeSpecifications[_tokenId];
        require(spec.owner == msg.sender, "Access Forbidden");
        spec.owner = _newOwner;
        _safeTransferFrom(msg.sender, _newOwner, _tokenId, balanceOf(msg.sender, _tokenId), "");
    }
}
