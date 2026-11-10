// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LINKDAO_TokenPrivilegeTest is Test {
    LINKDAO_Token token;
    address owner;
    address user = address(0x1);
    address attacker = address(0x2);
    
    // Helper function for token decimals conversion
    function tokens(uint256 amount) internal view returns (uint256) {
        return amount * (10 ** token.decimals());
    }
    
    function setUp() public {
        owner = address(this);
        token = new LINKDAO_Token();
    }
    
    function test_mint_privilege_escalation() public {
        uint256 mintAmount = tokens(1);
        
        // Pre-mint snapshot
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console.log("Owner balance before:", ownerBalanceBefore);

        // Trigger mint operation
        console.log("--- Trigger Mint ---");
        token.mint(mintAmount);

        // Post-mint snapshot
        console.log("--- AFTER-Trigger Mint ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Owner balance after:", ownerBalanceAfter);
        
        // Differential verification
        uint256 actualIncrease = ownerBalanceAfter - ownerBalanceBefore;
        bool mintSuccessful = (actualIncrease == mintAmount);
        
        console.log("Expected increase:", mintAmount);
        console.log("Actual increase:", actualIncrease);
        console.log("Mint success:", mintSuccessful ? "YES" : "NO");
        
        // Final verdict
        if (mintSuccessful) {
            console.log("Vulnerability not Exist: Owner mint operation executed as expected");
        } else {
            console.log("Vulnerability Exist: Mint operation did not increase balance properly");
        }
    }
    
    function test_non_owner_cannot_mint() public {
        uint256 mintAmount = tokens(1);
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(mintAmount);
    }

    function test_delegate_privilege_escalation() public {
        // Transfer tokens to user
        uint256 initialUserBalance = tokens(100);
        token.transfer(user, initialUserBalance);
        
        // Pre-delegation snapshot
        console.log("--- BEFORE-Trigger Delegate ---");
        uint256 attackerVotesBefore = token.getCurrentVotes(attacker);
        console.log("Attacker voting power before:", attackerVotesBefore);

        // Trigger delegation
        console.log("--- Trigger Delegate ---");
        vm.prank(user);
        token.delegate(attacker);

        // Post-delegation snapshot
        console.log("--- AFTER-Trigger Delegate ---");
        uint256 attackerVotesAfter = token.getCurrentVotes(attacker);
        console.log("Attacker voting power after:", attackerVotesAfter);
        
        // Differential verification
        uint256 voteIncrease = attackerVotesAfter - attackerVotesBefore;
        bool voteChangeProper = (voteIncrease == initialUserBalance);
        
        console.log("Expected voting power increase:", initialUserBalance);
        console.log("Actual voting power increase:", voteIncrease);
        console.log("Vote delegation success:", voteChangeProper ? "YES" : "NO");
        
        // Final verdict
        if (voteChangeProper) {
            console.log("Vulnerability not Exist: Delegation voting power correctly changed");
        } else {
            console.log("Vulnerability Exist: Voting power affected improperly");
        }
    }
}