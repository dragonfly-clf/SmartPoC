// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract TestExcessiveFee is Test {
    APTD token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        address mockFactory = address(0x123);
        address mockPair = address(0x456);
        
        // Mock router.factory() call
        bytes4 factorySelector = bytes4(keccak256("factory()"));
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodePacked(factorySelector),
            abi.encode(mockFactory)
        );
        
        // Mock factory.createPair() call
        bytes4 createPairSelector = bytes4(
            keccak256("createPair(address,address)")
        );
        vm.mockCall(
            mockFactory,
            abi.encodePacked(createPairSelector),
            abi.encode(mockPair)
        );

        // Deploy token contract
        token = new APTD();
    }

    function testBuyFeeCanBeExcessive() public {
        console.log("--- BEFORE-Trigger updateBuyFees ---");
        uint256 beforeBuyTotalFees = token.buyTotalFees();
        uint256 beforeBuyDevFee = token.buyDevFee();
        uint256 beforeBuyLiquidityFee = token.buyLiquidityFee();
        console.log("buyTotalFees: %s", beforeBuyTotalFees);
        console.log("buyDevFee: %s", beforeBuyDevFee);
        console.log("buyLiquidityFee: %s", beforeBuyLiquidityFee);

        console.log("--- Trigger updateBuyFees(1000,1000) ---");
        token.updateBuyFees(1000, 1000);

        console.log("--- AFTER-Trigger updateBuyFees ---");
        uint256 afterBuyTotalFees = token.buyTotalFees();
        uint256 afterBuyDevFee = token.buyDevFee();
        uint256 afterBuyLiquidityFee = token.buyLiquidityFee();
        console.log("buyTotalFees: %s", afterBuyTotalFees);
        console.log("buyDevFee: %s", afterBuyDevFee);
        console.log("buyLiquidityFee: %s", afterBuyLiquidityFee);

        bool vulnerabilityExists = afterBuyDevFee == 1000 && afterBuyLiquidityFee == 1000;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Protocol fee parameters manipulated");
        } else {
            console.log("Vulnerability not Exist: Fee parameters unchanged");
        }
    }

    function testSellFeeCanBeExcessive() public {
        console.log("--- BEFORE-Trigger updateSellFees ---");
        uint256 beforeSellTotalFees = token.sellTotalFees();
        uint256 beforeSellDevFee = token.selDevFee();
        uint256 beforeSellLiquidityFee = token.sellLiquidityFee();
        console.log("sellTotalFees: %s", beforeSellTotalFees);
        console.log("selDevFee: %s", beforeSellDevFee);
        console.log("sellLiquidityFee: %s", beforeSellLiquidityFee);

        console.log("--- Trigger updateSellFees(1000,1000) ---");
        token.updateSellFees(1000, 1000);

        console.log("--- AFTER-Trigger updateSellFees ---");
        uint256 afterSellTotalFees = token.sellTotalFees();
        uint256 afterSellDevFee = token.selDevFee();
        uint256 afterSellLiquidityFee = token.sellLiquidityFee();
        console.log("sellTotalFees: %s", afterSellTotalFees);
        console.log("selDevFee: %s", afterSellDevFee);
        console.log("sellLiquidityFee: %s", afterSellLiquidityFee);

        bool vulnerabilityExists = afterSellDevFee == 1000 && afterSellLiquidityFee == 1000;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Protocol fee parameters manipulated");
        } else {
            console.log("Vulnerability not Exist: Fee parameters unchanged");
        }
    }
}