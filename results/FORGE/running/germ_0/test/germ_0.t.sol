// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GERMToken.sol";

contract GERMTokenMintTest is Test {
    GERMToken token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 constant MINT_AMOUNT = 1_000_000 ether;

    function setUp() public {
        vm.startPrank(owner);
        token = new GERMToken();
        vm.stopPrank();
    }

    function test_owner_can_mint_unlimited_tokens() public {
        // Record initial states
        uint256 initialSupply = token.totalSupply();
        uint256 userBalanceBefore = token.balanceOf(user);
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial total supply: ", initialSupply);
        console.log("Initial user balance: ", userBalanceBefore);

        console.log("--- Trigger: Mint Operation ---");
        // Owner mints large amount of tokens
        vm.prank(owner);
        token.mint(user, MINT_AMOUNT);

        // Query final states
        uint256 finalSupply = token.totalSupply();
        uint256 userBalanceAfter = token.balanceOf(user);
        console.log("--- AFTER-Trigger ---");
        console.log("Final total supply: ", finalSupply);
        console.log("Final user balance: ", userBalanceAfter);

        // Compute differences
        uint256 supplyDiff = finalSupply - initialSupply;
        uint256 balanceDiff = userBalanceAfter - userBalanceBefore;
        
        // Log differential results
        console.log("Supply change: ", supplyDiff);
        console.log("Balance change: ", balanceDiff);

        // Determine vulnerability existence
        bool unlimitedMintPossible = supplyDiff == MINT_AMOUNT && balanceDiff == MINT_AMOUNT;
        if (unlimitedMintPossible) {
            console.log("Vulnerability Exists: Owner can mint unlimited tokens");
        } else {
            console.log("Vulnerability not Exist: Token minting is properly restricted");
        }
        
        // Verify using assertions
        assertEq(finalSupply, initialSupply + MINT_AMOUNT, "Total supply mismatch");
        assertEq(userBalanceAfter, userBalanceBefore + MINT_AMOUNT, "User balance mismatch");
    }
}