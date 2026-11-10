// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPOOKYHALLOWEENFLOKI.sol";

contract SPOOKYHALLOWEENFLOKI_UniquenessTest is Test {
    SPOOKYHALLOWEENFLOKI token;
    address alice = address(0x2);
    address bob = address(0x3);

    function setUp() public {
        // Fork Binance Smart Chain mainnet
        vm.createSelectFork("https://bsc-dataseed.binance.org");
        
        // Deploy contract in forked environment
        token = new SPOOKYHALLOWEENFLOKI();
    }

    function testDuplicatesInMultiTransfer() public {
        // Create array with duplicate address (Alice appears twice)
        address[] memory addresses = new address[](3);
        addresses[0] = alice;
        addresses[1] = bob;
        addresses[2] = alice; // Duplicate!

        // Create corresponding token amounts
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300; // Additional transfer to Alice

        // Calculate total transfer amount
        uint256 totalAmount = amounts[0] + amounts[1] + amounts[2];
        
        console.log("--- BEFORE-Trigger MultiTransfer ---");
        // Record initial state
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        
        console.log("Alice balance Before:", aliceBalanceBefore);
        console.log("Bob balance Before:", bobBalanceBefore);
        console.log("Sender (Test Contract) balance Before:", senderBalanceBefore);
        console.log("");

        console.log("--- Trigger MultiTransfer ---");
        // Execute multiTransfer from test contract address
        token.multiTransfer(address(this), addresses, amounts);
        console.log("");

        console.log("--- AFTER-Trigger MultiTransfer ---");
        // Record final state
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 senderBalanceAfter = token.balanceOf(address(this));
        
        console.log("Alice balance After:", aliceBalanceAfter);
        console.log("Bob balance After:", bobBalanceAfter);
        console.log("Sender (Test Contract) balance After:", senderBalanceAfter);
        console.log("");

        console.log("--- State Change Analysis ---");
        // Calculate changes using positive values
        uint256 aliceChange = aliceBalanceAfter - aliceBalanceBefore;
        uint256 bobChange = bobBalanceAfter - bobBalanceBefore;
        uint256 senderChange = senderBalanceBefore - senderBalanceAfter;  // Positive value for sender loss
        
        uint256 totalRecipientGain = aliceChange + bobChange;
        console.log("Alice Balance Change:", aliceChange);
        console.log("Bob Balance Change:", bobChange);
        console.log("Sender Balance Change (Loss):", senderChange);
        console.log("Total Recipients Gain:", totalRecipientGain);

        // Check token conservation
        bool conservationViolated = senderChange != totalRecipientGain;
        console.log("Token Conservation Violated:", conservationViolated ? "YES" : "No");

        // Expected changes
        uint256 expectedAliceChange = amounts[0] + amounts[2];
        uint256 expectedBobChange = amounts[1];
        uint256 expectedSenderChange = totalAmount;

        // Compare actual vs expected
        bool aliceOK = aliceChange == expectedAliceChange;
        bool bobOK = bobChange == expectedBobChange;
        bool senderOK = senderChange == expectedSenderChange;
        bool accountingValid = aliceOK && bobOK && senderOK;

        console.log("Alice Change Actual/Expected:", aliceChange, "/", expectedAliceChange);
        console.log("Bob Change Actual/Expected:", bobChange, "/", expectedBobChange);
        console.log("Sender Change Actual/Expected:", senderChange, "/", expectedSenderChange);

        // Final vulnerability detection
        if (accountingValid && !conservationViolated) {
            console.log("Final Verdict: Vulnerability not Exist: Token accounting correct");
        } else {
            console.log("Final Verdict: Vulnerability Exists: Duplicates cause accounting error");
        }
    }
}