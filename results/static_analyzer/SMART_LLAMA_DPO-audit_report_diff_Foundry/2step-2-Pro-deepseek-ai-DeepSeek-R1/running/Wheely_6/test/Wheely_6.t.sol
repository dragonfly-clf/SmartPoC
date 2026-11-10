// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyTest is Test {
    Wheely public wheely;
    address owner = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        wheely = new Wheely("Wheely", "WHL", 18, 1000, address(0));
        vm.stopPrank();
    }

    function test_UnderflowInTransfer() public {
        console.log("--- BEFORE-Trigger State Query ---");
        uint256 initialOwnerBalance = wheely.balanceOf(owner);
        uint256 initialRecipientBalance = wheely.balanceOf(recipient);
        console.log("Owner balance before transfer: ", initialOwnerBalance);
        console.log("Recipient balance before transfer: ", initialRecipientBalance);
        
        console.log("--- Trigger Transfer Operation ---");
        uint256 excessiveAmount = initialOwnerBalance + 1;
        vm.prank(owner);
        vm.expectRevert("BEP20: transfer amount exceeds balance");
        wheely.transfer(recipient, excessiveAmount);
        
        console.log("--- AFTER-Trigger State Query ---");
        uint256 ownerBalanceAfter = wheely.balanceOf(owner);
        uint256 recipientBalanceAfter = wheely.balanceOf(recipient);
        console.log("Owner balance after transfer: ", ownerBalanceAfter);
        console.log("Recipient balance after transfer: ", recipientBalanceAfter);
        
        console.log("--- Differential Verification Result ---");
        bool vulnerabilityExists = false;
        if (ownerBalanceAfter != initialOwnerBalance) {
            console.log("WARNING: Owner balance changed unexpectedly");
            vulnerabilityExists = true;
        }
        if (recipientBalanceAfter != initialRecipientBalance) {
            console.log("WARNING: Recipient balance changed unexpectedly");
            vulnerabilityExists = true;
        }
        if (ownerBalanceAfter == 0) {
            console.log("WARNING: Owner balance set to zero!");
            vulnerabilityExists = true;
        }
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Balances changed unexpectedly or owner balance zeroed");
        } else {
            console.log("Vulnerability not Exist: Balances remained unchanged and owner balance positive");
        }
        
        assertEq(
            ownerBalanceAfter,
            initialOwnerBalance,
            "Owner balance changed after failed transfer"
        );
        assertEq(
            recipientBalanceAfter,
            initialRecipientBalance,
            "Recipient balance changed after failed transfer"
        );
        assertGt(
            ownerBalanceAfter,
            0,
            "Owner balance incorrectly set to zero"
        );
    }
}