// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Interface of $Sleep Contract
/// @author Sleepn
/// @notice $Sleep is the official token of Sleepn
interface ISleep is IERC20 {
    /// @notice Stops the contract
    /// @dev This function can only be called by the owner of the contract
    function pause() external;

    /// @notice Starts the contract
    /// @dev This function can only be called by the owner of the contract
    function unpause() external;

    /// @notice Mints tokens
    /// @param _amount Amount of tokens to mint
    /// @dev This function can only be called by the owner
    function mint(uint256 _amount) external;

    /// @notice Burns tokens
    /// @param _account Tokens owner address
    /// @param _amount Tokens amount to burn
    function burnFrom(address _account, uint256 _amount) external;

    /// @notice Burns tokens
    /// @param _amount Tokens amount to burn
    function burn(uint256 _amount) external;
}
