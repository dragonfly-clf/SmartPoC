// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    constructor() {
        balanceOf[address(this)] = 100 ether;
    }
    
    function transfer(address, uint256) external returns (bool) {
        return false; // Always fail transfer
    }
}

contract WizardPay_TransferAnyERC20Tokens_Test is Test {
    WizardPay wizardPay;
    MaliciousToken maliciousToken;
    address owner = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        wizardPay = new WizardPay();
        maliciousToken = new MaliciousToken();
        vm.stopPrank();
    }

    function test_transferAnyERC20Tokens_IgnoresFailure() public {
        uint256 amount = 50 ether;
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = maliciousToken.balanceOf(address(wizardPay));
        uint256 recipientBalanceBefore = maliciousToken.balanceOf(recipient);
        console.log("WizardPay contract balance (initial):", contractBalanceBefore);
        console.log("Recipient balance (initial):", recipientBalanceBefore);

        console.log("--- Trigger transferAnyERC20Tokens ---");
        vm.prank(owner);
        (bool success, ) = address(wizardPay).call(
            abi.encodeWithSignature(
                "transferAnyERC20Tokens(address,address,uint256)",
                address(maliciousToken),
                recipient,
                amount
            )
        );
        console.log("Transaction success status:", success ? "Success (no revert)" : "Failed (reverted)");
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = maliciousToken.balanceOf(address(wizardPay));
        uint256 recipientBalanceAfter = maliciousToken.balanceOf(recipient);
        console.log("WizardPay contract balance (after call):", contractBalanceAfter);
        console.log("Recipient balance (after call):", recipientBalanceAfter);

        // Assert transaction state
        assertTrue(success, "Transaction should not revert");
        assertEq(contractBalanceAfter, contractBalanceBefore, "Contract token balance should be unchanged");
        assertEq(recipientBalanceAfter, recipientBalanceBefore, "Recipient token balance should be unchanged");
        
        // Differential state verification
        console.log("--- Verification ---");
        bool vulnerabilityExists = success;
        bool balancesConstant = (contractBalanceAfter == contractBalanceBefore) && 
                                (recipientBalanceAfter == recipientBalanceBefore);
        
        console.log("Balances remained constant:", balancesConstant ? "Yes" : "No");
        console.log("Transaction completed successfully:", vulnerabilityExists ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (vulnerabilityExists && balancesConstant) {
            console.log("Vulnerability Exists: transferAnyERC20Tokens ignores failed transfers and completes transactions without reverting");
        } else {
            console.log("Vulnerability not Exist: transferAnyERC20Tokens handles transfer failures correctly by reverting");
        }
    }
}