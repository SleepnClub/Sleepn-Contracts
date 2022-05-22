// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

/// @title $Sleep Token Contract
/// @author Alexis Balayre
/// @notice $Sleep is the official token of getSleepn App
contract SleepToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    /// @notice Reward Contract Address
    address public rewardContract;

    /// @notice Team Wallet
    address public teamWallet;

    /// @notice Uniswap Liquidity Pool Address
    IUniswapV3Pool public pool;

    /// @notice UniswapV3Factory Contract Address
    IUniswapV3Factory public factory;

    /// @dev Initializer
    /// @param _totalSupply Total Supply of $Sleep
    /// @param _rewardContract Reward Contract Address
    /// @param _teamWallet Team Wallet Address
    function initialize(
        uint256 _totalSupply,
        address _rewardContract,
        address _teamWallet
    ) public initializer {
        __ERC20_init("Sleep Token", "$SLEEP");
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        rewardContract = _rewardContract;
        factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
        teamWallet = _teamWallet;

        _mint(msg.sender, _totalSupply * 10**decimals());
    }

    /// @notice Settles Reward Contract Address
    /// @param _rewardContract Reward Contract Address
    /// @dev This function can only be called by the owner of the contract
    function setRewardContract(address _rewardContract) external onlyOwner {
        rewardContract = _rewardContract;
    }

    /// @notice Settles Pool Address
    /// @param _newAddress Address of the pool
    /// @dev This function can only be called by the owner of the contract
    function setPool(IUniswapV3Pool _newAddress) external onlyOwner {
        pool = _newAddress;
    }

    /// @notice Stops the contract
    /// @dev This function can only be called by the owner of the contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Starts the contract
    /// @dev This function can only be called by the owner of the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Mints tokens for this smart contract
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner of the contract
    function mintTokens(uint256 _amount) external onlyOwner {
        _mint(address(this), _amount);
    }

    /// @notice Burns tokens of this smart contract
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner of the contract
    function burnTokens(uint256 _amount) external onlyOwner {
        _burn(address(this), _amount);
    }

    /// @notice Sends tokens to reward Contract
    /// @param _amount Amount of tokens to send
    /// @dev This function can only be called by the owner of the contract
    function supplyRewardContract(uint256 _amount) external onlyOwner {
        _transfer(address(this), rewardContract, _amount);
    }

    /// @dev Function called before each transfert
    /// @param from Sender Address
    /// @param to Receiver Address
    /// @param amount Amount of tokens to send
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @notice Creates a new Pool and settles the initial price for the pool
    /// @param _tokenB Address of the pair token
    /// @param _fee Fee of the pool
    /// @param _sqrtPriceX96 Initial price of $Sleep
    /// @dev This function can only be called by the owner of the contract
    function createNewPool(
        address _tokenB,
        uint24 _fee,
        uint160 _sqrtPriceX96
    ) external onlyOwner {
        address newPool = factory.createPool(address(this), _tokenB, _fee);
        // Set new pool address
        pool = IUniswapV3Pool(newPool);
        // Init price of the pool
        pool.initialize(_sqrtPriceX96);
    }

    /// @notice Adds liquidity to the Pool
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @param _amount Amount of tokens
    /// @dev This function can only be called by the owner of the contract
    function addLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external onlyOwner {
        pool.mint(address(this), _tickLower, _tickUpper, _amount, "");
    }

    /// @notice Burns liquidity from the sender and account tokens owed
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @param _amount Amount of tokens
    /// @dev This function can only be called by the owner of the contract
    function burnLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external onlyOwner {
        pool.burn(_tickLower, _tickUpper, _amount);
    }

    /// @notice Collectes the pool fees
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @dev This function can only be called by the owner of the contract
    function collectFee(int24 _tickLower, int24 _tickUpper) external onlyOwner {
        pool.collect(
            teamWallet,
            _tickLower,
            _tickUpper,
            type(uint128).max,
            type(uint128).max
        );
    }
}
