// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract TokenSenderTest is Test {
    TokenSender tokenSender;
    address initialOwner = address(0x1);
    address newOwner = address(0x2);
    address nonOwner = address(0x3);
    address tokenAddress = address(0x4);

    function setUp() public {
        vm.prank(initialOwner);
        tokenSender = new TokenSender(tokenAddress);
    }

    function test_InitialOwnerSetCorrectly() public {
        assertEq(tokenSender.owner(), initialOwner, "Initial owner should be set");
    }

    function test_OwnerCanChangeOwnership() public {
        console.log("--- BEFORE-Trigger owner() ---");
        address currentOwnerBefore = tokenSender.owner();
        console.log("Current owner before:", currentOwnerBefore);
        
        console.log("--- Trigger ChangeOwner ---");
        vm.prank(initialOwner);
        tokenSender.changeOwner(newOwner);
        
        console.log("--- AFTER-Trigger owner() ---");
        address currentOwnerAfter = tokenSender.owner();
        console.log("Current owner after:", currentOwnerAfter);
        
        assertEq(currentOwnerAfter, newOwner, "Ownership should transfer to new owner");
    }

    function test_NonOwnerCannotChangeOwnership() public {
        console.log("--- BEFORE-Trigger owner() ---");
        address currentOwnerBefore = tokenSender.owner();
        console.log("Current owner before:", currentOwnerBefore);
        
        console.log("--- Trigger ChangeOwner ---");
        vm.prank(nonOwner);
        tokenSender.changeOwner(newOwner);
        
        console.log("--- AFTER-Trigger owner() ---");
        address currentOwnerAfter = tokenSender.owner();
        console.log("Current owner after:", currentOwnerAfter);
        
        // Vulnerability verification logic
        if (currentOwnerAfter != initialOwner) {
            console.log("Vulnerability Exists: non-owner was able to change ownership");
        } else {
            console.log("Vulnerability not Exist: ownership remains unchanged after non-owner call");
        }
        
        assertEq(tokenSender.owner(), initialOwner, "Owner must not change when called by non-owner");
    }
    
    function test_OwnershipTransferToZeroAddress() public {
        console.log("--- BEFORE-Trigger owner() ---");
        address currentOwnerBefore = tokenSender.owner();
        console.log("Current owner before:", currentOwnerBefore);
        
        console.log("--- Trigger ChangeOwner ---");
        vm.prank(initialOwner);
        tokenSender.changeOwner(address(0));
        
        console.log("--- AFTER-Trigger owner() ---");
        address currentOwnerAfter = tokenSender.owner();
        console.log("Current owner after:", currentOwnerAfter);
        
        assertEq(tokenSender.owner(), address(0), "Owner should be zero address");
    }
}