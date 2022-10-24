// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IUpgradeNft.sol";

/// @title Interface of the Bedroom NFT Contract
/// @author Sleepn
/// @notice Bedroom NFT is the main NFT of Sleepn app
interface IBedroomNft is IERC1155 {
    /// @notice Scores of a Bedroom NFT
    struct NftSpecifications {
        address owner;
        uint64 scores;
        uint256 level;
        uint256 value;
    }

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

    /// @notice Returns the number of Bedroom NFTs in existence
    /// @return nftsNumber Representing the number of Bedroom NFTs in existence
    function getNftsNumber() external view returns (uint256 nftsNumber);

    /// @notice Returns the specifications of a Bedroom NFT
    /// @param _tokenId Id of the Bedroom NFT
    /// @return nftSpecifications Specifications of the Bedroom NFT
    function getSpecifications(uint256 _tokenId)
        external
        view
        returns (NftSpecifications memory nftSpecifications);

    /// @notice Returns the specifications of some Bedroom NFTs
    /// @param _tokenIds Ids of the Bedroom NFTs
    /// @return nftSpecifications Specifications of the Bedroom NFTs
    function getSpecificationsBatch(uint256[] calldata _tokenIds)
        external
        view
        returns (NftSpecifications[] memory nftSpecifications);

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
        );

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
        );

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
    ) external;

    /// @notice Settles initial NFT Design URI
    /// @param _initialURI New URI
    /// @dev This function can only be called by the owner of the contract
    function setInitialDesignURI(string calldata _initialURI)
        external;

    /// @notice Settles the URI of a NFT
    /// @param _tokenId Id of the NFT
    /// @param _tokenURI Uri of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setTokenURI(uint256 _tokenId, string memory _tokenURI)
        external;

    /// Settles baseURI as the _baseURI for all tokens
    /// @param _baseURI Base URI of NFTs
    /// @dev This function can only be called by the owner of the contract
    function setBaseURI(string memory _baseURI) external;

    /// @notice Withdraws the money from the contract
    /// @param _token Address of the token to withdraw
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney(IERC20 _token) external;

    /// @notice Launches the procedure to create an NFT
    /// @param _owner Owner of the NFT
    /// @return _tokenId NFT ID
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNft(address _owner)
        external
        returns (uint256 _tokenId);

    /// @notice Launches the procedure to create an NFT - Batch Transaction
    /// @param _owners Nfts Owners
    /// @return _tokenIds NFT IDs
    /// @dev This function can only be called by Dex Contract
    function mintBedroomNfts(address[] calldata _owners)
        external
        returns (uint256[] memory _tokenIds);

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
    ) external;
}
