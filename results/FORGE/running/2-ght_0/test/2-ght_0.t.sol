// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract MockPair {
    function sync() external {}
}

contract GoldHuntTest is Test {
    GoldHunt token;
    address owner = address(0x1);
    address rewardsPool = address(0x2);
    address userA = address(0x3);
    MockPair mockPair;
    address public constant RECIPIENT = address(0x4);

    function setUp() public {
        vm.startPrank(owner);
        token = new GoldHunt();
        token.setRewardsPool(rewardsPool);
        mockPair = new MockPair();
        token.setPair(address(mockPair));
        vm.stopPrank();

        uint256 decimals = token.decimals();
        uint256 initialAmount = 10 * 10 ** decimals;

        // Fund rewards pool and userA
        vm.prank(owner);
        token.transfer(rewardsPool, initialAmount);
        
        vm.prank(owner);
        token.transfer(userA, initialAmount);
    }

    function testTransferFailureAfterRebase() public {
        uint256 decimals = token.decimals();
        uint256 transferAmount = 10 * 10 ** decimals;
        uint256 snapshotId = vm.snapshot();

        // Pre-rebase transfer test - should succeed
        console.log("--- BEFORE-TRIGGER ACTION ---");
        uint256 userABalancePreRebase = token.balanceOf(userA);
        uint256 recipientBalancePreRebase = token.balanceOf(RECIPIENT);
        console.log("Pre-rebase userA balance:", userABalancePreRebase);
        console.log("Pre-rebase recipient balance:", recipientBalancePreRebase);

        console.log("--- PRE-REBASE TRANSFER ---");
        vm.prank(userA);
        token.transfer(RECIPIENT, transferAmount);
        
        uint256 userABalanceAfterTransfer = token.balanceOf(userA);
        uint256 recipientBalanceAfterTransfer = token.balanceOf(RECIPIENT);
        console.log("Post-transfer userA balance:", userABalanceAfterTransfer);
        console.log("Post-transfer recipient balance:", recipientBalanceAfterTransfer);
        console.log("Pre-rebase transfer succeeded");
        vm.revertTo(snapshotId);

        // Verify state revert successful
        assertEq(token.balanceOf(userA), transferAmount, "UserA should have original balance after revert");
        assertEq(token.balanceOf(RECIPIENT), 0, "Recipient should have 0 balance after revert");
        console.log("--- REVERT SUCCESSFUL, STATE RESET ---");

        // Execute rebase
        console.log("--- TRIGGER ACTION: REBASE ---");
        vm.prank(owner);
        token.rebase(10);

        // Check balances after rebase
        console.log("--- POST-TRIGGER STATE ---");
        uint256 userABalancePostRebase = token.balanceOf(userA);
        uint256 recipientBalancePostRebase = token.balanceOf(RECIPIENT);
        console.log("Post-rebase userA balance:", userABalancePostRebase);
        console.log("Post-rebase recipient balance:", recipientBalancePostRebase);
        assertEq(userABalancePostRebase, transferAmount / 10, "UserA should have 1 token post-rebase");

        // Attempt post-rebase transfer
        console.log("--- POST-REBASE TRANSFER ATTEMPT ---");
        vm.startPrank(userA);
        vm.expectRevert();
        token.transfer(RECIPIENT, transferAmount);
        vm.stopPrank();
        console.log("Post-rebase transfer reverted as expected");

        // Check for vulnerability existence
        if (
            (userABalancePreRebase - transferAmount == userABalanceAfterTransfer) && 
            (recipientBalancePreRebase + transferAmount == recipientBalanceAfterTransfer) &&
            (token.balanceOf(RECIPIENT) == 0)
        ) {
            console.log("Vulnerability Exists: Same transfer amount succeeds before rebase but fails after rebase");
        } else {
            console.log("Vulnerability not Exist: Pre/post rebase transfer behavior matches expectations");
        }
    }
}