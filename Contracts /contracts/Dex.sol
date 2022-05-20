// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Interfaces/ISleepToken.sol";
import "./Interfaces/IBedroomNft.sol";
import "./Interfaces/IUpgradeNft.sol";

contract Dex is Initializable, OwnableUpgradeable {
    // Team Wallet
    address internal teamWallet;

    // Sleep Token Contract
    ISleepToken public sleepTokenInstance;

    // Bedroom NFT Contract
    IBedroomNft public bedroomNftInstance;

    // UpgradeNFT Contract
    IUpgradeNft public upgradeNftInstance;

    /// @notice Informations about an upgrade
    struct upgradeInfos {
        uint256 indexAttribute;
        uint256 valueToAddMax;
        uint256 price;
    }

    /// @notice Purchase cost and Upgrade costs
    struct NftPrices {
        uint256 purchaseCost; // Initial Cost
        mapping(uint256 => upgradeInfos) upgradeCosts; // Upgrade Costs
    }

    /// @notice Purchase cost and Upgrade costs depending on the category of the NFT
    mapping(IBedroomNft.Category => NftPrices) public prices;

    // Events
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

    // Init
    function initialize(
        address _teamWallet,
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft
    ) public initializer {
        teamWallet = _teamWallet;
        sleepTokenInstance = _sleepToken;
        bedroomNftInstance = _bedroomNft;
        upgradeNftInstance = _upgradeNft;

        assert(address(sleepTokenInstance) != address(0));
        assert(address(bedroomNftInstance) != address(0));
        assert(address(upgradeNftInstance) != address(0));
    }

    // Set Team Wallet
    function setTeamWallet(address _newAddress) public onlyOwner {
        teamWallet = _newAddress;
    }

    // Set NFT prices - Buying prices
    function setBuyingPrices(IBedroomNft.Category _category, uint256 _price)
        public
        onlyOwner
    {
        prices[_category].purchaseCost = _price;
    }

    // Set NFT prices - Upgrading prices
    function setUpgradePrices(
        IBedroomNft.Category _category,
        uint256 _upgradeIndex,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        uint256 _price
    ) public onlyOwner {
        prices[_category].upgradeCosts[_upgradeIndex] = upgradeInfos(
            _upgradeIndex,
            _valueToAddMax,
            _price
        );
    }

    // Withdraw Money
    function withdrawMoney() internal {
        address payable teamWalletAddress = payable(teamWallet);
        uint256 price = address(this).balance;

        teamWalletAddress.transfer(price);

        emit WithdrawMoney(teamWalletAddress, price);
    }

    // getBalance
    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    // Buy NFT
    function buyNft(IBedroomNft.Category _categorie, uint256 _designId)
        public
        payable
    {
        require(
            msg.value >= prices[_categorie].purchaseCost,
            "Not enough money was sent"
        );
        bedroomNftInstance.mintingBedroomNft(
            _designId,
            msg.value,
            _categorie,
            msg.sender
        );
    }

    // Upgrade NFT
    function upgradeNft(
        uint256 _tokenId,
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _upgradeIndex,
        uint256 _price
    ) public {
        // Get NFT informations
        IBedroomNft.NftOwnership memory nftOwnership = bedroomNftInstance
            .tokenIdToNftOwnership(_tokenId);
        IBedroomNft.Category category = nftOwnership.category;

        // Get Upgrade infos
        uint256 price = prices[category].upgradeCosts[_upgradeIndex].price;
        uint256 value = prices[category].upgradeCosts[_upgradeIndex].valueToAddMax;
        uint256 index = prices[category].upgradeCosts[_upgradeIndex].indexAttribute;

        // Sender is owner
        require(msg.sender == nftOwnership.owner, "Wrong sender");

        // Good amount of tokens
        require(
            _price == price,
            "Wrong tx"
        );

        // Check Balance of sender
        uint256 initialBalance = sleepTokenInstance.balanceOf(msg.sender);
        require(initialBalance >= _price, "Not enough funds");

        // Tx to approve before
        require(
            sleepTokenInstance.allowance(msg.sender, address(this)) >= _price,
            "Check allowance"
        );

        // Burns tokens
        sleepTokenInstance.burnFrom(msg.sender, _price);

        // Checks that the tokens were burned
        require(
            sleepTokenInstance.balanceOf(msg.sender) + _price ==
                initialBalance,
            "An error occurred"
        );

        // Minting of the upgrade token
        upgradeNftInstance.mintingUpgradeNft(
            _newDesignId,
            _upgradeDesignId,
            _price,
            index,
            value,
            msg.sender
        );
        emit UpgradeNft(
            msg.sender,
            category,
            _tokenId,
            _newDesignId,
            _upgradeDesignId,
            _upgradeIndex,
            _price
        );
    }

    // Receive Money fallback function
    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}
