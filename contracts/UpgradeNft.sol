// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "./Interfaces/ISleepToken.sol";
import "./Interfaces/IBedroomNft.sol";

/// @title Upgrade Nft Contract
/// @author Alexis Balayre
/// @notice An update NFT is used to upgrade a Bedroom NFT
contract UpgradeNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155URIStorage {
    /// @notice Dex Contract address
    address public dexAddress;

    /// @notice Bedroom NFT Contract address
    IBedroomNft public bedroomNftInstance;

    /// @notice Chainlink VRF Variables
    VRFCoordinatorV2Interface public immutable COORDINATOR;
    uint32 private numWords;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint64 private subscriptionId;
    bytes32 private keyHash;

    /// @notice Upgrade Specifications
    struct UpgradeSpecifications {
        uint256 attributeIndex;
        uint256 valueToAdd;
        uint256 valueToAddMax;
        address owner;
        uint256 price;
        uint256 newDesignId;
        uint256 upgradeDesignId;
    }

    /// @notice File format
    string public fileFormat;

    /// @notice Number of NFT
    uint256 public tokenId;

    /// @notice Maps an NFT ID to a Chainlink VRF Request ID
    mapping(uint256 => uint256) private requestIdToTokenId;

    /// @notice Maps the Upgrade NFT specifications to an NFT ID
    mapping(uint256 => UpgradeSpecifications)
        private tokenIdToUpgradeSpecifications;

    /// @notice Upgrade NFT Minting Event
    event UpgradeNftMinting(
        uint256 tokenId,
        string tokenURI,
        UpgradeSpecifications specifications
    );

    /// @notice Returned Random Numbers Event
    event ReturnedRandomness(uint256[] randomWords);

    /// @dev Constructor
    /// @param _subscriptionId Chainlink VRF Id Subscription
    /// @param _vrfCoordinator Address of the Coordinator Contract
    /// @param _keyHash Chainlink VRF key hash
    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) ERC1155("") VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = 50000;
        requestConfirmations = 3;
        numWords = 1;
        tokenId = 0;
    }

    /// @notice Settles contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, IBedroomNft _bedroomNft)
        external
        onlyOwner
    {
        dexAddress = _dexAddress;
        bedroomNftInstance = _bedroomNft;
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
    ) external onlyOwner {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
    }

    /// @notice Settles File format
    /// @param _format New file format
    /// @dev This function can only be called by the owner of the contract
    function setFileFormat(string memory _format) external onlyOwner {
        fileFormat = _format;
    }

    /// @notice Launches the procedure to create an NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    /// @param _upgradeDesignId Design Id of the Upgrade NFT
    /// @param _price Price of the Upgrade NFT
    /// @param _indexAttribute Index of the Bedroom NFT attribute to upgrade
    /// @param _valueToAddMax Value Max to add to the score of desired Bedroom NFT attribute
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
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

    /// Gets the name of a NFT
    /// @param _tokenId Id of the NFT
    /// @return _name Name of the NFT
    function getName(uint256 _tokenId) external pure returns (string memory) {
        return string(abi.encodePacked("Token #", Strings.toString(_tokenId)));
    }

    /// @dev Callback function with the requested random numbers
    /// @param requestId Chainlink VRF Random Number Request Id
    /// @param randomWords List of random words
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        _mintingUpgradeNft(requestIdToTokenId[requestId], randomWords);
        emit ReturnedRandomness(randomWords);
    }

    /// @dev Mints a new Upgrade NFT
    /// @param _tokenId Id of the NFT
    /// @param _randomWords List of random words
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

    /// Settles baseURI as the _baseURI for all tokens
    /// @param _baseURI Base URI of NFTs
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }
}
