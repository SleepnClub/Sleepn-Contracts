// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

interface ISleepToken is IERC20Upgradeable {
    function burnFrom(address account, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function setPool(IUniswapV3Pool _newAddress) external;

    function pause() external;

    function unpause() external;

    function mintTokens(uint256 _amount) external;

    function supplyRewardContract(uint256 _amount) external;

    function createNewPool(
        address _tokenB,
        uint24 _fee,
        uint160 _sqrtPriceX96
    ) external;

    function addLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    function burnLiquidity(
        int24 _tickLower,
        int24 _tickUpper,
        uint128 _amount
    ) external;

    function collectFee(int24 _tickLower, int24 _tickUpper) external;
}
