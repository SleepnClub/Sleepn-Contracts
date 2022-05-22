// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

/// @title Interface of the $Sleep Token Contract
/// @author Alexis Balayre
/// @notice $Sleep is the official token of getSleepn App
interface ISleepToken is IERC20Upgradeable {
    /// @notice Burns tokens from an account
    /// @param _account Address of the account
    /// @param _amount Number of tokens to burn
    function burnFrom(address _account, uint256 _amount) external;

    /// @notice Gets balance of an account
    /// @param _account Address of the account
    /// @return _balance Balance of the account
    function balanceOf(address _account)
        external
        view
        returns (uint256 _balance);

    /// @notice Settles Pool Address
    /// @param _newAddress Address of the pool
    /// @dev This function can only be called by the owner of the contract
    function setPool(IUniswapV3Pool _newAddress) external;

    /// @notice Stops the contract
    /// @dev This function can only be called by the owner of the contract
    function pause() external;

    /// @notice Starts the contract
    /// @dev This function can only be called by the owner of the contract
    function unpause() external;

    /// @notice Mints tokens for this smart contract
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner of the contract
    function mintTokens(uint256 _amount) external;

    /// @notice Burns tokens of this smart contract
    /// @param _amount Amount of tokens to burn
    /// @dev This function can only be called by the owner of the contract
    function burnTokens(uint256 _amount) external;

    /// @notice Sends tokens to reward Contract
    /// @param _amount Amount of tokens to send
    /// @dev This function can only be called by the owner of the contract
    function supplyRewardContract(uint256 _amount) external;

    /// @notice Creates a new Pool and settles the initial price for the pool
    /// @param _tokenB Address of the pair token
    /// @param _fee Fee of the pool
    /// @param _sqrtPriceX96 Initial price of $Sleep
    /// @dev This function can only be called by the owner of the contract
    function createNewPool(
        address _tokenB,
        uint24 _fee,
        uint160 _sqrtPriceX96
    ) external;

    /// @notice Adds liquidity to the Pool
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @param _amount Amount of tokens
    /// @dev This function can only be called by the owner of the contract
    function addLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    /// @notice Burns liquidity from the sender and account tokens owed
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @param _amount Amount of tokens
    /// @dev This function can only be called by the owner of the contract
    function burnLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    /// @notice Collectes the pool fees
    /// @param _tickLower Lower tick
    /// @param _tickUpper Upper tick
    /// @dev This function can only be called by the owner of the contract
    function collectFee(int24 _tickLower, int24 _tickUpper) external;
}
