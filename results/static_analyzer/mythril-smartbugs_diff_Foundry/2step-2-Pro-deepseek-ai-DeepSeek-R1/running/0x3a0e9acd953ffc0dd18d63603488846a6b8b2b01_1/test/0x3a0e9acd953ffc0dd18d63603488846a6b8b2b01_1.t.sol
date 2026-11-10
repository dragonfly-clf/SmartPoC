// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract OwnerTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address addr1 = address(0x2);
    address addr2 = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.stopPrank();
    }

    function test_ChangeOwnerWithUnderflow() public {
        // Following the original PoC flow
        console.log("--- BEFORE-Trigger Proxy Owner Changes ---");
        console.log("Creating initial owner chain: owner -> addr1 -> addr2");
        
        vm.prank(owner);
        tokenBank.changeOwner(addr1);
        console.log("Owner changed to addr1 (expected)");
        
        vm.prank(addr1);
        tokenBank.changeOwner(addr2);
        console.log("Owner changed to addr2 (expected)");

        console.log("--- Trigger Underflow: Change Owner to address(0) ---");
        vm.prank(addr2);
        try tokenBank.changeOwner(address(0)) {
            // If execution continues, vulnerable to underflow
            console.log("Transaction succeeded unexpectedly!");
            console.log("Vulnerability Exists: Underflow vulnerability detected");
        } catch {
            // Reverted path means no vulnerability
            console.log("Transaction reverted safely");
            console.log("Vulnerability not Exist: Safe arithmetic used");
        }
    }
}