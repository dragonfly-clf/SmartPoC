// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetBitcoinAi.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockWETH {}

contract BetBitcoinAiTest is Test {
    BetBitcoinAi token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address recipient = makeAddr("recipient");
    uint256 transferAmount;
    
    function setUp() public {
        // Deploy and mock necessary Uniswap contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        MockWETH mockWETH = new MockWETH();
        
        // Etch contracts to expected addresses
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        vm.etch(address(0x1234567890123456789012345678901234567890), address(mockFactory).code);
        vm.etch(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), address(mockWETH).code);
        
        vm.startPrank(owner);
        token = new BetBitcoinAi();
        token.swapTrading(); // Initial activation
        transferAmount = 100 * 10 ** token.decimals();
        token.transfer(user, 1000 * 10 ** token.decimals()); // Fund user
        vm.stopPrank();
    }

    function test_swapTrading_causes_99PercentFee() public {
        // Start with normal state snapshot
        console.log("--- BEFORE-Trigger Normal Transfer ---");
        uint256 preNormalRecipientBal = token.balanceOf(recipient);
        uint256 preNormalMarketingFees = token.tokensForMarketing();
        uint256 preNormalLiquidityFees = token.tokensForLiquidity();
        console.log("Normal marketing fees (pre):", preNormalMarketingFees);
        console.log("Normal liquidity fees (pre):", preNormalLiquidityFees);
        console.log("Normal recipient balance (pre):", preNormalRecipientBal);
        
        // Execute normal transfer
        vm.prank(user);
        token.transfer(recipient, transferAmount);
        
        { // Scoped block to reduce stack depth
            uint256 postNormalRecipientBal = token.balanceOf(recipient);
            uint256 receivedTokensNormal = postNormalRecipientBal - preNormalRecipientBal;
            uint256 normalFee = transferAmount - receivedTokensNormal;
            uint256 normalFeePercent = (normalFee * 100) / transferAmount;
            
            uint256 postNormalMarketingFees = token.tokensForMarketing();
            uint256 postNormalLiquidityFees = token.tokensForLiquidity();
            uint256 normalMarketingFees = postNormalMarketingFees - preNormalMarketingFees;
            uint256 normalLiquidityFees = postNormalLiquidityFees - preNormalLiquidityFees;
            uint256 normalTotalFees = normalMarketingFees + normalLiquidityFees;
            
            console.log("Normal transfer results - Amount received:", receivedTokensNormal);
            console.log("Total fees collected:", normalTotalFees);
            console.log("Normal transfer fee percentage:", normalFeePercent, "%");
        }

        // Activate high-fee mode
        console.log("--- TRIGGER: swapTrading() HIGH FEE ACTIVATED ---");
        vm.prank(owner);
        token.swapTrading(); // Activate high-fee period
        vm.roll(block.number + 1);  // Move forward 1 block

        // Take high-fee state snapshot
        console.log("--- AFTER-Trigger High Fee Transfer ---");
        uint256 preHighRecipientBal = token.balanceOf(recipient);
        uint256 preHighMarketingFees = token.tokensForMarketing();
        uint256 preHighLiquidityFees = token.tokensForLiquidity();
        console.log("High-fee marketing fees (pre):", preHighMarketingFees);
        console.log("High-fee liquidity fees (pre):", preHighLiquidityFees);
        console.log("High-fee recipient balance (pre):", preHighRecipientBal);
        
        // Execute high-fee transfer
        vm.prank(user);
        token.transfer(recipient, transferAmount);
        
        { // Scoped block to reduce stack depth
            uint256 postHighRecipientBal = token.balanceOf(recipient);
            uint256 receivedTokensHigh = postHighRecipientBal - preHighRecipientBal;
            uint256 expectedReceived = transferAmount / 100; // 1% of amount
            uint256 highFeePercent = (transferAmount - receivedTokensHigh) * 100 / transferAmount;
            
            uint256 postHighMarketingFees = token.tokensForMarketing();
            uint256 postHighLiquidityFees = token.tokensForLiquidity();
            uint256 highMarketingFees = postHighMarketingFees - preHighMarketingFees;
            uint256 highLiquidityFees = postHighLiquidityFees - preHighLiquidityFees;
            uint256 highTotalFees = highMarketingFees + highLiquidityFees;
            
            console.log("High-fee transfer results - Amount received:", receivedTokensHigh);
            console.log("Total fees collected:", highTotalFees);
            console.log("High-fee transfer fee percentage:", highFeePercent, "%");
            
            // Vulnerability determination
            bool excessiveFees = receivedTokensHigh <= expectedReceived;
            bool dramaticChange = highFeePercent >= 95; 
            
            if (excessiveFees && dramaticChange) {
                console.log("Vulnerability Exists: High-fee transfer only delivered %stokens (expected %s) with %s%% fees", 
                            receivedTokensHigh, expectedReceived, highFeePercent);
            } else {
                console.log("Vulnerability not Exist: High-fee transfer delivered %stokens (expected minimal %s) with %s%% fees", 
                            receivedTokensHigh, expectedReceived, highFeePercent);
            }
            
            // Final validation condition
            require(excessiveFees && dramaticChange, "Expected 99% fee but not observed");
        }
    }
}