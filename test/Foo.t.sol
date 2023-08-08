// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Test, console } from "forge-std/Test.sol";

import { Foo } from "../src/Foo.sol";

contract FooTest is Test {
    Foo internal foo;

    function setUp() public virtual {
        foo = new Foo();
    }

    function test_Example() external {
        console.log("Hello World");
        uint256 x = 42;
        assertEq(foo.id(x), x, "value mismatch");
    }
}
