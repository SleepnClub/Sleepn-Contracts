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

    // Prices
    struct NftPrices {
        uint256 purchaseCost; // Initial Cost
        mapping(uint256 => uint256) upgradesPrices; // Upgrades Cost
    }

    // Prices
    mapping(IBedroomNft.Category => NftPrices) public prices;

    // Events
    event ReceivedMoney(address indexed sender, uint256 amount);
    event BuyNft(address indexed owner, IBedroomNft.Category category, uint256 designId);
    event UpgradeNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 upgradeDesignId,
        uint256 upgradeIndex,
        uint256 amount
    );
    event WithdrawMoney(address indexed receiver, uint256 amount);

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
    function setBuyingPrices(IBedroomNft.Category _category, uint256 _amount)
        public
        onlyOwner
    {
        prices[_category].purchaseCost = _amount;
    }

    // Set NFT prices - Upgrading prices
    function setUpgradePrices(
        IBedroomNft.Category _category,
        uint256 _upgradeIndex,
        uint256 _amount
    ) public onlyOwner {
        prices[_category].upgradesPrices[_upgradeIndex] = _amount;
    }

    // Withdraw Money
    function withdrawMoney() internal {
        address payable teamWalletAddress = payable(teamWallet);
        uint256 amount = address(this).balance;

        teamWalletAddress.transfer(amount);

        emit WithdrawMoney(teamWalletAddress, amount);
    }

    // getBalance
    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    // Buy NFT
    function buyNft(IBedroomNft.Category _categorie, uint256 _designId) public payable {
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
        uint256 _amount
    ) public {
        // Get NFT informations
        IBedroomNft.NftOwnership memory nftOwnership = bedroomNftInstance
            .tokenIdToNftOwnership(_tokenId);
        IBedroomNft.Category category = nftOwnership.category;

        // Sender is owner
        require(msg.sender == nftOwnership.owner, "Wrong sender");

        // Good amount of tokens
        require(
            _amount == prices[category].upgradesPrices[_upgradeIndex],
            "Wrong tx"
        );

        // Check Balance of sender
        uint256 initialBalance = sleepTokenInstance.balanceOf(msg.sender);
        require(initialBalance >= _amount, "Not enough funds");

        // Tx to approve before
        require(
            sleepTokenInstance.allowance(msg.sender, address(this)) >= _amount,
            "Check allowance"
        );

        // Burns tokens
        sleepTokenInstance.burnFrom(msg.sender, _amount);

        // Checks that the tokens were burned
        require(
            sleepTokenInstance.balanceOf(msg.sender) + _amount ==
                initialBalance,
            "An error occurred"
        );

        // Minting of the upgrade token
        upgradeNftInstance.mintingUpgradeNft(
            _newDesignId,
            _upgradeDesignId,
            _amount,
            _upgradeIndex,
            msg.sender
        );
        emit UpgradeNft(
            msg.sender,
            category,
            _tokenId,
            _newDesignId,
            _upgradeDesignId,
            _upgradeIndex,
            _amount
        );
    }

    // Receive Money fallback function
    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}
