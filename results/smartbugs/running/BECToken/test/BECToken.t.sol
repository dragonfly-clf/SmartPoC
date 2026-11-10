// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenTest is Test {
    BecToken token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address[] receivers;

    function setUp() public {
        vm.startPrank(owner);
        token = new BecToken();
        // Transfer some tokens to attacker for testing
        token.transfer(attacker, 1000 ether);
        vm.stopPrank();

        // Setup receivers array
        receivers = new address[](20);
        for (uint i = 0; i < 20; i++) {
            receivers[i] = address(uint160(i + 100)); // Generate unique addresses
        }
    }

    function testBatchTransferUnderflow() public {
        console.log("--- BEFORE-Trigger batchTransfer ---");
        uint256 balBefore = token.balanceOf(attacker);
        console.log("Attacker balance before: %s", balBefore);

        vm.startPrank(attacker);
        console.log("--- Trigger batchTransfer (with overflow amount) ---");
        uint256 largeValue = type(uint256).max / 20 + 1; // Expected overflow value
        
        // Should revert in fixed contract
        vm.expectRevert();
        token.batchTransfer(receivers, largeValue);
        vm.stopPrank();

        console.log("--- AFTER-Trigger batchTransfer ---");
        uint256 balAfter = token.balanceOf(attacker);
        console.log("Attacker balance after: %s", balAfter);

        if (balBefore != balAfter) {
            console.log("Vulnerability Exists: Balance changed during reverted transaction");
        } else {
            console.log("Vulnerability not Exist: BatchTransfer reverted as expected");
        }
    }

    function testBatchTransferEdgeCase() public {
        console.log("--- BEFORE-Trigger batchTransfer ---");
        uint256 balBefore = token.balanceOf(attacker);
        console.log("Attacker balance before: %s", balBefore);

        vm.startPrank(attacker);
        console.log("--- Trigger batchTransfer (edge case amount) ---");
        uint256 maxValue = type(uint256).max / 20; // Precision edge case
        
        // Should revert due to insufficient balance
        vm.expectRevert();
        token.batchTransfer(receivers, maxValue);
        vm.stopPrank();

        console.log("--- AFTER-Trigger batchTransfer ---");
        uint256 balAfter = token.balanceOf(attacker);
        console.log("Attacker balance after: %s", balAfter);

        if (balBefore != balAfter) {
            console.log("Vulnerability Exists: Edge case transaction modified balances");
        } else {
            console.log("Vulnerability not Exist: Edge case reverted correctly");
        }
    }

    function testValidBatchTransfer() public {
        // Test valid batch transfer that shouldn't overflow
        vm.startPrank(attacker);
        
        uint256 validValue = 50 ether; // 50 tokens per receiver
        
        // Should succeed
        token.batchTransfer(receivers, validValue);
        
        // Verify balances
        assertEq(token.balanceOf(attacker), 1000 ether - (20 * validValue));
        for (uint i = 0; i < 20; i++) {
            assertEq(token.balanceOf(receivers[i]), validValue);
        }
        vm.stopPrank();
    }
}