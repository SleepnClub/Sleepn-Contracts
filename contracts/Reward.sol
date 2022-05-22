// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ISuperfluid} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

import "./Interfaces/ISleepToken.sol";
import "./Interfaces/IBedroomNft.sol";

/// @title GetSleepn Reward Contract
/// @author Alexis Balayre
/// @notice This contract is used to stream $Sleep to GetSleepn users
contract Reward is Initializable, OwnableUpgradeable {
    /// @notice Address of the super token address
    ISuperToken public superToken;

    /// @dev Address of the Superfluid Host contract
    ISuperfluid private host; // host

    /// @dev Address of the Superfluid CFA contract
    IConstantFlowAgreementV1 private cfa;

    /// @dev CFAv1 Library
    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData private cfaV1;

    /// @dev Bedroom NFT Contract
    IBedroomNft private bedroomNft;

    /// @notice Maps rewards to NFT Category
    mapping(IBedroomNft.Category => mapping(uint256 => int96))
        public rewardsByCategory;

    /// @notice Open or Update Stream Event
    event OpenUpdateStream(address receiver, int96 flowRate);

    /// @notice Close Stream Event
    event CloseStream(address receiver);

    /// @dev Initializer
    /// @param _host Superfluid Host Contract Address
    /// @param _cfa Superfluid CFA Contract Address
    /// @param _bedroomNft Bedroom NFT Contract Address
    function initialize(
        ISuperfluid _host,
        IConstantFlowAgreementV1 _cfa,
        IBedroomNft _bedroomNft
    ) public initializer {
        __Ownable_init();
        host = _host;
        cfa = _cfa;
        bedroomNft = _bedroomNft;

        assert(address(host) != address(0));
        assert(address(cfa) != address(0));
        assert(address(bedroomNft) != address(0));

        cfaV1 = CFAv1Library.InitData(
            _host,
            IConstantFlowAgreementV1(
                address(
                    _host.getAgreementClass(
                        keccak256(
                            "org.superfluid-finance.agreements.ConstantFlowAgreement.v1"
                        )
                    )
                )
            )
        );

        // Init Base rewards : (Number of tokens / 60) * 10^18
        rewardsByCategory[IBedroomNft.Category.Studio][0] = 166666666666666; // 10 SLP per minute of light sleep
        rewardsByCategory[IBedroomNft.Category.Studio][1] = 333333333333333; // 20 SLP per minute of REM sleep
        rewardsByCategory[IBedroomNft.Category.Studio][2] = 499999999999999; // 30 SLP per minute of Deep sleep

        rewardsByCategory[IBedroomNft.Category.Deluxe][0] = 249999999999999; // 15 SLP per minute of light sleep
        rewardsByCategory[IBedroomNft.Category.Deluxe][1] = 499999999999999; // 30 SLP per minute of REM sleep
        rewardsByCategory[IBedroomNft.Category.Deluxe][2] = 749999999999998; // 45 SLP per minute of Deep sleep

        rewardsByCategory[IBedroomNft.Category.Luxury][0] = 333333333333332; // 20 SLP per minute of light sleep
        rewardsByCategory[IBedroomNft.Category.Luxury][1] = 666666666666666; // 40 SLP per minute of REM sleep
        rewardsByCategory[IBedroomNft.Category.Luxury][2] = 999999999999998; // 60 SLP per minute of Deep sleep
    }

    /// @notice Settles Super Token Address
    /// @param _superToken Super Token Contract Address
    /// @dev This function can only be called by the owner of the contract
    function setSuperToken(ISuperToken _superToken) external onlyOwner {
        superToken = _superToken;
    }

    /// @notice Settles rewards flowrat
    /// @notice Rewards flowrate : (Number of tokens / 60) * 10^18
    /// @param _category Category of the NFT
    /// @param _indexReward Index of the reward
    /// @param _flowRate Flowrate of the stream reward
    /// @dev This function can only be called by the owner of the contract
    function setRewards(
        IBedroomNft.Category _category,
        uint256 _indexReward,
        int96 _flowRate
    ) external onlyOwner {
        rewardsByCategory[_category][_indexReward] = _flowRate;
    }

    /// @notice Opens or Updates a reward stream
    /// @param _receiver Address of the receiver
    /// @param _tokenId ID of the NFT
    /// @param _rewardIndex Index of the reward flowrate
    /// @dev This function can only be called by Dex Contract
    function createUpdateStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) external onlyOwner {
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        // Get NFT informations
        IBedroomNft.NftOwnership memory nftOwnership = bedroomNft
            .getNftOwnership(_tokenId);

        // Verifies that the recipient is the owner of the NFT
        require(nftOwnership.owner == _receiver, "Wrong receiver");

        // Gets flow rate
        int96 flowrate = rewardsByCategory[nftOwnership.category][_rewardIndex];

        (, int96 outFlowRate, , ) = cfa.getFlow(
            superToken,
            address(this),
            _receiver
        );

        if (outFlowRate == 0) {
            cfaV1.createFlow(_receiver, superToken, flowrate);
        } else {
            cfaV1.updateFlow(_receiver, superToken, flowrate);
        }

        emit OpenUpdateStream(_receiver, flowrate);
    }

    /// @notice Closes a reward stream
    /// @param _receiver Address of the receiver
    /// @dev This function can only be called by Dex Contract
    function closeStream(address _receiver) external onlyOwner {
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        cfaV1.deleteFlow(address(this), _receiver, superToken);

        emit CloseStream(_receiver);
    }
}
