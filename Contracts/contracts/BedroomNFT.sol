// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract BedroomNft is VRFConsumerBaseV2, ERC1155, Ownable, ERC1155Supply, ERC1155URIStorage {
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
        uint256 price; // Price - Index 16
        uint256 designId; // Design Id - Index 17
        uint256 level; // Level - Index 18
    }

    // Score thresholds 
    struct Thresholds {
        uint256 initialScoreMax; // Initial Score Maximum value 
        uint256 upgradeIncreases; // Number of percents per increase 
        uint256 requiredLevel; // Required level to be unlock
    }

    // File format
    string public fileFormat;

    // Number of NFT 
    uint256 public tokenId;

    // Mappings
    mapping(uint256 => uint256) public requestIdToTokenId;
    mapping(uint256 => address) public tokenIdToOwner;
    mapping(uint256 => NftSpecifications) tokenIdToNftSpecifications; 
    mapping(uint256 => Thresholds) public thresholds;

    // Events
    event BedroomNFTMinting(
        uint256 tokenId, 
        string tokenURI,
        NftSpecifications specifications
    );
    event BedroomNFTUpgrading(
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

    // Get NFT Specifications
    function getNftSpecifications(
        uint256 _tokenId, 
        uint256 _indexAttribute
    ) external view returns (uint256) {
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
        if (_indexAttribute == 16) {
            return tokenIdToNftSpecifications[_tokenId].price;
        }
        if (_indexAttribute == 17) {
            return tokenIdToNftSpecifications[_tokenId].designId;
        }
        if (_indexAttribute == 18) {
            return tokenIdToNftSpecifications[_tokenId].level;
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
        uint256 _requiredLevel
    ) external onlyOwner {
        thresholds[_indexAttribute].initialScoreMax = _initialScoreMax;
        thresholds[_indexAttribute].upgradeIncreases = _upgradeIncreases;
        thresholds[_indexAttribute].requiredLevel = _requiredLevel;
    }

    // Set file format
    function setFileFormat(string memory _format) public onlyOwner {
        fileFormat = _format;
    }

    // Generation of a new random room
    function createBedroom(uint256 _randomNumber,  uint256 _tokenId) internal {
        // Light Isolation Score
        tokenIdToNftSpecifications[_tokenId].lightIsolationScore = (_randomNumber % thresholds[0].initialScoreMax); // Index 0
        // Thermal Isolation Score
        tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore = (_randomNumber % thresholds[1].initialScoreMax); // Index 1
        // Sound Isolation Score
        tokenIdToNftSpecifications[_tokenId].soundIsolationScore = (_randomNumber % thresholds[2].initialScoreMax); // Index 2
        // Temperature Score
        tokenIdToNftSpecifications[_tokenId].temperatureScore = (_randomNumber % thresholds[3].initialScoreMax); // Index 3
        // Humidity Score
        tokenIdToNftSpecifications[_tokenId].humidityScore = (_randomNumber % thresholds[4].initialScoreMax); // Index 4
        // Sleep Aid Machines Score
        tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore = (_randomNumber % thresholds[5].initialScoreMax); // Index 5
         // Size Score
        tokenIdToNftSpecifications[_tokenId].sizeScore = (_randomNumber % thresholds[6].initialScoreMax); // Index 6
        // Height Score
        tokenIdToNftSpecifications[_tokenId].heightScore = (_randomNumber % thresholds[7].initialScoreMax); // Index 7
        // Bed Base Score
        tokenIdToNftSpecifications[_tokenId].bedBaseScore = (_randomNumber % thresholds[8].initialScoreMax); // Index 8
        // Mattress Technology Score
        tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore = (_randomNumber % thresholds[9].initialScoreMax); // Index 9
        // Mattress Thickness Score
        tokenIdToNftSpecifications[_tokenId].mattressThicknessScore = (_randomNumber % thresholds[10].initialScoreMax); // Index 10
        // Mattress Deformation Score 
        tokenIdToNftSpecifications[_tokenId].mattressDeformationScore = (_randomNumber % thresholds[11].initialScoreMax); // Index 11
        // Thermal Isolation Score
        tokenIdToNftSpecifications[_tokenId].thermalIsolationScore = (_randomNumber % thresholds[12].initialScoreMax); // Index 12
        // Hygrometric Regulation Score
        tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore = (_randomNumber % thresholds[13].initialScoreMax); // Index 13
        // Comforter Comfortability Score
        tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore = (_randomNumber % thresholds[14].initialScoreMax); // Index 14
        // Pillow Comfortability Score
        tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore = (_randomNumber % thresholds[15].initialScoreMax); // Index 15
    }

    // Updating a bedroom object 
    function updateBedroom(uint256 _tokenId) internal {    
        // lightIsolationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[0].requiredLevel) {
            uint256 _lightIsolationScore = tokenIdToNftSpecifications[_tokenId].lightIsolationScore;
            if (_lightIsolationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].lightIsolationScore =_lightIsolationScore + thresholds[0].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].lightIsolationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].lightIsolationScore = 100;
                }
            }
        }
    
        // bedroomThermalIsolationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[1].requiredLevel) {
            uint256 _bedroomThermalIsolationScore = tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore;
            if (_bedroomThermalIsolationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore = _bedroomThermalIsolationScore + thresholds[1].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].bedroomThermalIsolationScore = 100;
                }
            }
        }

        
        // soundIsolationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[2].requiredLevel) {
            uint256 _soundIsolationScore = tokenIdToNftSpecifications[_tokenId].soundIsolationScore;
            if (_soundIsolationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].soundIsolationScore = _soundIsolationScore + thresholds[2].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].soundIsolationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].soundIsolationScore = 100;
                }
            }   
        }

        // temperatureScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[3].requiredLevel) {
            uint256 _temperatureScore = tokenIdToNftSpecifications[_tokenId].temperatureScore;
            if (_temperatureScore < 100) {
                tokenIdToNftSpecifications[_tokenId].temperatureScore = _temperatureScore + thresholds[3].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].temperatureScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].temperatureScore = 100;
                }
            }
        }

        // humidityScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[4].requiredLevel) {
            uint256 _humidityScore = tokenIdToNftSpecifications[_tokenId].humidityScore;
            if (_humidityScore < 100) {
                tokenIdToNftSpecifications[_tokenId].humidityScore = _humidityScore + thresholds[4].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].humidityScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].humidityScore = 100;
                }
            }
        }

        // sleepAidMachinesScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[5].requiredLevel) {
            uint256 _sleepAidMachinesScore = tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore;
            if (_sleepAidMachinesScore < 100) {
                tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore = _sleepAidMachinesScore + thresholds[5].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].sleepAidMachinesScore = 100;
                }
            }
        }

        // sizeScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[6].requiredLevel) {
            uint256 _sizeScore = tokenIdToNftSpecifications[_tokenId].sizeScore;
            if (_sizeScore < 100) {
                tokenIdToNftSpecifications[_tokenId].sizeScore = _sizeScore + thresholds[6].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].sizeScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].sizeScore = 100;
                }
            }
        }

        // heightScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[7].requiredLevel) {
            uint256 _heightScore = tokenIdToNftSpecifications[_tokenId].heightScore;
            if (_heightScore < 100) {
                tokenIdToNftSpecifications[_tokenId].heightScore = _heightScore + thresholds[7].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].heightScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].heightScore = 100;
                }
            }           
        }

        // bedBaseScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[8].requiredLevel) {
            uint256 _bedBaseScore = tokenIdToNftSpecifications[_tokenId].bedBaseScore;
            if (_bedBaseScore < 100) {
                tokenIdToNftSpecifications[_tokenId].bedBaseScore = _bedBaseScore + thresholds[8].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].bedBaseScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].bedBaseScore = 100;
                }
            }          
        }
        
        // mattressTechnologyScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[9].requiredLevel) {
            uint256 _mattressTechnologyScore = tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore;
            if (_mattressTechnologyScore < 100) {
                tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore = _mattressTechnologyScore + thresholds[9].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].mattressTechnologyScore = 100;
                }
            }            
        }

        // mattressThicknessScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[10].requiredLevel) {
            uint256 _mattressThicknessScore = tokenIdToNftSpecifications[_tokenId].mattressThicknessScore;
            if (_mattressThicknessScore < 100) {
                tokenIdToNftSpecifications[_tokenId].mattressThicknessScore = _mattressThicknessScore + thresholds[10].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].mattressThicknessScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].mattressThicknessScore = 100;
                }
            }            
        }
  
        // mattressDeformationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[11].requiredLevel) {
            uint256 _mattressDeformationScore = tokenIdToNftSpecifications[_tokenId].mattressDeformationScore;
            if (_mattressDeformationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].mattressDeformationScore = _mattressDeformationScore + thresholds[11].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].mattressDeformationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].mattressDeformationScore = 100;
                }
            }           
        }

        // thermalIsolationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[12].requiredLevel) {
            uint256 _hygrometricRegulationScore = tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore;
            if (_hygrometricRegulationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore = _hygrometricRegulationScore + thresholds[13].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore = 100;
                }
            }          
        }
        
        // hygrometricRegulationScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[13].requiredLevel) {
            uint256 _hygrometricRegulationScore = tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore;
            if (_hygrometricRegulationScore < 100) {
                tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore = _hygrometricRegulationScore + thresholds[13].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].hygrometricRegulationScore = 100;
                }
            }            
        }
        
        // comforterComfortabilityScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[14].requiredLevel) {
            uint256 _comforterComfortabilityScore = tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore;
            if (_comforterComfortabilityScore < 100) {
                tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore = _comforterComfortabilityScore + thresholds[14].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].comforterComfortabilityScore = 100;
                }
            }           
        }

        // pillowComfortabilityScore
        if (tokenIdToNftSpecifications[_tokenId].level >= thresholds[15].requiredLevel) {
            uint256 _pillowComfortabilityScore = tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore;
            if (_pillowComfortabilityScore < 100) {
                tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore = _pillowComfortabilityScore + thresholds[15].upgradeIncreases;
                if (tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore > 100) {
                    tokenIdToNftSpecifications[_tokenId].pillowComfortabilityScore = 100;
                }
            }            
        }
    }

    // This function is creating a new random bedroom NFT by generating a random number
    function mintingBedroomNft(uint256 _designId, address _owner) public onlyOwner {
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWord
        );
        requestIdToTokenId[requestId] = tokenId;
        tokenIdToOwner[tokenId] = _owner;
        tokenIdToNftSpecifications[tokenId].designId = _designId;

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
                Strings.toString(tokenIdToNftSpecifications[_tokenId].level)
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
        _mint(tokenIdToOwner[tokenId], _tokenId, 1, "");

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(tokenIdToNftSpecifications[_tokenId].designId), 
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNFTMinting(
            _tokenId,
            uri(_tokenId),
            tokenIdToNftSpecifications[_tokenId]
        );
    }

    // NFT Upgrading
    function upgradeBedroomNft(uint256 _tokenId, uint256 _newDesignId) public onlyOwner {
        // Update Bedroom 
        updateBedroom(_tokenId); 

        // Set Token Level
        tokenIdToNftSpecifications[_tokenId].level++;

        // Set Token URI
        string memory DesignName = string(
            abi.encodePacked(
                Strings.toString(_newDesignId), 
                fileFormat
            )
        );
        _setURI(_tokenId, DesignName);

        emit BedroomNFTUpgrading(
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