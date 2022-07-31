// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Cheats } from "forge-std/Cheats.sol";
import { console } from "forge-std/console.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract ContractTest is PRBTest, Cheats {
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testExample() public {
        console.log("Hello World");
        assertTrue(true);
    }
}
