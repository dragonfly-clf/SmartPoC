// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCashWallet.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123456);
    }
}

contract MockWETH {}

contract MockRouterForStorage {
    address public factoryAddress;
    address public wethAddress;

    function factory() external view returns (address) {
        return factoryAddress;
    }

    function WETH() external view returns (address) {
        return wethAddress;
    }
}

contract MetaCashWalletTest is Test {
    MetaCashWallet token;
    address owner = address(0x1);
    uint256 constant MAX_ACCEPTABLE_FEE = 25;

    function setUp() public {
        MockFactory factory = new MockFactory();
        MockWETH weth = new MockWETH();
        address fixedRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        MockRouterForStorage tmpRouter = new MockRouterForStorage();
        vm.etch(fixedRouterAddr, address(tmpRouter).code);

        // Store values using variables to avoid parentheis errors
        bytes32 slot0 = bytes32(uint256(0));
        bytes32 slot1 = bytes32(uint256(1));
        bytes32 factoryVal = bytes32(uint256(uint160(address(factory))));
        bytes32 wethVal = bytes32(uint256(uint160(address(weth))));

        vm.store(fixedRouterAddr, slot0, factoryVal);
        vm.store(fixedRouterAddr, slot1, wethVal);

        vm.startPrank(owner);
        token = new MetaCashWallet();
        vm.stopPrank();
    }

    function testTaxFeeCanExceedLimit() public {
        console.log("--- BEFORE-Trigger TaxFee ---");
        uint256 taxFeeBefore = token._taxFee();
        console.log("Existing Tax Fee:", taxFeeBefore);

        console.log("--- Trigger setTaxFeePercent ---");
        vm.prank(owner);
        token.setTaxFeePercent(MAX_ACCEPTABLE_FEE + 1);

        console.log("--- AFTER-Trigger TaxFee ---");
        uint256 taxFeeAfter = token._taxFee();
        console.log("New Tax Fee:", taxFeeAfter);

        if (taxFeeAfter == MAX_ACCEPTABLE_FEE + 1) {
            console.log("Vulnerability Exists: Tax fee set beyond maximum limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee not changed beyond limit");
        }
    }

    function testCharityFeeCanExceedLimit() public {
        console.log("--- BEFORE-Trigger MarketingFee ---");
        uint256 marketingFeeBefore = token._marketingFee();
        console.log("Existing Marketing Fee:", marketingFeeBefore);

        console.log("--- Trigger setChartityFeePercent ---");
        vm.prank(owner);
        token.setChartityFeePercent(MAX_ACCEPTABLE_FEE + 1);

        console.log("--- AFTER-Trigger MarketingFee ---");
        uint256 marketingFeeAfter = token._marketingFee();
        console.log("New Marketing Fee:", marketingFeeAfter);

        if (marketingFeeAfter == MAX_ACCEPTABLE_FEE + 1) {
            console.log("Vulnerability Exists: Marketing fee set beyond maximum limit");
        } else {
            console.log("Vulnerability not Exist: Marketing fee not changed beyond limit");
        }
    }

    function testLiquidityFeeCanExceedLimit() public {
        console.log("--- BEFORE-Trigger LiquidityFee ---");
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("Existing Liquidity Fee:", liquidityFeeBefore);

        console.log("--- Trigger setLiquidityFeePercent ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(MAX_ACCEPTABLE_FEE + 1);

        console.log("--- AFTER-Trigger LiquidityFee ---");
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("New Liquidity Fee:", liquidityFeeAfter);

        if (liquidityFeeAfter == MAX_ACCEPTABLE_FEE + 1) {
            console.log("Vulnerability Exists: Liquidity fee set beyond maximum limit");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee not changed beyond limit");
        }
    }

    function testBurnFeeCanExceedLimit() public {
        console.log("--- BEFORE-Trigger BurnFee ---");
        uint256 burnFeeBefore = token._burnFee();
        console.log("Existing Burn Fee:", burnFeeBefore);

        console.log("--- Trigger setBurnFeePercent ---");
        vm.prank(owner);
        token.setBurnFeePercent(MAX_ACCEPTABLE_FEE + 1);

        console.log("--- AFTER-Trigger BurnFee ---");
        uint256 burnFeeAfter = token._burnFee();
        console.log("New Burn Fee:", burnFeeAfter);

        if (burnFeeAfter == MAX_ACCEPTABLE_FEE + 1) {
            console.log("Vulnerability Exists: Burn fee set beyond maximum limit");
        } else {
            console.log("Vulnerability not Exist: Burn fee not changed beyond limit");
        }
    }
}