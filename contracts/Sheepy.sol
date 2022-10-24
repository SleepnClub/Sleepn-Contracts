// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Interfaces/IBedroomNft.sol";
import "./Interfaces/ITracker.sol";

import "./Tokens/Sleep.sol";
import "./Tokens/Health.sol";

contract Sheepy is Ownable {
    using SafeERC20 for IERC20;

    /// @notice $Sleep Contract
    Sleep public immutable sleepContract;

    /// @notice $Health Contract
    Health public immutable healthContract;

    /// @dev Bedroom NFT Contract
    IBedroomNft public immutable bedroomNftContract;

    /// @dev Tracker Contract address
    ITracker public immutable trackerContract;

    /// @dev Dev Wallet
    address private devWallet;

    /// @notice Owner privileges state
    bool public ownerHasPrivileges;

    /// @notice Sleep Minted Event
    event SleepMinted(address indexed owner, uint256 amount);
    /// @notice Health Minted Event
    event HealthMinted(address indexed owner, uint256 amount);
    /// @notice Sleep Burned Event
    event SleepBurned(address indexed owner, uint256 amount);
    /// @notice Health Burned Event
    event HealthBurned(address indexed owner, uint256 amount);
    /// @notice Sleep Transferred Event
    event SleepTransferred(
        address indexed from, address indexed to, uint256 amount
    );
    /// @notice Health Transferred Event
    event HealthTransferred(
        address indexed from, address indexed to, uint256 amount
    );
    /// @notice Sleep Reward Event
    event SleepReward(address indexed owner, uint256 amount);
    /// @notice Health Reward Event
    event HealthReward(address indexed owner, uint256 amount);
    /// @notice Withdraw Money Event
    event WithdrawMoney(address indexed owner, uint256 amount);

    /// @notice Restricted Access Error - Wrong caller
    error RestrictedAccess(address caller);
    /// @notice Owner Privileges Error - Owner privileges are disabled
    error OwnerPrivilegesDisabled();
    /// @notice Wrong Receiver Error - Receiver doesn't have a Bedroom NFT
    error WrongReceiver(address receiver);
    /// @notice Different Length Error - Arrays length
    error DifferentLength();

    /// @dev Initializer
    /// @param _sleepTotalSupply Total Supply of $Sleep
    /// @param _healthTotalSupply Total Supply of $Health
    constructor(
        uint256 _sleepTotalSupply,
        uint256 _healthTotalSupply,
        address _devWallet,
        IBedroomNft _bedroomNftContract,
        ITracker _trackerContract
    ) {
        sleepContract = new Sleep(_sleepTotalSupply);
        healthContract = new Health(_healthTotalSupply);
        ownerHasPrivileges = true;
        bedroomNftContract = _bedroomNftContract;
        devWallet = _devWallet;
        trackerContract = _trackerContract;
    }

    /// @notice Stops the $Sleep Contract
    /// @dev This function can only be called by the owner of the contract
    function pauseSleep() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        sleepContract.pause();
    }

    /// @notice Stops the $Health Contract
    /// @dev This function can only be called by the owner of the contract
    function pauseHealth() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        healthContract.pause();
    }

    /// @notice Starts the $Sleep Contract
    /// @dev This function can only be called by the owner of the contract
    function unpauseSleep() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        sleepContract.unpause();
    }

    /// @notice Starts the $Health Contract
    /// @dev This function can only be called by the owner of the contract
    function unpauseHealth() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        healthContract.unpause();
    }

    /// @notice Mints $Sleep tokens
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function mintSleep(uint256 _amount) external {
        if (msg.sender != owner() && msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        sleepContract.mint(address(this), _amount);
        emit SleepMinted(address(this), _amount);
    }

    /// @notice Mints $Health tokens
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function mintHealth(uint256 _amount) external {
        if (msg.sender != owner() && msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        healthContract.mint(address(this), _amount);
        emit HealthMinted(address(this), _amount);
    }

    /// @notice Burns $Sleep tokens
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner or dev Wallet
    function burnSleep(uint256 _amount) external {
        if (msg.sender != owner() && msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        sleepContract.burn(_amount);
        emit SleepBurned(address(this), _amount);
    }

    /// @notice Burns $Health tokens
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner or dev Wallet
    function burnHealth(uint256 _amount) external {
        if (msg.sender != owner() && msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        healthContract.burn(_amount);
        emit HealthBurned(address(this), _amount);
    }

    /// @notice Transfers $Sleep tokens
    /// @param _to Tokens receiver address
    /// @param _amount Amount of tokens to burn
    function transferSleep(address _to, uint256 _amount) external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        sleepContract.transfer(_to, _amount);
        emit SleepTransferred(address(this), _to, _amount);
    }

    /// @notice Transfers $Health tokens
    /// @param _to Tokens receiver address
    /// @param _amount Amount of tokens to burn
    function transferHealth(address _to, uint256 _amount) external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        healthContract.transfer(_to, _amount);
        emit HealthTransferred(address(this), _to, _amount);
    }

    /// @notice Withdraws the money from the contract
    /// @param _token Address of the token to withdraw
    /// @dev This function can only be called by the owner or the dev Wallet
    function withdrawMoney(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(msg.sender, balance);
        emit WithdrawMoney(msg.sender, balance);
    }

    /// @notice Rewards with $Sleep tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amounts Amounts of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function sleepRewardBatch(
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        if (_addresses.length != _amounts.length) {
            revert DifferentLength();
        }
        for (uint256 i = 0; i < _addresses.length; ++i) {
            if (trackerContract.getBedroomNftsAmount(_addresses[i]) == 0) {
                revert WrongReceiver(_addresses[i]);
            }
            sleepContract.mint(_addresses[i], _amounts[i]);
            emit SleepReward(_addresses[i], _amounts[i]);
        }
    }

    /// @notice Rewards with $Health tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amounts Amounts of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function healthRewardBatch(
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        if (_addresses.length != _amounts.length) {
            revert DifferentLength();
        }
        for (uint256 i = 0; i < _addresses.length; ++i) {
            if (trackerContract.getBedroomNftsAmount(_addresses[i]) == 0) {
                revert WrongReceiver(_addresses[i]);
            }
            healthContract.mint(_addresses[i], _amounts[i]);
            emit HealthReward(_addresses[i], _amounts[i]);
        }
    }

    /// @notice Rewards with $Sleep tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function sleepRewardBatchV2(address[] calldata _addresses, uint256 _amount)
        external
    {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        for (uint256 i = 0; i < _addresses.length; ++i) {
            if (trackerContract.getBedroomNftsAmount(_addresses[i]) == 0) {
                revert WrongReceiver(_addresses[i]);
            }
            sleepContract.mint(_addresses[i], _amount);
            emit SleepReward(_addresses[i], _amount);
        }
    }

    /// @notice Rewards with $Health tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function healthRewardBatchV2(address[] calldata _addresses, uint256 _amount)
        external
    {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        for (uint256 i = 0; i < _addresses.length; ++i) {
            if (trackerContract.getBedroomNftsAmount(_addresses[i]) == 0) {
                revert WrongReceiver(_addresses[i]);
            }
            healthContract.mint(_addresses[i], _amount);
            emit HealthReward(_addresses[i], _amount);
        }
    }

    /// @notice Rewards with $Sleep tokens
    /// @param _address Tokens receiver address
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function sleepReward(address _address, uint256 _amount) external {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        if (trackerContract.getBedroomNftsAmount(_address) == 0) {
            revert WrongReceiver(_address);
        }
        sleepContract.mint(_address, _amount);
        emit SleepReward(_address, _amount);
    }

    /// @notice Rewards with $Health tokens
    /// @param _address Tokens receiver address
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function healthReward(address _address, uint256 _amount) external {
        if (msg.sender != devWallet) {
            revert RestrictedAccess(msg.sender);
        }
        if (trackerContract.getBedroomNftsAmount(_address) == 0) {
            revert WrongReceiver(_address);
        }
        healthContract.mint(_address, _amount);
        emit HealthReward(_address, _amount);
    }

    /// @notice Stops owner privileges
    /// @dev This function can only be called by the owner of the contract
    function transferContractsOwnership() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        sleepContract.transferOwnership(msg.sender);
        healthContract.transferOwnership(msg.sender);
    }

    /// @notice Stops owner privileges
    /// @dev This function can only be called by the owner of the contract
    function stopPrivileges() external onlyOwner {
        if (!ownerHasPrivileges) {
            revert OwnerPrivilegesDisabled();
        }
        ownerHasPrivileges = false;
    }

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }
}
