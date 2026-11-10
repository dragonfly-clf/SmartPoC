// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankUnderflowTest is Test {
    TokenBank public tokenBank;
    address public constant owner = 0xb4c79Dab8F259c7aee6E5b2AA729141c2c27e7f1;
    address public constant underflowAddress = address(type(uint160).max);

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function test_confirmOwner_CanCreateUnderflow() public {
        // BEFORE: Read _owner from storage slot 0
        bytes32 slotOwner = vm.load(address(tokenBank), bytes32(uint256(0)));
        address currentOwnerBefore = address(uint160(uint256(slotOwner)));
        console2.log("--- BEFORE ACTION ---");
        console2.log("Current owner address (pre-confirm):", currentOwnerBefore);
        console2.log("Expected initial owner address:", owner);

        // Setup: make underflowAddress the new proposed owner
        vm.prank(owner);
        tokenBank.changeOwner(underflowAddress);

        console2.log("--- TRIGGER ACTION ---");
        // Confirm ownership from the underflowAddress
        vm.prank(underflowAddress);
        tokenBank.confirmOwner();

        // AFTER: Read _owner from storage slot 0 again
        slotOwner = vm.load(address(tokenBank), bytes32(uint256(0)));
        address currentOwnerAfter = address(uint160(uint256(slotOwner)));
        console2.log("--- AFTER ACTION ---");
        console2.log("Current owner address (post-confirm):", currentOwnerAfter);
        console2.log("Expected owner address:", underflowAddress);

        // Verify ownership change
        if (currentOwnerAfter == underflowAddress) {
            console2.log("Vulnerability Exists: Ownership transferred to underflow address via integer underflow during casting.");
        } else {
            console2.log("Vulnerability not Exist: Ownership remains with original address.");
        }
    }
}