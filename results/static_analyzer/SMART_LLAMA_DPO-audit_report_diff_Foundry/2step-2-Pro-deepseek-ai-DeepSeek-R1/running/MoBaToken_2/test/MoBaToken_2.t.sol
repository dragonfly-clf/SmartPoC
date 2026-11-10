// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = address(0x1);
    address alice = address(0x2);
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        vm.startPrank(owner);
        token = new MoBaToken("MoBaToken", "MOBA");
        token.cross(alice, INITIAL_BALANCE);
        vm.stopPrank();
    }

    function test_BurnSameAccountMultipleTimes() public {
        vm.startPrank(owner);
        
        // State snapshot before first burn
        uint256 aliceBalanceBefore1st = token.balanceOf(alice);
        uint256 totalSupplyBefore1st = token.totalSupply();
        console.log("--- BEFORE FIRST BURN ---");
        console.log("Alice balance:", aliceBalanceBefore1st);
        console.log("Total supply:", totalSupplyBefore1st);
        console.log("");
        
        // First burn
        uint256 firstBurnAmount = 100 ether;
        console.log("--- TRIGGER: FIRST BURN ---");
        token.managerBurn(alice, firstBurnAmount);
        console.log("Burned amount:", firstBurnAmount);
        console.log("");

        // State snapshot after first burn
        uint256 aliceBalanceAfter1st = token.balanceOf(alice);
        uint256 totalSupplyAfter1st = token.totalSupply();
        console.log("--- AFTER FIRST BURN ---");
        console.log("Alice balance:", aliceBalanceAfter1st);
        console.log("Total supply:", totalSupplyAfter1st);
        
        // Verify first burn effect
        bool firstBurnValid = (aliceBalanceBefore1st - aliceBalanceAfter1st == firstBurnAmount) &&
                              (totalSupplyBefore1st - totalSupplyAfter1st == firstBurnAmount);
        console.log("First burn effect verified:", firstBurnValid ? "YES" : "NO");
        console.log("-----------------------");
        console.log("");

        // State snapshot before second burn
        uint256 aliceBalanceBefore2nd = token.balanceOf(alice);
        uint256 totalSupplyBefore2nd = token.totalSupply();
        console.log("--- BEFORE SECOND BURN ---");
        console.log("Alice balance:", aliceBalanceBefore2nd);
        console.log("Total supply:", totalSupplyBefore2nd);
        console.log("");
        
        // Second burn on same account
        uint256 secondBurnAmount = 100 ether;
        console.log("--- TRIGGER: SECOND BURN ---");
        token.managerBurn(alice, secondBurnAmount);
        console.log("Burned amount:", secondBurnAmount);
        console.log("");

        // State snapshot after second burn
        uint256 aliceBalanceAfter2nd = token.balanceOf(alice);
        uint256 totalSupplyAfter2nd = token.totalSupply();
        console.log("--- AFTER SECOND BURN ---");
        console.log("Alice balance:", aliceBalanceAfter2nd);
        console.log("Total supply:", totalSupplyAfter2nd);
        
        // Verify second burn effect
        bool secondBurnValid = (aliceBalanceBefore2nd - aliceBalanceAfter2nd == secondBurnAmount) &&
                               (totalSupplyBefore2nd - totalSupplyAfter2nd == secondBurnAmount);
        console.log("Second burn effect verified:", secondBurnValid ? "YES" : "NO");
        console.log("-----------------------");
        console.log("");

        // Final verification
        uint256 expectedBalance = INITIAL_BALANCE - firstBurnAmount - secondBurnAmount;
        bool vulnerabilityExists = 
            aliceBalanceAfter2nd == expectedBalance && 
            totalSupplyAfter2nd == token.totalSupply();
        
        // Vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: The contract allows multiple burns on same account without uniqueness check");
        } else {
            console.log("Vulnerability not Exist: Failed to achieve expected state after multiple burns");
        }

        vm.stopPrank();
    }
}