// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract FreebieTest is Test {
    Freebie freebie;
    address owner = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        vm.prank(owner);
        freebie = new Freebie();
        vm.deal(address(freebie), 1 ether);
    }

    function testUncheckedLowLevelCall() public {
        console.log("--- BEFORE-Trigger ---");
        // Record initial balances
        uint256 initialBalanceFreebie = address(freebie).balance;
        uint256 initialBalanceRecipient = recipient.balance;
        console.log("Freebie balance: %d", initialBalanceFreebie);
        console.log("Recipient balance: %d", initialBalanceRecipient);

        // Prepare call data that will fail (calling a non-existent function)
        bytes memory data = abi.encodeWithSignature("nonExistentFunction()");

        console.log("--- Trigger Command ---");
        // Execute Command function with failing call
        vm.prank(owner);
        (bool success,) = address(freebie).call(
            abi.encodeWithSignature(
                "Command(address,bytes)",
                recipient,
                data
            )
        );

        console.log("--- AFTER-Trigger ---");
        // Record post-trigger balances
        uint256 currentBalanceFreebie = address(freebie).balance;
        uint256 currentBalanceRecipient = recipient.balance;
        console.log("Freebie balance: %d", currentBalanceFreebie);
        console.log("Recipient balance: %d", currentBalanceRecipient);

        // Validate vulnerability conditions
        bool vulnerabilityExists = success && 
                                   (currentBalanceFreebie == initialBalanceFreebie) &&
                                   (currentBalanceRecipient == initialBalanceRecipient);
        
        // Print final verdict based on state comparison
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Call succeeded despite internal failure and balances remained unchanged");
        } else {
            console.log("Vulnerability not Exist: Call failed or balances changed during transaction");
        }

        // Original assertions
        assertTrue(success, "Transaction should not revert");
        assertEq(currentBalanceFreebie, initialBalanceFreebie, "Funds should remain unchanged");
        assertEq(currentBalanceRecipient, 0, "Recipient should not receive funds");
    }
}