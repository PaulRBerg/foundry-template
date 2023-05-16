// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { console2 } from "forge-std/console2.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { Vm } from "@prb/test/Vm.sol";

import { Foo } from "src/Foo.sol";

contract Handler is StdUtils {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    Vm internal constant vm = Vm(VM_ADDRESS);

    Foo internal foo;

    constructor(Foo foo_) {
        foo = foo_;
    }

    // function id(uint256 value) external {
    //     foo.id(value);
    // }

    function warp(uint256 timeWarp) external {
        uint256 lowerBound = 24 hours;
        uint256 currentTime = block.timestamp;
        uint256 upperBound = currentTime + 10_000 days;
        timeWarp = _bound(timeWarp, lowerBound, upperBound);

        console2.log("Initial time is ", block.timestamp);
        vm.warp({ timestamp: currentTime + timeWarp });
        console2.log("After time is   ", block.timestamp);
    }
}
