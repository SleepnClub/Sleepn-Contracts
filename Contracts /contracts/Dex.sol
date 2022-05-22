// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Interfaces/ISleepToken.sol";
import "./Interfaces/IBedroomNft.sol";
import "./Interfaces/IUpgradeNft.sol";

/// @title GetSleepn Decentralized Exchange Contract
/// @author Alexis Balayre
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

    /// @notice Received Money Event
    event ReceivedMoney(address indexed sender, uint256 price);

    /// @notice Buy NFT Event
    event BuyNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 designId
    );

    /// @notice Upgrade NFT Event
    event UpgradeNft(
        address indexed owner,
        IBedroomNft.Category category,
        uint256 tokenId,
        uint256 newDesignId,
        uint256 upgradeDesignId,
        uint256 upgradeIndex,
        uint256 price
    );

    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed receiver, uint256 price);

    /// @notice Constructor 
    /// @param _teamWallet Team Wallet address
    /// @param _sleepToken Sleep Token Contract address
    /// @param _bedroomNft Bedroom NFT Contract address
    /// @param _UpgradeNft Upgrade NFT Contract address
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

    /// @notice Settles Team Wallet contract address
    /// @param _newAddress New Team Wallet address 
    /// @dev This function can only be called by the owner of the contract
    function setTeamWallet(address _newAddress) external onlyOwner {
        teamWallet = _newAddress;
    }

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @dev This function can only be called by the owner of the contract
    function setContracts(
        ISleepToken _sleepToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft
    ) external onlyOwner {
        sleepTokenInstance = _sleepToken;
        bedroomNftInstance = _bedroomNft;
        upgradeNftInstance = _upgradeNft;
    }

    /// @notice Settles NFTs purchase prices
    /// @param _category Category of the NFT
    /// @param _price Purchase price of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setBuyingPrices(IBedroomNft.Category _category, uint256 _price)
        external
        onlyOwner
    {
        prices[_category].purchaseCost = _price;
    }

    /// @notice Settles NFTs upgrade prices
    /// @param _category Category of the Bedroom NFT
    /// @param _upgradeIndex Index of the upgrade 
    /// @param _indexAttribute Index of the attribute concerned by the upgrade
    /// @param _valueToAddMax Value max to add to the existing score
    /// @param _price Purchase price of the Upgrade NFT
    /// @dev This function can only be called by the owner of the contract
    function setUpgradePrices(
        IBedroomNft.Category _category,
        uint256 _upgradeIndex,
        uint256 _indexAttribute,
        uint256 _valueToAddMax,
        uint256 _price
    ) external onlyOwner {
        prices[_category].upgradeCosts[_upgradeIndex] = upgradeInfos(
            _indexAttribute,
            _valueToAddMax,
            _price
        );
    }

    /// @notice Withdraws the money from the contract
    /// @dev This function can only be called by the owner of the contract
    function withdrawMoney() public onlyOwner {
        address payable to = payable(teamWallet);
        to.transfer(address(this).balance);
        emit WithdrawMoney(teamWallet, address(this).balance);
    }

    /// @notice Returns the balance of the contract
    /// @return _balance Balance of the contract
    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    /// @notice Launches the mint procedure of a Bedroom NFT
    /// @param _category Category of the desired Bedroom NFT
    /// @param _designId Design Id of the NFT
    function buyNft(IBedroomNft.Category _category, uint256 _designId)
        public
        payable
    {
        require(msg.value == prices[_category].purchaseCost*1e18, "Wrong tx");
        bedroomNftInstance.mintingBedroomNft(
            _designId,
            msg.value,
            _category,
            msg.sender
        );
        emit BuyNft(msg.sender, _category, _designId);
        emit ReceivedMoney(msg.sender, msg.value);
    }

    /// @notice Launches the mint procedure of a Bedroom NFT
    /// @param _tokenId Category of the desired Bedroom NFT
    /// @param _newDesignId Design Id of the NFT
    /// @param _upgradeDesignId Category of the desired Bedroom NFT
    /// @param _upgradeIndex Design Id of the NFT
    /// @param _price Design Id of the NFT
    function upgradeNft(
        uint256 _tokenId,
        uint256 _newDesignId,
        uint256 _upgradeDesignId,
        uint256 _upgradeIndex,
        uint256 _price
    ) external {
        // Get NFT informations
        IBedroomNft.NftOwnership memory nftOwnership = bedroomNftInstance
            .getNftOwnership(_tokenId);
        IBedroomNft.Category category = nftOwnership.category;

        // Get Upgrade infos
        uint256 price = prices[category].upgradeCosts[_upgradeIndex].price;
        uint256 value = prices[category]
            .upgradeCosts[_upgradeIndex]
            .valueToAddMax;
        uint256 index = prices[category]
            .upgradeCosts[_upgradeIndex]
            .indexAttribute;

        // Sender is owner
        require(msg.sender == nftOwnership.owner, "Wrong sender");

        // Good amount of tokens
        require(_price == price, "Wrong tx");

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
            sleepTokenInstance.balanceOf(msg.sender) + _price == initialBalance,
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
}
