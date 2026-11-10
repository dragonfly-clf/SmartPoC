// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract TransferOverflowTest is Test {
    Reentrancy_cross_function public bank;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    
    function setUp() public {
        bank = new Reentrancy_cross_function();
    }

    function testTransferCausesOverflow() public {
        // Set up initial balances using storage manipulation
        uint mappingSlot = 0; // Assuming userBalances mapping is at slot 0
        uint aliceBalanceSlot = uint(keccak256(abi.encode(alice, mappingSlot)));
        uint bobBalanceSlot = uint(keccak256(abi.encode(bob, mappingSlot)));
        uint maxUint = type(uint).max;

        // Set Alice's balance to 10
        vm.store(address(bank), bytes32(aliceBalanceSlot), bytes32(uint(10)));
        
        // Set Bob's balance to MAX_UINT - 1 to create overflow scenario
        vm.store(address(bank), bytes32(bobBalanceSlot), bytes32(maxUint - 1));

        console.log("--- BEFORE-Trigger State ---");
        uint aliceBefore = bank.getBalance(alice);
        uint bobBefore = bank.getBalance(bob);
        console.log("Alice initial balance:", aliceBefore);
        console.log("Bob initial balance:", bobBefore);

        console.log("--- Trigger Transfer ---");
        vm.prank(alice);
        bank.transfer(bob, 2);

        console.log("--- AFTER-Trigger State ---");
        uint aliceAfter = bank.getBalance(alice);
        uint bobAfter = bank.getBalance(bob);
        console.log("Alice balance after transfer:", aliceAfter);
        console.log("Bob balance after transfer:", bobAfter);

        // Extract vulnerability verification
        bool overflowOccurred = (bobAfter == 0) && (aliceAfter == 8);
        console.log("Vulnerability Verification:");
        console.log("Overflow occurred (Bob=0)?", overflowOccurred ? "YES" : "NO");
        
        // Final verdict condition
        if (overflowOccurred) {
            console.log("Vulnerability Exists: Bob's balance overflowed to 0 after transfer");
        } else {
            console.log("Vulnerability not Exist: Overflow did not occur as expected");
        }
    }
}