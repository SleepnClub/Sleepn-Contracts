// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";


contract SleepToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    // Reward Contract Address
    address public rewardContract;

    // Team Wallet
    address public teamWallet;

    // Pool Address
    IUniswapV3Pool public pool;

    // UniswapV3Factory Address
    IUniswapV3Factory public factory;

    // Init
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

    // Set rewardContract
    function setRewardContract(address _rewardContract) external onlyOwner {
        rewardContract = _rewardContract;
    }

    // Set pool address
    function setPool(IUniswapV3Pool _newAddress) external onlyOwner {
        pool = _newAddress;
    }

    // Stop the contract
    function pause() external onlyOwner {
        _pause();
    }

    // Start the contract
    function unpause() external onlyOwner {
        _unpause();
    }

    // Mint tokens for this smart contract
    function mintTokens(uint256 _amount) external onlyOwner {
        _mint(address(this), _amount);
    }

    // Burn tokens of this smart contract
    function burnTokens(uint256 _amount) external onlyOwner {
        _burn(address(this), _amount);
    }

    // Send tokens to reward Contract
    function supplyRewardContract(uint256 _amount) external onlyOwner {
        _transfer(address(this), rewardContract, _amount);
    }

    // Before each transfert
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // Create a new Pool and set the initial price for the pool
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

    // Add liquidity to the Pool
    function addLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external onlyOwner {
        pool.mint(address(this), _tickLower, _tickUpper, _amount, "");
    }

    // Burn liquidity from the sender and account tokens owed
    function burnLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external onlyOwner {
        pool.burn(_tickLower, _tickUpper, _amount);
    }

    // Collect fees
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
