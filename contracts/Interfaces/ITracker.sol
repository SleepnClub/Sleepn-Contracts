// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title Interface of the Tracker Contract
/// @author Sleepn
/// @notice The Tracker Contract is used to track the NFTs

interface ITracker {
    /// @dev Struct to store the NFT IDs of a user
    struct NftsID {
        EnumerableSet.UintSet bedroomNfts;
        EnumerableSet.UintSet upgradeNfts;
    }
    /// @dev Struct to store the amounts owned of a NFT ID
    struct UpgradeNft {
        uint256 amountOwned;
        uint256 amountUsed;
        EnumerableSet.UintSet bedroomNftIds;
    }

    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);
    /// @notice Invalid NFT ID Error - NFT ID is invalid
    error IdAlreadyUsed(uint256 tokenId);

    /// @notice BedroomNft ID Linked To Wallet Event
    event BedroomNftLinkedToWallet(
        uint256 indexed bedroomNftId,
        address indexed owner
    );
    /// @notice BedroomNft ID Unlinked From Wallet Event
    event BedroomNftUnlinkedFromWallet(
        uint256 indexed bedroomNftId,
        address indexed owner
    );
    /// @notice UpgradeNft ID Linked To Wallet Event
    event UpgradeNftLinkedToWallet(
        address indexed owner,
        uint256 indexed upgradeNftId,
        uint256 amount
    );
    /// @notice UpgradeNft ID Unlinked From Wallet Event
    event UpgradeNftUnlinkedFromWallet(
        address indexed owner,
        uint256 indexed upgradeNftId,
        uint256 amount
    );
    /// @notice UpgradeNft ID Linked To BedroomNft ID Event
    event UpgradeNftLinkedToBedroomNft(
        uint256 indexed upgradeNftId,
        uint256 indexed bedroomNftId,
        uint256 amount
    );
    /// @notice UpgradeNft ID Unlinked From BedroomNft ID Event
    event UpgradeNftUnlinkedFromBedroomNft(
        uint256 indexed upgradeNftId,
        uint256 indexed bedroomNftId,
        uint256 amount
    );

    /// @notice Gets the NFTs owned by an address
    /// @param _owner The address of the owner
    /// @return _bedroomNfts The Bedroom NFTs owned by the address
    /// @return _upgradeNfts The Upgrade NFTs owned by the address
    function getNftsID(address _owner)
        external
        view
        returns (uint256[] memory _bedroomNfts, uint256[] memory _upgradeNfts);

    /// @notice Adds a Bedroom NFT ID to the tracker
    /// @param _owner The owner of the NFT
    /// @param _tokenId The NFT ID
    /// @return stateUpdated Returns true if the update worked
    function addBedroomNft(address _owner, uint256 _tokenId)
        external
        returns (bool);

    /// @notice Remove a Bedroom NFT from the tracker
    /// @param _owner The owner of the Bedroom NFT
    /// @param _newOwner The new owner of the Bedroom NFT
    /// @param _tokenId The ID of the Bedroom NFT
    /// @return stateUpdated Returns true if the update worked
    function removeBedroomNft(
        address _owner,
        address _newOwner,
        uint256 _tokenId
    ) external returns (bool);

    /// @notice Returns true if the owner of the bedroom NFT is the wallet address
    /// @param _tokenId The ID of the bedroom NFT
    /// @param _wallet The wallet address of the owner
    /// @return isOwner True if the owner of the bedroom NFT is the wallet address
    function isBedroomNftOwner(uint256 _tokenId, address _wallet)
        external
        view
        returns (bool isOwner);

    /// @notice Returns the amount of bedroom NFTs owned by an owner
    /// @param _owner The owner of the bedroom NFTs
    /// @return nftsAmount The amount of bedroom NFTs owned by the owner
    function getBedroomNftsAmount(address _owner)
        external
        view
        returns (uint256 nftsAmount);

    /// @notice Adds an upgrade NFT ID to the settled upgrade NFT IDs
    /// @param _tokenId The ID of the upgrade NFT
    function settleUpgradeNftData(uint256 _tokenId) external;

    /// @notice Returns the upgrade NFT IDs that have been settled
    /// @return nftIdsSettled The upgrade NFT IDs that have been settled
    function getUpgradeNftSettled()
        external
        view
        returns (uint256[] memory nftIdsSettled);

    /// @notice Returns true if the Upgrade NFT ID is settled
    /// @param _tokenId The ID of the Upgrade NFT
    /// @return isSettled True if the Upgrade NFT ID is settled
    function isIdSettled(uint256 _tokenId)
        external
        view
        returns (bool isSettled);

    /// @notice Adds an upgrade NFT to the tracker
    /// @param _owner The owner of the upgrade NFT
    /// @param _tokenId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @return stateUpdated Returns true if the update worked
    function addUpgradeNft(
        address _owner, 
        uint256 _tokenId, 
        uint256 _amount
    )
        external
        returns (bool);

    /// @notice Removes an upgrade NFT from the tracker
    /// @param _owner The owner of the upgrade NFT
    /// @param _tokenId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @return stateUpdated Returns true if the update worked
    function removeUpgradeNft(
        address _owner, 
        uint256 _tokenId, 
        uint256 _amount
    )
        external
        returns (bool);

    /// @notice Returns true if the given address is the owner of the given Upgrade NFT
    /// @param _tokenId The ID of the Upgrade NFT to check
    /// @param _wallet The address to check
    /// @return isOwner True if the given address is the owner of the given Upgrade NFT
    function isUpgradeNftOwner(uint256 _tokenId, address _wallet)
        external
        view
        returns (bool isOwner);

    /// @notice Returns the amount of Upgrade NFTs owned by a wallet
    /// @param _owner The owner wallet address
    /// @return nftsAmount The amount of Upgrade NFTs owned by the wallet
    function getUpgradeNftsAmount(address _owner)
        external
        view
        returns (uint256 nftsAmount);

    /// @notice Returns the amounts of a specific Upgrade NFT owned by a specific wallet
    /// @param _owner The owner wallet address
    /// @param _tokenId The ID of the Upgrade NFT
    /// @return amountOwned The amount of Upgrade NFTs owned by the wallet
    /// @return amountUsed The amount of Upgrade NFTs used by the wallet
    function getUpgradeNftAmounts(address _owner, uint256 _tokenId)
        external
        view
        returns (uint256 amountOwned, uint256 amountUsed);

    /// @notice Returns the owners of a specified Upgrade NFT
    /// @param _tokenId The upgrade NFT ID
    /// @return owners Owners of the specified Upgrade NFT
    function getUpgradeNftOwners(uint256 _tokenId)
        external
        view
        returns (address[] memory owners);

    /// @notice Links an upgrade NFT to a Bedroom NFT
    /// @param _owner The owner of the upgrade NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @param _upgradeNftId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @return stateUpdated Returns true if the update worked
    function linkUpgradeNft(
        address _owner,
        uint256 _bedroomNftId,
        uint256 _upgradeNftId,
        uint256 _amount
    ) external returns (bool);

    /// @notice Unlinks an upgrade NFT to a Bedroom NFT
    /// @param _owner The owner of the upgrade NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @param _upgradeNftId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @return stateUpdated Returns true if the update worked
    function unlinkUpgradeNft(
        address _owner,
        uint256 _bedroomNftId,
        uint256 _upgradeNftId,
        uint256 _amount
    ) external returns (bool);

    /// @notice Returns the upgrade NFTs linked to a Bedroom NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @return upgradeNfts The upgrade NFTs linked to the Bedroom NFT
    function getUpgradeNfts(uint256 _bedroomNftId)
        external
        view
        returns (uint256[] memory upgradeNfts);
}
