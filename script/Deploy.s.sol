// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.37 <0.9.0;

import { Foo } from "../src/Foo.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://getfoundry.sh/forge/scripting
/// @title Deploy
/// @author Paul Razvan Berg
/// @notice Deploys `Foo` with the configured broadcaster.
contract Deploy is BaseScript {
    /// @notice Broadcasts a new `Foo` deployment.
    /// @return foo The deployed contract.
    function run() public broadcast returns (Foo foo) {
        foo = new Foo();
    }
}
