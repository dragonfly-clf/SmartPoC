// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyTest is Test {
    Wheely token;
    address owner = address(this);
    address feeAddress = address(0xFEE);
    address recipient = address(0x1337);
    uint8 constant DECIMALS = 18;
    uint256 constant TOTAL_SUPPLY = 1_000_000 * (10 ** DECIMALS);
    
    // Helper for decimal precision
    function tokenAmount(uint256 amount) internal pure returns (uint256) {
        return amount * (10 ** DECIMALS);
    }

    function setUp() public {
        token = new Wheely("TestToken", "TEST", DECIMALS, 1_000_000, feeAddress);
    }

    function testSmallTransferPaysNoFee() public {
        console.log("========= STARTING DIFFERENTIAL TEST =========");
        uint256 smallAmount = tokenAmount(9_999);

        console.log("--- BEFORE Transfer: STATE SNAPSHOT ---");
        uint256 senderBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 feeAddressBalanceBefore = token.balanceOf(feeAddress);
        console.log("Sender balance:", senderBalanceBefore);
        console.log("Recipient balance:", recipientBalanceBefore);
        console.log("Fee address balance:", feeAddressBalanceBefore);
        console.log("----------------------------------------");

        console.log("--- TRIGGER: Executing Transfer ---");
        token.transfer(recipient, smallAmount);
        console.log("Transfer:", smallAmount / (10**DECIMALS), "tokens");
        console.log("----------------------------------------");

        console.log("--- AFTER Transfer: STATE SNAPSHOT ---");
        uint256 senderBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        uint256 feeAddressBalanceAfter = token.balanceOf(feeAddress);
        console.log("Sender balance:", senderBalanceAfter);
        console.log("Recipient balance:", recipientBalanceAfter);
        console.log("Fee address balance:", feeAddressBalanceAfter);
        console.log("----------------------------------------");
        
        console.log("--- FEE CALCULATION VERIFICATION ---");
        uint256 actualFeeTaken = feeAddressBalanceAfter - feeAddressBalanceBefore;
        uint256 expectedRecipientGain = recipientBalanceAfter - recipientBalanceBefore;
        uint256 expectedSenderLoss = senderBalanceBefore - senderBalanceAfter;
        
        console.log("Actual fee taken:", actualFeeTaken);
        console.log("Expected fee should be: 0");
        console.log("Net token movement:", expectedRecipientGain);
        console.log("----------------------------------------");

        // Vulnerability condition: Fee taken when none should be
        if (actualFeeTaken > 0) {
            console.log("Verdict: Fee mismatch - Vulnerability CONFIRMED");
            console.log("Vulnerability Exists: Fee was incorrectly charged for small transfer");
        } else {
            // Verify no token leakage
            bool correctNetFlow = (expectedSenderLoss == smallAmount) && 
                                  (expectedRecipientGain == smallAmount);
            
            if (correctNetFlow) {
                console.log("Verdict: Correct fee calculation - No vulnerability detected");
                console.log("Vulnerability not Exist: Transaction executed with zero fee as expected");
            } else {
                console.log("Verdict: Balance inconsistency - Potential vulnerability");
                console.log("Vulnerability Exists: Unexpected token movement detected");
            }
        }
        console.log("====================================");
    }
}