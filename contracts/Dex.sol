// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Interfaces/ISleep.sol";
import "./Interfaces/IHealth.sol";
import "./Interfaces/IBedroomNft.sol";
import "./Interfaces/IUpgradeNft.sol";

/// @title GetSleepn Decentralized Exchange Contract
/// @author Sleepn
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
contract Dex is Initializable, OwnableUpgradeable {
    /// @notice Sleep Token Contract
    ISleep public sleepTokenInstance;

    /// @notice Health Token Contract
    IHealth public healthTokenInstance;

    /// @notice Bedroom NFT Contract
    IBedroomNft public bedroomNftInstance;

    /// @notice UpgradeNFT Contract
    IUpgradeNft public upgradeNftInstance;

    /// @notice Dex Contract address
    address public teamWallet;

    /// @dev Dev Wallet
    address private devWallet;

    /// @notice Payment Token
    IERC20 public paymentToken;

    /// @notice Purchase cost and Upgrade cost
    uint256 public purchaseCost;

    /// @notice Upgrade costs
    struct Upgrade {
        uint256 designId; // Design Id
        uint256 data; // NFT Data
    }

    /// @notice Upgrade costs depending on the id of the Upgrade Nft
    mapping(uint256 => Upgrade) private upgradeCosts;

    /// @notice Buy Bedroom NFT Event
    event BuyBedroomNft(
        address indexed owner,
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
    function initialize(
        address _teamWallet
    ) public initializer {
        __Ownable_init();
        teamWallet = _teamWallet;
    }

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _healthToken Address of the Health Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @param _teamWallet New Team Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @param _tokenAddress New Payment Token contract address
    /// @dev This function can only be called by the owner of the contract
    function setAddresses(
        ISleep _sleepToken,
        IHealth _healthToken,
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
        healthTokenInstance = _healthToken;
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

    /// @notice Settles NFTs Upgrade data
    /// @param _price Purchase price of the Upgrade NFT
    /// @param _upgradeId Id of the upgrade
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner of the contract
    function setUpgradeData(
        uint256 _price,
        uint256 _upgradeId,
        uint256 _amount,
        uint256 _designId,
        uint256 _level,
        uint256 _levelMin,
        uint256 _attributeIndex,
        uint256 _valueToAdd,
        uint256 _typeNft,
        uint256 _data
    ) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Wrong sender");
        upgradeCosts[_upgradeId] = Upgrade(
            _designId,
            _level + (_levelMin << 16) + (_data << 32) + (_attributeIndex << 48) + (_valueToAdd << 64) + (_typeNft << 80) + (_price << 96) + (_amount << 112)
        );
    }

    /// @notice Settles NFTs Upgrade data - Batch transaction
    /// @param _price Purchase price of the Upgrade NFT
    /// @param _upgradeId Id of the upgrade
    /// @param _amount Amount of tokens to add to the Upgrade Nft
    /// @param _designId Upgrade Nft URI 
    /// @param _level Level to add to the Bedroom Nft
    /// @param _levelMin Bedroom Nft Level min required
    /// @param _attributeIndex Score involved (optionnal)
    /// @param _valueToAdd Value to add to the score (optionnal)
    /// @param _typeNft NFT Type 
    /// @param _data Additionnal data (optionnal)
    /// @dev This function can only be called by the owner or the dev Wallet
    function setUpgradeDataBatch(
        uint256[] memory _price,
        uint256[] memory _upgradeId,
        uint256[] memory _amount,
        uint256[] memory _designId,
        uint256[] memory _level,
        uint256[] memory _levelMin,
        uint256[] memory _attributeIndex,
        uint256[] memory _valueToAdd,
        uint256[] memory _typeNft,
        uint256[] memory _data
    ) external {
        require(
            msg.sender == owner() || msg.sender == devWallet,
            "Access Forbidden"
        );
        for(uint256 i = 0; i < _upgradeId.length; i++) {
            upgradeCosts[_upgradeId[i]] = Upgrade(
                _designId[i],
                _level[i] + (_levelMin[i] << 16) + (_data[i] << 32) + (_attributeIndex[i] << 48) + (_valueToAdd[i] << 64) + (_typeNft[i] << 80) + (_price[i] << 96) + (_amount[i] << 112)
            );
        }
    }

    /// @notice Returns the data of an Upgrade Nft
    /// @param _upgradeId Id of the upgrade
    /// @return designId Upgrade Nft URI 
    /// @return price Purchase price of the Upgrade NFT
    /// @return amount Amount of tokens to add to the Upgrade Nft
    /// @return level Level to add to the Bedroom Nft
    /// @return levelMin Bedroom Nft Level min required
    /// @return attributeIndex Score involved (optionnal)
    /// @return valueToAdd Value to add to the score (optionnal)
    /// @return typeNft NFT Type 
    /// @return data Additionnal data (optionnal)
    function getUpgradeData(uint256 _upgradeId) 
        external 
        view 
        returns (
            uint256 designId,
            uint16 price,
            uint16 amount,
            uint16 level,
            uint16 levelMin,
            uint16 attributeIndex,
            uint16 valueToAdd,
            uint16 typeNft,
            uint16 data
    ) {
        Upgrade memory spec = upgradeCosts[_upgradeId];
        designId = spec.designId;
        level =  uint16(spec.data);
        levelMin = uint16(spec.data >> 16); 
        data = uint16(spec.data >> 32);
        attributeIndex = uint16(spec.data >> 48); 
        valueToAdd = uint16(spec.data >> 64);
        typeNft = uint16(spec.data >> 80);
        price = uint16(spec.data >> 96);
        amount = uint16(spec.data >> 112);
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

    /// @notice Launches the mint procedure of a Bedroom NFT
    function buyBedroomNft()
        external
    {
        // Token Transfer
        paymentToken.transferFrom(msg.sender, address(this), purchaseCost * 1 ether/10);

        // NFT Minting
        bedroomNftInstance.mintBedroomNft(
            msg.sender
        );

        emit BuyBedroomNft(
            msg.sender,
            purchaseCost
        );
    }

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeId Id of the Upgrade 
    function buyUpgradeNft(
        uint256 _upgradeId
    ) external {
        // Gets U^grade data
        Upgrade memory spec = upgradeCosts[_upgradeId];

        // Burns tokens
        sleepTokenInstance.burnFrom(msg.sender, uint16(spec.data >> 96) * 1 ether);

        // Mints Upgrade NFT
        upgradeNftInstance.mint(
            uint16(spec.data >> 112),
            spec.designId,
            msg.sender, 
            uint16(spec.data),
            uint16(spec.data >> 16),
            uint16(spec.data >> 48),
            uint16(spec.data >> 64),
            uint16(spec.data >> 80),
            uint16(spec.data >> 32)
        );

        emit BuyUpgradeNft(
            msg.sender,
            _upgradeId,
            uint16(spec.data >> 96)
        );
    }

    /// @notice Links an Upgrade Nft
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

    /// @notice Unlinks an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _newDesignId New Design Id of the Bedroom NFT
    function unlinkUpgradeNft(
        uint256 _upgradeNftId, 
        uint256 _newDesignId
    ) external {
        upgradeNftInstance.unlinkUpgradeNft(
            _upgradeNftId,
            msg.sender,
            _newDesignId
        );
    }

    /// @notice Airdrops some Bedroom NFTs
    /// @param _addresses Addresses of the receivers 
    /// @dev This function can only be called by the owner of the contract
    function airdropBedroomNFT(
        address[] memory _addresses
    ) external onlyOwner {
        for(uint256 i=0; i<_addresses.length; i++) {
            bedroomNftInstance.mintBedroomNft(
                _addresses[i]
            );
        }
    }

}
