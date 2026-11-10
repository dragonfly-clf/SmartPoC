// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBankAuditTest is Test {
    TokenBank public tokenBank;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address approvedNewOwner = makeAddr("approvedNewOwner");

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function test_NonOwnerCannotChangePendingOwner() public {
        // Owner sets newOwner properly
        vm.prank(owner);
        tokenBank.changeOwner(approvedNewOwner);
        
        console.log("--- BEFORE-Trigger State ---");
        bytes32 pendingOwnerBefore = vm.load(address(tokenBank), bytes32(uint256(0)));
        bytes32 ownerBefore = vm.load(address(tokenBank), bytes32(uint256(1)));
        console.log("Pending owner (slot0): %s", address(uint160(uint256(pendingOwnerBefore))));
        console.log("Actual owner (slot1): %s", address(uint160(uint256(ownerBefore))));

        console.log("--- Trigger Action: Attacker calls changeOwner ---");
        vm.prank(attacker);
        tokenBank.changeOwner(attacker);

        console.log("--- AFTER-Trigger State ---");
        bytes32 pendingOwnerAfter = vm.load(address(tokenBank), bytes32(uint256(0)));
        bytes32 ownerAfter = vm.load(address(tokenBank), bytes32(uint256(1)));
        console.log("Pending owner (slot0): %s", address(uint160(uint256(pendingOwnerAfter))));
        console.log("Actual owner (slot1): %s", address(uint160(uint256(ownerAfter))));

        console.log("--- Status Verification ---");
        bool stateChanged = (pendingOwnerAfter != pendingOwnerBefore) || (ownerAfter != ownerBefore);
        if (stateChanged) {
            console.log("ALERT: Unauthorized state modification detected!");
            console.log("Vulnerability Exists: Non-owner changed ownership state");
        } else {
            console.log("State remains secure: Contract maintained permissions");
            console.log("Vulnerability not Exist: Access control prevents state changes");
        }
    }
}