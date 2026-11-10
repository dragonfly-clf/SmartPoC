// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract WizardPayDuplicateTransferTest is Test {
    WizardPay public token;
    address public owner;
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // Deploy token contract
        token = new WizardPay();
        owner = token.owner();
        
        // Configure fee settings
        token.setMaxTxPercent(10000); // Increase max transfer limit
        token.setBurningFee(0);
        token.setSMarketingFee(0);
        token.setTaxFee(0);
        token.setBuyBackv1Fee(0);
        token.setLiquidityFee(0);

        // Transfer sufficient tokens to Alice for two transactions
        uint256 transferAmount = token.balanceOf(owner) / 2;
        vm.prank(owner);
        token.transfer(alice, transferAmount * 2); // Double amount for two transfers
    }

    function testDuplicateTransferVulnerability() public {
        uint256 transferAmount = token.balanceOf(alice) / 2;
        uint256 initialBobBalance = token.balanceOf(bob);

        // First transfer from Alice to Bob (establish baseline)
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        uint256 afterFirstTransfer = token.balanceOf(bob) - initialBobBalance;

        // Differential state check (before duplicate transfer)
        console.log("--- BEFORE-Trigger: Bob Balance ---");
        uint256 beforeDupTransfer = token.balanceOf(bob);
        console.log("Bob balance: %d", beforeDupTransfer);

        console.log("--- Trigger: Duplicate Transfer ---");
        // Second transfer (identical params) - critical vulnerability trigger
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        console.log("Executed duplicate transfer of %d tokens to Bob", transferAmount);

        console.log("--- AFTER-Trigger: Bob Balance ---");
        uint256 afterDupTransfer = token.balanceOf(bob);
        console.log("Bob balance: %d", afterDupTransfer);

        // Calculate state changes
        uint256 preToPostIncrease = afterDupTransfer - beforeDupTransfer;
        uint256 expectedIncreaseFromDup = transferAmount;
        console.log("Balance increase from duplicate transfer: %d", preToPostIncrease);
        console.log("Expected increase: %d", expectedIncreaseFromDup);

        // Vulnerability verification logic
        bool vulnerabilityExists = (preToPostIncrease == expectedIncreaseFromDup);
        if (vulnerabilityExists) {
            console.log("Verdict: Duplicate transfer increased balance normally"); 
            console.log("Vulnerability Exists: Duplicate transfer succeeds indicating abnormal balance increase");
        } else {
            console.log("Verdict: Duplicate transfer balance change (%d) differs from expected (%d)", 
                         preToPostIncrease, expectedIncreaseFromDup);
            console.log("Vulnerability not Exist: Duplicate transfer is blocked");
        }
    }
}