// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract BedroomNFT is VRFConsumerBaseV2, ERC1155, Ownable, Pausable, ERC1155Supply, ERC1155URIStorage {
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;
    uint64 immutable internal subscriptionId; 
    bytes32 immutable internal keyHash;     
    uint32 immutable internal callbackGasLimit;
    uint16 immutable internal requestConfirmations;
    uint32 immutable internal numWord;

    // Bedroom object
    struct Bedroom {
        string name;
        uint256 nbUpgrades; 
        uint256 lightIsolationScore; // Index 0
        uint256 thermalIsolationScore; // Index 1
        uint256 soundIsolationScore; // Index 2
        uint256 temperatureScore; // Index 3
        uint256 humidityScore; // Index 4
        uint256 sleepAidMachinesScore; // Index 5
    }

    // Bed object
    struct Bed {
        uint256 nbUpgrades; 
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

    // Score thresholds 
    struct Thresholds {
        uint256 initialScoreMax;
        uint256 upgradeIncreases;
    }

    // Number of NFT 
    uint256 public tokenId;

    // Mappings
    mapping(uint256 => address) public tokenIdToAddress;
    mapping(uint256 => Bedroom) public tokenIdToBedroom;
    mapping(uint256 => Bed) public tokenIdToBed;
    mapping(uint256 => Thresholds) public thresholds;

    // Events
    event MintingBedroomNFT(
        uint256 _tokenID, 
        string _tokenURI,
        Bedroom _bedroom,
        Bed _bed, 
        address _owner
    );

    event UpgradingBedroomNFT(
        uint256 _tokenID, 
        string _newTokenURI,
        Bedroom _newBedroom,
        Bed _newBed, 
        address _owner
    );
    
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

    // Set a new thresholds
    function setThresholds(
        uint256 _indexAttribute, 
        uint256 _initialScoreMax,  
        uint256 _upgradeIncreases
    ) public onlyOwner {
        thresholds[_indexAttribute].initialScoreMax = _initialScoreMax;
        thresholds[_indexAttribute].upgradeIncreases = _upgradeIncreases;
    }

    // This function is creating a new random bedroom NFT by generating a random number
    function newRandomBedroom() public onlyOwner {
        tokenIdToAddress[tokenId] = msg.sender;
        COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWord
        );
    }

    // Creating a new random bedroom object 
    function createBedroom(uint256 _randomNumber,  uint256 _tokenId) internal {
        // New Bedroom
        string memory name = string(abi.encodePacked("token #", Strings.toString(_tokenId)));
        Bedroom memory bedroom = Bedroom(
            name,
            0,
            (_randomNumber % thresholds[0].initialScoreMax), 
            (_randomNumber % thresholds[1].initialScoreMax), 
            (_randomNumber % thresholds[2].initialScoreMax), 
            (_randomNumber % thresholds[3].initialScoreMax), 
            (_randomNumber % thresholds[4].initialScoreMax), 
            (_randomNumber % thresholds[5].initialScoreMax)
        );
        // Storage of the new Bedroom
        tokenIdToBedroom[_tokenId] = bedroom;
        // Increment the index
        tokenId++;
    }

    // Updating a bedroom object 
    function updateBedroom(uint256 _tokenId) internal {
        // nbUpgrades
        tokenIdToBedroom[_tokenId].nbUpgrades++;
        // name
        tokenIdToBedroom[_tokenId].name = string(
            abi.encodePacked(
                tokenIdToBedroom[_tokenId].name, 
                " Upgrade ", 
                Strings.toString(tokenIdToBedroom[_tokenId].nbUpgrades)
            )
        );
        // humidityScore
        uint256 _humidityScore = tokenIdToBedroom[_tokenId].humidityScore;
        tokenIdToBedroom[_tokenId].humidityScore = _humidityScore + thresholds[4].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].humidityScore > 100) {
            tokenIdToBedroom[_tokenId].humidityScore = 100;
        }
        // lightIsolationScore
        uint256 _lightIsolationScore = tokenIdToBedroom[_tokenId].lightIsolationScore;
        tokenIdToBedroom[_tokenId].lightIsolationScore =_lightIsolationScore + thresholds[0].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].lightIsolationScore > 100) {
            tokenIdToBedroom[_tokenId].lightIsolationScore = 100;
        }
        // thermalIsolationScore
        uint256 _thermalIsolationScore = tokenIdToBedroom[_tokenId].thermalIsolationScore;
        tokenIdToBedroom[_tokenId].thermalIsolationScore = _thermalIsolationScore + thresholds[1].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].thermalIsolationScore > 100) {
            tokenIdToBedroom[_tokenId].thermalIsolationScore = 100;
        }
        // soundIsolationScore
        uint256 _soundIsolationScore = tokenIdToBedroom[_tokenId].soundIsolationScore;
        tokenIdToBedroom[_tokenId].soundIsolationScore = _soundIsolationScore + thresholds[2].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].soundIsolationScore > 100) {
            tokenIdToBedroom[_tokenId].soundIsolationScore = 100;
        }
        // temperatureScore
        uint256 _temperatureScore = tokenIdToBedroom[_tokenId].temperatureScore;
        tokenIdToBedroom[_tokenId].temperatureScore = _temperatureScore + thresholds[3].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].temperatureScore > 100) {
            tokenIdToBedroom[_tokenId].temperatureScore = 100;
        }
        // sleepAidMachinesScore
        uint256 _sleepAidMachinesScore = tokenIdToBedroom[_tokenId].sleepAidMachinesScore;
        tokenIdToBedroom[_tokenId].sleepAidMachinesScore = _sleepAidMachinesScore + thresholds[5].upgradeIncreases;
        if (tokenIdToBedroom[_tokenId].sleepAidMachinesScore > 100) {
            tokenIdToBedroom[_tokenId].sleepAidMachinesScore = 100;
        }
    }

    // Creating a new random Bed object 
    function createBed(uint256 _randomNumber, uint256 _tokenId) internal {
        // New Bed
        Bed memory bed = Bed(
            0,
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
        // Storage of the new Bed
        tokenIdToBed[_tokenId] = bed;
    }

    // Updating a Bed object 
    function updateBed(uint256 _tokenId) internal {  
        // sizeScore
        uint256 _sizeScore = tokenIdToBed[_tokenId].sizeScore;
        tokenIdToBed[_tokenId].sizeScore = _sizeScore + thresholds[6].upgradeIncreases;
        if (tokenIdToBed[_tokenId].sizeScore > 100) {
            tokenIdToBed[_tokenId].sizeScore = 100;
        }

        // heightScore
        uint256 _heightScore = tokenIdToBed[_tokenId].heightScore;
        tokenIdToBed[_tokenId].heightScore = _heightScore + thresholds[7].upgradeIncreases;
        if (tokenIdToBed[_tokenId].heightScore > 100) {
            tokenIdToBed[_tokenId].heightScore = 100;
        }

        // bedBaseScore
        uint256 _bedBaseScore = tokenIdToBed[_tokenId].bedBaseScore;
        tokenIdToBed[_tokenId].bedBaseScore = _bedBaseScore + thresholds[8].upgradeIncreases;
        if (tokenIdToBed[_tokenId].bedBaseScore > 100) {
            tokenIdToBed[_tokenId].bedBaseScore = 100;
        }
        
        // mattressTechnologyScore
        uint256 _mattressTechnologyScore = tokenIdToBed[_tokenId].mattressTechnologyScore;
        tokenIdToBed[_tokenId].mattressTechnologyScore = _mattressTechnologyScore + thresholds[9].upgradeIncreases;
        if (tokenIdToBed[_tokenId].mattressTechnologyScore > 100) {
            tokenIdToBed[_tokenId].mattressTechnologyScore = 100;
        }
        
        // mattressThicknessScore
        uint256 _mattressThicknessScore = tokenIdToBed[_tokenId].mattressThicknessScore;
        tokenIdToBed[_tokenId].mattressThicknessScore = _mattressThicknessScore + thresholds[10].upgradeIncreases;
        if (tokenIdToBed[_tokenId].mattressThicknessScore > 100) {
            tokenIdToBed[_tokenId].mattressThicknessScore = 100;
        }
        
        // mattressDeformationScore
        uint256 _mattressDeformationScore = tokenIdToBed[_tokenId].mattressDeformationScore;
        tokenIdToBed[_tokenId].mattressDeformationScore = _mattressDeformationScore + thresholds[11].upgradeIncreases;
        if (tokenIdToBed[_tokenId].mattressDeformationScore > 100) {
            tokenIdToBed[_tokenId].mattressDeformationScore = 100;
        }
        
        // thermalIsolationScore
        uint256 _thermalIsolationScore = tokenIdToBed[_tokenId].thermalIsolationScore;
        tokenIdToBed[_tokenId].thermalIsolationScore = _thermalIsolationScore + thresholds[12].upgradeIncreases;
        if (tokenIdToBed[_tokenId].thermalIsolationScore > 100) {
            tokenIdToBed[_tokenId].thermalIsolationScore = 100;
        }
        
        // hygrometricRegulationScore
        uint256 _hygrometricRegulationScore = tokenIdToBed[_tokenId].hygrometricRegulationScore;
        tokenIdToBed[_tokenId].hygrometricRegulationScore = _hygrometricRegulationScore + thresholds[13].upgradeIncreases;
        if (tokenIdToBed[_tokenId].hygrometricRegulationScore > 100) {
            tokenIdToBed[_tokenId].hygrometricRegulationScore = 100;
        }
        
        // comforterComfortabilityScore
        uint256 _comforterComfortabilityScore = tokenIdToBed[_tokenId].comforterComfortabilityScore;
        tokenIdToBed[_tokenId].comforterComfortabilityScore = _comforterComfortabilityScore + thresholds[14].upgradeIncreases;
        if (tokenIdToBed[_tokenId].comforterComfortabilityScore > 100) {
            tokenIdToBed[_tokenId].comforterComfortabilityScore = 100;
        }
        
        // pillowComfortabilityScore
        uint256 _pillowComfortabilityScore = tokenIdToBed[_tokenId].pillowComfortabilityScore;
        tokenIdToBed[_tokenId].pillowComfortabilityScore = _pillowComfortabilityScore + thresholds[15].upgradeIncreases;
        if (tokenIdToBed[_tokenId].pillowComfortabilityScore > 100) {
            tokenIdToBed[_tokenId].pillowComfortabilityScore = 100;
        }
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        // Index of the new Bedroom NFT 
        uint256 _tokenId = tokenId;

        // Create new Bedroom 
        createBedroom(_randomWords[0], _tokenId);

        // Create new Bed
        createBed(_randomWords[0], _tokenId);

        // Minting of the new Bedroom NFT 
        _mint(tokenIdToAddress[_tokenId], _tokenId, 1, "");
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

    // Pause contract
    function pause() public onlyOwner {
        _pause();
    }

    // unPause contract
    function unpause() public onlyOwner {
        _unpause();
    }

    // Mint a Bedroom NFT
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    // Batched version of _mint
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // Hook that is called before any token transfer.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}