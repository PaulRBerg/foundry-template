// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.29 <0.9.0;

import { Foo } from "../src/Foo.sol";
import { Script } from "forge-std/src/Script.sol";

contract DeployBrowser is Script {
    function run() public returns (Foo foo) {
        vm.startBroadcast();
        foo = new Foo();
        vm.stopBroadcast();
    }
}
