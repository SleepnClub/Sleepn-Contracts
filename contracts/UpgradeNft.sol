// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../../Interfaces/ISleepToken.sol";
import "../../Interfaces/IBedroomNft.sol";

/// @title Upgrade Nft Contract
/// @author Sleepn
/// @notice An update NFT is used to upgrade a Bedroom NFT
contract UpgradeNft is ERC1155, Ownable, ERC1155URIStorage {
    /// @dev Dex Contract address
    address private dexAddress;

    /// @dev Dev Wallet
    address private devWallet;

    /// @dev Bedroom NFT Contract address
    IBedroomNft private bedroomNftInstance;

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

    /// @dev Constructor
    constructor(
    ) ERC1155("") {
        tokenId = 0;
        fileFormat = ".json";
    }

    /// @notice Settles contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _devWallet Address of the Dev Wallet
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, address _devWallet, IBedroomNft _bedroomNft)
        external
        onlyOwner
    {
        dexAddress = _dexAddress;
        devWallet = _devWallet;
        bedroomNftInstance = _bedroomNft;
        assert(dexAddress != address(0));
        assert(devWallet != address(0));
        assert(address(bedroomNftInstance) != address(0));
    }

    /// @notice Returns informations about a NFT
    /// @param _tokenId The id of the NFT
    /// @return _infos Informations about the NFT
    function getUpgradeNftSpecifications(uint256 _tokenId)
        external
        view
        returns (UpgradeSpecifications memory)
    {
        return tokenIdToUpgradeSpecifications[_tokenId];
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
        assert(address(bedroomNftInstance) != address(0));
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");

        // Get Bedroom NFT informations
        IBedroomNft.NftSpecifications memory nftSpecifications = bedroomNftInstance
            .getNftSpecifications(_bedroomNftId);

        require(tokenIdToUpgradeSpecifications[_upgradeNftId].owner == _owner && nftSpecifications.owner == _owner, "Wrong owner");
        require(tokenIdToUpgradeSpecifications[_upgradeNftId].isUsed == false, "Nft already linked");
        require(tokenIdToUpgradeSpecifications[_upgradeNftId].levelMin <= nftSpecifications.level, "Level too low"); 

        if (tokenIdToUpgradeSpecifications[_upgradeNftId].attributeValue > 0) {
            bedroomNftInstance.updateBedroomNft(
                _bedroomNftId,
                tokenIdToUpgradeSpecifications[_upgradeNftId].attributeIndex,
                tokenIdToUpgradeSpecifications[_upgradeNftId].attributeValue,
                _newDesignId,
                balanceOf(_owner, _upgradeNftId),
                tokenIdToUpgradeSpecifications[_upgradeNftId].levelToAdd,
                1
            );
        } else {
            bedroomNftInstance.updateBedroomNft(
                _bedroomNftId,
                0,
                0,
                _newDesignId,
                balanceOf(_owner, _upgradeNftId),
                tokenIdToUpgradeSpecifications[_upgradeNftId].levelToAdd,
                3
            );
        }

        tokenIdToUpgradeSpecifications[_upgradeNftId].owner = _owner;
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
        assert(address(bedroomNftInstance) != address(0));
        assert(address(dexAddress) != address(0));
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");

        // Get Bedroom NFT informations
        uint256 id = tokenIdToUpgradeSpecifications[_upgradeNftId].bedroomNftId;
        IBedroomNft.NftSpecifications memory nftSpecifications = bedroomNftInstance
            .getNftSpecifications(id);

        require(tokenIdToUpgradeSpecifications[_upgradeNftId].isUsed == true, "Nft not linked");
        require(_owner == tokenIdToUpgradeSpecifications[_upgradeNftId].owner && nftSpecifications.owner == _owner, "Wrong owner");

        if (tokenIdToUpgradeSpecifications[_upgradeNftId].attributeValue > 0) {
            bedroomNftInstance.updateBedroomNft(
                id,
                tokenIdToUpgradeSpecifications[_upgradeNftId].attributeIndex,
                tokenIdToUpgradeSpecifications[_upgradeNftId].attributeValue,
                _newDesignId,
                balanceOf(_owner, _upgradeNftId),
                tokenIdToUpgradeSpecifications[_upgradeNftId].levelToAdd,
                2
            );
        } else {
            bedroomNftInstance.updateBedroomNft(
                id,
                0,
                0,
                _newDesignId,
                balanceOf(_owner, _upgradeNftId),
                tokenIdToUpgradeSpecifications[_upgradeNftId].levelToAdd,
                4
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
        external
    {
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );

        tokenIdToUpgradeSpecifications[tokenId] = UpgradeSpecifications(
            _account,
            0,
            _attribute,
            _value,
            _levelToAdd,
            _levelMin,
            false
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
            uri(tokenId),
            tokenIdToUpgradeSpecifications[tokenId]
        );

        tokenId++;
    }

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
        external
    {   
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );
        require(_amounts.length == _attributes.length, "ERC1155: amounts and attributes length mismatch");
        require(_attributes.length == _values.length, "ERC1155: attributes and values length mismatch");

        for(uint256 i = 0; i < _amounts.length; i++) {
            uint256 amount = _amounts[i];
            uint256 attribute = _attributes[i];
            uint256 value = _values[i];
            uint256 designId = _designIds[i];
            uint256 level = _levels[i];
            uint256 levelMin = _levelsMin[i];

            // Specifications
            tokenIdToUpgradeSpecifications[tokenId] = UpgradeSpecifications(
                dexAddress,
                0,
                attribute,
                value,
                level,
                levelMin,
                false
            );

            // Mints a Nft
            _mint(dexAddress, tokenId, amount, "");

            // Settles Metadata
            string memory DesignName = string(
                abi.encodePacked(
                    Strings.toString(
                        designId
                    ),
                    fileFormat
                )
            );
            _setURI(tokenId, DesignName);

            emit UpgradeNftMinting(
                dexAddress,
                tokenId,
                uri(tokenId),
                tokenIdToUpgradeSpecifications[tokenId]
            );

            // Increases Id 
            tokenId++;
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
        require(tokenIdToUpgradeSpecifications[_tokenId].owner == msg.sender, "Access Forbidden");
        tokenIdToUpgradeSpecifications[_tokenId].owner = _newOwner;
        _safeTransferFrom(msg.sender, _newOwner, _tokenId, balanceOf(msg.sender, _tokenId), "");
    }
}
