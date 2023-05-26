// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { Foo } from "../src/Foo.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcaster returns (Foo foo) {
        foo = new Foo();
    }
}
