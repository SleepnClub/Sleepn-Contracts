// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "./UpgradeNft.sol";

/// @title Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of Sleepn app
contract BedroomNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155URIStorage {
    /// @dev Dex Contract address
    address private immutable dexAddress;

    /// @dev Upgrade NFT Contract address
    UpgradeNft public immutable upgradeNftInstance;

    /// @dev Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable COORDINATOR;
    uint32 private numWords;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint64 private subscriptionId;
    bytes32 private keyHash;

    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        address owner;
        uint64 scores; 
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

    /// @dev Maps NFTs number owned to Owner address 
    mapping(address => uint256) private ownerToNftsNumber;

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinting(
        address indexed owner,
        uint256 tokenId,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Score is upgraded
    event BedroomNftScoreUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Score is downgraded
    event BedroomNftScoreDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level,
        uint16 ambiance, 
        uint16 quality, 
        uint16 luck, 
        uint16 confortability
    );

    /// @notice Emits an event when a Bedroom NFT Level is upgraded
    event BedroomNftLevelUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Level is downgraded
    event BedroomNftLevelDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Design is upgraded
    event BedroomNftDesignUpgrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level
    );

    /// @notice Emits an event when a Bedroom NFT Design is downgraded
    event BedroomNftDesignDowngrading(
        address indexed owner,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 amount, 
        uint256 level
    );

    /// @notice Returned Random Numbers Event
    event ReturnedRandomness(uint256[] randomWords);

    /// @dev Constructor
    /// @param _subscriptionId Chainlink VRF Id Subscription
    /// @param _vrfCoordinator Address of the Coordinator Contract
    /// @param _dexAddress Dex Contract Address
    /// @param _devWallet Dev Wallet Address
    /// @param _keyHash Chainlink VRF key hash
    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        address _dexAddress, 
        address _devWallet,
        bytes32 _keyHash
    ) ERC1155("Bedroom") VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = 200000;
        requestConfirmations = 3;
        numWords = 4;
        tokenId = 0;
        dexAddress = _dexAddress;
        fileFormat = ".png";
        // Deploy Upgrade NFT
        upgradeNftInstance = new UpgradeNft(
            _dexAddress,
            _devWallet
        );
        upgradeNftInstance.transferOwnership(msg.sender);
    }

    /// @notice Returns the owner of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _owner NFT owner address
    function getNftsOwner(uint256 _tokenId) external view returns(address _owner) {
        _owner = tokenIdToNftSpecifications[_tokenId].owner;
    }

    /// @notice Returns the level of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _level NFT level
    function getNftsLevel(uint256 _tokenId) external view returns(uint256 _level) {
        _level = tokenIdToNftSpecifications[_tokenId].level;
    }

    /// @notice Returns the number of Nfts owned by an address
    /// @param _owner Owner address
    /// @return _number NFTs number
    function getNftsNumber(address _owner) 
        external
        view
        returns (uint256)
    {
        return ownerToNftsNumber[_owner];
    }

    /// @notice Returns the data of a NFT 
    /// @param _tokenId The id of the NFT
    /// @return _ambiance Score 1
    /// @return _quality Score 2
    /// @return _luck Score 3
    /// @return _confortability Score 4
    /// @return _owner NFT Owner
    /// @return _level NFT Level
    function getScores(
        uint256 _tokenId
    ) external view returns(
        uint16 _ambiance, 
        uint16 _quality, 
        uint16 _luck, 
        uint16 _confortability,
        address _owner,
        uint256 _level
    ) {
        NftSpecifications memory spec = tokenIdToNftSpecifications[_tokenId];
        _ambiance = uint16(spec.scores);
        _quality = uint16(spec.scores >> 16); 
        _luck = uint16(spec.scores >> 32); 
        _confortability = uint16(spec.scores >> 48); 
        _owner = spec.owner;
        _level = spec.level;
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
    /// @param _owner Owner of the NFT
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNft(
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
            _owner,
            0,
            1
        );

        // Index of next NFT
        ++tokenId;
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
        uint64 score1 = uint64((randomWords[0] % 100) + 1); // Ambiance
        uint64 score2 = uint64((randomWords[1] % 100) + 1); // Quality 
        uint64 score3 = uint64((randomWords[2] % 100) + 1); // Luck 
        uint64 score4 = uint64((randomWords[3] % 100) + 1); // Confortability
        tokenIdToNftSpecifications[_tokenId].scores = score1 + (score2 << 16) + (score3 << 32) + (score4 << 48);

        // Minting of the new Bedroom NFT
        address nftOwner = tokenIdToNftSpecifications[_tokenId].owner;
        _mint(
            nftOwner, 
            _tokenId, 
            score1+score2+score3+score4, 
            ""
        );

        // Increases Nfts counter
        ++ownerToNftsNumber[nftOwner];

        // Settles Token URI
        string memory DesignName = string(
            abi.encodePacked(
                "0",
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftMinting(
            nftOwner,
            _tokenId,
            uint16(score1), 
            uint16(score2), 
            uint16(score3),
            uint16(score4)
        );
    }

    /// @notice Launches the procedure to update the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _attributeIndex Index of the attribute to upgrade
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _value Value to add to the attribute score
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateScores(
        uint256 _tokenId,
        uint256 _attributeIndex,
        uint256 _newDesignId,
        uint256 _amount, 
        uint256 _level,
        uint16 _value,
        bool _action   
    ) external {
        require(msg.sender == address(upgradeNftInstance), "Access forbidden");
        if (_action) {
            scoreAdd_u9q(
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

            // Get the new data
            NftSpecifications memory spec = tokenIdToNftSpecifications[_tokenId];
            emit BedroomNftScoreUpgrading(
                spec.owner,
                _tokenId,
                _newDesignId,
                _amount, 
                spec.level,
                uint16(spec.scores),
                uint16(spec.scores >> 16), 
                uint16(spec.scores >> 32), 
                uint16(spec.scores >> 48)
            );
        } else {
            scoreRemove_reh(
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

            // Get the new data
            NftSpecifications memory spec = tokenIdToNftSpecifications[_tokenId];

            emit BedroomNftScoreDowngrading(
                spec.owner,
                _tokenId,
                _newDesignId,
                _amount, 
                spec.level,
                uint16(spec.scores),
                uint16(spec.scores >> 16), 
                uint16(spec.scores >> 32), 
                uint16(spec.scores >> 48)
            );
        } 

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(Strings.toString(_newDesignId), fileFormat)
        );
        _setURI(_tokenId, DesignName);
    }

    /// @notice Launches the procedure to update the level of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateLevel(
        uint256 _tokenId, 
        uint256 _level,
        bool _action   
    ) external {
        require(msg.sender == address(upgradeNftInstance), "Access forbidden");
        if (_action) {
            tokenIdToNftSpecifications[_tokenId].level += _level;
            emit BedroomNftLevelUpgrading(
                tokenIdToNftSpecifications[_tokenId].owner,
                _tokenId,
                tokenIdToNftSpecifications[_tokenId].level
            );
        } else {
            tokenIdToNftSpecifications[_tokenId].level -= _level;
            emit BedroomNftLevelDowngrading(
                tokenIdToNftSpecifications[_tokenId].owner,
                _tokenId,
                tokenIdToNftSpecifications[_tokenId].level
            );
        } 
    }

    /// @notice Launches the procedure to update the level of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _newDesignId New design Id of the NFT
    /// @param _amount Price of the upgrade
    /// @param _level Level to add to the Nft
    /// @param _action Action to do
    /// @dev This function can only be called by Dex Contract
    function updateDesign(
        uint256 _tokenId, 
        uint256 _newDesignId,
        uint256 _amount,
        uint256 _level,
        bool _action
    ) external {
        require(msg.sender == address(upgradeNftInstance), "Access forbidden");
        if (_action) {
            if (_level > 0) {
                tokenIdToNftSpecifications[_tokenId].level += _level;
            }

            if (_amount > 0) {
                _mint(
                    tokenIdToNftSpecifications[_tokenId].owner, 
                    _tokenId, 
                    _amount,
                    ""
                );
            }

            emit BedroomNftDesignUpgrading(
                tokenIdToNftSpecifications[_tokenId].owner,
                _tokenId,
                _newDesignId,
                _amount, 
                tokenIdToNftSpecifications[_tokenId].level
            );
            
        } else {
            if (_level > 0) {
                tokenIdToNftSpecifications[_tokenId].level -= _level;
            }

            if (_amount > 0) {
                _burn(
                    tokenIdToNftSpecifications[_tokenId].owner, 
                    _tokenId, 
                    _amount
                );
            }

            emit BedroomNftDesignDowngrading(
                tokenIdToNftSpecifications[_tokenId].owner,
                _tokenId,
                _newDesignId,
                _amount, 
                tokenIdToNftSpecifications[_tokenId].level
            );
        } 

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(Strings.toString(_newDesignId), fileFormat)
        );
        _setURI(_tokenId, DesignName);
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
    {
        require(dexAddress != address(0), "Dex address is not configured");
        require(msg.sender == owner() || msg.sender == dexAddress, "Access forbidden");
        _setURI(_tokenId, _tokenURI);
    }

    /// Settles baseURI as the _baseURI for all tokens
    /// @param _baseURI Base URI of NFTs
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    /// @dev Updates the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _indexAttribute Index of the attribute
    /// @param _valueToAdd Value to add to the score
    function scoreAdd_u9q(
        uint256 _tokenId,
        uint256 _indexAttribute,
        uint16 _valueToAdd
    ) internal {
        uint64 scores = tokenIdToNftSpecifications[_tokenId].scores;
        uint16[4] memory scoresList = [
            uint16(scores),
            uint16(scores >> 16),
            uint16(scores >> 32),
            uint16(scores >> 48)
        ]; 
        require(scoresList[_indexAttribute] < 100, "score can't be greater than 100"); 
        scoresList[_indexAttribute] += _valueToAdd;
        if (scoresList[_indexAttribute] > 100) {
            scoresList[_indexAttribute] = 100;
        }
        tokenIdToNftSpecifications[_tokenId].scores = uint64(scoresList[0]) + (uint64(scoresList[1]) << 16) + (uint64(scoresList[2]) << 32) + (uint64(scoresList[3]) << 48);
    }

    /// @dev Updates the scores of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _indexAttribute Index of the attribute
    /// @param _valueToRemove Value to remove to the score
    function scoreRemove_reh(
        uint256 _tokenId,
        uint256 _indexAttribute,
        uint16 _valueToRemove
    ) internal {
        uint64 scores = tokenIdToNftSpecifications[_tokenId].scores;
        uint16[4] memory scoresList = [
            uint16(scores),
            uint16(scores >> 16),
            uint16(scores >> 32),
            uint16(scores >> 48)
        ]; 
        require(scoresList[_indexAttribute] >= _valueToRemove, "score can't be negative");
        scoresList[_indexAttribute] -= _valueToRemove;
        if (scoresList[_indexAttribute] > 100) {
            scoresList[_indexAttribute] = 100;
        }
        tokenIdToNftSpecifications[_tokenId].scores = uint64(scoresList[0]) + (uint64(scoresList[1]) << 16) + (uint64(scoresList[2]) << 32) + (uint64(scoresList[3]) << 48);
    }
}
