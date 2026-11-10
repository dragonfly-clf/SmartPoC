// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {VmSafe} from "forge-std/Vm.sol";
import "../src/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol";

contract UnboundedLogGrowthTest is Test {
    Log public logContract;
    W_WALLET public walletContract;
    
    // Helper function to try reading from Log.History
    function tryGetHistoryLength(address logAddress) internal returns (uint256 finalLength) {
        uint256 i = 0;
        while (true) {
            (bool success, ) = address(logAddress).call(
                abi.encodeWithSignature("History(uint256)", i)
            );
            if (!success) {
                break;
            }
            i++;
        }
        return i;
    }

    function setUp() public {
        logContract = new Log();
        walletContract = new W_WALLET(address(logContract));
    }

    function test_CanExceed100LogEntriesWithoutRevert() public {
        uint256 messageCount = 101;
        uint256 valuePerCall = 1 ether;
        uint256 totalValue = messageCount * valuePerCall;

        // Fund the test contract sufficient ether
        deal(address(this), totalValue);

        console2.log("--- BEFORE-Trigger History Length ---");
        uint256 initialHistoryLength;
        // Attempt to find initial length via reverts
        initialHistoryLength = tryGetHistoryLength(address(logContract));
        console2.log("Initial History Length (revert test):", initialHistoryLength);

        console2.log("--- Trigger Put Loop (101 times) ---");
        // Execute 101 Put operations to create log entries
        for (uint256 i = 0; i < messageCount; i++) {
            walletContract.Put{value: valuePerCall}(block.timestamp + 100 days);
        }

        console2.log("--- AFTER-Trigger History Length ---");
        uint256 finalHistoryLength = tryGetHistoryLength(address(logContract));
        console2.log("Final History Length (revert test):", finalHistoryLength);

        uint256 addedEntries = finalHistoryLength - initialHistoryLength;
        console2.log("Added Entries:", addedEntries, "Expected:", messageCount);
        bool vulnerabilityExists = addedEntries == messageCount;

        // Verify all ether was transferred to wallet
        assertEq(address(walletContract).balance, totalValue, "Wallet balance mismatch");
        assertEq(address(this).balance, 0, "Test contract balance should be zero");

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Successfully added 101 entries to History array without restrictions");
        } else {
            console2.log("Vulnerability not Exist: Failed to add 101 entries to History array");
        }
    }
}