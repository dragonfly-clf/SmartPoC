// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KOFATOKEN.sol";

contract GasManipulationTest is Test {
    ERC20DividendTracker tracker;
    
    // Helper function to create multiple holders
    function createHolders(uint256 count, uint256 minBalance) internal returns (address[] memory) {
        address[] memory holders = new address[](count);
        for(uint256 i = 0; i < count; i++) {
            holders[i] = address(uint160(0x1000 + i));
            tracker.setBalance(payable(holders[i]), minBalance + 1);
        }
        return holders;
    }

    function setUp() public {
        // Deploy the dividend tracker
        tracker = new ERC20DividendTracker();
        
        // Define minimum balance required for dividends
        uint256 minBalance = tracker.minimumTokenBalanceForDividends();
        
        // Create 100 token holders with minimum balance
        createHolders(100, minBalance);
        
        // Advance time to pass claimWait period
        vm.warp(block.timestamp + 350); // claimWait is 300 seconds
    }

    function testGasManipulation() public {
        // Take initial state snapshot
        uint256 snapshotId = vm.snapshot();
        
        console.log("--- BEFORE-Trigger Operation ---");
        console.log("State: Unprocessed dividend tracker with 100 holders");

        uint256 lowGas = 50_000;
        uint256 normalGas = 500_000;

        console.log("--- Trigger Operation: First call with low gas ---");
        (uint256 iterationsLow,,) = tracker.process(lowGas);
        console.log("Number of iterations processed (low gas): %d", iterationsLow);

        // Revert to pre-trigger state
        vm.revertTo(snapshotId);
        
        console.log("--- Before-Trigger Operation: Second call with normal gas ---");
        console.log("State: Reset to unprocessed state using snapshot");

        console.log("--- Trigger Operation: Second call with normal gas ---");
        (uint256 iterationsNormal,,) = tracker.process(normalGas);
        console.log("Number of iterations processed (normal gas): %d", iterationsNormal);

        console.log("--- Verdict ---");
        console.log("Comparison: iterations (normal gas) = %d, iterations (low gas) = %d", iterationsNormal, iterationsLow);
        
        if (iterationsNormal > iterationsLow) {
            console.log("Vulnerability Exists: Gas limit manipulation affects processing iterations");
        } else {
            console.log("Vulnerability not Exist: Gas limit manipulation does not affect processing iterations");
        }
    }
    
    function testFairProcessing() public {
        // Process with sufficient gas to cover all holders
        (uint256 iterations,,) = tracker.process(2_000_000);
        
        // Verify fair processing of all holders
        require(
            iterations == 100, 
            "Vulnerability: Not all holders processed with sufficient gas"
        );
    }
}