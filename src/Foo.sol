// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.37;

/// @title Foo
/// @author Paul Razvan Berg
/// @notice A minimal example contract.
contract Foo {
    /// @notice Returns the input value unchanged.
    /// @param value The value to return.
    /// @return The input value.
    function echo(uint256 value) external pure returns (uint256) {
        return value;
    }
}
