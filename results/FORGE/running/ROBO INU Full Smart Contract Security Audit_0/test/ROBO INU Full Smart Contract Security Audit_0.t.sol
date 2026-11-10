// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Token.sol";

contract MockFactory {
    function createPair(address, address) external returns (address pair) {
        return address(0x1234);
    }
}

contract MockUniswapRouter {
    address public factory;
    
    constructor() {
        factory = address(new MockFactory());
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract TokenTest is Test {
    Token token;
    MockUniswapRouter mockRouter;
    address owner = address(0x1);
    address accountA = address(0x2);
    address marketingWallet = address(0x3);
    address uniswapPair;

    function setUp() public {
        vm.startPrank(owner);
        mockRouter = new MockUniswapRouter();
        token = new Token(address(mockRouter));
        uniswapPair = token.uniswapV2Pair();

        // Remove transaction limits
        token.setMaxTxAmount(type(uint256).max);
        token.setMaxTokenHolder(type(uint256).max);

        // Set marketing wallet and fees
        token.setMarketingWallet(marketingWallet);
        token.setSellMarketingDivisor(10);
        
        // Prepare tokens for testing
        uint amount = 1000 * 10**token.decimals();
        token.transfer(accountA, amount);
        
        // Configure test account
        token.excludeFromReward(accountA);
        vm.stopPrank();
    }

    function testMarketingFeeForExcludedSenderBug() public {
        uint sellAmount = 100 * 10**token.decimals();
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint accountABalanceBefore = token.balanceOf(accountA);
        uint marketingBalanceBefore = token.balanceOf(marketingWallet);
        console.log("accountA balance before:", accountABalanceBefore);
        console.log("marketingWallet balance before:", marketingBalanceBefore);
        
        console.log("--- Trigger Transfer ---");
        uint expectedBalance = accountABalanceBefore - sellAmount;
        vm.prank(accountA);
        token.transfer(uniswapPair, sellAmount);
        
        console.log("--- AFTER-Trigger Balances ---");
        uint accountABalanceAfter = token.balanceOf(accountA);
        uint marketingBalanceAfter = token.balanceOf(marketingWallet);
        console.log("accountA balance after:", accountABalanceAfter);
        console.log("marketingWallet balance after:", marketingBalanceAfter);
        
        // Differential comparison
        uint256 marketingReceived = marketingBalanceAfter - marketingBalanceBefore;
        uint256 accountADeduction = accountABalanceBefore - accountABalanceAfter;
        console.log("Actual deduction from accountA:", accountADeduction);
        console.log("Expected deduction (without fee):", sellAmount);
        console.log("Marketing fee charged:", marketingReceived);
        
        // Original validation remains for compatibility
        assertGt(
            accountABalanceAfter, 
            expectedBalance,
            "Marketing fee transfer failed to account for excluded sender"
        );
        
        // Vulnerability verdict
        if (marketingReceived > 0) {
            console.log("Vulnerability Exists: Marketing wallet received tokens when sender is excluded from fees");
        } else {
            console.log("Vulnerability not Exist: Marketing wallet received no tokens as expected for excluded sender");
        }
    }
}