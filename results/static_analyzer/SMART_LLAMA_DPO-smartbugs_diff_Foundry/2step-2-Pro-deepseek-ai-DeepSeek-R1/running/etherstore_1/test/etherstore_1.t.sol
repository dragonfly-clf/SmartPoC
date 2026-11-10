// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract EtherStoreTest is Test {
    EtherStore public etherStore;
    address public user = makeAddr("user");
    uint256 public constant TEST_DEPOSIT = 0.1 ether;
    uint256 public constant WITHDRAWAL_AMOUNT = 0.05 ether;
    uint256 public constant ONE_WEEK = 1 weeks;
    bool vulnerabilityExists;

    function setUp() public {
        etherStore = new EtherStore();
        vm.deal(user, 10 ether);
        
        // Advance time to simulate passed one week after contract deployment
        vm.warp(block.timestamp + ONE_WEEK);
        
        // Deposit funds for the test user
        vm.prank(user);
        etherStore.depositFunds{value: TEST_DEPOSIT}();
    }

    function testTimestampDependenceVulnerability() public {
        vulnerabilityExists = false;
        
        // --- First withdrawal (expected success) ---
        console.log("\n=== Attempt 1: Initial Withdrawal ===");
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore1 = etherStore.getUserBalance(user);
        uint256 contractBalanceBefore1 = etherStore.getContractBalance();
        console.log("User balance: %d", userBalanceBefore1);
        console.log("Contract balance: %d", contractBalanceBefore1);
        
        console.log("--- Trigger Withdrawal of %d ---", WITHDRAWAL_AMOUNT);
        vm.prank(user);
        etherStore.withdrawFunds(WITHDRAWAL_AMOUNT);
        
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter1 = etherStore.getUserBalance(user);
        uint256 contractBalanceAfter1 = etherStore.getContractBalance();
        console.log("User balance: %d", userBalanceAfter1);
        console.log("Contract balance: %d", contractBalanceAfter1);

        // Validate successful withdrawal state changes
        bool attempt1Valid = true;
        if (userBalanceAfter1 != userBalanceBefore1 - WITHDRAWAL_AMOUNT) {
            console.log("!! USER BALANCE CHANGE INVALID");
            attempt1Valid = false;
        }
        if (contractBalanceAfter1 != contractBalanceBefore1 - WITHDRAWAL_AMOUNT) {
            console.log("!! CONTRACT BALANCE CHANGE INVALID");
            attempt1Valid = false;
        }
        if (!attempt1Valid) vulnerabilityExists = true;
        console.log("Success: %s", attempt1Valid ? "VALID" : "INVALID");

        // --- Second withdrawal (expected fail) ---
        console.log("\n=== Attempt 2: Immediate Withdrawal ===");
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore2 = userBalanceAfter1;
        uint256 contractBalanceBefore2 = contractBalanceAfter1;
        console.log("User balance: %d", userBalanceBefore2);
        console.log("Contract balance: %d", contractBalanceBefore2);

        console.log("--- Trigger Withdrawal of %d ---", WITHDRAWAL_AMOUNT);
        bool attempt2Reverted = false;
        vm.startPrank(user);
        vm.expectRevert();
        try etherStore.withdrawFunds(WITHDRAWAL_AMOUNT) {
            console.log("!! REVERT NOT CAUGHT");
        } catch {
            attempt2Reverted = true;
        }
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter2 = etherStore.getUserBalance(user);
        uint256 contractBalanceAfter2 = etherStore.getContractBalance();
        console.log("User balance: %d", userBalanceAfter2);
        console.log("Contract balance: %d", contractBalanceAfter2);

        // Validate no state change after failed withdrawal
        bool attempt2Valid = true;
        if (userBalanceAfter2 != userBalanceBefore2) {
            console.log("!! USER BALANCE CHANGED IMPROPERLY");
            attempt2Valid = false;
        }
        if (contractBalanceAfter2 != contractBalanceBefore2) {
            console.log("!! CONTRACT BALANCE CHANGED IMPROPERLY");
            attempt2Valid = false;
        }
        if (!attempt2Valid || !attempt2Reverted) vulnerabilityExists = true;
        console.log("Success: %s", attempt2Valid && attempt2Reverted ? "VALID" : "INVALID");

        // --- Third withdrawal (1 second before cooldown) ---
        console.log("\n=== Attempt 3: Premature Withdrawal ===");
        vm.warp(block.timestamp + ONE_WEEK - 1);
        
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore3 = userBalanceAfter2;
        uint256 contractBalanceBefore3 = contractBalanceAfter2;
        console.log("User balance: %d", userBalanceBefore3);
        console.log("Contract balance: %d", contractBalanceBefore3);

        console.log("--- Trigger Withdrawal of %d ---", WITHDRAWAL_AMOUNT);
        bool attempt3Reverted = false;
        vm.prank(user);
        vm.expectRevert();
        try etherStore.withdrawFunds(WITHDRAWAL_AMOUNT) {
            console.log("!! REVERT NOT CAUGHT");
        } catch {
            attempt3Reverted = true;
        }
        
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter3 = etherStore.getUserBalance(user);
        uint256 contractBalanceAfter3 = etherStore.getContractBalance();
        console.log("User balance: %d", userBalanceAfter3);
        console.log("Contract balance: %d", contractBalanceAfter3);

        // Validate no state change after failed withdrawal
        bool attempt3Valid = true;
        if (userBalanceAfter3 != userBalanceBefore3) {
            console.log("!! USER BALANCE CHANGED IMPROPERLY");
            attempt3Valid = false;
        }
        if (contractBalanceAfter3 != contractBalanceBefore3) {
            console.log("!! CONTRACT BALANCE CHANGED IMPROPERLY");
            attempt3Valid = false;
        }
        if (!attempt3Valid || !attempt3Reverted) vulnerabilityExists = true;
        console.log("Success: %s", attempt3Valid && attempt3Reverted ? "VALID" : "INVALID");

        // --- Fourth withdrawal (exactly at cooldown end) ---
        console.log("\n=== Attempt 4: Cooldown Completion Withdrawal ===");
        vm.warp(block.timestamp + 1);
        
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore4 = userBalanceAfter3;
        uint256 contractBalanceBefore4 = contractBalanceAfter3;
        console.log("User balance: %d", userBalanceBefore4);
        console.log("Contract balance: %d", contractBalanceBefore4);

        console.log("--- Trigger Withdrawal of %d ---", WITHDRAWAL_AMOUNT);
        vm.prank(user);
        etherStore.withdrawFunds(WITHDRAWAL_AMOUNT);
        
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter4 = etherStore.getUserBalance(user);
        uint256 contractBalanceAfter4 = etherStore.getContractBalance();
        console.log("User balance: %d", userBalanceAfter4);
        console.log("Contract balance: %d", contractBalanceAfter4);

        // Validate successful withdrawal state changes
        bool attempt4Valid = true;
        if (userBalanceAfter4 != userBalanceBefore4 - WITHDRAWAL_AMOUNT) {
            console.log("!! USER BALANCE CHANGE INVALID");
            attempt4Valid = false;
        }
        if (contractBalanceAfter4 != contractBalanceBefore4 - WITHDRAWAL_AMOUNT) {
            console.log("!! CONTRACT BALANCE CHANGE INVALID");
            attempt4Valid = false;
        }
        if (!attempt4Valid) vulnerabilityExists = true;
        console.log("Success: %s", attempt4Valid ? "VALID" : "INVALID");
        
        // Final vulnerability determination
        console.log("\n--- FINAL VERDICT ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Withdrawal behavior inconsistent with cooldown rules");
        } else {
            console.log("Vulnerability not Exist: All state changes aligned with expected results");
        }
    }
}