// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Plenty.sol";

contract PlentyFeeTest is Test {
    Plenty plentyToken;
    address owner = address(0x1);
    address buyback = address(0x3);

    // Mock addresses for router and factory
    address mockRouter = address(0x2000);
    address mockFactory = address(0x3000);
    address mockWeth = address(0x4000);
    address mockPair = address(0x5000);

    function setUp() public {
        // Mock Uniswap router/factory behavior
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWeth)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy and initialize contract with mocked router
        vm.startPrank(owner);
        plentyToken = new Plenty();
        plentyToken.initialize(mockRouter, buyback);
        vm.stopPrank();
    }

    function testOwnerCanSetFeeAboveThreshold() public {
        console.log("--- BEFORE SETTING FEES ---");
        uint256 initialTaxFee = plentyToken._taxFee();
        uint256 initialLiquidityFee = plentyToken._liquidityFee();
        console.log("  Initial TaxFeePercent:", initialTaxFee);
        console.log("  Initial LiquidityFeePercent:", initialLiquidityFee);

        console.log("\n--- TRIGGERING FEE CHANGE ---");
        vm.startPrank(owner);
        // Set tax fee to 26% (above 25% threshold)
        plentyToken.setTaxFeePercent(26);
        
        // Set liquidity fee to 26% (above 25% threshold)
        plentyToken.setLiquidityFeePercent(26);
        vm.stopPrank();
        console.log("Fees set to 26% (above 25% threshold)");

        console.log("\n--- AFTER SETTING FEES ---");
        uint256 finalTaxFee = plentyToken._taxFee();
        uint256 finalLiquidityFee = plentyToken._liquidityFee();
        console.log("  Final TaxFeePercent:", finalTaxFee);
        console.log("  Final LiquidityFeePercent:", finalLiquidityFee);

        console.log("\n--- VERDICT ---");
        bool taxFeeExceeded = (finalTaxFee == 26);
        bool liquidityFeeExceeded = (finalLiquidityFee == 26);
        
        if (taxFeeExceeded && liquidityFeeExceeded) {
            console.log("Vulnerability Exists: Owner successfully set fees above 25%% threshold");
        } else {
            console.log("Vulnerability not Exist: Fee state variables not changed as expected");
        }
    }
}