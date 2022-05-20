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


enum Category {
    Studio,
    Deluxe,
    Luxury
}

/// @notice Administration informations of a Bedroom NFT
struct NftOwnership {
    address owner;
    uint256 price;
    uint256 designId;
    uint256 level;
    Category category;
}


contract Reward is Initializable, OwnableUpgradeable {
    ISuperToken public superToken; // super token address

    ISuperfluid private host; // host
    IConstantFlowAgreementV1 private cfa; // the stored constant flow agreement class address

    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData private cfaV1; //initialize cfaV1 variable

    // Bedroom NFT Contract
    IBedroomNft private bedroomNft;

    // Index Reward to flow rate
    mapping(uint256 => int96) public rewards;

    // NFT Category to multiplier
    mapping(Category => uint256) public multipliers;

    // Init
    function initialize(
        ISuperToken _superToken,
        ISuperfluid _host,
        IConstantFlowAgreementV1 _cfa,
        IBedroomNft _bedroomNft
    ) public initializer {
        superToken = _superToken;
        host = _host;
        cfa = _cfa;
        bedroomNft = _bedroomNft;

        assert(address(superToken) != address(0));
        assert(address(host) != address(0));
        assert(address(cfa) != address(0));

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
        rewards[0] = 166666666666666; // 10 SLP per minute of light sleep
        rewards[1] = 333333333333333; // 20 SLP per minute of REM sleep
        rewards[2] = 499999999999999; // 30 SLP per minute of Deep sleep

        // Set NFT categories multiplier
        multipliers[Category.Studio] = 10;
        multipliers[Category.Deluxe] = 15;
        multipliers[Category.Luxury] = 20;
    }

    // Set rewards flowrate : (Number of tokens / 60) * 10^18
    function setRewards(uint256 _indexReward, int96 _flowRate)
        public
        onlyOwner
    {
        rewards[_indexReward] = _flowRate;
    }

    // Set NFT Categories multipliers
    function setMultipliers(Category _category, uint256 _multiplier)
        public
        onlyOwner
    {
        multipliers[_category] = _multiplier;
    }

    // Create a stream
    function createStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) public onlyOwner {
        // Get NFT informations
        IBedroomNft.NftOwnership memory nftOwnership = bedroomNft.tokenIdToNftOwnership(
            _tokenId
        );

        // Verifies that the recipient is the owner of the NFT
        IBedroomNft.Category categoryNft = bedroomNft
            .tokenIdToNftOwnership(_tokenId)
            .category;
        require(nftOwnership.owner == _receiver, "Wrong receiver");
    }

    // Increase the flow or create it
    function _increaseFlow(address _receiver, int96 _flowRate) internal {
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        (, int96 outFlowRate, , ) = cfa.getFlow(
            superToken,
            address(this),
            _receiver
        );

        if (outFlowRate == 0) {
            cfaV1.createFlow(_receiver, superToken, _flowRate);
        } else {
            cfaV1.updateFlow(_receiver, superToken, outFlowRate + _flowRate);
        }
    }

    // Reduce the flow or delete it
    function _reduceFlow(address _receiver, int96 _flowRate) internal {
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        (, int96 outFlowRate, , ) = cfa.getFlow(
            superToken,
            address(this),
            _receiver
        );

        if (outFlowRate == _flowRate) {
            cfaV1.deleteFlow(address(this), _receiver, superToken);
        } else if (outFlowRate > _flowRate) {
            cfaV1.updateFlow(_receiver, superToken, outFlowRate - _flowRate);
        }
    }
}
