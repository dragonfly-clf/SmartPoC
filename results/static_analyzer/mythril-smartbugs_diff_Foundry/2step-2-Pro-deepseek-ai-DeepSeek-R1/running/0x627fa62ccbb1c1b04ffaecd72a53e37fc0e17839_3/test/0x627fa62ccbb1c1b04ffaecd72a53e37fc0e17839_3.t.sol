// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner;
    address newOwner = address(0x12345);
    address newOwner2 = address(0x11111);
    address attacker = address(0x999);
    
    // Helper function for zero-address test
    function externalCallToChangeOwnerByZeroAddress(address _newOwner) public {
        vm.prank(address(0));
        tokenBank.changeOwner(_newOwner);
    }

    function setUp() public {
        owner = address(this); // deployer becomes the owner
        tokenBank = new TokenBank();
    }

    function testConfirmOwnerTransition() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Setting newOwner to:", newOwner);
        tokenBank.changeOwner(newOwner);
        
        console.log("--- Trigger Operation ---");
        console.log("Calling confirmOwner from newOwner:", newOwner);
        vm.prank(newOwner);
        tokenBank.confirmOwner();

        console.log("--- AFTER-Trigger Verification ---");
        console.log("NewOwner attempts owner action (changeOwner)");
        vm.prank(newOwner);
        tokenBank.changeOwner(newOwner2);
        
        console.log("Intended ownership transfer successful - No vulnerability detected in this path");
    }

    function testConfirmOwnerUnauthorizedAddress() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Setting newOwner to:", newOwner);
        tokenBank.changeOwner(newOwner);
        
        console.log("--- Trigger Operation ---");
        console.log("Calling confirmOwner from attacker:", attacker);
        vm.prank(attacker);
        tokenBank.confirmOwner();

        console.log("--- AFTER-Trigger Verification ---");
        bool success;
        try tokenBank.changeOwner(attacker) {
            success = true;
        } catch {
            success = false;
        }
        
        if (!success) {
            console.log("Vulnerability Exists: Unauthorized address successfully became owner (old owner lost access)");
        } else {
            console.log("Vulnerability not Exist: Ownership remains with original owner");
        }
    }

    function testConfirmOwnerFromZeroAddress() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Setting newOwner to zero address");
        tokenBank.changeOwner(address(0));
        
        console.log("--- Trigger Operation ---");
        console.log("Calling confirmOwner from zero address");
        vm.prank(address(0));
        tokenBank.confirmOwner();

        console.log("--- AFTER-Trigger Verification ---");
        bool success;
        try this.externalCallToChangeOwnerByZeroAddress(newOwner) {
            success = true;
        } catch {
            success = false;
        }
        
        if (success) {
            console.log("Vulnerability Exists: Zero address gained owner privileges");
        } else {
            console.log("Vulnerability not Exist: Zero address failed to gain owner privileges");
        }
    }
}