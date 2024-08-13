// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

/// @title IEntry
/// @notice An example entry contract interface
/// @author You
interface IEntry {
    /// @notice A public function that sets the value
    /// @param _value The new value
    function setValue(uint256 _value) external;
}
