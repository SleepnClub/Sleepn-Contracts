// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


// NFT Categories
enum Category { Studio, Deluxe, Luxury }

interface BedroomNftInterface {
    function mintingBedroomNft(uint256 _designId, uint256 _price, Category _categorie, address _owner) external;
    function upgradeBedroomNft(uint256 _tokenId, uint256 _newDesignId, uint256 _amount, uint256 _action) external;
}

interface SleepTokenInterface {
    function burnFrom(address account, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract Dex is Initializable, OwnableUpgradeable {
    // Team Wallet 
    address internal teamWallet;

    // Sleep Token Contract 
    SleepTokenInterface public sleepToken;

    // Bedroom NFT Contract
    BedroomNftInterface public bedroomNft;

    // Prices Struct 
    struct NftPrices {
        uint256 purchaseCost;
        mapping(uint256 => uint256) upgradesPrices; 
    }

    // Prices
    mapping(Category => NftPrices) public prices;

    // Events
    event ReceivedMoney(address indexed sender, uint256 amount);
    event BuyNft(address indexed owner, Category categorie, uint256 designId);
    event UpgradeNft(
        address indexed owner, 
        Category categorie, 
        uint256 tokenId, 
        uint256 newDesignId, 
        uint256 amount,
        uint256 upgradeIndex
    );
    event WithdrawMoney(address indexed receiver, uint256 amount);

    // Init 
    function initialize(
        address _owner
    ) initializer public {
        walletTeam = _walletTeam;
    }

    // Set Team Wallet 
    function setTeamWallet(address _newAddress) public onlyOwner {
        teamWallet = _newAddress;
    }

    // Set NFT prices - Buying prices
    function setBuyingPrices(
        Category _categorie,
        uint256 _amount
    ) public onlyOwner {
        prices[_categorie].purchaseCost = _amount;
    }

    // Set NFT prices - Upgrading prices
    function setUpPrices(
        Category _categorie,
        uint256 _upgradeIndex,
        uint256 _amount
    ) public onlyOwner {
        prices[_categorie].upgradesPrices[_upgradeIndex] = _amount;
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
        require(address(bedroomNft) != address(0), "Address not configured");

        bedroomNft.mintingBedroomNft(_designId, msg.value, _categorie, msg.sender);
    }

    // Upgrade NFT
    function upgradeNft(
        Category _categorie, 
        uint256 _tokenId, 
        uint256 _newDesignId, 
        uint256 _amount,
        uint256 _upgradeIndex
    ) public {
        require(_amount == prices[_categorie].upgradesPrices[_upgradeIndex], "Wrong tx");
        require(address(bedroomNft) != address(0), "Address not configured");
        require(address(sleepToken) != address(0), "Address not configured");
        uint256 initialBalance = sleepToken.balanceOf(msg.sender);
        require(initialBalance >= _amount,"Not enough funds");
        // Tx to approve before 
        require(sleepToken.allowance(msg.sender, address(this)) >= _amount,"Check allowance");
        // Burns tokens 
        sleepToken.burnFrom(msg.sender, _amount); 
        // Checks that the tokens were burned
        require(sleepToken.balanceOf(msg.sender) + _amount == initialBalance, "An error occurred");
        // Upgrading of the NFT
        bedroomNft.upgradeBedroomNft(_tokenId, _newDesignId, _amount, _upgradeIndex);
        emit UpgradeNft(
            msg.sender, 
            _categorie, 
            _tokenId, 
            _newDesignId, 
            _amount,
            _upgradeIndex
        );
    }
 
    // Receive Money fallback function
    receive() external payable {
        emit ReceivedMoney(msg.sender, msg.value);
    }
}