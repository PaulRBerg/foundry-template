// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract FooTest is PRBTest, StdCheats {
    /// @dev An optional function invoked before each test case is run
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// @dev Simple test. Run Forge with `-vvvv` to see console logs.
    function test_Example() external {
        console2.log("Hello World");
        assertTrue(true);
    }

    /// @dev Test that fuzzes an unsigned integer. Run Forge with `-vvvv` to see console logs.
    function testFuzz_Example(uint256 x) external {
        vm.assume(x != 0);
        console2.log("x", x);
        assertTrue(x > 0);
    }
}
