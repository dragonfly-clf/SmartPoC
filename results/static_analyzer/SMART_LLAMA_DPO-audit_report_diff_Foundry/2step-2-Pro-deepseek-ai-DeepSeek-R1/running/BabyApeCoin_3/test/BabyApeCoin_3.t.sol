// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract BabyApeVulnerabilityTest is Test {
    BabyApeCoin token;
    address owner = address(this); // Test contract becomes owner
    address alice = address(0x1);
    address bob = address(0x2);
    address charles = address(0x3);

    function setUp() public {
        token = new BabyApeCoin();
        // Mint tokens to Alice
        token.mint(alice, 1000 ether); // Use ether suffix for proper decimals
        token.mint(charles, 5 ether); // Charles needs a small initial balance for delegation
    }

    function testVotesExceedBalance() public {
        // Alice transfers tokens to Bob
        vm.prank(alice);
        token.transfer(bob, 100 ether);

        // Record Charles' state BEFORE Alice delegates
        console.log("--- BEFORE-Trigger (Alice delegates to Charles) ---");
        uint charlesVotesBefore = token.getCurrentVotes(charles);
        uint charlesBalanceBefore = token.balanceOf(charles);
        console.log("Charles' votes (before):", charlesVotesBefore);
        console.log("Charles' balance (before):", charlesBalanceBefore);

        // Alice delegates all voting power to Charles
        console.log("--- TRIGGER: Alice delegates to Charles ---");
        vm.prank(alice);
        token.delegate(charles);

        // Record Charles' state AFTER Alice delegates
        console.log("--- AFTER-Trigger (Alice delegates to Charles) ---");
        uint charlesVotesAfter = token.getCurrentVotes(charles);
        uint charlesBalanceAfter = token.balanceOf(charles);
        console.log("Charles' votes (after):", charlesVotesAfter);
        console.log("Charles' balance (after):", charlesBalanceAfter);

        // Check for vulnerability (voting power > token balance)
        bool vulnerabilityExists = false;
        if (charlesBalanceBefore == charlesBalanceAfter) {
            console.log("Balance remains unchanged (expected)");
            if (charlesVotesAfter > charlesVotesBefore) {
                console.log("Votes increased (expected)");
                vulnerabilityExists = (charlesVotesAfter > charlesBalanceAfter);
            } else {
                console.log("ERROR: Votes did NOT increase after delegation");
            }
        } else {
            console.log("ERROR: Balance changed during delegation");
        }

        // Continued PoC operations...
        // Charles delegates to himself to initialize state
        vm.prank(charles);
        token.delegate(charles);

        // Get Charles' voting power (should include both tokens held + Alice's delegation)
        uint256 charlesVotes = token.getCurrentVotes(charles);
        uint256 charlesBalance = token.balanceOf(charles);

        // Print values for verification
        emit log_named_uint("Charles' votes", charlesVotes);
        emit log_named_uint("Charles' balance", charlesBalance);

        // Verify Alice's tokens are properly delegated
        uint256 aliceVotes = token.getCurrentVotes(alice);
        uint256 delegatedAliceBalance = token.balanceOf(alice);
        assertEq(aliceVotes, 0, "Alice should have 0 votes after delegation");
        assertGt(delegatedAliceBalance, 0, "Alice still has tokens");

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Charles has more votes than tokens after delegation without holding tokens");
        } else {
            console.log("Vulnerability not Exist: Charles' votes don't exceed tokens after delegation");
        }
    }
}