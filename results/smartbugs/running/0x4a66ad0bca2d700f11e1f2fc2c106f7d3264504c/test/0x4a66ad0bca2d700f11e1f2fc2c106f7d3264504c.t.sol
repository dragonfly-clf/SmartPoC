// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4a66ad0bca2d700f11e1f2fc2c106f7d3264504c.sol";

contract EBUTest is Test {
    EBU ebu;
    address constant authorizedSender = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address from = address(0x123);
    address caddress = address(0x456);
    
    // Test recipient addresses
    address recipient1 = address(0x1);
    address recipient2 = address(0x2);
    
    function setUp() public {
        vm.prank(authorizedSender);
        ebu = new EBU();
        
        // Mock the caddress to simulate failed transfers
        vm.etch(caddress, new bytes(0));
    }

    function testUncheckedLowLevelCall() public {
        // Prepare test data
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;
        
        uint[] memory amounts = new uint[](2);
        amounts[0] = 1; // 1 token (will be multiplied by 1e18 in contract)
        amounts[1] = 2; // 2 tokens (will be multiplied by 1e18 in contract)
        
        // --- BEFORE: Get initial state ---
        console2.log("--- BEFORE-Trigger ---");
        uint initialBalance1 = ebu.getRecipientBalance(recipient1);
        uint initialBalance2 = ebu.getRecipientBalance(recipient2);
        (uint initialTotalTransfers, uint initialTotalAmount) = ebu.getTotalStats();
        
        console2.log("Recipient1 initial balance: %d", initialBalance1);
        console2.log("Recipient2 initial balance: %d", initialBalance2);
        console2.log("Initial total transfers: %d", initialTotalTransfers);
        console2.log("Initial total amount: %d", initialTotalAmount);
        
        // --- TRIGGER: Execute vulnerable operation ---
        console2.log("--- Trigger: ebu.transfer() ---");
        vm.prank(authorizedSender);
        bool success = ebu.transfer(recipients, amounts);
        
        // --- AFTER: Get state after operation ---
        console2.log("--- AFTER-Trigger ---");
        uint afterBalance1 = ebu.getRecipientBalance(recipient1);
        uint afterBalance2 = ebu.getRecipientBalance(recipient2);
        (uint afterTotalTransfers, uint afterTotalAmount) = ebu.getTotalStats();
        
        console2.log("Recipient1 after balance: %d", afterBalance1);
        console2.log("Recipient2 after balance: %d", afterBalance2);
        console2.log("After total transfers: %d", afterTotalTransfers);
        console2.log("After total amount: %d", afterTotalAmount);
        
        // Vulnerability verification conditions
        bool stateChangeValid = true;
        string memory reason;

        // Check function return value (should be true)
        if (!success) {
            stateChangeValid = false;
            reason = "Function call returned false";
        }
        // Check recipient1 balance changed (+1e18)
        else if (afterBalance1 != initialBalance1 + 1 ether) {
            stateChangeValid = false;
            reason = "Recipient1 balance not increased by 1 ether";
        }
        // Check recipient2 balance changed (+2e18)
        else if (afterBalance2 != initialBalance2 + 2 ether) {
            stateChangeValid = false;
            reason = "Recipient2 balance not increased by 2 ether";
        }
        // Check total transfers count
        else if (afterTotalTransfers != initialTotalTransfers + 2) {
            stateChangeValid = false;
            reason = "Total transfers not increased by 2";
        }
        // Check total amount changed
        else if (afterTotalAmount != initialTotalAmount + 3 ether) {
            stateChangeValid = false;
            reason = "Total amount not increased by 3 ether";
        }

        // Final vulnerability verdict
        if (stateChangeValid) {
            console2.log("Vulnerability Exists: State was updated despite failed low-level call to caddress");
        } else {
            console2.log("Vulnerability not Exist: %s", reason);
        }
    }
}