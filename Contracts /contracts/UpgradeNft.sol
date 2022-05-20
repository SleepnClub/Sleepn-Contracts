// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./Interfaces/ISleepToken.sol";
import "./Interfaces/IBedroomNft.sol";
import "./Utils/VRFConsumerBaseV2Upgradable.sol";

/// @title Upgrade Nft Contract
/// @author Alexis Balayre
contract UpgradeNft is
    Initializable,
    VRFConsumerBaseV2Upgradable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155URIStorageUpgradeable
{
    // Dex Address
    address public dexAddress;

    // bedroomNft Contract
    IBedroomNft public bedroomNftInstance;

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private COORDINATOR;
    LinkTokenInterface private LINKTOKEN;
    uint32 private numWords;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint64 private subscriptionId;
    bytes32 private keyHash;

    // Upgrade Specifications
    struct UpgradeSpecifications {
        uint256 attributeIndex;
        uint256 valueToAdd;
        uint256 valueToAddMax;
        address owner;
        uint256 price;
        uint256 newDesignId;
        uint256 upgradeDesignId;
    }

    // File format
    string public fileFormat;

    // Number of NFT
    uint256 public tokenId;

    // Mappings
    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(uint256 => UpgradeSpecifications)
        public tokenIdToUpgradeSpecifications;

    // Events
    event UpgradeNftMinting(
        uint256 tokenId,
        string tokenURI,
        UpgradeSpecifications specifications
    );
    event ReturnedRandomness(uint256[] randomWords);

    function initialize(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        address _link_token_contract,
        bytes32 _keyHash,
        IBedroomNft _bedroomNftAddress
    ) public initializer {
        __ERC1155_init("");
        __Ownable_init();
        __VrfCoordinator_init(_vrfCoordinator);

        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(_link_token_contract);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = 200000;
        requestConfirmations = 3;
        numWords = 1;
        tokenId = 0;
        bedroomNftInstance = _bedroomNftAddress;
    }

    // set Dex address
    function setDex(address _dexAddress) external onlyOwner {
        dexAddress = _dexAddress;
    }

    // update chainlink
    function updateChainlink(
        uint32 _callbackGasLimit,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) external onlyOwner {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
    }

    // Set file format
    function setFileFormat(string memory _format) external onlyOwner {
        fileFormat = _format;
    }

    // This function is creating a new random Upgrade NFT by generating a random number
    function mintingUpgradeNft(
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _price,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        address _owner
    ) external {
        require(dexAddress != address(0), "dex address is not configured");
        require(msg.sender == dexAddress, "Access forbidden");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIdToTokenId[requestId] = tokenId;

        tokenIdToUpgradeSpecifications[tokenId] = UpgradeSpecifications(
            _indexAttribute,
            0,
            _valueToAddMax,
            _owner,
            _price,
            _newDesignId,
            _upgradeDesignId
        );

        // Index of next NFT
        tokenId++;
    }

    // Get Token Name
    function getName(uint256 _tokenId) external pure returns (string memory) {
        return string(abi.encodePacked("Token #", Strings.toString(_tokenId)));
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        _mintingUpgradeNft(requestIdToTokenId[requestId], randomWords);
        emit ReturnedRandomness(randomWords);
    }

    function _mintingUpgradeNft(uint256 _tokenId, uint256[] memory _randomWords)
        internal
    {
        // Create new random upgrade
        tokenIdToUpgradeSpecifications[_tokenId].valueToAdd =
            (_randomWords[0] %
                tokenIdToUpgradeSpecifications[_tokenId].valueToAddMax) +
            1;

        // Minting of the new Bedroom NFT
        _mint(tokenIdToUpgradeSpecifications[tokenId].owner, _tokenId, 1, "");

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(
                    tokenIdToUpgradeSpecifications[_tokenId].upgradeDesignId
                ),
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        // Upgrading of BedroomNft
        require(
            address(bedroomNftInstance) != address(0),
            "BedroomNftInstance not initialized"
        );
        bedroomNftInstance.upgradeBedroomNft(
            _tokenId,
            tokenIdToUpgradeSpecifications[_tokenId].attributeIndex,
            tokenIdToUpgradeSpecifications[_tokenId].valueToAdd,
            tokenIdToUpgradeSpecifications[_tokenId].newDesignId,
            tokenIdToUpgradeSpecifications[_tokenId].price
        );

        emit UpgradeNftMinting(
            _tokenId,
            uri(_tokenId),
            tokenIdToUpgradeSpecifications[_tokenId]
        );
    }

    // This implementation returns the concatenation of the _baseURI and the token-specific uri if the latter is set
    function uri(uint256 _tokenId)
        public
        view
        override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)
        returns (string memory)
    {
        return super.uri(_tokenId);
    }

    // Sets tokenURI as the tokenURI of tokenId.
    function setTokenURI(uint256 _tokenId, string memory _tokenURI)
        external
        onlyOwner
    {
        _setURI(_tokenId, _tokenURI);
    }

    // Sets baseURI as the _baseURI for all tokens
    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }
}
