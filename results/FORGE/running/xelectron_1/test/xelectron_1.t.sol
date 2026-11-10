// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BEP20Token.sol";

contract FeeManipulationTest is Test {
    BEP20Token token;
    address owner = makeAddr("owner");
    address payable market = payable(makeAddr("market"));
    
    // Mock addresses for Uniswap components
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0x123);
    address constant MOCK_WETH = address(0x456);
    address constant MOCK_PAIR = address(0x789);

    function setUp() public {
        // Mock external contract calls to bypass real network dependencies
        // Mock router factory() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router WETH() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Fund owner and deploy contract
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        token = new BEP20Token(market);
        vm.stopPrank();
    }

    function testSellTaxCanExceed25Percent() public {
        // 记录初始税率状态
        console.log("--- BEFORE-Trigger ---");
        uint256 initialLiqFee = token._sellLiquidityFee();
        uint256 initialMarketFee = token._sellMarketingFee();
        uint256 initialTeamFee = token._sellTeamFee();
        uint256 initialTotalFee = token._totalTaxIfSelling();
        
        console.log("Initial Liquidity Fee:", initialLiqFee);
        console.log("Initial Marketing Fee:", initialMarketFee);
        console.log("Initial Team Fee:", initialTeamFee);
        console.log("Initial Total Selling Fee:", initialTotalFee);

        // 第一次触发：设置26%税率（超过25%限额）
        console.log("--- Trigger First setSellTaxes (26%) ---");
        vm.prank(owner);
        token.setSellTaxes(10, 10, 6);  // 10+10+6=26%

        // 第一次触发后查询
        console.log("--- AFTER-Trigger (First) ---");
        uint256 afterFirstLiq = token._sellLiquidityFee();
        uint256 afterFirstMarket = token._sellMarketingFee();
        uint256 afterFirstTeam = token._sellTeamFee();
        uint256 afterFirstTotal = token._totalTaxIfSelling();
        
        console.log("After First - Liquidity Fee:", afterFirstLiq);
        console.log("After First - Marketing Fee:", afterFirstMarket);
        console.log("After First - Team Fee:", afterFirstTeam);
        console.log("After First - Total Selling Fee:", afterFirstTotal);
        
        bool firstTaxChanged = 
            (afterFirstLiq == 10) &&
            (afterFirstMarket == 10) &&
            (afterFirstTeam == 6) &&
            (afterFirstTotal == 26);
            
        console.log("[First Set] Tax values changed as expected? ", firstTaxChanged ? "YES" : "NO");

        // 第二次触发：设置100%极端税率
        console.log("--- Trigger Second setSellTaxes (100%) ---");
        vm.prank(owner);
        token.setSellTaxes(50, 30, 20);  // 50+30+20=100%

        // 第二次触发后查询
        console.log("--- AFTER-Trigger (Second) ---");
        uint256 afterSecondLiq = token._sellLiquidityFee();
        uint256 afterSecondMarket = token._sellMarketingFee();
        uint256 afterSecondTeam = token._sellTeamFee();
        uint256 afterSecondTotal = token._totalTaxIfSelling();
        
        console.log("After Second - Liquidity Fee:", afterSecondLiq);
        console.log("After Second - Marketing Fee:", afterSecondMarket);
        console.log("After Second - Team Fee:", afterSecondTeam);
        console.log("After Second - Total Selling Fee:", afterSecondTotal);
        
        bool secondTaxChanged = 
            (afterSecondLiq == 50) &&
            (afterSecondMarket == 30) &&
            (afterSecondTeam == 20) &&
            (afterSecondTotal == 100);
            
        console.log("[Second Set] Tax values changed as expected? ", secondTaxChanged ? "YES" : "NO");

        // 最终漏洞结论
        if (afterFirstTotal > 25 && afterSecondTotal == 100) {
            console.log("Vulnerability Exists: Owner can arbitrarily set sell taxes exceeding 25% cap (up to 100%)");
        } else {
            console.log("Vulnerability not Exist: Sell tax constraint enforced (25% cap)");
        }
    }
}