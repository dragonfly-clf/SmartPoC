// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenBatchTransferDenialTest is Test {
    BecToken token;
    address owner;
    address user1;
    address user2;
    address receiver;

    function setUp() public {
        owner = address(this);       // Test contract acts as owner
        user1 = address(0x100);      // Sample user 1
        user2 = address(0x200);      // Sample user 2
        receiver = address(0x300);   // Token receiver
        
        // Deploy token contract
        token = new BecToken();
        
        // Fund users with tokens
        token.transfer(user1, 5000 ether);
        token.transfer(user2, 5000 ether);
    }

    function testBatchTransferDenialWhenPaused() public {
        // Pre-Trigger Phase
        console.log("--- BEFORE-Trigger (Pause) State ---");
        console.log("Contract pause status:", token.paused() ? "PAUSED" : "UNPAUSED");
        console.log("Receiver initial balance:", token.balanceOf(receiver));
        
        // Confirm batchTransfer works normally
        address[] memory receivers = new address[](1);
        receivers[0] = receiver;
        
        console.log("Performing normal batchTransfer...");
        vm.prank(user1);
        token.batchTransfer(receivers, 100);
        console.log("batchTransfer success! New balance:", token.balanceOf(receiver));
        assertEq(token.balanceOf(receiver), 100);

        // Trigger Phase
        console.log("\n--- TRIGGER: Owner Pauses Contract ---");
        token.pause();
        console.log("Paused status after trigger:", token.paused() ? "PAUSED" : "UNPAUSED");
        console.log("Vulnerable state activated - transfers should revert");

        // Post-Trigger Verification
        console.log("\n--- AFTER-Trigger (Paused) State ---");
        console.log("Verifying batchTransfer denial...");
        vm.startPrank(user1);
        vm.expectRevert(); // Expect revert due to pause
        console.log("User1 batchTransfer attempt: REVERTED");
        token.batchTransfer(receivers, 100);
        vm.stopPrank();

        console.log("Verifying user2 batchTransfer denial...");
        vm.prank(user2);
        vm.expectRevert();
        console.log("User2 batchTransfer attempt: REVERTED");
        token.batchTransfer(receivers, 100);

        console.log("Verifying normal transfer denial...");
        vm.prank(user2);
        vm.expectRevert();
        console.log("User2 regular transfer attempt: REVERTED");
        token.transfer(receiver, 100);

        // Final Verdict
        console.log("\nVulnerability exists: All transfers revert during paused state");
        console.log("\nVulnerability Exists: Contract pause causes batchTransfer denial");
    }
}