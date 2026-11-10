// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AANT.sol";

contract AANTUninitializedBlacklistTest is Test {
    AANT token;
    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);
    
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factory = address(0xFAC70);
    address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address pair = address(0x12345);
    uint256 constant FEE_PERCENT = 15; // 15% total fee

    function setUp() public {
        vm.startPrank(owner);
        // Mock router and factory
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(factory));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(weth));
        vm.mockCall(factory, abi.encodeWithSignature("createPair(address,address)"), abi.encode(pair));
        
        token = new AANT();
        vm.stopPrank();
        
        // Transfer initial tokens to user1
        vm.prank(owner);
        token.transfer(user1, 1000 ether);
    }

    function testBlacklistNotInitialized() public {
        uint256 transferAmount = 500 ether;
        uint256 feeAmount = transferAmount * FEE_PERCENT / 100;
        uint256 expectedRecipientAmount = transferAmount - feeAmount;

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 user1BalanceBefore = token.balanceOf(user1);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        console.log("user1 balance before transfer:", user1BalanceBefore);
        console.log("user2 balance before transfer:", user2BalanceBefore);

        // Transfer should succeed without blacklist reverts
        console.log("--- Trigger Transfer ---");
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        console.log("Transfer triggered: user1 -> user2 =", transferAmount, "tokens");

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 user1BalanceAfter = token.balanceOf(user1);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        console.log("user1 balance after transfer:", user1BalanceAfter);
        console.log("user2 balance after transfer:", user2BalanceAfter);

        uint256 user1Change = user1BalanceBefore - user1BalanceAfter;
        uint256 user2Change = user2BalanceAfter - user2BalanceBefore;
        
        console.log("Actual user1 decrease:", user1Change);
        console.log("Actual user2 increase:", user2Change);
        console.log("Expected user1 decrease (full amount):", transferAmount);
        console.log("Expected user2 increase (after fee):", expectedRecipientAmount);

        // Account for fee deduction
        assertEq(user2BalanceAfter, expectedRecipientAmount, "Transfer fee deduction mismatch");
        
        // Differential verdict
        bool exploitationSuccess = (user1Change == transferAmount) && 
                                (user2Change == expectedRecipientAmount);
        console.log("Vulnerability Exploit Result:", exploitationSuccess ? "SUCCESSFUL" : "UNSUCCESSFUL");
        
        // Final vulnerability verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Transfer succeeded without requiring blacklist to be initialized");
        } else {
            console.log("Vulnerability not Exist: Transfer behavior doesn't match uninitialized vulnerability expectations");
        }
    }

    function testTransferFromWithUninitializedBlacklist() public {
        uint256 transferAmount = 500 ether;

        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 user2BalanceBefore = token.balanceOf(user2);
        console.log("owner balance before:", ownerBalanceBefore);
        console.log("user2 balance before:", user2BalanceBefore);

        // Owner is excluded from fees, so no fee applies
        vm.prank(owner);
        token.approve(user1, transferAmount);
        
        console.log("--- Trigger TransferFrom ---");
        // TransferFrom should succeed without blacklist reverts
        vm.prank(user1);
        token.transferFrom(owner, user2, transferAmount);
        console.log("TransferFrom triggered: owner -> user2 =", transferAmount, "tokens");

        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 user2BalanceAfter = token.balanceOf(user2);
        console.log("owner balance after:", ownerBalanceAfter);
        console.log("user2 balance after:", user2BalanceAfter);

        uint256 ownerChange = ownerBalanceBefore - ownerBalanceAfter;
        uint256 user2Change = user2BalanceAfter - user2BalanceBefore;
        
        console.log("Owner decrease:", ownerChange);
        console.log("User2 increase:", user2Change);
        console.log("Expected owner decrease (no fee):", transferAmount);
        console.log("Expected user2 increase (no fee):", transferAmount);

        // Full amount should be received since owner is fee-excluded
        assertEq(user2BalanceAfter, transferAmount, "TransferFrom amount mismatch");
        
        // Differential verdict
        bool exploitationSuccess = (ownerChange == transferAmount) && 
                                (user2Change == transferAmount);
        console.log("Vulnerability Exploit Result:", exploitationSuccess ? "SUCCESSFUL" : "UNSUCCESSFUL");
        
        // Final vulnerability verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: TransferFrom succeeded without requiring blacklist to be initialized");
        } else {
            console.log("Vulnerability not Exist: TransferFrom behavior doesn't match uninitialized vulnerability expectations");
        }
    }
}