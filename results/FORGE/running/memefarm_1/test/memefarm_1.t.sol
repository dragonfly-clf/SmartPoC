// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MemeFarm.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xBEEF);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;
    
    constructor() {
        factory = address(new MockUniswapV2Factory());
        WETH = address(0xDEAD);
    }
}

contract MemeFarmTaxTest is Test {
    MemeFarm token;
    address owner = makeAddr("owner");
    address mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy and setup mock router
        MockUniswapV2Router mock = new MockUniswapV2Router();
        
        // Override real router address with mock code
        vm.etch(mockRouter, address(mock).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new MemeFarm();
        vm.stopPrank();
    }
    
    function test_OwnerCanSetExcessiveBuyTaxes() public {
        console.log("\n--- BEFORE-Trigger ---");
        uint256 beforeBuyTax = token._totalTaxIfBuying();
        console.log("Pre-trigger buy tax: %s%%", beforeBuyTax);
        
        console.log("\n--- Trigger: setBuyTaxes(10,10,10) ---");
        vm.startPrank(owner);
        token.setBuyTaxes(10, 10, 10);
        vm.stopPrank();
        
        console.log("\n--- AFTER-Trigger ---");
        uint256 afterBuyTax = token._totalTaxIfBuying();
        console.log("Post-trigger buy tax: %s%%", afterBuyTax);
        
        console.log("Changed: %s%% to %s%%", beforeBuyTax, afterBuyTax);
        console.log("Buy tax components: Liquidity=%s%%, Marketing=%s%%, Team=%s%%", 
            token._buyLiquidityFee(),
            token._buyMarketingFee(),
            token._buyTeamFee()
        );
        
        if (afterBuyTax > 25) {
            console.log("Vulnerability Exists: Set excessive buy taxes (%s%%) over 25%% limit", afterBuyTax);
        } else {
            console.log("Vulnerability not Exist: Buy taxes (%s%%) within 25%% limit", afterBuyTax);
        }
    }
    
    function test_OwnerCanSetExcessiveSellTaxes() public {
        console.log("\n--- BEFORE-Trigger ---");
        uint256 beforeSellTax = token._totalTaxIfSelling();
        console.log("Pre-trigger sell tax: %s%%", beforeSellTax);
        
        console.log("\n--- Trigger: setAllTaxes(10,10,10) ---");
        vm.startPrank(owner);
        token.setAllTaxes(10, 10, 10);
        vm.stopPrank();
        
        console.log("\n--- AFTER-Trigger ---");
        uint256 afterSellTax = token._totalTaxIfSelling();
        console.log("Post-trigger sell tax: %s%%", afterSellTax);
        
        console.log("Changed: %s%% to %s%%", beforeSellTax, afterSellTax);
        console.log("Sell tax components: Liquidity=%s%%, Marketing=%s%%, Team=%s%%", 
            token._sellLiquidityFee(),
            token._sellMarketingFee(),
            token._sellTeamFee()
        );
        
        if (afterSellTax > 25) {
            console.log("Vulnerability Exists: Set excessive sell taxes (%s%%) over 25%% limit", afterSellTax);
        } else {
            console.log("Vulnerability not Exist: Sell taxes (%s%%) within 25%% limit", afterSellTax);
        }
    }
    
    function test_ExtremeTaxSettingsDontRevert() public {
        // Test Part 1: Buy taxes
        console.log("\n--- [Part 1] BEFORE buy tax change ---");
        uint256 beforeBuyTax = token._totalTaxIfBuying();
        console.log("Pre-trigger buy tax: %s%%", beforeBuyTax);
        
        console.log("\n--- Trigger: setBuyTaxes(34,33,33) ---");
        vm.startPrank(owner);
        token.setBuyTaxes(34, 33, 33);
        vm.stopPrank();
        
        console.log("\n--- AFTER buy tax change ---");
        uint256 afterBuyTax = token._totalTaxIfBuying();
        console.log("Post-trigger buy tax: %s%%", afterBuyTax);
        
        // Test Part 2: Sell taxes
        console.log("\n--- [Part 2] BEFORE sell tax change ---");
        uint256 beforeSellTax = token._totalTaxIfSelling();
        console.log("Pre-trigger sell tax: %s%%", beforeSellTax);
        
        console.log("\n--- Trigger: setAllTaxes(100,100,0) ---");
        vm.startPrank(owner);
        token.setAllTaxes(100, 100, 0);
        vm.stopPrank();
        
        console.log("\n--- AFTER sell tax change ---");
        uint256 afterSellTax = token._totalTaxIfSelling();
        console.log("Post-trigger sell tax: %s%%", afterSellTax);
        
        // Vulnerability verdict
        if (afterBuyTax > 25 || afterSellTax > 25) {
            console.log("Vulnerability Exists: Extreme tax settings bypass safety limits");
            console.log("- Buy tax: %s%%", afterBuyTax);
            console.log("- Sell tax: %s%%", afterSellTax);
        } else {
            console.log("Vulnerability not Exist: Tax limits enforced successfully");
        }
    }
}