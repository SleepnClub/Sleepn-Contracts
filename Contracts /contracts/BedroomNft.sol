// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "./Interfaces/IUpgradeNft.sol";

/// @title Bedroom NFT Contract
/// @author Alexis Balayre
/// @notice Bedroom NFT is the main NFT of GetSleepn app
contract BedroomNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155URIStorage {
    /// @notice Dex Contract address
    address public dexAddress;

    /// @notice Upgrade NFT Contract address
    IUpgradeNft public upgradeNftInstance;

    /// @notice Chainlink VRF Variables
    VRFCoordinatorV2Interface public immutable COORDINATOR;
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

    /// @notice File format of NFT design files
    string public fileFormat;

    /// @notice Number of NFT
    uint256 public tokenId;

    /// @notice Maps Chainlink VRF Random Number Request Id to NFT Id
    mapping(uint256 => uint256) private requestIdToTokenId;

    /// @notice Maps NFT Scores to NFT Id
    mapping(uint256 => NftSpecifications) private tokenIdToNftSpecifications;

    /// @notice Maps NFT Informations to NFT Id
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

    /// @notice Returned Random Numbers Event 
    event ReturnedRandomness(uint256[] randomWords);

    /// @notice Constructor
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
        callbackGasLimit = 500000;
        requestConfirmations = 6;
        numWords = 17;
        tokenId = 0;
    }

    /// @notice Settles contracts addresses
    /// @param _dexAddress Address of the Dex contract
    /// @param _upgradeNftAddress Address of the Upgrade NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(address _dexAddress, IUpgradeNft _upgradeNftAddress)
        external
        onlyOwner
    {
        dexAddress = _dexAddress;
        upgradeNftInstance = _upgradeNftAddress;
    }

    /// @notice Returns the informations of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _infos Informations about the NFT
    function getNftOwnership(uint256 _tokenId)
        external
        view
        returns (NftOwnership memory)
    {
        return tokenIdToNftOwnership[_tokenId];
    }

    /// @notice Returns the scores of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _scores Scores of the NFT
    function getNftSpecifications(uint256 _tokenId)
        external
        view
        returns (NftSpecifications memory)
    {
        return tokenIdToNftSpecifications[_tokenId];
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
    /// @param _designId Design Id the NFT
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

    /// Gets the name of a NFT
    /// @param _tokenId Id of the NFT
    /// @return _name Name of the NFT
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

    /// @notice Launches the procedure to update an NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the attribute to upgrade
    /// @param _valueToAdd Value to add to the attribute score
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @dev This function can only be called by Dex Contract
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
