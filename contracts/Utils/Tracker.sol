// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title Tracker Contract
/// @author Sleepn
/// @notice The Tracker Contract is used to track the NFTs
contract Tracker {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

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

    /// @dev Set of Upgrade NFTs ID settled
    EnumerableSet.UintSet private upgradeNftIdsSettled;

    /// @dev Maps the NFTs ID Sets to an owner
    mapping(address => NftsID) private ownerToNftsID;
    /// @dev Maps the Upgrade NFTs amounts to an owner and an NFT ID
    mapping(uint256 => mapping(address => UpgradeNft)) private upgradeNftsOwned;
    /// @dev Maps a set of owners to an Upgrade NFT ID
    mapping(uint256 => EnumerableSet.AddressSet) private upgradeNftToOwners;
    /// @dev Maps a set of Upgrade NFT IDs to a Bedroom NFT ID
    mapping(uint256 => EnumerableSet.UintSet) private bedroomNftToUpgradeNfts;

    /// @notice Bedroom NFT Contract address
    address public immutable bedroomNftContract;
    /// @notice Upgrade NFT Contract address
    address public immutable upgradeNftContract;
    /// @notice Upgrader Contract address
    address public immutable upgraderContract;

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

    /// @notice Constructor
    /// @param _bedroomNftAddress Bedroom NFT Contract address
    /// @param _upgradeNftAddress Upgrade NFT Contract address
    constructor(address _bedroomNftAddress, address _upgradeNftAddress) {
        bedroomNftContract = _bedroomNftAddress;
        upgradeNftContract = _upgradeNftAddress;
        upgraderContract = msg.sender;
    }

    /// @notice Gets the NFTs owned by an address
    /// @param _owner The address of the owner
    /// @return _bedroomNfts The Bedroom NFTs owned by the address
    /// @return _upgradeNfts The Upgrade NFTs owned by the address
    function getNftsID(address _owner)
        external
        view
        returns (uint256[] memory _bedroomNfts, uint256[] memory _upgradeNfts)
    {
        _bedroomNfts = ownerToNftsID[_owner].bedroomNfts.values();
        _upgradeNfts = ownerToNftsID[_owner].upgradeNfts.values();
    }

    /// @notice Adds a Bedroom NFT ID to the tracker
    /// @param _owner The owner of the NFT
    /// @param _tokenId The NFT ID
    /// @return stateUpdated Returns true if the update worked
    function addBedroomNft(address _owner, uint256 _tokenId)
        external
        returns (bool)
    {
        if (msg.sender != bedroomNftContract) {
            revert RestrictedAccess(msg.sender);
        }
        emit BedroomNftLinkedToWallet(_tokenId, _owner);
        return ownerToNftsID[_owner].bedroomNfts.add(_tokenId);
    }

    /// @notice Remove a Bedroom NFT from the tracker
    /// @param _owner The owner of the Bedroom NFT
    /// @param _newOwner The new owner of the Bedroom NFT
    /// @param _tokenId The ID of the Bedroom NFT
    /// @return stateUpdated Returns true if the update worked
    function removeBedroomNft(
        address _owner,
        address _newOwner,
        uint256 _tokenId
    ) external returns (bool) {
        if (msg.sender != bedroomNftContract) {
            revert RestrictedAccess(msg.sender);
        }
        for (
            uint256 i = 0; i < bedroomNftToUpgradeNfts[_tokenId].length(); i++
        ) {
            uint256 upgradeNftId = bedroomNftToUpgradeNfts[_tokenId].at(i);
            uint256 amount = upgradeNftsOwned[upgradeNftId][_owner].amountOwned;
            bool isRemoved = removeUpgradeNft(_owner, upgradeNftId, amount);
            bool idAdded = addUpgradeNft(_newOwner, upgradeNftId, amount);
            if (!isRemoved || !idAdded) {
                return false;
            }
        }
        if (ownerToNftsID[_owner].bedroomNfts.remove(_tokenId)) {
            emit BedroomNftUnlinkedFromWallet(_tokenId, _owner);
            return true;
        }
        return false;
    }

    /// @notice Returns true if the owner of the bedroom NFT is the wallet address
    /// @param _tokenId The ID of the bedroom NFT
    /// @param _wallet The wallet address of the owner
    /// @return isOwner True if the owner of the bedroom NFT is the wallet address
    function isBedroomNftOwner(uint256 _tokenId, address _wallet)
        external
        view
        returns (bool isOwner)
    {
        isOwner = ownerToNftsID[_wallet].bedroomNfts.contains(_tokenId);
    }

    /// @notice Returns the amount of bedroom NFTs owned by an owner
    /// @param _owner The owner of the bedroom NFTs
    /// @return nftsAmount The amount of bedroom NFTs owned by the owner
    function getBedroomNftsAmount(address _owner)
        external
        view
        returns (uint256 nftsAmount)
    {
        nftsAmount = ownerToNftsID[_owner].bedroomNfts.length();
    }

    /// @notice Adds an upgrade NFT ID to the settled upgrade NFT IDs
    /// @param _tokenId The ID of the upgrade NFT
    function settleUpgradeNftData(uint256 _tokenId) external {
        if (msg.sender != upgradeNftContract) {
            revert RestrictedAccess(msg.sender);
        }
        if (upgradeNftIdsSettled.contains(_tokenId)) {
            revert IdAlreadyUsed(_tokenId);
        }
        upgradeNftIdsSettled.add(_tokenId);
    }

    /// @notice Returns the upgrade NFT IDs that have been settled
    /// @return nftIdsSettled The upgrade NFT IDs that have been settled
    function getUpgradeNftSettled()
        external
        view
        returns (uint256[] memory nftIdsSettled)
    {
        nftIdsSettled = upgradeNftIdsSettled.values();
    }

    /// @notice Returns true if the Upgrade NFT ID is settled
    /// @param _tokenId The ID of the Upgrade NFT
    /// @return isSettled True if the Upgrade NFT ID is settled
    function isIdSettled(uint256 _tokenId)
        external
        view
        returns (bool isSettled)
    {
        isSettled = upgradeNftIdsSettled.contains(_tokenId);
    }

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
        public
        returns (bool)
    {
        if (
            msg.sender != upgradeNftContract
                && msg.sender != bedroomNftContract
        ) {
            revert RestrictedAccess(msg.sender);
        }
        ownerToNftsID[_owner].upgradeNfts.add(_tokenId);
        upgradeNftToOwners[_tokenId].add(_owner);
        upgradeNftsOwned[_tokenId][_owner].amountOwned += _amount;
        emit UpgradeNftLinkedToWallet(_owner, _tokenId, _amount);
        return true;
    }

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
        public
        returns (bool)
    {
        if (
            msg.sender != upgradeNftContract
                && msg.sender != bedroomNftContract
        ) {
            revert RestrictedAccess(msg.sender);
        }
        upgradeNftsOwned[_tokenId][_owner].amountOwned -= _amount;
        if (upgradeNftsOwned[_tokenId][_owner].amountOwned == 0) {
            bool isRemoved1 =
                ownerToNftsID[_owner].upgradeNfts.remove(_tokenId);
            bool isRemoved2 = upgradeNftToOwners[_tokenId].remove(_owner);
            if (!isRemoved1 || !isRemoved2) {
                return false;
            }
        }
        emit UpgradeNftUnlinkedFromWallet(_owner, _tokenId, _amount);
        return true;
    }

    /// @notice Returns true if the given address is the owner of the given Upgrade NFT
    /// @param _tokenId The ID of the Upgrade NFT to check
    /// @param _wallet The address to check
    /// @return isOwner True if the given address is the owner of the given Upgrade NFT
    function isUpgradeNftOwner(uint256 _tokenId, address _wallet)
        external
        view
        returns (bool isOwner)
    {
        isOwner = ownerToNftsID[_wallet].upgradeNfts.contains(_tokenId);
    }

    /// @notice Returns the amount of Upgrade NFTs owned by a wallet
    /// @param _owner The owner wallet address
    /// @return nftsAmount The amount of Upgrade NFTs owned by the wallet
    function getUpgradeNftsAmount(address _owner)
        external
        view
        returns (uint256 nftsAmount)
    {
        EnumerableSet.UintSet storage set = ownerToNftsID[_owner].upgradeNfts;
        for (uint256 i = 0; i < set.length(); ++i) {
            uint256 tokenId = set.at(i);
            nftsAmount += upgradeNftsOwned[tokenId][_owner].amountOwned;
        }
    }

    /// @notice Returns the amounts of a specific Upgrade NFT owned by a specific wallet
    /// @param _owner The owner wallet address
    /// @param _tokenId The ID of the Upgrade NFT
    /// @return amountOwned The amount of Upgrade NFTs owned by the wallet
    /// @return amountUsed The amount of Upgrade NFTs used by the wallet
    function getUpgradeNftAmounts(address _owner, uint256 _tokenId)
        external
        view
        returns (uint256 amountOwned, uint256 amountUsed)
    {
        amountOwned = upgradeNftsOwned[_tokenId][_owner].amountOwned;
        amountUsed = upgradeNftsOwned[_tokenId][_owner].amountUsed;
    }

    /// @notice Returns the owners of a specified Upgrade NFT
    /// @param _tokenId The upgrade NFT ID
    /// @return owners Owners of the specified Upgrade NFT
    function getUpgradeNftOwners(uint256 _tokenId)
        external
        view
        returns (address[] memory owners)
    {
        owners = upgradeNftToOwners[_tokenId].values();
    }

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
    ) external returns (bool) {
        if (msg.sender != upgraderContract) {
            revert RestrictedAccess(msg.sender);
        }
        bedroomNftToUpgradeNfts[_bedroomNftId].add(_upgradeNftId);
        upgradeNftsOwned[_upgradeNftId][_owner].amountUsed += _amount;
        emit UpgradeNftLinkedToBedroomNft(_upgradeNftId, _bedroomNftId, _amount);
        return true;
    }

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
    ) external returns (bool) {
        if (msg.sender != upgraderContract) {
            revert RestrictedAccess(msg.sender);
        }
        upgradeNftsOwned[_upgradeNftId][_owner].amountUsed -= _amount;
        if (upgradeNftsOwned[_upgradeNftId][_owner].amountUsed == 0) {
            if (!bedroomNftToUpgradeNfts[_bedroomNftId].remove(_upgradeNftId))
            {
                return false;
            }
        }
        emit UpgradeNftUnlinkedFromBedroomNft(_upgradeNftId, _bedroomNftId, _amount);
        return true;
    }

    /// @notice Returns the upgrade NFTs linked to a Bedroom NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @return upgradeNfts The upgrade NFTs linked to the Bedroom NFT
    function getUpgradeNfts(uint256 _bedroomNftId)
        external
        view
        returns (uint256[] memory upgradeNfts)
    {
        upgradeNfts = bedroomNftToUpgradeNfts[_bedroomNftId].values();
    }
}
