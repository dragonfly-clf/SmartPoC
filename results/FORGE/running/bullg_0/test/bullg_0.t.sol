// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BULLGOLD.sol";

contract BullgoldFeeManipulationTest is Test {
    BULLGOLD token;
    address owner = address(0x1);
    uint256 MAX_ACCEPTABLE_FEE = 25;

    function setUp() public {
        address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))
        );
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
        );
        vm.mockCall(
            address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x0))
        );

        vm.startPrank(owner);
        token = new BULLGOLD();
        vm.stopPrank();
    }

    function test_owner_can_set_liquidity_fee_above_max() public {
        uint256 excessiveFee = MAX_ACCEPTABLE_FEE + 1; // 26%
        
        console.log("--- BEFORE-Trigger _liquidityFee ---");
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("[State] Liquidity Fee Before: %d", liquidityFeeBefore);

        console.log("--- Trigger setLiquidityFeePercent(%d) ---", excessiveFee);
        bool success;
        vm.prank(owner);
        (success, ) = address(token).call(
            abi.encodeWithSignature("setLiquidityFeePercent(uint256)", excessiveFee)
        );
        console.log("Transaction %s", success ? "succeeded" : "reverted");

        console.log("--- AFTER-Trigger _liquidityFee ---");
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("[State] Liquidity Fee After: %d", liquidityFeeAfter);

        string memory verdict;
        if (success && liquidityFeeAfter == excessiveFee) {
            verdict = "Vulnerability Exists: Fee set beyond max limit";
        } else if (!success) {
            verdict = "Vulnerability not Exist: Transaction reverted";
        } else {
            verdict = "Vulnerability not Exist: Fee not set to target value";
        }
        
        console.log("%s", verdict);
    }
}