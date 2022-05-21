// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./Interfaces/IUpgradeNft.sol";
import "./Utils/VRFConsumerBaseV2Upgradable.sol";

/// @title Bedroom NFT Contract
/// @author Alexis Balayre
/// @notice Bedroom NFT is the main NFT of GetSleepn app
contract BedroomNft is
    Initializable,
    VRFConsumerBaseV2Upgradable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155URIStorageUpgradeable
{
    /// @dev Dex Contract address
    address private dexAddress;

    /// @dev Upgrade NFT Contract address
    IUpgradeNft private upgradeNftInstance;

    /// @dev Chainlink VRF Variables
    VRFCoordinatorV2Interface private COORDINATOR;
    LinkTokenInterface private LINKTOKEN;
    uint32 private numWords;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint64 private subscriptionId;
    bytes32 private keyHash;

    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        uint256 lightIsolationScore; // Index 0
        uint256 bedroomThermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 temperatureScore; // Index 3
        uint256 humidityScore; // Index 4
        uint256 sleepAidMachinesScore; // Index 5
        uint256 circadianRhythmRegulation; // Index 6
        uint256 sizeScore; // Index 7
        uint256 heightScore; // Index 8
        uint256 bedBaseScore; // Index 9
        uint256 mattressTechnologyScore; // Index 10
        uint256 mattressThicknessScore; // Index 11
        uint256 mattressDeformationScore; // Index 12
        uint256 thermalIsolationScore; // Index 13
        uint256 hygrometricRegulationScore; // Index 14
        uint256 comforterComfortabilityScore; // Index 15
        uint256 pillowComfortabilityScore; // Index 16
    }

    /// @notice Enumeration of the different categories of a Bedroom NFT
    enum Category {
        Studio,
        Deluxe,
        Luxury
    }

    /// @notice Administration informations of a Bedroom NFT
    struct NftOwnership {
        address owner;
        uint256 price;
        uint256 designId;
        uint256 level;
        Category category;
    }

    /// @dev File format of NFT design files
    string private fileFormat;

    /// @dev Number of NFT
    uint256 private tokenId;

    /// @dev Maps Chainlink VRF Random Number Request Id to NFT Id
    mapping(uint256 => uint256) private requestIdToTokenId;

    /// @dev Maps NFT Scores to NFT Id
    mapping(uint256 => NftSpecifications) private tokenIdToNftSpecifications;

    /// @dev Maps NFT Informations to NFT Id
    mapping(uint256 => NftOwnership) private tokenIdToNftOwnership;

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinting(
        uint256 tokenId,
        string tokenURI,
        NftSpecifications specifications
    );

    /// @notice Emits an event when a Bedroom NFT is upgraded
    event BedroomNftUpgrading(
        uint256 tokenId,
        string newTokenURI,
        NftSpecifications specifications
    );
    event ReturnedRandomness(uint256[] randomWords);

    /// @dev Init function
    function initialize(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        address _link_token_contract,
        bytes32 _keyHash
    ) public initializer {
        __ERC1155_init("");
        __Ownable_init();
        __VrfCoordinator_init(_vrfCoordinator);

        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(_link_token_contract);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = 450000;
        requestConfirmations = 6;
        numWords = 17;
        tokenId = 0;
    }

    /// @notice Inits contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _upgradeNftAddress Address of the Upgrade NFT contract
    /// @dev This function can only be called by the owner of the contract
    function initContracts(address _dexAddress, IUpgradeNft _upgradeNftAddress)
        external
        onlyOwner
    {
        dexAddress = _dexAddress;
        upgradeNftInstance = _upgradeNftAddress;
    }

    function getNftOwnership(uint256 _tokenId)
        external
        view
        returns (NftOwnership memory)
    {
        return tokenIdToNftOwnership[_tokenId];
    }

    /// @notice Returns the score of a NFT attribute
    /// @param _tokenId The id of the NFT
    /// @param _indexAttribute The index of the desired attribute
    /// @return _score Score of the desired attribute
    function getNftSpecifications(uint256 _tokenId, uint256 _indexAttribute)
        external
        view
        returns (uint256)
    {
        if (_indexAttribute == 0) {
            return tokenIdToNftSpecifications[_tokenId].lightIsolationScore;
        }
        if (_indexAttribute == 1) {
            return
                tokenIdToNftSpecifications[_tokenId]
                    .bedroomThermalIsolationScore;
        }
        if (_indexAttribute == 2) {
            return tokenIdToNftSpecifications[_tokenId].soundIsolationScore;
        }
        if (_indexAttribute == 3) {
            return tokenIdToNftSpecifications[_tokenId].temperatureScore;
        }
        if (_indexAttribute == 4) {
            return tokenIdToNftSpecifications[_tokenId].humidityScore;
        }
        if (_indexAttribute == 5) {
            return tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore;
        }
        if (_indexAttribute == 6) {
            return
                tokenIdToNftSpecifications[_tokenId].circadianRhythmRegulation;
        }
        if (_indexAttribute == 7) {
            return tokenIdToNftSpecifications[_tokenId].sizeScore;
        }
        if (_indexAttribute == 8) {
            return tokenIdToNftSpecifications[_tokenId].heightScore;
        }
        if (_indexAttribute == 9) {
            return tokenIdToNftSpecifications[_tokenId].bedBaseScore;
        }
        if (_indexAttribute == 10) {
            return tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore;
        }
        if (_indexAttribute == 11) {
            return tokenIdToNftSpecifications[_tokenId].mattressThicknessScore;
        }
        if (_indexAttribute == 12) {
            return
                tokenIdToNftSpecifications[_tokenId].mattressDeformationScore;
        }
        if (_indexAttribute == 13) {
            return tokenIdToNftSpecifications[_tokenId].thermalIsolationScore;
        }
        if (_indexAttribute == 14) {
            return
                tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore;
        }
        if (_indexAttribute == 15) {
            return
                tokenIdToNftSpecifications[_tokenId]
                    .comforterComfortabilityScore;
        }
        if (_indexAttribute == 16) {
            return
                tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore;
        }
        return 0;
    }

    /// @notice Updates chainlink variables
    /// @param _callbackGasLimit Callback Gas Limit
    /// @param _subscriptionId Chainlink subscription Id
    /// @param _keyHash Chainlink Key Hash
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

    /// @dev Generates random scores
    /// @param _randomWords List of random numbers
    /// @param _tokenId Id of the NFT
    function createBedroom(uint256[] memory _randomWords, uint256 _tokenId)
        internal
    {
        tokenIdToNftSpecifications[_tokenId] = NftSpecifications(
            (_randomWords[0] % 100) + 1,
            (_randomWords[1] % 100) + 1,
            (_randomWords[2] % 100) + 1,
            (_randomWords[3] % 100) + 1,
            (_randomWords[4] % 100) + 1,
            (_randomWords[5] % 100) + 1,
            (_randomWords[6] % 100) + 1,
            (_randomWords[7] % 100) + 1,
            (_randomWords[8] % 100) + 1,
            (_randomWords[9] % 100) + 1,
            (_randomWords[10] % 100) + 1,
            (_randomWords[11] % 100) + 1,
            (_randomWords[12] % 100) + 1,
            (_randomWords[13] % 100) + 1,
            (_randomWords[14] % 100) + 1,
            (_randomWords[15] % 100) + 1,
            (_randomWords[16] % 100) + 1
        );
    }

    /// @dev Updates the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _indexAttribute Index of the attribute
    /// @param _valueToAdd Value to add to the score
    function updateBedroom(
        uint256 _tokenId,
        uint256 _indexAttribute,
        uint256 _valueToAdd
    ) internal {
        if (_indexAttribute == 0) {
            tokenIdToNftSpecifications[_tokenId].lightIsolationScore =
                tokenIdToNftSpecifications[_tokenId].lightIsolationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 1) {
            tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore =
                tokenIdToNftSpecifications[_tokenId]
                    .bedroomThermalIsolationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 2) {
            tokenIdToNftSpecifications[_tokenId].soundIsolationScore =
                tokenIdToNftSpecifications[_tokenId].soundIsolationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 3) {
            tokenIdToNftSpecifications[_tokenId].temperatureScore =
                tokenIdToNftSpecifications[_tokenId].temperatureScore +
                _valueToAdd;
        }
        if (_indexAttribute == 4) {
            tokenIdToNftSpecifications[_tokenId].humidityScore =
                tokenIdToNftSpecifications[_tokenId].humidityScore +
                _valueToAdd;
        }
        if (_indexAttribute == 5) {
            tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore =
                tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore +
                _valueToAdd;
        }
        if (_indexAttribute == 6) {
            tokenIdToNftSpecifications[_tokenId].circadianRhythmRegulation =
                tokenIdToNftSpecifications[_tokenId].circadianRhythmRegulation +
                _valueToAdd;
        }
        if (_indexAttribute == 7) {
            tokenIdToNftSpecifications[_tokenId].sizeScore =
                tokenIdToNftSpecifications[_tokenId].sizeScore +
                _valueToAdd;
        }
        if (_indexAttribute == 8) {
            tokenIdToNftSpecifications[_tokenId].heightScore =
                tokenIdToNftSpecifications[_tokenId].heightScore +
                _valueToAdd;
        }
        if (_indexAttribute == 9) {
            tokenIdToNftSpecifications[_tokenId].bedBaseScore =
                tokenIdToNftSpecifications[_tokenId].bedBaseScore +
                _valueToAdd;
        }
        if (_indexAttribute == 10) {
            tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore =
                tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore +
                _valueToAdd;
        }
        if (_indexAttribute == 11) {
            tokenIdToNftSpecifications[_tokenId].mattressThicknessScore =
                tokenIdToNftSpecifications[_tokenId].mattressThicknessScore +
                _valueToAdd;
        }
        if (_indexAttribute == 12) {
            tokenIdToNftSpecifications[_tokenId].mattressDeformationScore =
                tokenIdToNftSpecifications[_tokenId].mattressDeformationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 13) {
            tokenIdToNftSpecifications[_tokenId].thermalIsolationScore =
                tokenIdToNftSpecifications[_tokenId].thermalIsolationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 14) {
            tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore =
                tokenIdToNftSpecifications[_tokenId]
                    .hygrometricRegulationScore +
                _valueToAdd;
        }
        if (_indexAttribute == 15) {
            tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore =
                tokenIdToNftSpecifications[_tokenId]
                    .comforterComfortabilityScore +
                _valueToAdd;
        }
        if (_indexAttribute == 16) {
            tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore =
                tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore +
                _valueToAdd;
        }
    }

    /// @notice Launches the procedure to create an NFT
    /// @param _designId Design If the NFT
    /// @param _price Price of the NFT
    /// @param _category Category of the NFT
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintingBedroomNft(
        uint256 _designId,
        uint256 _price,
        Category _category,
        address _owner
    ) external {
        require(dexAddress != address(0), "Dex address is not configured");
        require(msg.sender == dexAddress, "Access forbidden");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIdToTokenId[requestId] = tokenId;

        tokenIdToNftOwnership[tokenId] = NftOwnership(
            _owner,
            _price,
            _designId,
            0,
            _category
        );

        // Index of next NFT
        tokenId++;
    }

    /// Gets the name of a Nft
    /// @param _tokenId Id of the NFT
    /// @return _name Name of thr NFT
    function getName(uint256 _tokenId) external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "Token #",
                    Strings.toString(_tokenId),
                    " Level ",
                    Strings.toString(tokenIdToNftOwnership[_tokenId].level)
                )
            );
    }

    /// @dev Callback function with the requested random numbers
    /// @param _requestId Chainlink VRF Random Number Request Id
    /// @param _randomWords List of random words
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        _mintingBedroomNft(requestIdToTokenId[_requestId], _randomWords);
        emit ReturnedRandomness(_randomWords);
    }

    /// @dev Mints a new Bedroom NFT
    /// @param _tokenId Id of the NFT
    /// @param _randomWords List of random words
    function _mintingBedroomNft(uint256 _tokenId, uint256[] memory _randomWords)
        internal
    {
        // Create new Bedroom
        createBedroom(_randomWords, _tokenId);

        // Minting of the new Bedroom NFT
        _mint(tokenIdToNftOwnership[tokenId].owner, _tokenId, 1, "");

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(tokenIdToNftOwnership[_tokenId].designId),
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftMinting(
            _tokenId,
            uri(_tokenId),
            tokenIdToNftSpecifications[_tokenId]
        );
    }

    // NFT Upgrading
    function upgradeBedroomNft(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _valueToAdd,
        uint256 _newDesignId,
        uint256 _amount
    ) external {
        require(
            address(upgradeNftInstance) != address(0),
            "UpgradeNft address is not configured"
        );
        require(msg.sender == address(upgradeNftInstance), "Access forbidden");

        // Update Bedroom
        updateBedroom(_tokenId, _attributeIndex, _valueToAdd);

        // Set Token Level
        tokenIdToNftOwnership[_tokenId].level++;

        // Set Token price
        tokenIdToNftOwnership[_tokenId].price += _amount;

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(Strings.toString(_newDesignId), fileFormat)
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftUpgrading(
            _tokenId,
            uri(_tokenId),
            tokenIdToNftSpecifications[_tokenId]
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
