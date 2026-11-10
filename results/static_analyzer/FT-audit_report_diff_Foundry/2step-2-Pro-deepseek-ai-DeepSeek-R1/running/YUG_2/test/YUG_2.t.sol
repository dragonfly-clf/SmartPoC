// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YUG.sol";

contract YUGFeeManipulationTest is Test {
    YUG public token;
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mock addresses
        address mockWETH = address(0x1);
        address mockFactory = address(0x2);
        
        // Mock router responses
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory to return dummy pair
        address dummyPair = address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(dummyPair)
        );
        
        // Deploy token - constructor will use mocked router
        token = new YUG();
    }

    function test_OwnerCanSetFeesAboveLimit() public {
        // Get initial fee values before setting
        uint256 initialTaxFee = token._taxFee();
        uint256 initialLiquidityFee = token._liquidityFee();
        
        console.log("--- BEFORE-Trigger Fee Values ---");
        console.log("Initial Tax Fee:", initialTaxFee);
        console.log("Initial Liquidity Fee:", initialLiquidityFee);
        
        console.log("--- Trigger Set High Fees (30%) ---");
        // Set fees to 30% (should be above allowed limit)
        token.setTaxFeePercent(30);
        token.setLiquidityFeePercent(30);
        
        console.log("--- AFTER-Trigger Fee Values ---");
        // Get fee values after setting
        uint256 updatedTaxFee = token._taxFee();
        uint256 updatedLiquidityFee = token._liquidityFee();
        console.log("Updated Tax Fee:", updatedTaxFee);
        console.log("Updated Liquidity Fee:", updatedLiquidityFee);
        
        console.log("--- Result Verification ---");
        // Determine and log vulnerability check result
        if (updatedTaxFee == 30 && updatedLiquidityFee == 30) {
            console.log("Vulnerability Exists: Fees set above max limit (25%)");
        } else {
            console.log("Vulnerability not Exist: Fees not changed to 30% as expected");
        }
    }
}