// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract MaliciousToken {
    mapping(address => uint) public balanceOf;

    function setBalance(address account, uint amount) public {
        balanceOf[account] = amount;
    }

    function transfer(address, uint) public pure returns (bool) {
        // Always returns false to simulate transfer failure
        return false;
    }
}

contract TestUncheckedTransfer is Test {
    EtherGet public etherGet;
    MaliciousToken public maliciousToken;
    address public owner = address(0xABCD);

    function setUp() public {
        // Deploy EtherGet contract as the owner
        vm.startPrank(owner);
        etherGet = new EtherGet();
        vm.stopPrank();

        // Deploy malicious token
        maliciousToken = new MaliciousToken();
        // Set balance for EtherGet contract to simulate tokens
        maliciousToken.setBalance(address(etherGet), 100);
    }

    function testUncheckedTransfer() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalOperations = etherGet.totalTokenOperations();
        uint256 initialWithdrawalCount = etherGet.tokenWithdrawalCount(address(maliciousToken));
        console.log("Initial totalTokenOperations:", initialTotalOperations);
        console.log("Initial tokenWithdrawalCount:", initialWithdrawalCount);
        
        // Record logs to capture emitted events
        vm.recordLogs();
        
        console.log("--- Trigger withdrawTokens ---");
        // Perform withdrawal (will fail but ignore return value)
        vm.prank(owner);
        etherGet.withdrawTokens(address(maliciousToken));

        console.log("--- AFTER-Trigger State ---");
        uint256 afterTotalOperations = etherGet.totalTokenOperations();
        uint256 afterWithdrawalCount = etherGet.tokenWithdrawalCount(address(maliciousToken));
        console.log("Updated totalTokenOperations:", afterTotalOperations);
        console.log("Updated tokenWithdrawalCount:", afterWithdrawalCount);
        
        // Differential Validation
        bool totalOperationsIncreased = (afterTotalOperations == initialTotalOperations + 1);
        bool withdrawalCountIncreased = (afterWithdrawalCount == initialWithdrawalCount + 1);
        bool vulnerabilityExists = totalOperationsIncreased && withdrawalCountIncreased;
        
        console.log("State changed after failed transfer?", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State variables updated despite token transfer failure");
        } else {
            console.log("Vulnerability not Exist: No unexpected state change detected");
        }
        
        // Validate event emission (original verification logic preserved)
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 expectedEventSig = keccak256("TokensWithdrawn(address,uint256)");
        bool eventFound = false;
        
        for (uint i = 0; i < logs.length; i++) {
            Vm.Log memory log = logs[i];
            if (log.topics[0] == expectedEventSig) {
                assertEq(log.topics.length, 2, "Incorrect topics count");
                address tokenAddress = address(uint160(uint256(log.topics[1])));
                uint amount = abi.decode(log.data, (uint));
                
                if (tokenAddress == address(maliciousToken) && amount == 100) {
                    eventFound = true;
                    break;
                }
            }
        }
        assertTrue(eventFound, "TokensWithdrawn event should be emitted despite transfer failure");
    }
}