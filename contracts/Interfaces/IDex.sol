// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IBedroomNft.sol";
import "./ISleep.sol";
import "./IHealth.sol";
import "./IUpgradeNft.sol";
import "./ITracker.sol";
import "./IUpgrader.sol";

/// @title Interface of GetSleepn Decentralized Exchange Contract
/// @author Sleepn
/// @notice This contract can be use to mint and upgrade a Bedroom NFT
interface IDex {
    /// @notice Packs costs
    struct Pack {
        string designURI; // Design Id
        uint256 price; // Price
        uint256[] upgradeIds; // UpgradeIds
    }

    /// @notice Upgrade Nft Buying Data
    struct UpgradeNft {
        bool isAvailable; // Is available ?
        uint256 cost; // Cost
        uint256 amountAvailable; // Amount available
    }

    /// @notice Bedroom NFT Purchased Event
    event BedroomNftPurchased(
        address indexed owner, uint256 indexed bedroomNftId, uint256 price
    );
    /// @notice Upgrade NFT Purchased Event
    event UpgradeNftPurchased(
        address indexed owner, uint256 indexed upgradeNftId, uint256 price
    );
    /// @notice Pack Purchased Event
    event PackPurchased(
        address indexed owner,
        uint256 indexed packId,
        uint256 bedroomNftId,
        uint256 price
    );
    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed receiver, uint256 price);
    /// @notice Bedroom NFT Purchase Cost Setted Event
    event BedroomNftPurchaseCostSetted(uint256 price);
    /// @notice Pack Cost Setted Event
    event PackCostSetted(uint256 packId, uint256 price);
    /// @notice Upgrade NFT Data Setted Event
    event UpgradeNftBuyingDataSetted(
        uint256 upgradeNftId, uint256 amountAvailable, bool isAvailable
    );
    /// @notice Upgrade Nft linked to a Bedroom Nft Event
    event UpgradeNftLinkedToBedroomNft(
        uint256 indexed bedroomNftId,
        uint256 indexed upgradeNftId,
        string designURI
    );
    /// @notice Upgrade Nft unlinked from a Bedroom Nft Event
    event UpgradeNftUnlinkedFromBedroomNft(
        uint256 indexed bedroomNftId,
        uint256 indexed upgradeNftId,
        string designURI
    );

    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);
    /// @notice Upgrade Nft not available Error - Upgrade Nft is not available
    error UpgradeNftNotAvailable(uint256 tokenId);

    /// @notice Settles contracts addresses
    /// @param _sleepToken Address of the Sleep Token contract
    /// @param _healthToken Address of the Health Token contract
    /// @param _bedroomNft Address of the Bedroom NFT contract
    /// @param _upgradeNft Address of the Upgrade NFT contract
    /// @param _tracker Address of the Tracker contract
    /// @param _upgrader Address of the Upgrader contract
    /// @param _teamWallet New Team Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @param _tokenAddress New Payment Token contract address
    /// @dev This function can only be called by the owner of the contract
    function setAddresses(
        ISleep _sleepToken,
        IHealth _healthToken,
        IBedroomNft _bedroomNft,
        IUpgradeNft _upgradeNft,
        ITracker _tracker,
        IUpgrader _upgrader,
        address _teamWallet,
        address _devWallet,
        IERC20 _tokenAddress
    ) external;

    /// @notice Settles NFTs purchase price
    /// @param _price Purchase price of the NFT
    /// @dev This function can only be called by the owner of the contract
    function setBuyingPrice(uint256 _price) external;

    /// @notice Settles Packs data
    /// @param _upgradeIds Ids of the Upgrade Nfts
    /// @param _designURI Bedroom NFT Design URI
    /// @param _price Purchase price of the Pack
    /// @param _packId Pack ID
    /// @dev This function can only be called by the owner of the contract or the dev wallet
    function setPackPrice(
        uint256[] calldata _upgradeIds,
        string calldata _designURI,
        uint256 _price,
        uint256 _packId
    ) external;

    /// @notice Settles Upgrade NFTs purchase price
    /// @param _upgradeId Id of the Upgrade Nft
    /// @param _price Purchase price of the Upgrade Nft
    /// @param _amountAvailable Amount available of the Upgrade Nft
    /// @param _isAvailable Is the Upgrade Nft available ?
    /// @dev This function can only be called by the owner of the contract or the dev wallet
    function setUpgradeBuyingData(
        uint256 _upgradeId,
        uint256 _price,
        uint256 _amountAvailable,
        bool _isAvailable
    ) external;

    /// @notice Settles Upgrade NFTs purchase price - Batch Transaction
    /// @param _upgradeIds IDs of the Upgrade NFTs
    /// @param _prices Purchase prices of the Upgrade NFTs
    /// @param _amountsAvailable Amounts available of the Upgrade NFTs
    /// @param _isAvailable Are the Upgrade NFTs available ?
    /// @dev This function can only be called by the owner of the contract or the dev wallet
    function setUpgradePriceBatch(
        uint256[] calldata _upgradeIds,
        uint256[] calldata _prices,
        uint256[] calldata _amountsAvailable,
        bool[] calldata _isAvailable
    ) external;

    /// @notice Returns the data of a Pack
    /// @param _packId Id of the Pack
    /// @return _designURI Upgrade Nft URI
    /// @return _price Purchase price of the Upgrade NFT
    /// @return _upgradeIds Upgrade Nfts ID
    function getPackData(uint256 _packId)
        external
        view
        returns (
            string memory _designURI, // Design URI
            uint256 _price, // Price
            uint256[] memory _upgradeIds // UpgradeIds
        );

    /// @notice Returns the price of an Upgrade Nft
    /// @param _upgradeId Id of the upgrade
    /// @return _price Purchase price of the Upgrade NFT
    /// @return _amountAvailable Amount of Upgrade NFTs available
    /// @return _isAvailable If the Upgrade NFT is available
    function getUpgradeNftBuyingData(uint256 _upgradeId)
        external
        view
        returns (uint256 _price, uint256 _amountAvailable, bool _isAvailable);

    /// @notice Withdraws the money from the contract
    /// @param _token Address of the token to withdraw
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney(IERC20 _token) external;

    /// @notice Launches the mint procedure of a Bedroom NFT
    function buyBedroomNft() external;

    /// @notice Buy an Upgrade Nft
    /// @param _upgradeId Id of the Upgrade Nft
    function buyUpgradeNft(uint256 _upgradeId) external;

    /// @notice Buy a Pack
    /// @param _packId Id of the Pack
    function buyPack(uint256 _packId) external;

    /// @notice Links an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignURI New Design URI of the Bedroom NFT
    function linkUpgradeNft(
        uint256 _upgradeNftId,
        uint256 _bedroomNftId,
        string calldata _newDesignURI
    ) external;

    /// @notice Links an Upgrade Nft - Batch transaction
    /// @param _upgradeNftIds IDs of the Upgrade NFTs
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignURI New Design URI of the Bedroom NFT
    function linkUpgradeNftBatch(
        uint256[] calldata _upgradeNftIds,
        uint256 _bedroomNftId,
        string calldata _newDesignURI
    ) external;

    /// @notice Unlinks an Upgrade Nft
    /// @param _upgradeNftId Id of the Upgrade NFT
    /// @param _bedroomNftId Id of the Bedroom NFT
    /// @param _newDesignURI New Design URI of the Bedroom NFT
    function unlinkUpgradeNft(
        uint256 _upgradeNftId,
        uint256 _bedroomNftId,
        string calldata _newDesignURI
    ) external;
}
