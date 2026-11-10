// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DUAL.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }

    function WETH() external pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract MockFactory {
    address constant PAIR = 0x000000000000000000000000000000000000bEEF;

    function createPair(address, address) external pure returns (address) {
        return PAIR;
    }
}

contract MockPinkAntiBot {
    function setTokenOwner(address) external pure {}
}

contract DUALPrivilegeTest is Test {
    DUAL token;
    address owner = address(0x1);

    function setUp() public {
        // Mock external contracts
        MockRouter routerMock = new MockRouter();
        MockFactory factoryMock = new MockFactory();
        MockPinkAntiBot pinkMock = new MockPinkAntiBot();

        // Setup router & factory at expected addresses
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(routerMock).code);
        vm.etch(address(0x000000000000000000000000000000000000dEaD), address(factoryMock).code);
        vm.etch(address(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002), address(pinkMock).code);

        // Deploy contract after mocks are set
        vm.prank(owner);
        token = new DUAL();
    }
    
    function testTaxManipulation() public {
        console.log("--- BEFORE-Trigger state ---");
        // Capture initial tax rates
        uint256 initialBuyTokenRewardsFee = token.buyTokenRewardsFee();
        uint256 initialBuyLiquidityFee = token.buyLiquidityFee();
        uint256 initialBuyMarketingFee = token.buyMarketingFee();
        uint256 initialBuyGasFee = token.buyGasFee();
        uint256 initialSellTokenRewardsFee = token.sellTokenRewardsFee();
        uint256 initialSellLiquidityFee = token.sellLiquidityFee();
        uint256 initialSellMarketingFee = token.sellMarketingFee();
        uint256 initialSellGasFee = token.sellGasFee();
        uint256 initialSwapThreshold = token.swapTokensAtAmount();

        // Log initial state
        console.log("Initial Buy Fees (Rewards/Liq/Market/Gas):", 
            initialBuyTokenRewardsFee,
            initialBuyLiquidityFee,
            initialBuyMarketingFee,
            initialBuyGasFee
        );
        console.log("Initial Sell Fees (Rewards/Liq/Market/Gas):", 
            initialSellTokenRewardsFee,
            initialSellLiquidityFee,
            initialSellMarketingFee,
            initialSellGasFee
        );
        console.log("Initial Swap Threshold:", initialSwapThreshold);
        
        console.log("--- Trigger Tax Manipulation ---");
        // Execute privileged actions
        vm.startPrank(owner);
        token.setBuyTaxes(1, 1, 1, 22);
        token.setSellTaxes(1, 1, 1, 22);
        token.setSwapTokensAtAmount(100);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger state ---");
        // Capture post-manipulation state
        uint256 afterBuyTokenRewardsFee = token.buyTokenRewardsFee();
        uint256 afterBuyLiquidityFee = token.buyLiquidityFee();
        uint256 afterBuyMarketingFee = token.buyMarketingFee();
        uint256 afterBuyGasFee = token.buyGasFee();
        uint256 afterSellTokenRewardsFee = token.sellTokenRewardsFee();
        uint256 afterSellLiquidityFee = token.sellLiquidityFee();
        uint256 afterSellMarketingFee = token.sellMarketingFee();
        uint256 afterSellGasFee = token.sellGasFee();
        uint256 afterSwapThreshold = token.swapTokensAtAmount();
        
        // Log post-manipulation state
        console.log("Post-Manipulation Buy Fees (Rewards/Liq/Market/Gas):", 
            afterBuyTokenRewardsFee,
            afterBuyLiquidityFee,
            afterBuyMarketingFee,
            afterBuyGasFee
        );
        console.log("Post-Manipulation Sell Fees (Rewards/Liq/Market/Gas):", 
            afterSellTokenRewardsFee,
            afterSellLiquidityFee,
            afterSellMarketingFee,
            afterSellGasFee
        );
        console.log("Post-Manipulation Swap Threshold:", afterSwapThreshold);
        
        // Verify state changes
        bool buyTaxesChanged = (afterBuyTokenRewardsFee == 1) && 
                             (afterBuyLiquidityFee == 1) &&
                             (afterBuyMarketingFee == 1) && 
                             (afterBuyGasFee == 22);
                             
        bool sellTaxesChanged = (afterSellTokenRewardsFee == 1) && 
                              (afterSellLiquidityFee == 1) &&
                              (afterSellMarketingFee == 1) && 
                              (afterSellGasFee == 22);
                             
        bool thresholdChanged = (afterSwapThreshold == 100);
        
        // Final vulnerability verdict
        if (buyTaxesChanged && sellTaxesChanged && thresholdChanged) {
            console.log("Vulnerability Exists: Critical parameters were modified beyond safe limits");
        } else {
            console.log("Vulnerability not Exist: Contract state remains secure");
        }
    }
}