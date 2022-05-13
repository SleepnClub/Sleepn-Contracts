// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract BedroomNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155Supply, ERC1155URIStorage {
    // Dex Address
    address public nftDexAddress;

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;
    uint32 immutable numWord; 
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint64 subscriptionId; 
    bytes32 keyHash;    

    // NFT Specifications
    struct NftSpecifications {
        uint256 lightIsolationScore; // Index 0
        uint256 bedroomThermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 temperatureScore; // Index 3
        uint256 humidityScore; // Index 4
        uint256 sleepAidMachinesScore; // Index 5
        uint256 sizeScore; // Index 6
        uint256 heightScore; // Index 7
        uint256 bedBaseScore; // Index 8
        uint256 mattressTechnologyScore; // Index 9
        uint256 mattressThicknessScore; // Index 10
        uint256 mattressDeformationScore; // Index 11
        uint256 thermalIsolationScore; // Index 12
        uint256 hygrometricRegulationScore; // Index 13
        uint256 comforterComfortabilityScore; // Index 14
        uint256 pillowComfortabilityScore; // Index 15
    }

    // NFT Ownership
    struct NftOwnership {
        address owner;
        uint256 price;
        uint256 designId;
        uint256 level; 
        uint256 categorie;
    }

    // Score thresholds 
    struct Thresholds {
        uint256 initialScoreMax; // Initial Score Maximum value 
        uint256 upgradeIncreases; // Number of percents per increase 
        uint256 requiredLevel; // Required level to be unlock
        uint256 multiplier; // Multiplier depending on the NFT category
    }

    // File format
    string public fileFormat;

    // Number of NFT 
    uint256 public tokenId;

    // Mappings
    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(uint256 => NftOwnership) public tokenIdToNftOwnership;
    mapping(uint256 => NftSpecifications) tokenIdToNftSpecifications; 
    mapping(uint256 => Thresholds) public thresholds;

    // Events
    event BedroomNftMinting(
        uint256 tokenId, 
        string tokenURI,
        NftSpecifications specifications
    );
    event BedroomNftUpgrading(
        uint256 tokenId, 
        string newTokenURI,
        NftSpecifications specifications
    );
    event ReturnedRandomness(uint256[] randomWords);
    
    constructor(
        // 162
        uint64 _subscriptionId, 
        // Mumbai Testnet : 0x6168499c0cFfCaCD319c818142124B7A15E857ab 
        address _vrfCoordinator,
        // Mumbai Testnet : 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
        address _link_token_contract,
        // Mumbai Testnet : 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
        bytes32 _keyHash
    ) 
    VRFConsumerBaseV2(_vrfCoordinator) 
    ERC1155("") 
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(_link_token_contract);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = 100000;
        requestConfirmations = 3;
        numWord = 1; 
        tokenId = 0;
    }

    // set Dex address 
    function setDex(address _nftDexAddress) public onlyOwner {
        nftDexAddress = _nftDexAddress;
    }

    // Get NFT Specifications
    function getNftSpecifications(
        uint256 _tokenId, 
        uint256 _indexAttribute
    ) public view returns (uint256) {
        if (_indexAttribute == 0) {
            return tokenIdToNftSpecifications[_tokenId].lightIsolationScore;
        }
        if (_indexAttribute == 1) {
            return tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore;
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
            return tokenIdToNftSpecifications[_tokenId].sizeScore;
        }
        if (_indexAttribute == 7) {
            return tokenIdToNftSpecifications[_tokenId].heightScore;
        }
        if (_indexAttribute == 8) {
            return tokenIdToNftSpecifications[_tokenId].bedBaseScore;
        }
        if (_indexAttribute == 9) {
            return tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore;
        }
        if (_indexAttribute == 10) {
            return tokenIdToNftSpecifications[_tokenId].mattressThicknessScore;
        }
        if (_indexAttribute == 11) {
            return tokenIdToNftSpecifications[_tokenId].mattressDeformationScore;
        }
        if (_indexAttribute == 12) {
            return tokenIdToNftSpecifications[_tokenId].thermalIsolationScore;
        }
        if (_indexAttribute == 13) {
            return tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore;
        }
        if (_indexAttribute == 14) {
            return tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore;
        }
        if (_indexAttribute == 15) {
            return tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore;
        }
        return 0;
    }

    function updateChainlink(
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit,
        uint64 _subscriptionId, 
        bytes32 _keyHash
    ) external onlyOwner {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
    }

    // Set a new thresholds
    function setThresholds(
        uint256 _indexAttribute, 
        uint256 _initialScoreMax,  
        uint256 _upgradeIncreases,
        uint256 _requiredLevel, 
        uint256 _multiplier
    ) external onlyOwner {
        thresholds[_indexAttribute] = Thresholds(
            _initialScoreMax, 
            _upgradeIncreases,
            _requiredLevel,
            _multiplier
        );
    }

    // Set file format
    function setFileFormat(string memory _format) public onlyOwner {
        fileFormat = _format;
    }

    // Generation of a new random room
    function createBedroom(uint256 _randomNumber,  uint256 _tokenId) internal {
        tokenIdToNftSpecifications[_tokenId] = NftSpecifications(
            (_randomNumber % thresholds[0].initialScoreMax),
            (_randomNumber % thresholds[1].initialScoreMax),
            (_randomNumber % thresholds[2].initialScoreMax),
            (_randomNumber % thresholds[3].initialScoreMax),
            (_randomNumber % thresholds[4].initialScoreMax),
            (_randomNumber % thresholds[5].initialScoreMax),
            (_randomNumber % thresholds[6].initialScoreMax),
            (_randomNumber % thresholds[7].initialScoreMax),
            (_randomNumber % thresholds[8].initialScoreMax),
            (_randomNumber % thresholds[9].initialScoreMax),
            (_randomNumber % thresholds[10].initialScoreMax),
            (_randomNumber % thresholds[11].initialScoreMax),
            (_randomNumber % thresholds[12].initialScoreMax),
            (_randomNumber % thresholds[13].initialScoreMax),
            (_randomNumber % thresholds[14].initialScoreMax),
            (_randomNumber % thresholds[15].initialScoreMax)
        );
    }

    // Updating a bedroom object 
    function updateBedroom(uint256 _tokenId) internal {   
        uint256[16] memory newPoints;
        uint256 level = tokenIdToNftOwnership[_tokenId].level;

        for (uint256 i=0; i<16; i++) {
            Thresholds memory _thresholds = thresholds[i];
            uint256 points = getNftSpecifications(_tokenId, i);

            if (level >= _thresholds.requiredLevel) {
                if (points < 100) {
                    points += _thresholds.upgradeIncreases * _thresholds.multiplier;
                    if (points > 100) {
                        points = 100;
                    }
                }
                newPoints[i] = points;
            }
        }

        tokenIdToNftSpecifications[_tokenId] = NftSpecifications(
            newPoints[0],
            newPoints[1],
            newPoints[2],
            newPoints[3],
            newPoints[4],
            newPoints[5],
            newPoints[6],
            newPoints[7],
            newPoints[8],
            newPoints[9],
            newPoints[10],
            newPoints[11],
            newPoints[12],
            newPoints[13],
            newPoints[14],
            newPoints[15]
        );
    }

    // This function is creating a new random bedroom NFT by generating a random number
    function mintingBedroomNft(uint256 _designId, uint256 _price, uint256 _categorie, address _owner) external {
        require(nftDexAddress != address(0), "Dex address is not configured");
        require(msg.sender == nftDexAddress, "Access forbidden");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWord
        );

        requestIdToTokenId[requestId] = tokenId;

        tokenIdToNftOwnership[tokenId] = NftOwnership(_owner, _price, _designId, 0, _categorie);

        // Index of next NFT 
        tokenId++;
    }

    // Get Token Name
    function getName(uint256 _tokenId) public view returns (string memory) {
        return string(
            abi.encodePacked(
                "Token #",
                Strings.toString(_tokenId), 
                " Level ", 
                Strings.toString(tokenIdToNftOwnership[_tokenId].level)
            )
        );
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        _mintingBedroomNft(requestIdToTokenId[requestId], randomWords[0]);
        emit ReturnedRandomness(randomWords);
    }

    function _mintingBedroomNft(uint256 _tokenId, uint256 _randomWord) internal {
        // Create new Bedroom 
        createBedroom(_randomWord, _tokenId);

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
    function upgradeBedroomNft(uint256 _tokenId, uint256 _newDesignId, uint256 _amount, uint256 _action) external {
        require(nftDexAddress != address(0), "Dex address is not configured");
        require(msg.sender == nftDexAddress, "Access forbidden");

        // Update Bedroom 
        updateBedroom(_tokenId); 

        // Set Token Level
        tokenIdToNftOwnership[_tokenId].level++;
        
        // Set Token price
        tokenIdToNftOwnership[_tokenId].price += _amount;

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(_newDesignId), 
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNftUpgrading(
            _tokenId, 
            uri(_tokenId),
            tokenIdToNftSpecifications[_tokenId]
        );
    }

    // This implementation returns the concatenation of the _baseURI and the token-specific uri if the latter is set
    function uri(uint256 _tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(_tokenId);
    }

    // Sets tokenURI as the tokenURI of tokenId.
    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public onlyOwner {
        _setURI(_tokenId, _tokenURI);
    }

    // Sets baseURI as the _baseURI for all tokens
    function setBaseURI(string memory _baseURI) public onlyOwner {
        _setBaseURI(_baseURI);
    }


    // Hook that is called before any token transfer.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}