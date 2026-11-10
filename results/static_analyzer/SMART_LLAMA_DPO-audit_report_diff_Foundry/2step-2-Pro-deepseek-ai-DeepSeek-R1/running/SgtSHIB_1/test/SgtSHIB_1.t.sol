// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SgtSHIB.sol";

contract DividendTrackerGasTest is Test {
    SgtSHIBDividendTracker public dividendTracker;
    
    address owner;
    uint256 public constant MINIMUM_BALANCE = 100 * (10**18);
    uint256 public constant CLAIM_WAIT = 3600; // Min allowed claim wait

    function setUp() public {
        owner = address(this);
        dividendTracker = new SgtSHIBDividendTracker();
        
        // Set valid claim wait and warp time to make claims possible
        dividendTracker.updateClaimWait(CLAIM_WAIT);
        vm.warp(CLAIM_WAIT + 1); // Set time past required duration

        // Create token holders with minimum balance
        for (uint i = 0; i < 20; i++) {
            address holder = address(uint160(i + 100));
            dividendTracker.setBalance(payable(holder), MINIMUM_BALANCE);
        }
    }

    function testGasManipulation() public {
        uint256 snapshotId = vm.snapshot();
        
        console.log("--- BEFORE-Trigger: Low Gas Processing ---");
        console.log("Executing process with 50_000 gas...");
        (uint256 iterationsLowGas,,) = dividendTracker.process(50_000);
        console.log("Resulting iterations count: %d", iterationsLowGas);
        
        console.log("--- REVERTING STATE FOR COMPARISON ---");
        vm.revertTo(snapshotId);
        
        console.log("--- BEFORE-Trigger: High Gas Processing ---");
        console.log("Executing process with 500_000 gas...");
        (uint256 iterationsHighGas,,) = dividendTracker.process(500_000);
        console.log("Resulting iterations count: %d", iterationsHighGas);
        
        console.log("--- DIFFERENTIAL VERIFICATION ---");
        uint256 iterationDifference = iterationsHighGas - iterationsLowGas;
        bool vulnerabilityExists = iterationsHighGas > iterationsLowGas;
        
        console.log("Iteration difference (HighGas - LowGas): %d", iterationDifference);
        console.log("Vulnerability state: %s", vulnerabilityExists ? "EXISTS" : "DOES NOT EXIST");
        
        // Final verdict and test assertion
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Miner can influence iterations through gas manipulation");
        } else {
            console.log("Vulnerability not Exist: Gas changes do not affect processing iterations");
        }
        assertTrue(vulnerabilityExists, "Vulnerability not detected: gas increase didn't produce more iterations");
    }
}