// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract DomainTest is Test {
    Domain token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address recipient = makeAddr("recipient");
    uint256 totalSupply;
    uint256 transferAmount = 1; // Fixed small amount

    // Mock PancakeSwap addresses
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockFactory = address(0x123);
    address mockWETH = address(0x456);
    address mockPair = address(0x789);

    function setUp() public {
        // Mock PancakeSwap router factory() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        // Mock PancakeSwap WETH() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        // Mock any createPair call by selector
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(createPairSelector),
            abi.encode(mockPair)
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = new Domain();
        
        // Set initial maxWalletAmount (2% of total supply)
        token.setMaxWalletAmount(50);
        vm.stopPrank();

        totalSupply = token.totalSupply();
        uint256 maxWallet = token.maxWalletAmount();
        uint256 userAmount = maxWallet / 2; // 1% of supply
        
        // Transfer within limit to user
        vm.prank(owner);
        token.transfer(user, userAmount);
    }

    function test_ZeroMaxWalletBreaksTransfers() public {
        uint256 initialUserBalance = token.balanceOf(user);
        assertGt(initialUserBalance, 0, "User has initial balance");
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        uint256 maxWalletBefore = token.maxWalletAmount();
        console.log("MaxWalletAmount (pre-trigger):", maxWalletBefore);
        console.log("Recipient balance (pre-trigger):", recipientBalanceBefore);
        console.log("Transferring", transferAmount, "token to recipient...");
        
        // Pre-trigger transfer
        vm.prank(user);
        token.transfer(recipient, transferAmount);
        
        uint256 recipientBalanceAfterFirst = token.balanceOf(recipient);
        console.log("Recipient balance (post-transfer/pre-trigger):", recipientBalanceAfterFirst);
        assertEq(recipientBalanceAfterFirst, recipientBalanceBefore + transferAmount, "Transfer should succeed before vulnerability trigger");
        
        console.log("\n--- TRIGGER: owner.setMaxWalletAmount(type(uint256).max) ---");
        // Vulnerability trigger
        vm.prank(owner);
        token.setMaxWalletAmount(type(uint256).max);
        uint256 maxWalletAfter = token.maxWalletAmount();
        console.log("MaxWalletAmount (post-trigger):", maxWalletAfter);
        require(maxWalletAfter == 0, "maxWallet should be 0 after trigger");
        
        console.log("\n--- AFTER-Trigger Transfer ---");
        uint256 recipientBalancePreSecond = token.balanceOf(recipient);
        console.log("Recipient balance (pre-second-transfer):", recipientBalancePreSecond);
        console.log("Attempting second transfer...");
        
        // Attempt post-trigger transfer
        vm.prank(user);
        bool transferSucceeded;
        // Low-level call to capture revert without test failure
        (transferSucceeded, ) = address(token).call(
            abi.encodeWithSelector(token.transfer.selector, recipient, transferAmount)
        );
        
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Transfer status:", transferSucceeded ? "SUCCEEDED" : "FAILED");
        console.log("Recipient balance (post-second-transfer):", recipientBalanceAfter);
        
        // Vulnerability verification
        bool balanceUnchanged = (recipientBalanceAfter == recipientBalancePreSecond);
        bool transferFailed = !transferSucceeded;
        bool vulnerabilityExists = balanceUnchanged && transferFailed && (maxWalletAfter == 0);
        
        console.log("\n--- VERDICT ---");
        console.log("Transfer after trigger:", transferFailed ? "FAILED (expected)" : "SUCCEEDED (vulnerability not exist)");
        console.log("Balance unchanged:", balanceUnchanged ? "YES (expected)" : "NO (problem)");
        console.log("MaxWallet=0:", maxWalletAfter==0 ? "YES" : "NO");
        
        require(initialUserBalance >= transferAmount*2, "Insufficient user balance for 2 transfers");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Zero MaxWallet breaks transfers");
        } else {
            console.log("Vulnerability not Exist: Transfers remain functional after MaxWallet=0");
        }
    }
}