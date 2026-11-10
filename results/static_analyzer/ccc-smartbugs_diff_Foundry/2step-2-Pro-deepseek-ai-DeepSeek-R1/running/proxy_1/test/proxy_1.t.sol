// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract ProxyTest is Test {
    Proxy private proxy;
    address private owner = makeAddr("owner");
    address private attacker = makeAddr("attacker");
    address private mockCallee;

    function setUp() public {
        // Deploy proxy contract
        vm.startPrank(owner);
        proxy = new Proxy();
        vm.stopPrank();

        // Deploy mock callee contract that always succeeds
        mockCallee = address(new MockSuccessContract());
    }

    function test_minerTimestampManipulation() public {
        // Warp block timestamp by 1 hour
        uint256 newTimestamp = block.timestamp + 3600;
        vm.warp(newTimestamp);

        console.log("--- BEFORE-Trigger State ---");
        console.log("Warped Block Timestamp   :", newTimestamp);
        console.log("Expected Event Timestamp :", newTimestamp);

        console.log("--- Trigger MinerTimestampManipulation ---");
        vm.recordLogs(); // Start capturing events
        vm.prank(attacker);
        proxy.forward(mockCallee, hex"00");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger Event Capture ---");
        require(entries.length > 0, "No events emitted during attack");
        
        // Process & validate captured event
        (address eventSender, address eventCallee, uint256 eventTimestamp) = 
            decodeEvent(entries[0]);
        
        console.log("Captured Event Data:");
        console.log("Event Timestamp   :", eventTimestamp);
        console.log("Event Sender      :", eventSender);
        console.log("Event Callee      :", eventCallee);

        // Verification logic
        bool vulnerabilityExists = (eventTimestamp == newTimestamp);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Miner successfully manipulated event timestamp");
        } else {
            console.log("Vulnerability not Exist: Event timestamp not manipulated");
        }
    }

    // Helper function to decode emitted event
    function decodeEvent(Vm.Log memory log) internal pure returns (address, address, uint256) {
        bytes32 expectedEventSig = keccak256("TransactionForwarded(address,address,uint256)");
        require(log.topics[0] == expectedEventSig, "Invalid event signature");
        
        address sender = address(uint160(uint256(log.topics[1])));
        address callee = address(uint160(uint256(log.topics[2])));
        uint256 timestamp = abi.decode(log.data, (uint256));
        
        return (sender, callee, timestamp);
    }
}

contract MockSuccessContract {
    fallback(bytes calldata) external returns (bytes memory) {
        return "";
    }
}