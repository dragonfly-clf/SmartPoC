// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KOFATOKEN.sol";

contract DividendTrackerTest is Test {
    ERC20DividendTracker dividendTracker;
    address nonHolder = address(0xDEAD);
    
    function setUp() public {
        dividendTracker = new ERC20DividendTracker();
    }

    function testNegativeIndex() public {
        console.log("--- BEFORE: Pre-Trigger State ---");
        console.log("No state change expected. Preparing to call getAccount()");

        console.log("--- Trigger: Calling getAccount() ---");
        (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        ) = dividendTracker.getAccount(nonHolder);

        console.log("--- AFTER: Post-Trigger State ---");
        console.log("Returned values from getAccount():");
        console.log("Account: ", account);
        console.log("Index: ", index);
        console.log("IterationsUntilProcessed: ", iterationsUntilProcessed);
        console.log("WithdrawableDividends: ", withdrawableDividends);
        console.log("TotalDividends: ", totalDividends);
        console.log("LastClaimTime: ", lastClaimTime);
        console.log("NextClaimTime: ", nextClaimTime);
        console.log("SecondsUntilAutoClaimAvailable: ", secondsUntilAutoClaimAvailable);

        // Validate static returns match vulnerable state
        bool isVulnerable = (account == nonHolder) && 
                            (index == -1) &&
                            (iterationsUntilProcessed == -1) &&
                            (withdrawableDividends == 0) &&
                            (totalDividends == 0) &&
                            (lastClaimTime == 0) &&
                            (nextClaimTime == 0) &&
                            (secondsUntilAutoClaimAvailable == 0);
        
        if (isVulnerable) {
            console.log("Vulnerability Exists: getAccount() returns negative index for non-holders");
        } else {
            console.log("Vulnerability not Exist: getAccount() returns safe values");
        }
    }
}