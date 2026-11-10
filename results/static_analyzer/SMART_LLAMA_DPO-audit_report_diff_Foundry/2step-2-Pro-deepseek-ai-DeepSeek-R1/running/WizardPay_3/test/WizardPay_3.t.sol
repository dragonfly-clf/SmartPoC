// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract InconsistentStateTest is Test {
    WizardPay token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address feeRecipient = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new WizardPay();
        
        // Configure fee addresses
        token.setBuyBackv1Address(feeRecipient);
        token.setLiquidityFeeAddress(feeRecipient);
        token.setSMarketingAddress(feeRecipient);
        token.setBurningAddress(feeRecipient);
        
        // Configure fees (total 6.5%)
        token.setBuyBackv1Fee(300);  // 3%
        token.setLiquidityFee(200);  // 2%
        token.setSMarketingFee(50);   // 0.5%
        token.setBurningFee(100);     // 1%
        token.setTaxFee(0);           // Turn off tax for simpler calculations
        
        // Give Alice initial tokens
        token.transfer(alice, 100_000 * 10 ** token.decimals());
        vm.stopPrank();
    }

    function testTokenBalanceConservation() public {
        uint256 transferAmount = 100 * 10 ** token.decimals();
        uint256 expectedFeeComponents = 650; // 6.5 basis points = 6.5%
        
        // Log pre-state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initAliceBal = token.balanceOf(alice);
        uint256 initBobBal = token.balanceOf(bob);
        uint256 initFeeBal = token.balanceOf(feeRecipient);
        uint256 initTotalBal = initAliceBal + initBobBal + initFeeBal;
        
        console.log("Alice initial balance:", initAliceBal);
        console.log("Bob initial balance:", initBobBal);
        console.log("FeeRecipient initial balance:", initFeeBal);
        console.log("Total initial balances:", initTotalBal);

        console.log("--- Trigger Transfer Operation ---");
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        // Log post-state
        console.log("--- AFTER-Trigger State ---");
        uint256 finalAliceBal = token.balanceOf(alice);
        uint256 finalBobBal = token.balanceOf(bob);
        uint256 finalFeeBal = token.balanceOf(feeRecipient);
        uint256 finalTotalBal = finalAliceBal + finalBobBal + finalFeeBal;

        console.log("Alice final balance:", finalAliceBal);
        console.log("Bob final balance:", finalBobBal);
        console.log("FeeRecipient final balance:", finalFeeBal);
        console.log("Total final balances:", finalTotalBal);

        // Debug logs with actual vs expected
        console.log("Alice decrease (expected/actual):", 
            transferAmount, 
            initAliceBal - finalAliceBal
        );
        
        uint256 expectedNetTransfer = transferAmount * (10000 - expectedFeeComponents) / 10000;
        console.log("Bob increase (expected/actual):", 
            expectedNetTransfer,
            finalBobBal - initBobBal
        );
        
        uint256 expectedFee = transferAmount * expectedFeeComponents / 10000;
        console.log("FeeRecipient increase (expected/actual):", 
            expectedFee,
            finalFeeBal - initFeeBal
        );
        
        console.log("Total tokens (should be conserved):", 
            initTotalBal,
            finalTotalBal
        );
        
        // Check conditions directly without variables
        bool vulnerabilityExists = 
            (initAliceBal - finalAliceBal) != transferAmount ||
            (finalBobBal - initBobBal) != expectedNetTransfer ||
            (finalFeeBal - initFeeBal) != expectedFee ||
            (finalTotalBal != initTotalBal);
            
        // Final verification with single output line
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Token balances show inconsistent state changes during transfer");
        } else {
            console.log("Vulnerability not Exist: Token balances remain consistent during transfer");
        }
    }
}