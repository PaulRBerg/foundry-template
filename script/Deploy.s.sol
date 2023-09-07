// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Foo } from "../src/Foo.sol";
import { BaseScript } from "./Base.s.sol";
import { DeploymentConfig } from "./DeploymentConfig.s.sol";

contract Deploy is BaseScript {
    function run() public returns (Foo foo, DeploymentConfig deploymentConfig) {
        deploymentConfig = new DeploymentConfig(broadcaster);
        foo = new Foo();
    }
}
