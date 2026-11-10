// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaTest is Test {
    Fidometa token;
    address owner = address(0x1);
    address user = address(0x2);
    
    // Correct lock parameters
    uint256 constant INITIAL_SUPPLY = 15000000000000000000; // 15 ether
    uint256 constant LOCK_AMOUNT = 10000000000000000000;   // 10 ether
    uint256 constant INITIAL_LOCK = 0;

    function setUp() public {
        vm.prank(owner);
        token = new Fidometa();
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY, "Owner initial balance incorrect");
    }

    // Test underflow when unlocking after 11 months
    function testUnlockIntegerUnderflow() public {
        // Set up lock for user
        vm.prank(owner);
        token.transferWithLock(user, LOCK_AMOUNT, INITIAL_LOCK);

        // First unlock at month 4 (120 days)
        vm.warp(block.timestamp + 120 days);
        token.unlock(user);

        // Advance to month 11 (330 days total)
        vm.warp(block.timestamp + 210 days);
        
        console.log("--- BEFORE-Trigger Unlock ---");
        (, uint256 remainedTokenPre, , , ) = token.locks(user);
        uint256 preBalance = token.balanceOf(user);
        console.log("PreTrigger RemainedToken: %s | User balance: %s", remainedTokenPre, preBalance);

        console.log("--- Trigger Unlock ---");
        // Use expectRevert to handle panic error without rollback
        vm.expectRevert(stdError.arithmeticError);
        vm.prank(user);
        token.unlock(user);

        console.log("--- AFTER-Trigger Unlock ---");
        (, uint256 remainedTokenPost, , , ) = token.locks(user);
        uint256 postBalance = token.balanceOf(user);
        console.log("PostTrigger RemainedToken: %s | User balance: %s", remainedTokenPost, postBalance);

        // Differential verification
        if (remainedTokenPre != remainedTokenPost || preBalance != postBalance) {
            console.log("Vulnerability not Exist: Unlock changed state despite revert");
        } else {
            console.log("Vulnerability Exists: Integer underflow occurred (reverted)");
        }
    }
}