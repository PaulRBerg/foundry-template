// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.37 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Foo } from "../src/Foo.sol";

/// @title IERC20
/// @author Paul Razvan Berg
/// @notice Minimal ERC-20 interface used by the fork test.
interface IERC20 {
    /// @notice Returns the token balance of an account.
    /// @param account The account to query.
    /// @return The account's token balance.
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://getfoundry.sh/forge/testing
/// @title FooTest
/// @author Paul Razvan Berg
/// @notice Exercises the example contract.
contract FooTest is Test {
    Foo internal foo;

    /// @dev A function invoked before each test case is run.
    /// @notice Initializes the contract-under-test.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        foo = new Foo();
    }

    /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    /// @notice Checks that `Foo.echo` returns its input.
    function test_Example() external view {
        console2.log("Hello World");
        uint256 x = 42;
        assertEq(foo.echo(x), x, "value mismatch");
    }

    /// @dev Fuzz test that provides random values for an unsigned integer, but which rejects zero as an input.
    /// If you need more sophisticated input validation, you should use the `bound` utility instead.
    /// See https://twitter.com/PaulRBerg/status/1622558791685242880
    /// @notice Checks `Foo.echo` for a nonzero fuzz input.
    /// @param x The input value to check.
    function testFuzz_Example(uint256 x) external view {
        vm.assume(x != 0); // or x = bound(x, 1, 100)
        assertEq(foo.echo(x), x, "value mismatch");
    }

    /// @dev Fork test that runs against an Ethereum Mainnet fork. For this to work, you need to set `API_KEY_ALCHEMY`
    /// in your environment You can get an API key for free at https://alchemy.com.
    /// @notice Checks a known USDC balance on an Ethereum Mainnet fork.
    function testFork_Example() external {
        // Silently pass this test if there is no API key.
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        if (bytes(alchemyApiKey).length == 0) {
            return;
        }

        // Otherwise, run the test against the mainnet fork.
        vm.createSelectFork({ urlOrAlias: "mainnet", blockNumber: 16_428_000 });
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address holder = 0x7713974908Be4BEd47172370115e8b1219F4A5f0;
        uint256 actualBalance = IERC20(usdc).balanceOf(holder);
        uint256 expectedBalance = 196_307_713.810457e6;
        assertEq(actualBalance, expectedBalance);
    }
}
