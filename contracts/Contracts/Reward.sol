 SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ISuperfluid} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

import "../Interfaces/ISleepToken.sol";
import "../Interfaces/IBedroomNft.sol";

/// @title GetSleepn Reward Contract
/// @author Sleepn
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

    /// @notice Maps rewards to Sleep type
    mapping(uint256 => int96) public rewardsByCategory;

    /// @dev Sleep Token Contract
    ISleepToken private sleepToken;

    /// @dev Dev Wallet 
    address private devWallet;

    /// @notice Open or Update Stream Event
    event OpenUpdateStream(address indexed receiver, int96 flowRate);

    /// @notice Close Stream Event
    event CloseStream(address indexed receiver);

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
        rewardsByCategory[0] = 166666666666666; // 10 SLP per minute of light sleep
        rewardsByCategory[1] = 333333333333333; // 20 SLP per minute of REM sleep
        rewardsByCategory[2] = 499999999999999; // 30 SLP per minute of Deep sleep
    }

    /// @notice Settles Super Token Address
    /// @param _superToken Super Token Contract Address
    /// @dev This function can only be called by the owner of the contract
    function setSuperToken(ISuperToken _superToken) external onlyOwner {
        superToken = _superToken;
    }

    /// @notice Settles rewards flowrat
    /// @notice Rewards flowrate : (Number of tokens / 60) * 10^18
    /// @param _indexReward Index of the reward
    /// @param _flowRate Flowrate of the stream reward
    /// @dev This function can only be called by the owner of the contract
    function setRewards(
        uint256 _indexReward,
        int96 _flowRate
    ) external onlyOwner {
        rewardsByCategory[_indexReward] = _flowRate;
    }

    /// @notice Opens or Updates a reward stream
    /// @param _receiver Address of the receiver
    /// @param _tokenId ID of the NFT
    /// @param _rewardIndex Index of the reward flowrate
    /// @dev This function can only be called by the owner or the dev Wallet
    function createUpdateStream(
        address _receiver,
        uint256 _tokenId,
        uint256 _rewardIndex
    ) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        // Get Bedroom NFT informations
        IBedroomNft.NftSpecifications memory nftSpecifications = bedroomNft
            .getNftSpecifications(_tokenId);

        // Verifies that the recipient is the owner of the NFT
        require(nftSpecifications.owner == _receiver, "Wrong receiver");

        // Gets flow rate
        int96 flowrate = rewardsByCategory[_rewardIndex];

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
    /// @dev This function can only be called by the owner or the dev Wallet
    function closeStream(address _receiver) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        require(
            _receiver != address(this),
            "Receiver must be different than sender"
        );

        cfaV1.deleteFlow(address(this), _receiver, superToken);

        emit CloseStream(_receiver);
    }

    /// @notice Settles Bedroom NFT address
    /// @param _bedroomNft Bedroom NFT Contract
    /// @dev This function can only be called by the owner of the contract
    function setBedroomNft(IBedroomNft _bedroomNft) external onlyOwner {
        bedroomNft = _bedroomNft;
    }

    /// @notice Upgrades ERC20 to SuperToken
    /// @param _amount Number of tokens to be upgraded (in 18 decimals)
    /// @dev This function can only be called by the owner or the dev Wallet
    function wrapTokens(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        sleepToken.approve(address(superToken), _amount);
        superToken.upgrade(_amount);
    }

    /// @notice Downgrades SuperToken to ERC20
    /// @param _amount Number of tokens to be downgraded (in 18 decimals)
    /// @dev This function can only be called by the owner or the dev Wallet
    function unwrapTokens(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Access Forbidden");
        superToken.downgrade(_amount);
    }

    /// @notice Returns balance of contract
    /// @return _balance Balance of contract
    function returnBalance() external view returns (uint256) {
        return superToken.balanceOf(address(this));
    }

    /// @notice Settles Sleep Token contract address 
    /// @param _sleepToken Address of the Sleep Token contract
    /// @dev This function can only be called by the owner of the contract
    function setSleepToken(ISleepToken _sleepToken) external onlyOwner {
        sleepToken = _sleepToken;
    }

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }
}
