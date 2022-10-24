// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// @title Interface of the Upgrader Contract
/// @author Sleepn
/// @notice The Upgrader Contract is used to upgrade a Bedroom NFT
interface IUpgrader {
    /// @notice Upgrade NFT linked to a Bedroom NFT Event
    event UpgradeNftLinked(
        uint256 indexed bedroomNftId,
        uint256 indexed upgradeNftId,
        address owner
    );
    /// @notice Upgrade NFT unlinked from a Bedroom NFT Event
    event UpgradeNftUnlinked(
        uint256 indexed bedroomNftId,
        uint256 indexed upgradeNftId,
        address owner
    );

    /// @notice NFT not owned Error - Upgrade NFT is not owned by the user
    error NftNotOwned(uint256 tokenId, address caller);
    /// @notice Upgrade NFT already linked Error - Upgrade NFT is already linked to a Bedroom NFT
    error IsAlreadyLinked(uint256 tokenId);
    /// @notice Upgrade NFT is not linked Error - Upgrade NFT is not linked to a Bedroom NFT
    error IsNotLinked(uint256 tokenId);
    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);
    /// @notice Level too low Error - Level is too low to upgrade
    error LevelTooLow(uint16 levelMin, uint256 bedroomNftLevel);
    /// @notice State not updated Error - State is not updated in tracker contract
    error StateNotUpdated();
    /// @notice Wrong Amount Error - The user does not have enough NFT
    error WrongAmount(uint256 upgradeNftId, uint256 amount);

    /// @notice Links an upgrade NFT to a Bedroom NFT
    /// @param _owner The owner of the upgrade NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @param _upgradeNftId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @param _designURI The new design URI of the bedroom NFT
    function linkUpgradeNft(
        address _owner,
        uint256 _bedroomNftId,
        uint256 _upgradeNftId,
        uint256 _amount,
        string memory _designURI
    ) external;

    /// @notice Uninks an upgrade NFT from a Bedroom NFT
    /// @param _owner The owner of the upgrade NFT
    /// @param _bedroomNftId The ID of the bedroom NFT
    /// @param _upgradeNftId The ID of the upgrade NFT
    /// @param _amount Amount of upgrade NFTs
    /// @param _designURI The new design URI of the bedroom NFT
    function unlinkUpgradeNft(
        address _owner,
        uint256 _bedroomNftId,
        uint256 _upgradeNftId,
        uint256 _amount,
        string memory _designURI
    ) external;
}
