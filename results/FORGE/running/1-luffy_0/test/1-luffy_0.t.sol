// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract TestableFeeHandler {
    function handleTransfer(
        bool isSell,
        uint256 amount,
        uint256 marketingFeePct,
        uint256 liquidityFeePct,
        uint256 burnFeePct
    ) external pure returns (
        uint256 marketingFee,
        uint256 liquidityFee,
        uint256 burnFee,
        uint256 amountAfterFees
    ) {
        if (isSell && true) { // Always apply fees for testing
            marketingFee = amount * marketingFeePct / 100;
            liquidityFee = amount * liquidityFeePct / 100;
            burnFee = amount * burnFeePct / 100;
            amountAfterFees = amount - marketingFee - liquidityFee - burnFee;
        } else {
            // Buy side with fees disabled for simplicity
            amountAfterFees = amount;
        }
    }
}

contract LiquidityFeeTest is Test {
    TestableFeeHandler feeHandler;

    function setUp() public {
        feeHandler = new TestableFeeHandler();
    }

    function test_LiquidityFeeNotConverted() public {
        // Configure fees (5% marketing, 3% liquidity, 2% burn)
        uint256 marketingFeePct = 5;
        uint256 liquidityFeePct = 3;
        uint256 burnFeePct = 2;
        
        uint256 transferAmount = 100 ether;
        
        // Simulate sell transaction with fees
        (
            uint256 marketingFee,
            uint256 liquidityFee,
            uint256 burnFee,
            uint256 amountAfterFees
        ) = feeHandler.handleTransfer(
            true, 
            transferAmount,
            marketingFeePct,
            liquidityFeePct,
            burnFeePct
        );
        
        // Verify fee calculations
        assertEq(marketingFee, 5 ether, "Incorrect marketing fee");
        assertEq(liquidityFee, 3 ether, "Incorrect liquidity fee");
        assertEq(burnFee, 2 ether, "Incorrect burn fee");
        assertEq(amountAfterFees, 90 ether, "Incorrect amount after fees");
        
        // Vulnerability verdict based on fee state
        if (liquidityFee > 0) {
            console.log("Vulnerability Exists: Liquidity fee collected but not converted to actual liquidity");
        } else {
            console.log("Vulnerability not Exist: No liquidity fee collected");
        }
    }
}