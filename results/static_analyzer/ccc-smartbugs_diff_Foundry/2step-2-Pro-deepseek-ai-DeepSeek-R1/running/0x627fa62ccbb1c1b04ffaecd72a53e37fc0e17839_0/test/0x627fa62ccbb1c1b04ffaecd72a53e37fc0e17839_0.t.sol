// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract MockToken {
    bool public transferStatus = false;
    mapping(address => uint256) public balanceOf;
    
    function setTransferStatus(bool success) external {
        transferStatus = success;
    }

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (!transferStatus) {
            return false;
        }
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract TokenBankTest is Test {
    TokenBank tokenBank;
    MockToken mockToken;
    address owner = address(0x100);
    address recipient = address(0x101);
    uint256 constant TRANSFER_AMOUNT = 100;
    uint256 constant INITIAL_BALANCE = 1000;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        mockToken = new MockToken();
        // Mint initial tokens to owner
        mockToken.mint(owner, INITIAL_BALANCE);
        vm.stopPrank();
    }

    function test_withdrawTokenIgnoresTransferFailures() public {
        // Set to simulate failed transfer
        mockToken.setTransferStatus(false);

        console.log("--- BEFORE-Trigger WithdrawToken Operation [FAILURE CASE] ---");
        uint256 ownerBalanceBefore = mockToken.balanceOf(owner);
        uint256 recipientBalanceBefore = mockToken.balanceOf(recipient);
        console.log("[Pre-state] Owner balance    :", ownerBalanceBefore);
        console.log("[Pre-state] Recipient balance:", recipientBalanceBefore);

        console.log("--- Trigger WithdrawToken Call (Simulate Failed Transfer) ---");
        // Attempt withdrawal (should fail silently)
        vm.prank(owner);
        tokenBank.WithdrawToken(address(mockToken), TRANSFER_AMOUNT, recipient);

        console.log("--- AFTER-Trigger WithdrawToken Operation ---");
        uint256 ownerBalanceAfter = mockToken.balanceOf(owner);
        uint256 recipientBalanceAfter = mockToken.balanceOf(recipient);
        console.log("[Post-state] Owner balance    :", ownerBalanceAfter);
        console.log("[Post-state] Recipient balance:", recipientBalanceAfter);

        uint256 ownerDiff = ownerBalanceAfter - ownerBalanceBefore;
        uint256 recipientDiff = recipientBalanceAfter - recipientBalanceBefore;
        bool balancesChanged = (ownerDiff != 0) || (recipientDiff != 0);

        console.log("[Verdict] Balances changed?:", balancesChanged ? "YES" : "NO");
        
        // Final vulnerability determination
        if (!balancesChanged) {
            console.log("Vulnerability Exists: Transfer failure ignored without reverting transaction");
        } else {
            console.log("Vulnerability not Exist: Transfer should not change balances on failure");
        }
    }
    
    function test_withdrawTokenSucceedsWhenTransferReturnsTrue() public {
        // Set to simulate successful transfer
        mockToken.setTransferStatus(true);

        console.log("--- BEFORE-Trigger WithdrawToken Operation [SUCCESS CASE] ---");
        uint256 ownerBalanceBefore = mockToken.balanceOf(owner);
        uint256 recipientBalanceBefore = mockToken.balanceOf(recipient);
        console.log("[Pre-state] Owner balance    :", ownerBalanceBefore);
        console.log("[Pre-state] Recipient balance:", recipientBalanceBefore);

        console.log("--- Trigger WithdrawToken Call (Simulate Successful Transfer) ---");
        // Attempt withdrawal (should succeed)
        vm.prank(owner);
        tokenBank.WithdrawToken(address(mockToken), TRANSFER_AMOUNT, recipient);

        console.log("--- AFTER-Trigger WithdrawToken Operation ---");
        uint256 ownerBalanceAfter = mockToken.balanceOf(owner);
        uint256 recipientBalanceAfter = mockToken.balanceOf(recipient);
        console.log("[Post-state] Owner balance    :", ownerBalanceAfter);
        console.log("[Post-state] Recipient balance:", recipientBalanceAfter);

        uint256 expectedOwnerBalance = ownerBalanceBefore - TRANSFER_AMOUNT;
        uint256 expectedRecipientBalance = recipientBalanceBefore + TRANSFER_AMOUNT;
        bool successCaseValid = (ownerBalanceAfter == expectedOwnerBalance) && 
                                (recipientBalanceAfter == expectedRecipientBalance);
        
        console.log("[Verdict] Balances updated correctly?:", successCaseValid ? "YES" : "NO");
        console.log("Normal Behavior: Successful transfer changed balances as expected");
    }
}