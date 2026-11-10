// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaElonVerse.sol";

contract DividendExclusionTest is Test {
    TOKENDividendTracker public dividendTracker;
    
    address owner = address(this); // Test contract is owner
    address user = address(0x2);
    uint256 initialBalance = 50000 * 10**18;

    function setUp() public {
        dividendTracker = new TOKENDividendTracker();
    }

    function testPermanentDividendExclusion() public {
        // Set initial balance for user
        dividendTracker.setBalance(payable(user), initialBalance);
        
        // BEFORE-Trigger: State before exclusion
        console2.log("--- BEFORE-Trigger Exclusion ---");
        bool excludedBefore = dividendTracker.excludedFromDividends(user);
        uint256 balanceBefore = dividendTracker.balanceOf(user);
        console2.log("excludedFromDividends? %s", excludedBefore ? "YES" : "NO");
        console2.log("balanceOf user: %s", balanceBefore);
        
        // Verify initial inclusion and balance
        assertFalse(excludedBefore);
        assertEq(balanceBefore, initialBalance);
        
        // TRIGGER: Exclusion operation
        console2.log("--- Trigger Exclusion ---");
        dividendTracker.excludeFromDividends(user);
        
        // AFTER-Trigger: State after exclusion
        console2.log("--- AFTER-Trigger Exclusion ---");
        bool excludedAfter = dividendTracker.excludedFromDividends(user);
        uint256 balanceAfter = dividendTracker.balanceOf(user);
        console2.log("excludedFromDividends? %s", excludedAfter ? "YES" : "NO");
        console2.log("balanceOf user: %s", balanceAfter);
        
        // Verify exclusion and zero balance
        assertTrue(excludedAfter);
        assertEq(balanceAfter, 0);
        
        // BEFORE-Trigger: State before setBalance
        console2.log("--- BEFORE-Trigger SetBalance ---");
        uint256 balanceBeforeSet = dividendTracker.balanceOf(user);
        console2.log("balanceOf user: %s", balanceBeforeSet);
        
        // TRIGGER: Try to set balance after exclusion
        console2.log("--- Trigger SetBalance ---");
        dividendTracker.setBalance(payable(user), initialBalance);
        
        // AFTER-Trigger: State after setBalance
        console2.log("--- AFTER-Trigger SetBalance ---");
        bool excludedFinal = dividendTracker.excludedFromDividends(user);
        uint256 balanceFinal = dividendTracker.balanceOf(user);
        console2.log("excludedFromDividends? %s", excludedFinal ? "YES" : "NO");
        console2.log("balanceOf user: %s", balanceFinal);
        
        // Final verdict
        if (balanceFinal != initialBalance) {
            console2.log("Vulnerability Exists: User remains permanently excluded");
        } else {
            console2.log("Vulnerability not Exist: Exclusion reverted successfully");
        }
        
        // Maintain original assertions
        assertTrue(excludedFinal);
        assertEq(balanceFinal, 0);
    }
}