// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 token;
    address owner = address(1);
    address receiver = address(2);
    address spender = address(3);

    function setUp() public {
        vm.startPrank(owner);
        token = new ERC20(1000);
        vm.stopPrank();
    }

    // Tests that transferring more tokens than the sender has triggers an underflow protection
    function testTransferUnderflow() public {
        console2.log("--- BEFORE state ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        console2.log("Owner balance:", ownerBalanceBefore);
        console2.log("Receiver balance:", receiverBalanceBefore);

        console2.log("--- Trigger transfer (expected revert) ---");
        vm.prank(owner);
        vm.expectRevert();
        token.transfer(receiver, 1001);

        console2.log("--- AFTER state ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console2.log("Owner balance:", ownerBalanceAfter);
        console2.log("Receiver balance:", receiverBalanceAfter);

        bool balancesChanged = (ownerBalanceBefore != ownerBalanceAfter) || 
                               (receiverBalanceBefore != receiverBalanceAfter);
                               
        if (balancesChanged) {
            console2.log("Vulnerability Exists: Balances changed during reverted transfer");
        } else {
            console2.log("Vulnerability not Exist: Balances unchanged (revert protected state)");
        }
    }

    // Tests that transferFrom fails when spending beyond the approved allowance
    function testTransferFromExceedsAllowance() public {
        console2.log("--- BEFORE state ---");
        uint256 allowanceBefore = token.allowance(owner, spender);
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        console2.log("Allowance:", allowanceBefore);
        console2.log("Owner balance:", ownerBalanceBefore);
        console2.log("Receiver balance:", receiverBalanceBefore);

        // Approve 100 tokens to spender
        vm.prank(owner);
        token.approve(spender, 100);
        console2.log("--- Set Allowance to 100 ---");
        
        console2.log("--- Trigger transferFrom (expected revert) ---");
        vm.prank(spender);
        vm.expectRevert();
        token.transferFrom(owner, receiver, 101);

        console2.log("--- AFTER state ---");
        uint256 allowanceAfter = token.allowance(owner, spender);
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console2.log("Allowance:", allowanceAfter);
        console2.log("Owner balance:", ownerBalanceAfter);
        console2.log("Receiver balance:", receiverBalanceAfter);

        bool stateChanged = (allowanceBefore != allowanceAfter) ||
                            (ownerBalanceBefore != ownerBalanceAfter) || 
                            (receiverBalanceBefore != receiverBalanceAfter);
                            
        if (stateChanged) {
            console2.log("Vulnerability Exists: State changed during allowance exceed revert");
        } else {
            console2.log("Vulnerability not Exist: State unchanged (revert protected)");
        }
    }

    // Tests that transferFrom fails when amount causes balance underflow
    function testTransferFromExceedsBalance() public {
        console2.log("--- BEFORE state ---");
        uint256 allowanceBefore = token.allowance(owner, spender);
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        console2.log("Allowance:", allowanceBefore);
        console2.log("Owner balance:", ownerBalanceBefore);
        console2.log("Receiver balance:", receiverBalanceBefore);

        // Approve 2000 tokens to spender
        vm.prank(owner);
        token.approve(spender, 2000);
        console2.log("--- Set Allowance to 2000 ---");
        
        console2.log("--- Trigger transferFrom (expected revert) ---");
        vm.prank(spender);
        vm.expectRevert();
        token.transferFrom(owner, receiver, 1001);

        console2.log("--- AFTER state ---");
        uint256 allowanceAfter = token.allowance(owner, spender);
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console2.log("Allowance:", allowanceAfter);
        console2.log("Owner balance:", ownerBalanceAfter);
        console2.log("Receiver balance:", receiverBalanceAfter);

        bool stateChanged = (allowanceBefore != allowanceAfter) ||
                            (ownerBalanceBefore != ownerBalanceAfter) || 
                            (receiverBalanceBefore != receiverBalanceAfter);
                            
        if (stateChanged) {
            console2.log("Vulnerability Exists: State changed during balance underflow revert");
        } else {
            console2.log("Vulnerability not Exist: State unchanged (underflow protection)");
        }
    }
}