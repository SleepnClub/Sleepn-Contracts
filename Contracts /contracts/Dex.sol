// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


// NFT Categories
enum Category { Studio, Deluxe, Luxury }

// BedroomNFT Ownership object
struct NftOwnership {
    address owner;
    uint256 price;
    uint256 designId;
    uint256 level; 
    Category category;
}

// BedroomNft Interface
interface BedroomNftInterface {
    function mintingBedroomNft(uint256 _designId, uint256 _price, Category _categorie, address _owner) external;
    function tokenIdToNftOwnership(
        uint256 _tokenId
    ) external returns (NftOwnership memory _struct);
}

// SleepToken Interface
interface SleepTokenInterface {
    function burnFrom(address account, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

// UpgradeNft Interface
interface UpgradeNftInterface {
    function mintingUpgradeNft(uint256 _newDesignId, uint256 _upgradeDesignId, uint256 _price, uint256 _indexAttribute, address _owner) external;
}

contract Dex is Initializable, OwnableUpgradeable {
    // Team Wallet 
    address internal teamWallet;

    // Sleep Token Contract 
    SleepTokenInterface public sleepTokenInstance;

    // Bedroom NFT Contract
    BedroomNftInterface public bedroomNftInstance;

    // UpgradeNFT Contract
    UpgradeNftInterface public upgradeNftInstance;

    // Prices
    struct NftPrices {
        uint256 purchaseCost; // Initial Cost 
        mapping(uint256 => uint256) upgradesPrices; // Upgrades Cost
    }

    // Prices
    mapping(Category => NftPrices) public prices;

    // Events
    event ReceivedMoney(address indexed sender, uint256 amount);
    event BuyNft(address indexed owner, Category category, uint256 designId);
    event UpgradeNft(
        address indexed owner, 
        Category category, 
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
        SleepTokenInterface _sleepToken,
        BedroomNftInterface _bedroomNft,
        UpgradeNftInterface _upgradeNft

    ) initializer public {
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
    function setBuyingPrices(
        Category _category,
        uint256 _amount
    ) public onlyOwner {
        prices[_category].purchaseCost = _amount;
    }

    // Set NFT prices - Upgrading prices
    function setUpgradePrices(
        Category _category,
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
    function buyNft(Category _categorie, uint256 _designId) public payable {
        require(msg.value >= prices[_categorie].purchaseCost, "Not enough money was sent");
        bedroomNftInstance.mintingBedroomNft(_designId, msg.value, _categorie, msg.sender);
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
        NftOwnership memory nftOwnership = bedroomNftInstance.tokenIdToNftOwnership(_tokenId);
        Category category = nftOwnership.category;

        // Sender is owner
        require(msg.sender == nftOwnership.owner, "Wrong sender");

        // Good amount of tokens 
        require(_amount == prices[category].upgradesPrices[_upgradeIndex], "Wrong tx");

        // Check Balance of sender
        uint256 initialBalance = sleepTokenInstance.balanceOf(msg.sender);
        require(initialBalance >= _amount,"Not enough funds");

        // Tx to approve before 
        require(sleepTokenInstance.allowance(msg.sender, address(this)) >= _amount,"Check allowance");

        // Burns tokens 
        sleepTokenInstance.burnFrom(msg.sender, _amount); 

        // Checks that the tokens were burned
        require(sleepTokenInstance.balanceOf(msg.sender) + _amount == initialBalance, "An error occurred");

        // Minting of the upgrade token
        upgradeNftInstance.mintingUpgradeNft(_newDesignId, _upgradeDesignId, _amount, _upgradeIndex, msg.sender);
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