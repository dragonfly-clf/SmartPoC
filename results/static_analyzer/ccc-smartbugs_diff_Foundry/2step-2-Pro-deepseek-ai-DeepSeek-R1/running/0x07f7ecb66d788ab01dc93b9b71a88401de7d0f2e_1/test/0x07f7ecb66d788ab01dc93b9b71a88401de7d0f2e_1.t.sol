// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x07f7ecb66d788ab01dc93b9b71a88401de7d0f2e.sol";

contract PoCGameOverflowTest is Test {
    PoCGame game;
    address whale = makeAddr("whale");
    address owner = makeAddr("owner");
    address player = makeAddr("player");
    uint256 constant MAX_UINT = type(uint256).max;

    function setUp() public {
        vm.startPrank(owner);
        game = new PoCGame(whale, 100);
        game.OpenToThePublic();
        vm.stopPrank();
    }

    function test_TotalDonatedOverflowViaDonate() public {
        // Pre-set totalDonated to MAX_UINT - 1 via donation
        vm.deal(owner, MAX_UINT - 1);
        vm.prank(owner);
        game.donate{value: MAX_UINT - 1}();

        console2.log("--- BEFORE-Trigger: Pre-overflow attempt state ---");
        uint256 contractBalanceBefore = address(game).balance;
        console2.log("Contract balance before overflow attempt:", contractBalanceBefore);

        console2.log("--- Trigger: Attempt to donate 2 wei (causing overflow) ---");
        vm.deal(player, 2);
        vm.prank(player);
        vm.expectRevert();
        game.donate{value: 2}();

        console2.log("--- AFTER-Trigger: Post-overflow attempt state ---");
        uint256 contractBalanceAfter = address(game).balance;
        console2.log("Contract balance after overflow attempt:", contractBalanceAfter);

        console2.log("--- COMPARISON: State change verification ---");
        if (contractBalanceBefore == contractBalanceAfter) {
            console2.log("Verification: State unchanged - Revert prevented overflow");
            console2.log("Vulnerability not Exist: Transaction revert successfully protected contract state");
        } else {
            console2.log("Verification: State changed!");
            console2.log("Vulnerability Exists: Overflow occurred causing unexpected state change");
        }
    }
}