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
        uint256 investmentBalance;
        uint256 nbUpgrades;
        uint256 lightIsolationScore;
        uint256 thermalIsolationScore;
        uint256 soundIsolationScore;
        uint256 temperatureScore;
        uint256 humidityScore;
        uint256 sleepAidMachinesScore;
    }

    // Bed object
    struct Bed {
        uint256 sizeScore;
        uint256 heightScore;
        uint256 bedBaseScore;
        uint256 mattressTechnologyScore;
        uint256 mattressThicknessScore; 
        uint256 deformationDepthScore;
        uint256 deformationSpeedScore;
        uint256 deformationPersistenceScore;
        uint256 thermalIsolationScore;
        uint256 hygrometricRegulationScore;
        uint256 comforterComfortabilityScore;
        uint256 pillowComfortabilityScore;
    }

    // Array of all Bedroom objects
    Bedroom[] public bedrooms;

    // Mappings
    mapping(uint256 => address) public tokenIdToAddress;
    mapping(uint256 => Bed) public tokenIdToBed;
    
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
    }

    // This function is creating a new random bedroom NFT by generating a random number
    function newRandomBedroom() public onlyOwner {
        uint256 tokenId = bedrooms.length;
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
            0,
            (_randomNumber%80), 
            (_randomNumber%75), 
            (_randomNumber%70), 
            (_randomNumber%65), 
            (_randomNumber%60), 
            (_randomNumber%50)
        );
        // Storage of the new Bedroom
        bedrooms.push(bedroom);
    }

    // Creating a new random bed object 
    function createBed(uint256 _randomNumber, uint256 _tokenId) internal {
        // New Bed
        Bed memory bed = Bed(
            (_randomNumber%100), 
            (_randomNumber%95), 
            (_randomNumber%80), 
            (_randomNumber%75), 
            (_randomNumber%70), 
            (_randomNumber%65), 
            (_randomNumber%60), 
            (_randomNumber%55), 
            (_randomNumber%50), 
            (_randomNumber%52), 
            (_randomNumber%59), 
            (_randomNumber%64)
        );
        // Storage of the new Bed
        tokenIdToBed[_tokenId] = bed;
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        // Index of the new Bedroom NFT 
        uint256 tokenId = bedrooms.length;

        // Create new Bedroom 
        createBedroom(_randomWords[0], tokenId);

        // Create new Bed
        createBed(_randomWords[0], tokenId);

        // Minting of the new Bedroom NFT 
        _mint(tokenIdToAddress[tokenId], tokenId, 1, "");
    }

    function upgradeToken(uint256 _tokenId) public onlyOwner {

    }

    function uri(uint256 _tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(_tokenId);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}