// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.37 <0.9.0;

import { Foo } from "../src/Foo.sol";
import { Script } from "forge-std/src/Script.sol";

/// @title DeployBrowser
/// @author Paul Razvan Berg
/// @notice Deploys `Foo` through a browser wallet.
contract DeployBrowser is Script {
    /// @notice Broadcasts a new `Foo` deployment.
    /// @return foo The deployed contract.
    function run() public returns (Foo foo) {
        vm.startBroadcast();
        foo = new Foo();
        vm.stopBroadcast();
    }
}
