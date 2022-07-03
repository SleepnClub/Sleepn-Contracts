// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Interfaces/ISleepToken.sol";
import "../Interfaces/IBedroomNft.sol";
import "../Interfaces/IUpgradeNft.sol";

/// @title Sleepn Decentralized Exchange Contract
/// @author Sleepn
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
contract Dex is Initializable, OwnableUpgradeable {
    /// @notice Dex Contract address
    address public teamWallet;

    /// @notice Sleep Token Contract
    ISleepToken public sleepTokenInstance;

    /// @notice Bedroom NFT Contract
    IBedroomNft public bedroomNftInstance;

    /// @notice UpgradeNFT Contract
    IUpgradeNft public upgradeNftInstance;

    /// @notice Purchase cost and Upgrade cost
    uint256 public purchaseCost;

    /// @notice Upgrade costs
    struct Upgrade {
        bool isOwned; // is Owned
        uint256 price; // Upgrade Cost
    }

    /// @notice Upgrade costs depending on the id of the Upgrade Nft
    mapping(uint256 => Upgrade) public upgradeCosts;

    /// @dev Dev Wallet
    address private devWallet;

    /// @notice Payment Token
    IERC20 public paymentToken;

    /// @notice Buy Bedroom NFT Event
    event BuyBedroomNft(
        address indexed owner,
        uint256 designId,
        uint256 price
    );

    /// @notice Buy Upgrade NFT Event
    event BuyUpgradeNft(
        address indexed owner,
        uint256 upgradeNftId,
        uint256 price
    );

    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed receiver, uint256 price);

    /// @dev Constructor
    /// @param _teamWallet Team Wallet address
    /// @param _sleepToken Sleep Token Contract address
    /// @param _bedroomNft Bedroom NFT Contract address
    /// @param _upgradeNft Upgrade NFT Contract address
    function initialize(
        address _teamWallet,
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft
    ) public initializer {
        __Ownable_init();
        teamWallet = _teamWallet;
        sleepTokenInstance = _sleepToken;
        bedroomNftInstance = _bedroomNft;
        upgradeNftInstance = _upgradeNft;

        assert(teamWallet != address(0));
        assert(address(bedroomNftInstance) != address(0));
        assert(address(upgradeNftInstance) != address(0));
        assert(address(sleepTokenInstance) != address(0));
    }

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @param _teamWallet New Team Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @param _tokenAddress New Payment Token contract address
    /// @dev This function can only be called by the owner of the contract
    function setAddresses(
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft,
        address _teamWallet,
        address _devWallet,
        IERC20 _tokenAddress
    ) external onlyOwner {
        sleepTokenInstance = _sleepToken;
        bedroomNftInstance = _bedroomNft;
        upgradeNftInstance = _upgradeNft;
        teamWallet = _teamWallet;
        devWallet = _devWallet;
        paymentToken = _tokenAddress;
    }

    /// @notice Settles NFTs purchase price
    /// @param _price Purchase price of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setBuyingPrice(uint256 _price)
        external
        onlyOwner
    {
        purchaseCost = _price;
    }

    /// @notice Settles NFTs upgrade price
    /// @param _upgradeId Id of the upgrade
    /// @param _price Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner of the contract
    function setUpgradePrice(
        uint256 _upgradeId,
        uint256 _price
    ) external onlyOwner {
        upgradeCosts[ _upgradeId].price = _price;
    }

    /// @notice Settles NFTs upgrade prices
    /// @param _upgradeIds Id of the upgrade
    /// @param _prices Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner or the dev Wallet
    function setUpgradePriceBatch(
        uint256[] memory _upgradeIds,
        uint256[] memory _prices
    ) external {
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );
        require(_upgradeIds.length == _prices.length, "ERC1155: _upgradeIds and _prices length mismatch");
        for(uint256 i = 0; i < _upgradeIds.length; i++) {
            uint256 upgradeId = _upgradeIds[i];
            uint256 price =  _prices[i];
            upgradeCosts[upgradeId].price = price;
        }
    }

    /// @notice Returns the price of an Upgrade Nft
    /// @param _id Id of the upgrade
    /// @return _price Price of the Upgrade Nft
    function getUpgradePrice(
        uint256 _id
    ) external view returns (uint256) {
        return upgradeCosts[_id].price;
    }

    /// @notice Withdraws the money from the contract
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney() external {
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );
        uint256 balance = paymentToken.balanceOf(address(this));
        paymentToken.transfer(teamWallet, balance);
        emit WithdrawMoney(teamWallet, balance);
    }

    /// @notice Returns the balance of the contract
    /// @return _balance Balance of the contract
    function getBalance() external view returns (uint256) {
        return paymentToken.balanceOf(address(this));
    }

    /// @notice Launches the mint procedure of a Bedroom NFT
    /// @param _designId Design Id of the NFT
    function buyBedroomNft(uint256 _designId)
        external
    {
        // Check Balance of sender
        require(paymentToken.balanceOf(msg.sender) >= purchaseCost * 1e17, "Not enough funds");

        // Check Allowance - tx to approve
        require(paymentToken.allowance(msg.sender, address(this)) >= purchaseCost * 1e17, "Check allowance");

        // Token Transfer
        paymentToken.transferFrom(msg.sender, address(this), purchaseCost * 1e17);

        // NFT Minting
        bedroomNftInstance.mintingBedroomNft(
            _designId,
            msg.sender
        );
        emit BuyBedroomNft(msg.sender, _designId, purchaseCost);
    }

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    function buyUpgradeNft(
        uint256 _upgradeNftId
    ) external {
        // Availability of Nft
        require(upgradeCosts[_upgradeNftId].isOwned == false, "Nft not available");

        // Price 
        uint256 price = upgradeCosts[_upgradeNftId].price;

        // Check Balance of sender
        require(sleepTokenInstance.balanceOf(msg.sender) >= price * 1e18, "Not enough funds");

        // Tx to approve before
        require(
            sleepTokenInstance.allowance(msg.sender, address(this)) >= price * 1e18,
            "Check allowance"
        );

        // Burns tokens
        sleepTokenInstance.burnFrom(msg.sender, price * 1e18);

        // Transfer ownership 
        upgradeNftInstance.transferUpgradeNft(_upgradeNftId, msg.sender);
        emit BuyUpgradeNft(
            msg.sender,
            _upgradeNftId,
            price
        );
    }

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    function linkUpgradeNft(
        uint256 _upgradeNftId, 
        uint256 _bedroomNftId, 
        uint256 _newDesignId
    ) external {
        upgradeNftInstance.linkUpgradeNft(
            _upgradeNftId,
            _bedroomNftId,
            _newDesignId,
            msg.sender
        );
    }

    /// @notice Airdrops some Bedroom NFTs
    /// @param _addresses Addresses of the receivers 
    /// @param _designId Design of the Bedroom NFTs
    /// @dev This function can only be called by the owner of the contract
    function airdropBedroomNFT(
        address[] memory _addresses, 
        uint256 _designId
    ) external onlyOwner {
        for(uint256 i=0; i<_addresses.length; i++) {
            bedroomNftInstance.mintingBedroomNft(
                _designId,
                _addresses[i]
            );
        }
    }

}
