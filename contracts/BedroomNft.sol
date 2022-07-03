// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "../../Interfaces/IUpgradeNft.sol";

/// @title Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of Sleepn app
contract BedroomNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155URIStorage {
    /// @dev Dex Contract address
    address private dexAddress;

    /// @dev Upgrade NFT Contract address
    IUpgradeNft private upgradeNftInstance;

    /// @dev Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable COORDINATOR;
    uint32 private numWords;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint64 private subscriptionId;
    bytes32 private keyHash;

    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        uint256 lightIsolationScore; // Index 0
        uint256 thermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 humidityScore; // Index 3
        uint256 temperatureScore; // Index 4
        uint256 ventilationScore; // Index 5
        uint256 surfaceScore; // Index 6
        uint256 furnitureScore; // Index 7
        uint256 sleepAidMachinesScore; // Index 8
        uint256 bedScore; // Index 9
        address owner;
        uint256 designId;
        uint256 level;
    }

    /// @dev File format of NFT design files
    string private fileFormat;

    /// @notice Number of NFT
    uint256 public tokenId;

    /// @dev Maps Chainlink VRF Random Number Request Id to NFT Id
    mapping(uint256 => uint256) private requestIdToTokenId;

    /// @dev Maps NFT Scores to NFT Id
    mapping(uint256 => NftSpecifications) private tokenIdToNftSpecifications;

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinting(
        address indexed owner,
        uint256 tokenId,
        string tokenURI,
        NftSpecifications specifications
    );

    /// @notice Emits an event when a Bedroom NFT is upgraded
    event BedroomNftUpgrading(
        address indexed owner,
        uint256 tokenId,
        string newTokenURI,
        NftSpecifications specifications
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
        callbackGasLimit = 400000;
        requestConfirmations = 5;
        numWords = 10;
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
        assert(dexAddress != address(0));
        assert(address(upgradeNftInstance) != address(0));
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

    /// @dev Updates the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _indexAttribute Index of the attribute
    /// @param _valueToAdd Value to add to the score
    function updateScoresAdd(
        uint256 _tokenId,
        uint256 _indexAttribute,
        uint256 _valueToAdd
    ) internal {
        if (_indexAttribute == 0) {
            tokenIdToNftSpecifications[_tokenId]
                .lightIsolationScore += _valueToAdd;
        }
        if (_indexAttribute == 1) {
            tokenIdToNftSpecifications[_tokenId]
                .thermalIsolationScore += _valueToAdd;
        }
        if (_indexAttribute == 2) {
            tokenIdToNftSpecifications[_tokenId]
                .soundIsolationScore += _valueToAdd;
        }
        if (_indexAttribute == 3) {
            tokenIdToNftSpecifications[_tokenId].humidityScore += _valueToAdd;
        }
        if (_indexAttribute == 4) {
            tokenIdToNftSpecifications[_tokenId]
                .temperatureScore += _valueToAdd;
        }
        if (_indexAttribute == 5) {
            tokenIdToNftSpecifications[_tokenId]
                .ventilationScore += _valueToAdd;
        }
        if (_indexAttribute == 6) {
            tokenIdToNftSpecifications[_tokenId].surfaceScore += _valueToAdd;
        }
        if (_indexAttribute == 7) {
            tokenIdToNftSpecifications[_tokenId].furnitureScore += _valueToAdd;
        }
        if (_indexAttribute == 8) {
            tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore += _valueToAdd;
        }
        if (_indexAttribute == 9) {
            tokenIdToNftSpecifications[_tokenId]
                .bedScore += _valueToAdd;
        }
    }

    /// @dev Updates the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _indexAttribute Index of the attribute
    /// @param _valueToRemove Value to remove to the score
    function updateScoresRemove(
        uint256 _tokenId,
        uint256 _indexAttribute,
        uint256 _valueToRemove
    ) internal {
        if (_indexAttribute == 0) {
            tokenIdToNftSpecifications[_tokenId]
                .lightIsolationScore -= _valueToRemove;
        }
        if (_indexAttribute == 1) {
            tokenIdToNftSpecifications[_tokenId]
                .thermalIsolationScore -= _valueToRemove;
        }
        if (_indexAttribute == 2) {
            tokenIdToNftSpecifications[_tokenId]
                .soundIsolationScore -= _valueToRemove;
        }
        if (_indexAttribute == 3) {
            tokenIdToNftSpecifications[_tokenId].humidityScore -= _valueToRemove;
        }
        if (_indexAttribute == 4) {
            tokenIdToNftSpecifications[_tokenId]
                .temperatureScore -= _valueToRemove;
        }
        if (_indexAttribute == 5) {
            tokenIdToNftSpecifications[_tokenId]
                .ventilationScore -= _valueToRemove;
        }
        if (_indexAttribute == 6) {
            tokenIdToNftSpecifications[_tokenId].surfaceScore -= _valueToRemove;
        }
        if (_indexAttribute == 7) {
            tokenIdToNftSpecifications[_tokenId].furnitureScore -= _valueToRemove;
        }
        if (_indexAttribute == 8) {
            tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore -= _valueToRemove;
        }
        if (_indexAttribute == 9) {
            tokenIdToNftSpecifications[_tokenId]
                .bedScore -= _valueToRemove;
        }
    }

    /// @notice Launches the procedure to create an NFT
    /// @param _designId Design Id the NFT
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintingBedroomNft(
        uint256 _designId,
        address _owner
    ) external {
        require(dexAddress != address(0), "Dex address is not configured");
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");
        

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIdToTokenId[requestId] = tokenId;

        tokenIdToNftSpecifications[tokenId] = NftSpecifications(
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            _owner,
            _designId,
            1
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
                    Strings.toString(tokenIdToNftSpecifications[_tokenId].level)
                )
            );
    }

    /// @dev Callback function with the requested random numbers
    /// @param requestId Chainlink VRF Random Number Request Id
    /// @param randomWords List of random words
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 _tokenId = requestIdToTokenId[requestId];

        // Create new Bedroom
        uint256 sum;
        uint256 score;
        score = (randomWords[0] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].lightIsolationScore = score; 
        sum+=score;
        score = (randomWords[1] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].thermalIsolationScore = score; 
        sum+=score;
        score = (randomWords[2] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].soundIsolationScore = score; 
        sum+=score;
        score = (randomWords[3] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].humidityScore = score; 
        sum+=score;
        score = (randomWords[4] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].temperatureScore = score;
        sum+=score;
        score = (randomWords[5] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].ventilationScore = score; 
        sum+=score;
        score = (randomWords[6] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].surfaceScore = score; 
        sum+=score;
        score = (randomWords[7] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].furnitureScore = score; 
        sum+=score;
        score = (randomWords[8] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore = score;
        sum+=score;
        score = (randomWords[9] % 100) + 1;
        tokenIdToNftSpecifications[_tokenId].bedScore = score; 
        sum+=score;

        // Minting of the new Bedroom NFT
        _mint(
            tokenIdToNftSpecifications[_tokenId].owner, 
            _tokenId, 
            sum, 
            ""
        );

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(tokenIdToNftSpecifications[_tokenId].designId),
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftMinting(
            tokenIdToNftSpecifications[_tokenId].owner,
            _tokenId,
            uri(_tokenId),
            tokenIdToNftSpecifications[_tokenId]
        );
    }

    /// @notice Launches the procedure to update an NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the attribute to upgrade
    /// @param _value Value to add to the attribute score
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateBedroomNft(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _value,
        uint256 _newDesignId,
        uint256 _amount, 
        uint256 _level,
        uint256 _action
    ) external {
        assert(address(upgradeNftInstance) != address(0));
        require(msg.sender == address(upgradeNftInstance), "Access forbidden");

        if (_action == 1) {
            updateScoresAdd(
                _tokenId,
                _attributeIndex,
                _value
            );
            _mint(
                tokenIdToNftSpecifications[_tokenId].owner, 
                _tokenId, 
                _amount,
                ""
            );
            // Set Token Level
            tokenIdToNftSpecifications[_tokenId].level += _level;
        } else if (_action == 2) {
            updateScoresRemove(
                _tokenId,
                _attributeIndex,
                _value
            );
            _burn(
                tokenIdToNftSpecifications[_tokenId].owner, 
                _tokenId, 
                _amount
            );
            // Set Token Level
            tokenIdToNftSpecifications[_tokenId].level -= _level;
        } else if (_action == 3) {
            // Set Token Level
            tokenIdToNftSpecifications[_tokenId].level += _level;
            _mint(
                tokenIdToNftSpecifications[_tokenId].owner, 
                _tokenId, 
                _amount,
                ""
            );
        } else if (_action == 4) {
            // Set Token Level
            tokenIdToNftSpecifications[_tokenId].level -= _level;
            _burn(
                tokenIdToNftSpecifications[_tokenId].owner, 
                _tokenId, 
                _amount
            );
        } 

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(Strings.toString(_newDesignId), fileFormat)
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftUpgrading(
            tokenIdToNftSpecifications[_tokenId].owner,
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
