// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaTest is Test {
    Fidometa public token;
    address public owner;
    address public recipient = address(0x123);
    address public zeroAddress = address(0);
    
    // Revised LockInfo structure with tuple destructuring
    struct LockInfoSnapshot {
        uint256 lockStarted;
        uint256 lockEnded;
        uint256 lockedAmount;
    }
    
    function setUp() public {
        owner = address(this);
        token = new Fidometa();
    }

    // Test 1: Insufficient balance during locking
    function testLockTransferExceedsBalance() public {
        console2.log("============ TEST 1: Lock Transfer Exceeds Balance ============");
        uint256 ownerBalance = token.balanceOf(owner);
        
        // Pre-trigger state with tuple destructuring
        (uint256 preLockStarted, uint256 preLockEnded, uint256 preLockedAmount, , ) = token.locks(recipient);
        LockInfoSnapshot memory lockPre = LockInfoSnapshot(preLockStarted, preLockEnded, preLockedAmount);
        uint256 ownerBalPre = token.balanceOf(owner);
        uint256 recipientBalPre = token.balanceOf(recipient);
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Owner balance: ", ownerBalPre);
        console2.log("Recipient balance: ", recipientBalPre);
        console2.log("Recipient lock state - Amount: %d, Started: %d, Ended: %d", 
            lockPre.lockedAmount, lockPre.lockStarted, lockPre.lockEnded);

        console2.log("--- Trigger Operation: transferWithLock(revert expected) ---");
        vm.expectRevert("ERC20: Insufficient Fund ");
        token.transferWithLock(recipient, ownerBalance + 1, 10);
        
        // Post-trigger state capture
        (uint256 postLockStarted, uint256 postLockEnded, uint256 postLockedAmount, , ) = token.locks(recipient);
        LockInfoSnapshot memory lockPost = LockInfoSnapshot(postLockStarted, postLockEnded, postLockedAmount);
        uint256 ownerBalPost = token.balanceOf(owner);
        uint256 recipientBalPost = token.balanceOf(recipient);
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Owner balance: ", ownerBalPost);
        console2.log("Recipient balance: ", recipientBalPost);
        console2.log("Recipient lock state - Amount: %d, Started: %d, Ended: %d", 
            lockPost.lockedAmount, lockPost.lockStarted, lockPost.lockEnded);
        
        // State change check
        bool stateUnchanged = (ownerBalPre == ownerBalPost) &&
            (recipientBalPre == recipientBalPost) &&
            (lockPre.lockedAmount == lockPost.lockedAmount) &&
            (lockPre.lockEnded == lockPost.lockEnded) &&
            (lockPre.lockStarted == lockPost.lockStarted);
        
        // Verdict
        if (stateUnchanged) {
            console2.log("Vulnerability not Exist: State remains unchanged after expected revert");
        } else {
            console2.log("Vulnerability Exists: State modified despite revert");
        }
    }

    // Test 2: Transfer to zero address
    function testLockTransferToZeroAddress() public {
        console2.log("\n============ TEST 2: Lock Transfer to Zero Address ============");
        uint256 ownerBalance = token.balanceOf(owner);
        
        // Pre-trigger for zero address
        (uint256 preLockStarted, uint256 preLockEnded, uint256 preLockedAmount, , ) = token.locks(zeroAddress);
        LockInfoSnapshot memory lockPre = LockInfoSnapshot(preLockStarted, preLockEnded, preLockedAmount);
        uint256 ownerBalPre = token.balanceOf(owner);
        uint256 zeroAddressBalPre = token.balanceOf(zeroAddress);
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Owner balance: ", ownerBalPre);
        console2.log("Zero address balance: ", zeroAddressBalPre);
        console2.log("Zero address lock state - Amount: %d, Started: %d, Ended: %d",
            lockPre.lockedAmount, lockPre.lockStarted, lockPre.lockEnded);

        console2.log("--- Trigger Operation: transferWithLock(revert expected) ---");
        vm.expectRevert("Invalid target");
        token.transferWithLock(zeroAddress, ownerBalance, 10);
        
        // Post-trigger capture
        (uint256 postLockStarted, uint256 postLockEnded, uint256 postLockedAmount, , ) = token.locks(zeroAddress);
        LockInfoSnapshot memory lockPost = LockInfoSnapshot(postLockStarted, postLockEnded, postLockedAmount);
        uint256 ownerBalPost = token.balanceOf(owner);
        uint256 zeroAddressBalPost = token.balanceOf(zeroAddress);
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Owner balance: ", ownerBalPost);
        console2.log("Zero address balance: ", zeroAddressBalPost);
        console2.log("Zero address lock state - Amount: %d, Started: %d, Ended: %d",
            lockPost.lockedAmount, lockPost.lockStarted, lockPost.lockEnded);
        
        // State change validation
        bool stateUnchanged = (ownerBalPre == ownerBalPost) &&
            (zeroAddressBalPre == zeroAddressBalPost) &&
            (lockPre.lockedAmount == lockPost.lockedAmount) &&
            (lockPre.lockEnded == lockPost.lockEnded) &&
            (lockPre.lockStarted == lockPost.lockStarted);
        
        // Final verdict
        if (stateUnchanged) {
            console2.log("Vulnerability not Exist: State remains unchanged after expected revert");
        } else {
            console2.log("Vulnerability Exists: State modified despite revert");
        }
    }
}