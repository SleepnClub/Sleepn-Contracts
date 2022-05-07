// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract BedroomNFT is VRFConsumerBaseV2, ERC1155, Ownable, Pausable, ERC1155Supply {
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;

    uint64 immutable internal subscriptionId; 
    bytes32 immutable internal keyHash;     
    uint32 immutable internal callbackGasLimit;
    uint16 immutable internal requestConfirmations;
    uint32 immutable internal numWord;

    uint256 public randomResult;

    struct Bedroom {
        string name;
        uint256 investmentBalance;
        uint256 nbUpgrades;
        uint256 decorationScore;
        uint256 lightIsolationScore;
        uint256 thermalIsolationScore;
        uint256 soundIsolationScore;
        uint256 temperatureScore;
        uint256 humidityScore;
        uint256 sleepAidMachinesScore;
    }

    struct Bed {
        string name;
        uint256 nbUpgrades;
        uint256 investmentBalance;
        uint256 sizeScore;
        uint256 heightScore;
        uint256 bedBaseMaterialScore;
        uint256 bedBaseThicknessScore; 
        uint256 bedBaseLegsScore;
        uint256 bedBaseApparenceScore;
        uint256 mattressTechnologyScore;
        uint256 mattressThicknessScore; 
        uint256 mattressFillingScore;
        uint256 mattressTopQuiltingScore;
        uint256 deformationDepthScore;
        uint256 deformationSpeedScore;
        uint256 deformationPersistenceScore;
        uint256 supportScore;
        uint256 suspensionScore;
        uint256 thermalIsolationScore;
        uint256 hygrometricRegulationScore;
        uint256 comforterTechnologyScore;
        uint256 comforterFillingScore;
        uint256 comforterSizeScore;
        uint256 comforterApparenceScore;
        uint256 pillowSizeScore;
        uint256 pillowTechnologyScore;
        uint256 pillowFillingScore;
        uint256 pillowApparenceScore;
    }

    // Array of all Bedroom NFT
    Bedroom[] public bedrooms;

    // Mappings
    mapping(uint256 => string) public requestToBedroomName; 
    mapping(uint256 => address) public requestToAddress;
    mapping(uint256 => address) public requestToValue;
    mapping(uint256 => uint256) public requestToTokenId; 
    mapping(uint256 => Bed) public TokenIdToBed;
    
    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        address _link_token_contract,
        bytes32 _keyHash,
        uint32  _callbackGasLimit,
        uint16 _requestConfirmation,
        uint32 _numWord
    ) 
    VRFConsumerBaseV2(_vrfCoordinator) 
    ERC1155("") 
    {

        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(_link_token_contract);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmation;
        numWord = _numWord;

    }
       
    function newRandomBedroom(string memory _name) public returns (uint256) {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWord
        );
        requestToBedroomName[requestId] = _name;
        requestToAddress[requestId] = msg.sender;
        requestToValue[requestId] = msg.value; 
        return requestId;
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomness(uint256 _requestId, uint256 _randomNumber) internal override {
        // New Bedroom
        Bedroom bedroom = new Bedroom(
            requestToBedroomName[_requestId],
            0,
            requestToValue[_requestId],
            _randomNumber%100, 
            (_randomNumber%800)/10, 
            (_randomNumber%8000)/100, 
            (_randomNumber%80000)/1000, 
            (_randomNumber%800000)/10000, 
            (_randomNumber%8000000)/100000, 
            (_randomNumber%80000000)/100000
        );

        // New Bed
        Bed bed = new Bed(
            requestToBedroomName[_requestId],
            0,
            0,
            (_randomNumber%50000)/1000, 
            (_randomNumber%85000)/1000,
            (_randomNumber%60000)/1000, 
            (_randomNumber%65000)/1000, 
            (_randomNumber%1000)/100, 
            (_randomNumber%1000)/10, 
            (_randomNumber%600000)/10000,, 
            (_randomNumber%70000)/1000, 
            (_randomNumber%600000)/10000, 
            (_randomNumber%8000000)/100000,
            (_randomNumber%7000000)/100000, 
            (_randomNumber%7000000)/100000, 
            (_randomNumber%7000000)/100000, 
            (_randomNumber%8000000)/100000, 
            (_randomNumber%8000000)/100000, 
            (_randomNumber%800000000)/10000000, 
            (_randomNumber%800000000)/10000000, 
            (_randomNumber%1000)/10, 
            (_randomNumber%70000)/1000,
            (_randomNumber%70000)/1000, 
            (_randomNumber%80000)/1000),
            (_randomNumber%8000)/100, 
            (_randomNumber%50000)/1000, 
            (_randomNumber%60000)/1000, 
            (_randomNumber%8000)/100 
        );

        // Storage of the new Bedroom
        bedrooms.push(bedroom);
        
        // Index of the new Bedroom NFT 
        uint256 tokenId = bedrooms.length - 1;

        // Minting of the new Bedroom NFT 
        _mint(requestToAddress, tokenId, 1, "");

        // Maps new token Id to new Bed
        tokenIdToBed[tokenId] = Bed;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
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