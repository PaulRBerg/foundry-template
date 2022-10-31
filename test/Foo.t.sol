// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract ContractTest is PRBTest, StdCheats {
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testExample() public {
        console2.log("Hello World");
        assertTrue(true);
    }
}
