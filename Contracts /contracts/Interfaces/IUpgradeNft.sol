// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./IBedroomNft.sol";

struct UpgradeSpecifications {
    uint256 attributeIndex;
    uint256 attributeValue;
    address owner;
    uint256 price;
    uint256 designId;
}

interface IUpgradeNft is IERC1155Upgradeable {
    function setDex(address _dexAddress) external;

    function setBedroomNft(IBedroomNft _bedroomNftAddress) external;

    function setUpgradeValueMax(uint256 _newValue) external;

    function updateChainlink(
        uint32 _callbackGasLimit,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) external;

    function mintingUpgradeNft(
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _price,
        uint256 _indexAttribute,
        address _owner
    ) external;

    function setFileFormat(string memory _format) external;

    function getName(uint256 _tokenId) external pure returns (string memory);

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    function setBaseURI(string memory _baseURI) external;
}
