// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "../Interfaces/ITracker.sol";
import "../Interfaces/IUpgrader.sol";

import "./UpgradeNft.sol";

/// @title Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of Sleepn app
contract BedroomNft is
    VRFConsumerBaseV2,
    ERC1155,
    Ownable,
    ERC1155URIStorage
{
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    /// @dev Dex Contract address
    address public immutable dexAddress;

    /// @dev Upgrade NFT Contract address
    UpgradeNft public immutable upgradeNftInstance;

    /// @dev Tracker Contract address
    ITracker public immutable trackerInstance;

    /// @dev Upgrader Contract address
    IUpgrader public immutable upgraderInstance;

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
        uint256 value;
    }

    /// @dev initial NFT design URI
    string private initialURI;

    /// @notice Number of NFT
    Counters.Counter private tokenId;

    /// @dev Maps Chainlink VRF Random Number Request Id to NFT Id
    mapping(uint256 => uint256) public requestIdToTokenId;

    /// @dev Maps NFT Scores to NFT Id
    mapping(uint256 => NftSpecifications) private tokenIdToNftSpecifications;

    /// @notice Emits an event when a Bedroom NFT is minted
    event BedroomNftMinted(
        address indexed owner,
        uint256 indexed requestID,
        uint256 tokenId,
        uint16 ambiance,
        uint16 quality,
        uint16 luck,
        uint16 comfortability
    );
    /// @notice Emits an event when a Bedroom NFT Score is updated
    event BedroomNftUpdated(
        address indexed owner, uint256 indexed tokenId, uint256 timestamp
    );
    /// @notice Returned Request ID, Invoker and Token ID
    event RequestedRandomness(
        uint256 indexed requestId, address invoker, uint256 indexed tokenId
    );
    /// @notice Returned Random Numbers Event, Invoker and Token ID
    event ReturnedRandomness(
        uint256[] randomWords,
        uint256 indexed requestId,
        uint256 indexed tokenId
    );
    /// @notice Base URI Changed Event
    event BaseURIChanged(string baseURI);
    /// @notice Chainlink Data Updated Event
    event ChainlinkDataUpdated(
        uint32 callbackGasLimit,
        uint64 subscriptionId,
        bytes32 keyHash,
        uint16 requestConfirmations
    );
    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed owner, uint256 amount);

    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);

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
        dexAddress = _dexAddress;

        // Deploys Upgrade NFT contract and transfers ownership
        upgradeNftInstance = new UpgradeNft(
            _dexAddress,
            _devWallet
        );
        upgradeNftInstance.transferOwnership(msg.sender);

        // Connects to Tracker and Upgrader contracts
        trackerInstance =
            ITracker(address(upgradeNftInstance.trackerInstance()));
        upgraderInstance =
            IUpgrader(address(upgradeNftInstance.upgraderInstance()));
    }

    /// @notice Returns the number of Bedroom NFTs in existence
    /// @return nftsNumber Representing the number of Bedroom NFTs in existence
    function getNftsNumber() external view returns (uint256 nftsNumber) {
        nftsNumber = tokenId.current();
    }

    /// @notice Returns the specifications of a Bedroom NFT
    /// @param _tokenId Id of the Bedroom NFT
    /// @return nftSpecifications Specifications of the Bedroom NFT
    function getSpecifications(uint256 _tokenId)
        external
        view
        returns (NftSpecifications memory nftSpecifications)
    {
        nftSpecifications = tokenIdToNftSpecifications[_tokenId];
    }

    /// @notice Returns the specifications of some Bedroom NFTs
    /// @param _tokenIds Ids of the Bedroom NFTs
    /// @return nftSpecifications Specifications of the Bedroom NFTs
    function getSpecificationsBatch(uint256[] calldata _tokenIds)
        external
        view
        returns (NftSpecifications[] memory nftSpecifications)
    {
        nftSpecifications = new NftSpecifications[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            nftSpecifications[i] = tokenIdToNftSpecifications[_tokenIds[i]];
        }
    }

    /// @notice Returns the data of a NFT
    /// @param _tokenId The id of the NFT
    /// @return _ambiance Ambiance Score
    /// @return _quality Quality Score
    /// @return _luck Luck Score
    /// @return _comfortability Comfortability Score
    /// @return _owner NFT owner address
    /// @return _level NFT level
    /// @return _value NFT value
    function getData(uint256 _tokenId)
        external
        view
        returns (
            uint16 _ambiance,
            uint16 _quality,
            uint16 _luck,
            uint16 _comfortability,
            address _owner,
            uint256 _level,
            uint256 _value
        )
    {
        NftSpecifications memory spec = tokenIdToNftSpecifications[_tokenId];
        _ambiance = uint16(spec.scores);
        _quality = uint16(spec.scores >> 16);
        _luck = uint16(spec.scores >> 32);
        _comfortability = uint16(spec.scores >> 48);
        _owner = spec.owner;
        _level = spec.level;
        _value = spec.value;
    }

    /// @notice Returns the data of some Bedroom NFTs
    /// @param _tokenIds Nfts IDs
    /// @return _ambiance Ambiance Score
    /// @return _quality Quality Score
    /// @return _luck Luck Score
    /// @return _comfortability Comfortability Score
    /// @return _owners NFT owner address
    /// @return _levels NFT level
    /// @return _values NFT value
    function getDataBatch(uint256[] calldata _tokenIds)
        external
        view
        returns (
            uint16[] memory _ambiance,
            uint16[] memory _quality,
            uint16[] memory _luck,
            uint16[] memory _comfortability,
            address[] memory _owners,
            uint256[] memory _levels,
            uint256[] memory _values
        )
    {
        _ambiance = new uint16[](_tokenIds.length);
        _quality = new uint16[](_tokenIds.length);
        _luck = new uint16[](_tokenIds.length);
        _comfortability = new uint16[](_tokenIds.length);
        _owners = new address[](_tokenIds.length);
        _levels = new uint256[](_tokenIds.length);
        _values = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            NftSpecifications memory spec =
                tokenIdToNftSpecifications[_tokenIds[i]];
            _ambiance[i] = uint16(spec.scores);
            _quality[i] = uint16(spec.scores >> 16);
            _luck[i] = uint16(spec.scores >> 32);
            _comfortability[i] = uint16(spec.scores >> 48);
            _owners[i] = spec.owner;
            _levels[i] = spec.level;
            _values[i] = spec.value;
        }
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
        emit ChainlinkDataUpdated(
            _callbackGasLimit, _subscriptionId, _keyHash, _requestConfirmations
            );
    }

    /// @notice Settles initial NFT Design URI
    /// @param _initialURI New URI
    /// @dev This function can only be called by the owner of the contract
    function setInitialDesignURI(string calldata _initialURI)
        external
        onlyOwner
    {
        initialURI = _initialURI;
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
        emit BaseURIChanged(_baseURI);
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

    /// @notice Launches the procedure to create an NFT
    /// @param _owner Owner of the NFT
    /// @return _tokenId NFT ID
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNft(address _owner)
        external
        returns (uint256 _tokenId)
    {
        if (msg.sender != owner() && msg.sender != dexAddress) {
            revert RestrictedAccess(msg.sender);
        }

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        _tokenId = tokenId.current();

        tokenId.increment();

        requestIdToTokenId[requestId] = _tokenId;

        tokenIdToNftSpecifications[_tokenId] =
            NftSpecifications(_owner, 0, 1, 0);

        trackerInstance.addBedroomNft(_owner, _tokenId);

        emit RequestedRandomness(requestId, msg.sender, _tokenId);
    }

    /// @notice Launches the procedure to create an NFT - Batch Transaction
    /// @param _owners Nfts Owners
    /// @return _tokenIds NFT IDs
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNfts(address[] calldata _owners)
        external
        returns (uint256[] memory _tokenIds)
    {
        if (msg.sender != owner() && msg.sender != dexAddress) {
            revert RestrictedAccess(msg.sender);
        }

        _tokenIds = new uint256[](_owners.length);

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        for (uint256 i = 0; i < _owners.length; ++i) {
            _tokenIds[i] = tokenId.current();

            tokenId.increment();

            tokenIdToNftSpecifications[_tokenIds[i]] =
                NftSpecifications(_owners[i], 0, 1, 0);

            trackerInstance.addBedroomNft(_owners[i], _tokenIds[i]);

            emit RequestedRandomness(requestId, msg.sender, _tokenIds[i]);
        }
    }

    /// @dev Callback function with the requested random numbers
    /// @param requestId Chainlink VRF Random Number Request Id
    /// @param randomWords List of random words
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 _tokenId = requestIdToTokenId[requestId];
        emit ReturnedRandomness(randomWords, requestId, _tokenId);

        // Create new Bedroom
        uint64 score1 = uint64((randomWords[0] % 100) + 1); // Ambiance
        uint64 score2 = uint64((randomWords[1] % 100) + 1); // Quality
        uint64 score3 = uint64((randomWords[2] % 100) + 1); // Luck
        uint64 score4 = uint64((randomWords[3] % 100) + 1); // comfortability
        tokenIdToNftSpecifications[_tokenId].scores =
            score1 + (score2 << 16) + (score3 << 32) + (score4 << 48);
        tokenIdToNftSpecifications[_tokenId].value =
            uint256(score1 + score2 + score3 + score4);

        // Minting of the new Bedroom NFT
        address nftOwner = tokenIdToNftSpecifications[_tokenId].owner;
        _mint(nftOwner, _tokenId, 1, "");

        _setURI(_tokenId, initialURI);

        emit BedroomNftMinted(
            nftOwner,
            requestId,
            _tokenId,
            uint16(score1),
            uint16(score2),
            uint16(score3),
            uint16(score4)
        );
    }

    /// @notice Updates a Bedroom NFT
    /// @param _tokenId Id of the NFT
    /// @param _newValue value of the NFT
    /// @param _newLevel level of the NFT
    /// @param _newScores Scores of the NFT
    /// @param _newDesignURI Design URI of the NFT
    function updateBedroomNft(
        uint256 _tokenId,
        uint256 _newValue,
        uint256 _newLevel,
        uint64 _newScores,
        string memory _newDesignURI
    ) external {
        if (msg.sender != address(upgraderInstance)) {
            revert RestrictedAccess(msg.sender);
        }
        /// Gets current NFT data
        NftSpecifications memory spec = tokenIdToNftSpecifications[_tokenId];
        /// Updates the level if it is different than the current one
        if (spec.level != _newLevel) {
            tokenIdToNftSpecifications[_tokenId].level = _newLevel;
        }
        /// Updates the value if it is different than the current one
        if (spec.value != _newValue) {
            tokenIdToNftSpecifications[_tokenId].value = _newValue;
        }
        /// Updates the scores if it is different than the current one
        if (spec.scores != _newScores) {
            tokenIdToNftSpecifications[_tokenId].scores = _newScores;
        }
        /// Updates the design URI if it is different than the current one
        if (bytes(_newDesignURI).length != 0) {
            _setURI(_tokenId, _newDesignURI);
        }
        emit BedroomNftUpdated(spec.owner, _tokenId, block.timestamp);
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
        tokenIdToNftSpecifications[_id].owner = _to;
        trackerInstance.removeBedroomNft(_from, _to, _id);
        trackerInstance.addBedroomNft(_to, _id);
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
            tokenIdToNftSpecifications[_ids[i]].owner = _to;
            trackerInstance.removeBedroomNft(_from, _to, _ids[i]);
            trackerInstance.addBedroomNft(_to, _ids[i]);
        }
        super._safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
    }
}
