// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CitysHome.sol";

contract CitysHome_Test is Test {
    CitysHome token;
    address owner;
    address user = address(0x1);

    function setUp() public {
        owner = address(this);
        token = new CitysHome();
    }

    // Test ownerWithdrew over-withdrawal vulnerability
    function test_ownerWithdrew_overWithdrawal() public {
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console.log("Contract reserve balance:", contractBalanceBefore);
        console.log("Owner balance:", ownerBalanceBefore);
        
        uint256 withdrawalAmount = contractBalanceBefore + 1; 
        console.log("\n--- Trigger Operation ---");
        console.log("Call: ownerWithdrew(%s)", withdrawalAmount);
        bool success;
        try token.ownerWithdrew(withdrawalAmount) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }

        // Post-trigger state snapshot
        console.log("\n--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Contract reserve balance:", contractBalanceAfter);
        console.log("Owner balance:", ownerBalanceAfter);

        // Compare states and print verdict
        console.log("\n--- STATE CHANGE VERDICT ---");
        bool reserveDecreased = contractBalanceAfter < contractBalanceBefore;
        bool ownerIncreased = ownerBalanceAfter > ownerBalanceBefore;
        bool exploitSuccessful = success && reserveDecreased && ownerIncreased;
        
        if (exploitSuccessful) {
            console.log("SUCCESSFUL EXPLOITATION: Reserve decreased by %s wei, Owner increased by %s wei", 
                        contractBalanceBefore - contractBalanceAfter, 
                        ownerBalanceAfter - ownerBalanceBefore);
            assertTrue(false, "Vulnerability Exists: Over-withdrawal succeeded");
        } else {
            console.log("UNSUCCESSFUL EXPLOITATION: Transaction reverted as expected");
            assertTrue(!success, "Vulnerability not Exist: Reverted properly");
        }
    }

    // Test over-deposit vulnerability
    function test_ownerDeposit_overDeposit() public {
        // Setup: Transfer tokens to owner
        uint256 transferAmount = 10 ether;
        vm.prank(address(token));
        token.transfer(owner, transferAmount);

        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger State ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        console.log("Owner balance:", ownerBalanceBefore);
        console.log("Contract reserve balance:", contractBalanceBefore);

        uint256 depositAmount = ownerBalanceBefore + 1;
        uint256 depositTokens = depositAmount / 1e18 + 1; // Decimals conversion
        console.log("\n--- Trigger Operation ---");
        console.log("Call: ownerDeposit(%s tokens)", depositTokens);
        bool success;
        try token.ownerDeposit(depositTokens) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }

        // Post-trigger state snapshot
        console.log("\n--- AFTER-Trigger State ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        console.log("Owner balance:", ownerBalanceAfter);
        console.log("Contract reserve balance:", contractBalanceAfter);

        // Compare states and print verdict
        console.log("\n--- STATE CHANGE VERDICT ---");
        bool reserveIncreased = contractBalanceAfter > contractBalanceBefore;
        bool ownerDecreased = ownerBalanceAfter < ownerBalanceBefore;
        bool exploitSuccessful = success && reserveIncreased && ownerDecreased;
        
        if (exploitSuccessful) {
            console.log("SUCCESSFUL EXPLOITATION: Reserve increased by %s wei, Owner decreased by %s wei", 
                        contractBalanceAfter - contractBalanceBefore, 
                        ownerBalanceBefore - ownerBalanceAfter);
            assertTrue(false, "Vulnerability Exists: Over-deposit succeeded");
        } else {
            console.log("UNSUCCESSFUL EXPLOITATION: Transaction reverted as expected");
            assertTrue(!success, "Vulnerability not Exist: Reverted properly");
        }
    }
}