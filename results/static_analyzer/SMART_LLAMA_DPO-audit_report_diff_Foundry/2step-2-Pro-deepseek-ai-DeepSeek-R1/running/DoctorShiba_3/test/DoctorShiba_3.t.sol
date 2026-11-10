// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaTest is Test {
    DoctorShiba token;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);
    
    function setUp() public {
        token = new DoctorShiba();
        // Owner mints tokens to alice for testing
        token.mint(alice, 1000 ether);
    }
    
    function testTransferFromSetsNewunAddress() public {
        // Pre-attack state
        console.log("--- BEFORE-Trigger State ---");
        address preNewun = token.newun();
        uint256 preBalanceBob = token.balanceOf(bob);
        uint256 preBalanceCharlie = token.balanceOf(charlie);
        console.log("Initial newun address: ", preNewun);
        console.log("Initial Bob balance: ", preBalanceBob);
        console.log("Initial Charlie balance: ", preBalanceCharlie);
        
        // Approve alice to spend owner's tokens
        token.approve(alice, 100 ether);
        
        console.log("--- Trigger Operation ---");
        // First transferFrom sets newun to bob's address
        vm.prank(alice);
        token.transferFrom(owner, bob, 100 ether);
        
        // Post-attack state
        console.log("--- AFTER-Trigger State ---");
        address postNewun = token.newun();
        uint256 postBalanceBob = token.balanceOf(bob);
        uint256 postBalanceCharlie = token.balanceOf(charlie);
        console.log("Updated newun address: ", postNewun);
        console.log("Updated Bob balance: ", postBalanceBob);
        console.log("Updated Charlie balance: ", postBalanceCharlie);
        
        // Vulnerability verification
        bool unauthorizedChange = (preNewun != postNewun && 
                                  postNewun == bob && 
                                  postBalanceBob == 100 ether && 
                                  preBalanceCharlie == postBalanceCharlie);
        
        if (unauthorizedChange) {
            console.log("Vulnerability Exists: TransferFrom set newun to non-owner address and bypassed restrictions");
        } else {
            console.log("Vulnerability not Exist: newun state change or balance transfer failed");
        }
        
        // Original assertion
        assertEq(token.newun(), bob, "newun address not set");
    }
    
    function testNewunLockBlocksTransfers() public {
        // Setup: newun is bob from first transfer
        token.approve(alice, 100 ether);
        vm.prank(alice);
        token.transferFrom(owner, bob, 100 ether);
        
        // Pre-lock state
        console.log("--- BEFORE-Trigger State ---");
        address preNewun = token.newun();
        uint256 preBalanceBob = token.balanceOf(bob);
        uint256 preBalanceCharlie = token.balanceOf(charlie);
        console.log("Pre-lock newun address: ", preNewun);
        console.log("Pre-lock Bob balance: ", preBalanceBob);
        console.log("Pre-lock Charlie balance: ", preBalanceCharlie);
        
        console.log("--- Trigger Operation ---");
        // Attempt transfer to bob (newun address) from non-owner
        vm.prank(charlie);
        vm.expectRevert("please wait");
        token.transfer(bob, 10 ether);
        
        // Post-lock state
        console.log("--- AFTER-Trigger State ---");
        address postNewun = token.newun();
        uint256 postBalanceBob = token.balanceOf(bob);
        uint256 postBalanceCharlie = token.balanceOf(charlie);
        console.log("Post-lock newun address: ", postNewun);
        console.log("Post-lock Bob balance: ", postBalanceBob);
        console.log("Post-lock Charlie balance: ", postBalanceCharlie);
        
        // Vulnerability verification
        bool lockEffective = (preNewun == postNewun && 
                             preBalanceBob == postBalanceBob && 
                             preBalanceCharlie == postBalanceCharlie);
        
        if (lockEffective) {
            console.log("Vulnerability Exists: Malicious lock prevents legitimate transfers to newun address");
        } else {
            console.log("Vulnerability not Exist: Lock ineffective or state changed unexpectedly");
        }
    }
    
    function testOwnerCanTransferToNewun() public {
        // Setup: newun is bob from first transfer
        token.approve(alice, 100 ether);
        vm.prank(alice);
        token.transferFrom(owner, bob, 100 ether);
        
        // Pre-transfer state
        console.log("--- BEFORE-Trigger State ---");
        address preNewun = token.newun();
        uint256 preBalanceBob = token.balanceOf(bob);
        uint256 preBalanceCharlie = token.balanceOf(charlie);
        console.log("Pre-transfer newun address: ", preNewun);
        console.log("Pre-transfer Bob balance: ", preBalanceBob);
        console.log("Pre-transfer Charlie balance: ", preBalanceCharlie);
        
        console.log("--- Trigger Operation ---");
        // Owner token transfer to newun address should succeed
        token.transfer(bob, 100 ether);
        
        // Post-transfer state
        console.log("--- AFTER-Trigger State ---");
        address postNewun = token.newun();
        uint256 postBalanceBob = token.balanceOf(bob);
        uint256 postBalanceCharlie = token.balanceOf(charlie);
        console.log("Post-transfer newun address: ", postNewun);
        console.log("Post-transfer Bob balance: ", postBalanceBob);
        console.log("Post-transfer Charlie balance: ", postBalanceCharlie);
        
        // Vulnerability verification
        bool bypassedLock = (preNewun == postNewun && 
                            postBalanceBob == preBalanceBob + 100 ether && 
                            preBalanceCharlie == postBalanceCharlie);
        
        if (bypassedLock) {
            console.log("Vulnerability Exists: Owner bypassed the lock condition unexpectedly");
        } else {
            console.log("Vulnerability not Exist: Owner transfer failed to bypass restrictions");
        }
        
        // Original assertion
        assertEq(token.balanceOf(bob), 200 ether, "Owner transfer failed");
    }
}