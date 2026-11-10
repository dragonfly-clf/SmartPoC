// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract MockWETH {}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(1);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract DemonHellboyFeeTest is Test {
    DemonHellboy token;
    address owner;
    address attacker;
    
    address constant hardcodedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        owner = makeAddr("owner");
        attacker = makeAddr("attacker");
        
        // Deploy mock dependencies
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter deployedMockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Replace hardcoded router with mock
        bytes memory code = address(deployedMockRouter).code;
        vm.etch(hardcodedRouter, code);
        
        // Initialize storage for mock router
        vm.store(
            hardcodedRouter,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            hardcodedRouter,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(address(mockWETH))))
        );

        // Deploy token
        vm.startPrank(owner);
        token = new DemonHellboy();
        vm.stopPrank();
    }

    function testExcessiveBuyFeeSetting() public {
        uint256 excessiveFee = 200;

        console.log("### TEST: SET EXCESSIVE BUY FEES ###");
        console.log("--- BEFORE-Trigger Fee Query ---");
        (
            bool beforeEnable, 
            uint256 beforeBuyTaxFee, 
            uint256 beforeBuyLiquidityFee, 
            uint256 beforeSellTaxFee, 
            uint256 beforeSellLiquidityFee,,
        ) = token._addressFees(attacker);
        console.log("State before attacker action:");
        console.log("IsEnabled? =", beforeEnable);
        console.log("BuyTax = %s%%", beforeBuyTaxFee);
        console.log("BuyLiquidity = %s%%", beforeBuyLiquidityFee);
        console.log("SellTax = %s%%", beforeSellTaxFee);
        console.log("SellLiquidity = %s%%", beforeSellLiquidityFee);

        console.log("--- Trigger Action: setBuyAddressFee ---");
        vm.prank(owner);
        token.setBuyAddressFee(
            attacker, 
            true, 
            excessiveFee, 
            excessiveFee
        );

        console.log("--- AFTER-Trigger Fee Query ---");
        (
            bool afterEnable, 
            uint256 afterBuyTaxFee, 
            uint256 afterBuyLiquidityFee, 
            uint256 afterSellTaxFee, 
            uint256 afterSellLiquidityFee,,
        ) = token._addressFees(attacker);
        console.log("State after attacker action:");
        console.log("IsEnabled? =", afterEnable);
        console.log("BuyTax = %s%%", afterBuyTaxFee);
        console.log("BuyLiquidity = %s%%", afterBuyLiquidityFee);
        console.log("SellTax = %s%%", afterSellTaxFee);
        console.log("SellLiquidity = %s%%", afterSellLiquidityFee);

        console.log("--- Result: Change Verification ---");
        if (afterBuyTaxFee == excessiveFee && afterBuyLiquidityFee == excessiveFee) {
            console.log("Buy fees set to excessive values - vulnerability exists!");
            console.log("Vulnerability Exists: Owner can set buy fees without restriction");
        } else {
            console.log("Buy fees not changed - no vulnerability");
            console.log("Vulnerability not Exist: Buy fee restrictions work properly");
        }
    }

    function testExcessiveSellFeeSetting() public {
        uint256 excessiveFee = 150;

        console.log("### TEST: SET EXCESSIVE SELL FEES ###");
        console.log("--- BEFORE-Trigger Fee Query ---");
        (
            bool beforeEnable, 
            uint256 beforeBuyTaxFee, 
            uint256 beforeBuyLiquidityFee, 
            uint256 beforeSellTaxFee, 
            uint256 beforeSellLiquidityFee,,
        ) = token._addressFees(attacker);
        console.log("State before attacker action:");
        console.log("IsEnabled? =", beforeEnable);
        console.log("BuyTax = %s%%", beforeBuyTaxFee);
        console.log("BuyLiquidity = %s%%", beforeBuyLiquidityFee);
        console.log("SellTax = %s%%", beforeSellTaxFee);
        console.log("SellLiquidity = %s%%", beforeSellLiquidityFee);

        console.log("--- Trigger Action: setSellAddressFee ---");
        vm.prank(owner);
        token.setSellAddressFee(
            attacker, 
            true, 
            excessiveFee, 
            excessiveFee
        );

        console.log("--- AFTER-Trigger Fee Query ---");
        (
            bool afterEnable, 
            uint256 afterBuyTaxFee, 
            uint256 afterBuyLiquidityFee, 
            uint256 afterSellTaxFee, 
            uint256 afterSellLiquidityFee,,
        ) = token._addressFees(attacker);
        console.log("State after attacker action:");
        console.log("IsEnabled? =", afterEnable);
        console.log("BuyTax = %s%%", afterBuyTaxFee);
        console.log("BuyLiquidity = %s%%", afterBuyLiquidityFee);
        console.log("SellTax = %s%%", afterSellTaxFee);
        console.log("SellLiquidity = %s%%", afterSellLiquidityFee);

        console.log("--- Result: Change Verification ---");
        if (afterSellTaxFee == excessiveFee && afterSellLiquidityFee == excessiveFee) {
            console.log("Sell fees set to excessive values - vulnerability exists!");
            console.log("Vulnerability Exists: Owner can set sell fees without restriction");
        } else {
            console.log("Sell fees not changed - no vulnerability");
            console.log("Vulnerability not Exist: Sell fee restrictions work properly");
        }
    }
}