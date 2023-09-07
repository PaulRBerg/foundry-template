// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Test, console } from "forge-std/Test.sol";

import { Deploy } from "../script/Deploy.s.sol";
import { DeploymentConfig } from "../script/DeploymentConfig.s.sol";
import { Foo } from "../src/Foo.sol";

contract FooTest is Test {
    Foo internal foo;
    DeploymentConfig internal deploymentConfig;

    address internal deployer;

    function setUp() public virtual {
        Deploy deployment = new Deploy();
        (foo, deploymentConfig) = deployment.run();
    }

    function test_Example() external {
        console.log("Hello World");
        uint256 x = 42;
        assertEq(foo.id(x), x, "value mismatch");
    }
}
