// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract xenoX_Fee_Manipulation_Test is Test {
    xenoX token;
    address owner = address(0x1);
    address devAddress = address(0x2);
    
    // Mock addresses for router and factory
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0xFAC7);
    address mockWETH = address(0xDEAD);

    function setUp() public {
        // Setup owner
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);

        // Mock router and factory calls
        vm.mockCall(
            PANCAKE_ROUTER, 
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            PANCAKE_ROUTER, 
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xCAFE))
        );

        // Deploy token
        token = new xenoX();
        token.setdevAddress(payable(devAddress));

        vm.stopPrank();
    }

    function test_Fee_Manipulation_Vulnerability() public {
        console.log("\n--- BEFORE-Trigger Fee Changes ---");
        uint256 buyFeeBefore = token.getBuyFee();
        uint256 sellFeeBefore = token.getSellFee();
        console.log("Initial Buy Fee: %s%", buyFeeBefore);
        console.log("Initial Sell Fee: %s%", sellFeeBefore);

        console.log("--- Trigger Fee Manipulation ---");
        vm.startPrank(owner);
        // Setting all fees for buy transactions (10+10+6=26%)
        token.setBuyTaxFeePercent(10);
        token.setBuyLiquidityFeePercent(10);
        token.setBuydevFeePercent(6);

        // Setting all fees for sell transactions (12+10+5=27%)
        token.setSellTaxFeePercent(12);
        token.setSellLiquidityFeePercent(10);
        token.setSelldevFeePercent(5);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee Changes ---");
        uint256 buyFeeAfter = token.getBuyFee();
        uint256 sellFeeAfter = token.getSellFee();
        console.log("Updated Buy Fee: %s%", buyFeeAfter);
        console.log("Updated Sell Fee: %s%", sellFeeAfter);

        bool buyFeeExceeded = buyFeeAfter > 25;
        bool sellFeeExceeded = sellFeeAfter > 25;
        bool vulnerabilityExists = buyFeeExceeded || sellFeeExceeded;

        console.log("\n=== Differential Validation ===");
        console.log("- Before Trigger: Buy %s% / Sell %s%", buyFeeBefore, sellFeeBefore);
        console.log("- Attack Trigger: Set fees to 26% buy, 27% sell");
        console.log("- After Trigger : Buy %s% / Sell %s%", buyFeeAfter, sellFeeAfter);
        console.log(
            "Result: %s",
            vulnerabilityExists 
                ? "PASS - Fee thresholds exceeded!" 
                : "FAIL - Fee within limits"
        );

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("\nVulnerability Exists: Fees successfully set beyond 25%% limit (buy=%s%%, sell=%s%%)", buyFeeAfter, sellFeeAfter);
        } else {
            console.log("\nVulnerability not Exist: Fee values within 25%% security boundary (buy=%s%%, sell=%s%%)", buyFeeAfter, sellFeeAfter);
        }
    }
}