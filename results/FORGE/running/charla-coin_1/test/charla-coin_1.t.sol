// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CharlaCoin.sol";

contract MockUniswapV2Factory {
    address public immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract CharlaCoinFeeTest is Test {
    CharlaCoin token;
    address owner = makeAddr("owner");
    address mockWeth = address(0x1);
    address mockPair = address(0x2);

    function setUp() public {
        // Create mock Uniswap factory and router
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory(mockPair);
        MockUniswapV2Router02 mockRouter = new MockUniswapV2Router02(address(mockFactory), mockWeth);
        
        // Use cheatcode to prevent deployment errors
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);
        
        // Deploy token contract
        vm.prank(owner);
        token = new CharlaCoin();
    }

    function test_SetBuyTaxesBeyondLimit() public {
        // BEFORE: Get initial buy tax and log
        console.log("--- BEFORE-Trigger Buy Taxes ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        console.log("Initial Buy Tax: %", initialBuyTax);
        assertLe(initialBuyTax, 25, "Initial taxes exceed 25% limit");

        // TRIGGER: Set excessive buy taxes
        console.log("--- Trigger Changing Buy Taxes ---");
        vm.prank(owner);
        token.setBuyTaxes(100, 100, 100);

        // AFTER: Get new buy tax and log
        console.log("--- AFTER-Trigger Buy Taxes ---");
        uint256 newBuyTax = token._totalTaxIfBuying();
        console.log("New Buy Tax: %", newBuyTax);
        
        // Differential validation: if tax >25% = vulnerability exists
        bool vulnerabilityExists = newBuyTax > 25;
        console.log("Vulnerability verification:", 
                    vulnerabilityExists ? "Tax exceeded 25% limit" : "Tax within allowed limit");
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can set buy taxes beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Buy taxes remain within 25% limit");
        }

        // Maintain original validation
        uint256 manualTaxSum = token._buyLiquidityFee() + 
                              token._buyMarketingFee() + 
                              token._buyTeamFee();
        assertGt(manualTaxSum, 25, "Buy taxes exceedance not captured");
    }

    function test_SetSellTaxesBeyondLimit() public {
        // BEFORE: Get initial sell tax and log
        console.log("--- BEFORE-Trigger Sell Taxes ---");
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial Sell Tax: %", initialSellTax);
        assertLe(initialSellTax, 25, "Initial taxes exceed 25% limit");

        // TRIGGER: Set excessive sell taxes
        console.log("--- Trigger Changing Sell Taxes ---");
        vm.prank(owner);
        token.setSellTaxes(100, 100, 100);

        // AFTER: Get new sell tax and log
        console.log("--- AFTER-Trigger Sell Taxes ---");
        uint256 newSellTax = token._totalTaxIfSelling();
        console.log("New Sell Tax: %", newSellTax);
        
        // Differential validation: if tax >25% = vulnerability exists
        bool vulnerabilityExists = newSellTax > 25;
        console.log("Vulnerability verification:", 
                    vulnerabilityExists ? "Tax exceeded 25% limit" : "Tax within allowed limit");
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can set sell taxes beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Sell taxes remain within 25% limit");
        }

        // Maintain original validation
        uint256 manualTaxSum = token._sellLiquidityFee() + 
                              token._sellMarketingFee() + 
                              token._sellTeamFee();
        assertGt(manualTaxSum, 25, "Sell taxes exceedance not captured");
    }
}