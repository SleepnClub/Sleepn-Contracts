// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

/// @title Interface of the SleepToken Contract
/// @author Alexis Balayre
/// @notice Contains the external functions of the SleepToken Contract
interface ISleepToken is IERC20Upgradeable {
    /// @notice Burns tokens from an account 
    /// @param _account Address of the account
    /// @param _amount Number of tokens to burn
    function burnFrom(address _account, uint256 _amount) external;

    /// @notice Gets balance of an account
    /// @param _account Address of the account
    function balanceOf(address _account) external view returns (uint256);

    /// @notice Settles the address of the Pool
    /// @param _newAddress New address of the pool
    /// @dev Only Owner contract
    function setPool(IUniswapV3Pool _newAddress) external;

    /// @notice Pauses the contract
    /// @dev Only Owner contract
    function pause() external;

    /// @notice Starts of the contract
    /// @dev Only Owner contract
    function unpause() external;

    /// @notice Mints tokens for the smartcontract
    /// @param _amount Number of tokens to mint
    /// @dev Only Owner contract
    function mintTokens(uint256 _amount) external;

    /// @notice Sends tokens to Reward Contract
    /// @param _amount Number of tokens to send 
    /// @dev Only Owner contract
    function supplyRewardContract(uint256 _amount) external;

    /// @notice Creates a new pool on Uniswap
    /// @param _tokenB Address of the collateral token
    /// @param _fee Fee price of the pool
    /// @param _sqrtPriceX96 Initial price of the token
    /// @dev Only Owner contract
    function createNewPool(
        address _tokenB,
        uint24 _fee,
        uint160 _sqrtPriceX96
    ) external;

    /// @notice Adds liquidity to the pool
    /// @param _tickLower tick Lower
    /// @param _tickUpper tick Upper
    /// @param _amount Amount of tokens to add
    /// @dev Only Owner contract
    function addLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    /// @notice Burns liquidity in the pool 
    /// @param _tickLower tick Lower
    /// @param _tickUpper tick Upper
    /// @param _amount Amount of tokens to burn
    /// @dev Only Owner contract
    function burnLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    /// @notice Collectes fees
    /// @param _tickLower tick Lower
    /// @param _tickUpper tick Upper
    /// @dev Only Owner contract
    function collectFee(int24 _tickLower, int24 _tickUpper) external;
}
