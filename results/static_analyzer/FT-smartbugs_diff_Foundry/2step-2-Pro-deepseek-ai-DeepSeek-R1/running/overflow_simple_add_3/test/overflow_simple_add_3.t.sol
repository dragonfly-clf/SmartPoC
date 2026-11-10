// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_simple_add.sol";

contract OverflowAddTest is Test {
    Overflow_Add public overflowAdd;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        overflowAdd = new Overflow_Add();
    }

    // Test that unauthorized user can manipulate deposits via add()
    function test_addFunctionLackingAccessControl() public {
        bool vulnerabilityExists = false;

        // ==== First attacker deposit ====
        console.log("--- BEFORE-Trigger (First attacker deposit) ---");
        vm.startPrank(attacker);
        uint attackerDepositBefore1 = overflowAdd.getMyDeposit();
        uint totalDepositsBefore1 = overflowAdd.totalDeposits();
        uint balanceBefore1 = address(overflowAdd).balance;
        vm.stopPrank();
        
        console.log("Attacker deposit:", attackerDepositBefore1);
        console.log("Total deposits:", totalDepositsBefore1);
        console.log("Contract ETH balance:", balanceBefore1);
        
        console.log("--- Trigger: Attacker deposits 100 tokens ---");
        vm.prank(attacker);
        overflowAdd.add(100);

        console.log("--- AFTER-Trigger (First attacker deposit) ---");
        vm.startPrank(attacker);
        uint attackerDepositAfter1 = overflowAdd.getMyDeposit();
        uint totalDepositsAfter1 = overflowAdd.totalDeposits();
        uint balanceAfter1 = address(overflowAdd).balance;
        vm.stopPrank();
        
        console.log("Attacker deposit:", attackerDepositAfter1);
        console.log("Total deposits:", totalDepositsAfter1);
        console.log("Contract ETH balance:", balanceAfter1);

        // Verify first deposit changes
        bool firstDepositSuccess = 
            (attackerDepositAfter1 == attackerDepositBefore1 + 100) &&
            (totalDepositsAfter1 == totalDepositsBefore1 + 100) &&
            (balanceAfter1 == balanceBefore1);
            
        if(firstDepositSuccess) {
            console.log("Verdict: Attacker successfully manipulated deposits (vulnerability indicator)");
            vulnerabilityExists = true;
        } else {
            console.log("Verdict: Initial deposit manipulation failed");
        }

        // ==== Regular user deposit ====
        console.log("User deposits 50 tokens...");
        vm.prank(user);
        overflowAdd.add(50);

        // ==== Second attacker deposit ====
        console.log("--- BEFORE-Trigger (Second attacker deposit) ---");
        vm.startPrank(attacker);
        uint attackerDepositBefore2 = overflowAdd.getMyDeposit();
        uint totalDepositsBefore2 = overflowAdd.totalDeposits();
        uint balanceBefore2 = address(overflowAdd).balance;
        vm.stopPrank();
        
        console.log("Attacker deposit:", attackerDepositBefore2);
        console.log("Total deposits:", totalDepositsBefore2);
        console.log("Contract ETH balance:", balanceBefore2);
        
        console.log("--- Trigger: Attacker deposits another 100 tokens ---");
        vm.prank(attacker);
        overflowAdd.add(100);

        console.log("--- AFTER-Trigger (Second attacker deposit) ---");
        vm.startPrank(attacker);
        uint attackerDepositAfter2 = overflowAdd.getMyDeposit();
        uint totalDepositsAfter2 = overflowAdd.totalDeposits();
        uint balanceAfter2 = address(overflowAdd).balance;
        vm.stopPrank();
        
        console.log("Attacker deposit:", attackerDepositAfter2);
        console.log("Total deposits:", totalDepositsAfter2);
        console.log("Contract ETH balance:", balanceAfter2);
        
        // Final verdict
        if(vulnerabilityExists) {
            console.log("Vulnerability Exists: Unauthorized attacker could manipulate deposit state variables");
        } else {
            console.log("Vulnerability not Exist: Attacker deposit changes failed - access control might be enforced");
        }
    }
}