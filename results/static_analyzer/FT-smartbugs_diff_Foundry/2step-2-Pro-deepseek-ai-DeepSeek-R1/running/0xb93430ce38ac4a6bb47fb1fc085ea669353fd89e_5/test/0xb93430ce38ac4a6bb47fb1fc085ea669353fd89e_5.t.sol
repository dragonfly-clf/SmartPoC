// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract PrivateBank_Fallback_Test is Test {
    Log private logContract; // Renamed to avoid conflict
    PrivateBank private bank;
    
    function setUp() public {
        logContract = new Log();
        bank = new PrivateBank(address(logContract));
    }

    function testUnrestrictedFallback() public {
        // Fund the test contract with Ether
        vm.deal(address(this), 1 ether);
        
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 initialBalance = address(bank).balance;
        console.log("Initial bank balance: %s", initialBalance);
        
        console.log("--- Trigger Deposit (via fallback) ---");
        // Send Ether via fallback (empty call)
        (bool success,) = address(bank).call{value: 1 ether}("");
        
        console.log("--- AFTER-Trigger Balance ---");
        uint256 finalBalance = address(bank).balance;
        console.log("Final bank balance: %s", finalBalance);
        
        // Verify transaction succeeded and balance increased
        assertTrue(success, "Fallback call should succeed");
        assertEq(
            finalBalance, 
            initialBalance + 1 ether, 
            "Contract balance should increase"
        );
        
        // Vulnerability verdict
        if (finalBalance == initialBalance + 1 ether) {
            console.log("Vulnerability Exists: Contract balance increased by 1 ETH through unrestricted fallback");
        } else {
            console.log("Vulnerability not Exist: Balance did not increase through fallback");
        }
    }
}