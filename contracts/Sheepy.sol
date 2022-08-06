// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Interfaces/IBedroomNft.sol";

import "./Tokens/Sleep.sol";
import "./Tokens/Health.sol";

contract Sheepy is Ownable {
    /// @notice $Sleep Contract
    Sleep public immutable sleepContract;

    /// @notice $Health Contract
    Health public immutable healthContract;

    /// @dev Bedroom NFT Contract
    IBedroomNft public immutable bedroomNftContract;

    /// @dev Dev Wallet
    address private devWallet;

    /// @notice Owner privileges state
    bool public ownerHasPrivileges;  

    // @dev Initializer
    /// @param _sleepTotalSupply Total Supply of $Sleep
    /// @param _healthTotalSupply Total Supply of $Health
    constructor(
        uint256 _sleepTotalSupply,
        uint256 _healthTotalSupply,
        address _devWallet,
        IBedroomNft _bedroomNftContract
    ) {
        sleepContract = new Sleep(_sleepTotalSupply);
        healthContract = new Health(_healthTotalSupply);
        ownerHasPrivileges = true;
        bedroomNftContract = _bedroomNftContract;
        devWallet = _devWallet;
    }

    /// @notice Stops the $Sleep Contract
    /// @dev This function can only be called by the owner of the contract
    function pauseSleep() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        sleepContract.pause();
    }

    /// @notice Stops the $Health Contract
    /// @dev This function can only be called by the owner of the contract
    function pauseHealth() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        healthContract.pause();
    }

    /// @notice Starts the $Sleep Contract
    /// @dev This function can only be called by the owner of the contract
    function unpauseSleep() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        sleepContract.unpause();
    }

    /// @notice Starts the $Health Contract
    /// @dev This function can only be called by the owner of the contract
    function unpauseHealth() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        healthContract.unpause();
    }

    /// @notice Mints $Sleep tokens 
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function mintSleep(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Wrong sender");
        sleepContract.mint(address(this), _amount);
    }

    /// @notice Mints $Health tokens    
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function mintHealth(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Wrong sender");
        healthContract.mint(address(this), _amount);
    }

    /// @notice Burns $Sleep tokens 
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner or dev Wallet
    function burnSleep(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Wrong sender");
        sleepContract.burn(_amount);
    }

    /// @notice Burns $Health tokens 
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner or dev Wallet
    function burnHealth(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == devWallet, "Wrong sender");
        healthContract.burn(_amount);
    }

    /// @notice Transfers $Sleep tokens 
    /// @param _to Tokens receiver address
    /// @param _amount Amount of tokens to burn
    function transferSleep(address _to, uint256 _amount) external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        sleepContract.transfer(_to, _amount);
    }

    /// @notice Transfers $Health tokens 
    /// @param _to Tokens receiver address
    /// @param _amount Amount of tokens to burn
    function transferHealth(address _to, uint256 _amount) external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        healthContract.transfer(_to, _amount);
    }

    /// @notice Rewards with $Sleep tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amounts Amounts of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function sleepRewardBatch(
        address[] memory _addresses, 
        uint256[] memory _amounts
    ) external {
        require(msg.sender == devWallet, "Wrong sender");
        require(_addresses.length == _amounts.length, "_addresses and _amounts length mismatch");
        for (uint256 i = 0; i < _addresses.length; ++i) {
            require(bedroomNftContract.getNftsNumber(_addresses[i]) > 0, "Wrong receiver");
            sleepContract.mint(_addresses[i], _amounts[i]);
        }
    }

    /// @notice Rewards with $Health tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amounts Amounts of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function healthRewardBatch(
        address[] memory _addresses, 
        uint256[] memory _amounts
    ) external {
        require(msg.sender == devWallet, "Wrong sender");
        require(_addresses.length == _amounts.length, "_addresses and _amounts length mismatch");
        for (uint256 i = 0; i < _addresses.length; ++i) {
            require(bedroomNftContract.getNftsNumber(_addresses[i]) > 0, "Wrong receiver");
            healthContract.mint(_addresses[i], _amounts[i]);
        }
    }

    /// @notice Rewards with $Sleep tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function sleepRewardBatchV2(
        address[] memory _addresses, 
        uint256 _amount
    ) external {
        require(msg.sender == devWallet, "Wrong sender");
        for (uint256 i = 0; i < _addresses.length; ++i) {
            require(bedroomNftContract.getNftsNumber(_addresses[i]) > 0, "Wrong receiver");
            sleepContract.mint(_addresses[i], _amount);
        }
    }

    /// @notice Rewards with $Health tokens - Batch operation
    /// @param _addresses Tokens receivers addresses
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the dev Wallet
    function healthRewardBatchV2(
        address[] memory _addresses, 
        uint256 _amount
    ) external {
        require(msg.sender == devWallet, "Wrong sender");
        for (uint256 i = 0; i < _addresses.length; ++i) {
            require(bedroomNftContract.getNftsNumber(_addresses[i]) > 0, "Wrong receiver");
            healthContract.mint(_addresses[i], _amount);
        }
    }

    /// @notice Rewards with $Sleep tokens 
    /// @param _address Tokens receiver address
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function sleepReward(address _address, uint256 _amount) external {
        require(msg.sender == devWallet, "Wrong sender");
        require(bedroomNftContract.getNftsNumber(_address) > 0, "Wrong receiver");
        sleepContract.mint(_address, _amount);
    }

    /// @notice Rewards with $Health tokens 
    /// @param _address Tokens receiver address
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner or dev Wallet
    function healthReward(address _address, uint256 _amount) external {
        require(msg.sender == devWallet, "Wrong sender");
        require(bedroomNftContract.getNftsNumber(_address) > 0, "Wrong receiver");
        healthContract.mint(_address, _amount);
    }

    /// @notice Stops owner privileges
    /// @dev This function can only be called by the owner of the contract
    function transferContractsOwnership() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        sleepContract.transferOwnership(msg.sender);
        healthContract.transferOwnership(msg.sender);
    }

    /// @notice Stops owner privileges
    /// @dev This function can only be called by the owner of the contract
    function stopPrivileges() external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        ownerHasPrivileges = false;
    }

    /// @notice Settles Dev Wallet address
    /// @param _devWallet New Dev Wallet address
    /// @dev This function can only be called by the owner of the contract
    function setDevAddress(address _devWallet) external onlyOwner {
        require(ownerHasPrivileges == true, "Owner doesn't have privileges");
        devWallet = _devWallet;
    }

}