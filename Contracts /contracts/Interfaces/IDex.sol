// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IBedroomNft.sol";

interface IDex {
    event ReceivedMoney(address indexed sender, uint256 price);
    event BuyNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 designId
    );
    event UpgradeNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 upgradeDesignId,
        uint256 upgradeIndex,
        uint256 price
    );
    event WithdrawMoney(address indexed receiver, uint256 price);

    function setTeamWallet(address _newAddress) external;

    function setBuyingPrices(IBedroomNft.Category _category, uint256 _price)
        external;

    function setUpgradePrices(
        IBedroomNft.Category _category,
        uint256 _upgradeIndex,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        uint256 _price
    ) external;

    function withdrawMoney() external;

    function getBalance() external view returns (uint256);

    function buyNft(IBedroomNft.Category _categorie, uint256 _designId)
        external
        payable;

    function upgradeNft(
        uint256 _tokenId,
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _upgradeIndex,
        uint256 _price
    ) external;

}