// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/0xe894d54dca59cb53fe9cbc5155093605c7068220.sol";

contract AuditTest is Test {
    airDrop drop;
    address constant TOKEN_ADDRESS = address(0);

    // Helper function to get current protocol state
    function _getState() internal view returns (
        uint totalDrops,
        uint totalTokensDistributed,
        uint userDropCount
    ) {
        totalDrops = drop.totalDrops();
        totalTokensDistributed = drop.totalTokensDistributed();
        userDropCount = drop.userDropCount(address(this));
    }

    function setUp() public {
        drop = new airDrop();
    }

    function test_transfer_overflow() public {
        // Initial state snapshot
        (uint totalDropsBefore, uint totalTokensDistributedBefore, uint userDropCountBefore) = _getState();

        console.log("\n--- BEFORE-Trigger State - Overflow Test ---");
        console.log("Initial totalDrops:", totalDropsBefore);
        console.log("Initial totalTokensDistributed:", totalTokensDistributedBefore);
        console.log("Initial userDropCount:", userDropCountBefore);

        address[] memory recipients = new address[](2);
        recipients[0] = address(0x1);
        recipients[1] = address(0x2);
        
        uint maliciousTransferVal = type(uint).max / 2 + 1;
        uint decimals = 0;

        console.log("\n--- Trigger Transfer (Overflow Attack) ---");
        vm.expectRevert(stdError.arithmeticError);
        drop.transfer(
            address(this),
            TOKEN_ADDRESS,
            recipients,
            maliciousTransferVal,
            decimals
        );

        // Post-attack state snapshot
        (uint totalDropsAfter, uint totalTokensDistributedAfter, uint userDropCountAfter) = _getState();
        console.log("\n--- AFTER-Trigger State - Overflow Test ---");
        console.log("Final totalDrops:", totalDropsAfter);
        console.log("Final totalTokensDistributed:", totalTokensDistributedAfter);
        console.log("Final userDropCount:", userDropCountAfter);

        // State differential verification
        bool isStateUnchanged = 
            (totalDropsBefore == totalDropsAfter) &&
            (totalTokensDistributedBefore == totalTokensDistributedAfter) &&
            (userDropCountBefore == userDropCountAfter);
        
        console.log("\n=== Differential Result - Overflow Test ===");
        console.log("State unchanged:", isStateUnchanged ? "YES" : "NO");

        if (isStateUnchanged) {
            console.log("Vulnerability not Exist: State preserved after arithmetic revert");
        } else {
            console.log("Vulnerability Exists: State corruption detected after overflow revert");
        }
    }

    function test_transfer_underflow() public {
        // Initial state snapshot
        (uint totalDropsBefore, uint totalTokensDistributedBefore, uint userDropCountBefore) = _getState();
        
        console.log("\n--- BEFORE-Trigger State - Underflow Test ---");
        console.log("Initial totalDrops:", totalDropsBefore);
        console.log("Initial totalTokensDistributed:", totalTokensDistributedBefore);
        console.log("Initial userDropCount:", userDropCountBefore);

        address[] memory recipients = new address[](2);
        recipients[0] = address(0x1);
        recipients[1] = address(0x2);
        
        uint maliciousTransferVal = 0;
        uint decimals = type(uint).max;

        console.log("\n--- Trigger Transfer (Underflow Attack) ---");
        vm.expectRevert(stdError.arithmeticError);
        drop.transfer(
            address(this),
            TOKEN_ADDRESS,
            recipients,
            maliciousTransferVal,
            decimals
        );

        // Post-attack state snapshot
        (uint totalDropsAfter, uint totalTokensDistributedAfter, uint userDropCountAfter) = _getState();
        console.log("\n--- AFTER-Trigger State - Underflow Test ---");
        console.log("Final totalDrops:", totalDropsAfter);
        console.log("Final totalTokensDistributed:", totalTokensDistributedAfter);
        console.log("Final userDropCount:", userDropCountAfter);

        // State differential verification
        bool isStateUnchanged = 
            (totalDropsBefore == totalDropsAfter) &&
            (totalTokensDistributedBefore == totalTokensDistributedAfter) &&
            (userDropCountBefore == userDropCountAfter);
        
        console.log("\n=== Differential Result - Underflow Test ===");
        console.log("State unchanged:", isStateUnchanged ? "YES" : "NO");

        if (isStateUnchanged) {
            console.log("Vulnerability not Exist: State preserved after arithmetic revert");
        } else {
            console.log("Vulnerability Exists: State corruption detected after underflow revert");
        }
    }
}