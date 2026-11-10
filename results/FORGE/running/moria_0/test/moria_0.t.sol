// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoriaUniverse.sol";

// Mock Router contract with fixed return values
contract MockRouter {
    function factory() public pure returns (address) {
        return 0x1234567890123456789012345678901234567890;
    }

    function WETH() public pure returns (address) {
        return 0x1111111111111111111111111111111111111111;
    }
}

// Mock Factory contract with fixed pair creation
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return 0x2222222222222222222222222222222222222222;
    }
}

contract MoriaUniverseTest is Test {
    MoriaUniverse token;
    address owner = address(0x1);
    address user = address(0x2);
    address recipient = address(0x3);
    
    // Fixed addresses used in implementation
    address constant hardcodedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant fakeFactoryAddress = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        // Create mock router and factory instances
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock code to fixed addresses
        vm.etch(hardcodedRouter, address(mockRouter).code);
        vm.etch(fakeFactoryAddress, address(mockFactory).code);
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new MoriaUniverse();
        vm.stopPrank();
        
        // Transfer initial tokens to user for testing
        uint256 tokens = 1000 * 10**token.decimals();
        vm.prank(owner);
        token.transfer(user, tokens);
    }

    function testOwnerCanStopTransactions() public {
        uint256 smallAmount = 1 * 10**token.decimals();

        // BEFORE-Trigger: Transfer should succeed
        console.log("--- BEFORE-Trigger: Transfer Operation ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("User balance before transfer:", userBalanceBefore);
        console.log("Recipient balance before transfer:", recipientBalanceBefore);

        vm.prank(user);
        token.transfer(recipient, smallAmount); // Should succeed ✅

        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("User balance after transfer:", userBalanceAfter);
        console.log("Recipient balance after transfer:", recipientBalanceAfter);
        bool beforeTransferSuccess = (userBalanceAfter < userBalanceBefore) && 
                                    (recipientBalanceAfter > recipientBalanceBefore);
        console.log("Initial transfer success:", beforeTransferSuccess ? "YES" : "NO");

        console.log("--- Trigger: Owner sets maxTxAmount=0 ---");
        // Owner sets max transaction amount to zero
        vm.prank(owner);
        token.setMaxTxAmount(0); // 🚨 Critical action

        // AFTER-Trigger: Identical transfer should fail
        console.log("--- AFTER-Trigger: Transfer Operation ---");
        userBalanceBefore = token.balanceOf(user);
        recipientBalanceBefore = token.balanceOf(recipient);
        console.log("User balance before transfer:", userBalanceBefore);
        console.log("Recipient balance before transfer:", recipientBalanceBefore);

        vm.prank(user);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(recipient, smallAmount); // Should revert ❌

        console.log("Transfer reverted as expected");
        uint256 userBalanceAfterRevert = token.balanceOf(user);
        uint256 recipientBalanceAfterRevert = token.balanceOf(recipient);
        console.log("User balance after reverted transfer:", userBalanceAfterRevert);
        console.log("Recipient balance after reverted transfer:", recipientBalanceAfterRevert);
        
        // Validate state changes
        bool afterTransferReverted = (userBalanceAfterRevert == userBalanceBefore) &&
                                    (recipientBalanceAfterRevert == recipientBalanceBefore);
        console.log("Reverted transfer preserved balances:", afterTransferReverted ? "YES" : "NO");

        // Final vulnerability verification
        if (beforeTransferSuccess && afterTransferReverted) {
            console.log("Vulnerability Exists: Owner can arbitrarily block transactions by setting maxTxAmount=0");
        } else {
            console.log("Vulnerability not Exist: Transaction blocking function not working as expected");
        }
    }
}