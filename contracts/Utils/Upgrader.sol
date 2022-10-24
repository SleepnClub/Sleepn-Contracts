// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Utils/Tracker.sol";

import "../Interfaces/IUpgradeNft.sol";
import "../Interfaces/IBedroomNft.sol";

/// @title Upgrader Contract
/// @author Sleepn
/// @notice The Upgrader Contract is used to upgrade a Bedroom NFT
contract Upgrader {
    /// @notice Bedroom NFT Contract address
    IBedroomNft public immutable bedroomNftContract;
    /// @notice Upgrade NFT Contract address
    IUpgradeNft public immutable upgradeNftContract;
    /// @notice Tracker Contract address
    Tracker public immutable trackerInstance;
    /// @notice Dex Contract address
    address public immutable dexAddress;

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

    /// @notice Initializer
    /// @param _bedroomNftContractAddr Bedroom NFT Contract address
    /// @param _dexAddress Dex Contract address
    constructor(address _bedroomNftContractAddr, address _dexAddress) {
        upgradeNftContract = IUpgradeNft(msg.sender);
        bedroomNftContract = IBedroomNft(_bedroomNftContractAddr);
        trackerInstance = new Tracker(
            _bedroomNftContractAddr,
            msg.sender
        );
        dexAddress = _dexAddress;
    }

    /// @notice Upgrade NFT Data
    struct UpgradeNftData {
        uint8 _attributeIndex;
        uint8 _valueToAdd;
        uint8 _typeNft;
        uint16 _level;
        uint16 _levelMin;
        uint16 _value;
        uint256 amountOwned;
        uint256 amountLinked;
    }

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
    ) external {
        /// @dev Checks who is calling the function
        if (msg.sender != dexAddress) {
            revert RestrictedAccess(msg.sender);
        }

        /// @dev Returns the data of the Bedroom NFT
        IBedroomNft.NftSpecifications memory nftSpecifications =
            bedroomNftContract.getSpecifications(_bedroomNftId);

        /// @dev Checks if the upgrade NFT is owned by the user
        if (
            nftSpecifications.owner != _owner
        ) {
            revert NftNotOwned(_upgradeNftId, _owner);
        }

        /// @dev Memory allocation for the upgrade NFT data
        UpgradeNftData memory upgradeNftData;

        /// @dev Checks if the upgrade NFT is already linked to a Bedroom NFT
        (upgradeNftData.amountOwned, upgradeNftData.amountLinked) =
            trackerInstance.getUpgradeNftAmounts(_owner, _upgradeNftId);
        if (_amount > (upgradeNftData.amountOwned - upgradeNftData.amountLinked)) {
            revert IsAlreadyLinked(_upgradeNftId);
        }

        /// @dev Returns the data of the upgrade NFT
        (
            ,
            upgradeNftData._level,
            upgradeNftData._levelMin,
            upgradeNftData._value,
            upgradeNftData._attributeIndex,
            upgradeNftData._valueToAdd,
            upgradeNftData._typeNft
        ) = upgradeNftContract.getData(_upgradeNftId);

        /// @dev Checks the level of the Bedroom NFT
        if (nftSpecifications.level < upgradeNftData._levelMin) {
            revert LevelTooLow(upgradeNftData._levelMin, nftSpecifications.level);
        }

        if (upgradeNftData._typeNft < 4) {
            /// @dev Checks if the NFT is level up
            nftSpecifications.level = upgradeNftData._level == 0
                ? nftSpecifications.level
                : upgradeNftData._level + uint16(nftSpecifications.level);
            /// @dev Checks if the NFT is value up
            nftSpecifications.value = upgradeNftData._value == 0
                ? nftSpecifications.value
                : upgradeNftData._value + uint16(nftSpecifications.value);
            /// @dev Checks if the NFT is attribute up
            if (upgradeNftData._typeNft == 2) {
                uint16[4] memory scores = [
                    uint16(nftSpecifications.scores),
                    uint16(nftSpecifications.scores >> 16),
                    uint16(nftSpecifications.scores >> 32),
                    uint16(nftSpecifications.scores >> 48)
                ];
                scores[upgradeNftData._attributeIndex] = (
                    scores[upgradeNftData._attributeIndex] + upgradeNftData._valueToAdd
                ) > 100 ? 100 : scores[upgradeNftData._attributeIndex] + upgradeNftData._valueToAdd;
                nftSpecifications.scores = uint64(scores[0])
                    + (uint64(scores[1]) << 16) + (uint64(scores[2]) << 32)
                    + (uint64(scores[3]) << 48);
            }
            /// @dev Updates the Bedroom NFT
            bedroomNftContract.updateBedroomNft(
                _bedroomNftId,
                nftSpecifications.value,
                nftSpecifications.level,
                nftSpecifications.scores,
                _designURI
            );
        }
        /// @dev Links the upgrade NFT to the Bedroom NFT
        if (
            !trackerInstance.linkUpgradeNft(
                _owner, 
                _bedroomNftId, 
                _upgradeNftId, 
                _amount
            )
        ) {
            revert StateNotUpdated();
        }
        emit UpgradeNftLinked(_bedroomNftId, _upgradeNftId, _owner);
    }

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
    ) external {
        /// @dev Checks who is calling the function
        if (msg.sender != dexAddress && msg.sender != address(trackerInstance))
        {
            revert RestrictedAccess(msg.sender);
        }

        /// @dev Checks if the upgrade NFT is owned by the user
        if (!trackerInstance.isUpgradeNftOwner(_upgradeNftId, _owner)) {
            revert NftNotOwned(_upgradeNftId, _owner);
        }

        /// @dev Memory allocation for the upgrade NFT data
        UpgradeNftData memory upgradeNftData;

        /// @dev Checks if the upgrade NFT is linked to the Bedroom NFT
        (upgradeNftData.amountOwned, upgradeNftData.amountLinked) =
            trackerInstance.getUpgradeNftAmounts(_owner, _upgradeNftId);
        if (_amount > upgradeNftData.amountOwned) {
            revert WrongAmount(_upgradeNftId, _amount);
        }
        if (_amount > upgradeNftData.amountLinked) {
            revert IsNotLinked(_upgradeNftId);
        }

        /// @dev Returns the data of the Bedroom NFT
        IBedroomNft.NftSpecifications memory nftSpecifications =
            bedroomNftContract.getSpecifications(_bedroomNftId);

        /// @dev Returns the data of the upgrade NFT
        (
            ,
            upgradeNftData._level,
            ,
            upgradeNftData._value,
            upgradeNftData._attributeIndex,
            upgradeNftData._valueToAdd,
            upgradeNftData._typeNft
        ) = upgradeNftContract.getData(_upgradeNftId);

        if (upgradeNftData._typeNft < 4) {
            /// @dev Checks if the NFT is level up
            nftSpecifications.level = upgradeNftData._level == 0
                ? nftSpecifications.level
                : uint16(nftSpecifications.level) - upgradeNftData._level;
            /// @dev Checks if the NFT is value up
            nftSpecifications.value = upgradeNftData._value == 0
                ? nftSpecifications.value
                : uint16(nftSpecifications.value) - upgradeNftData._value;
            /// @dev Checks if the NFT is attribute up
            if (upgradeNftData._typeNft == 2) {
                uint16[4] memory scores = [
                    uint16(nftSpecifications.scores),
                    uint16(nftSpecifications.scores >> 16),
                    uint16(nftSpecifications.scores >> 32),
                    uint16(nftSpecifications.scores >> 48)
                ];
                scores[upgradeNftData._attributeIndex] -= upgradeNftData._valueToAdd;
                nftSpecifications.scores = uint64(scores[0])
                    + (uint64(scores[1]) << 16) + (uint64(scores[2]) << 32)
                    + (uint64(scores[3]) << 48);
            }
            /// @dev Updates the Bedroom NFT
            bedroomNftContract.updateBedroomNft(
                _bedroomNftId,
                nftSpecifications.value,
                nftSpecifications.level,
                nftSpecifications.scores,
                _designURI
            );
        }
        if (
            !trackerInstance.unlinkUpgradeNft(
                _owner, 
                _bedroomNftId,
                _upgradeNftId, 
                _amount
            )
        ) {
            revert StateNotUpdated();
        }
        emit UpgradeNftUnlinked(_bedroomNftId, _upgradeNftId, _owner);
    }
}
