// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";

import { Foo } from "src/Foo.sol";
import { Handler } from "./Handler.sol";

contract FooInvariant is PRBTest, StdInvariant {
    Foo internal foo = new Foo();
    Handler internal handler = new Handler(foo);

    function setUp() public virtual {
        targetContract(address(handler));
        excludeSender(address(foo));

        // console2.log("Starting timestamp is ", block.timestamp);
    }

    function invariant_Foo() external {
        // console2.log("Current timestamp is  ", block.timestamp);
        handler.warp(100);
        assertTrue(true);
    }
}
