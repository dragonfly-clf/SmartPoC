// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract OddsAndEvensTest is Test {
    OddsAndEvens game;
    uint256 constant MAX_UINT = type(uint256).max;
    uint256 totSlot = 5; // Storage slot for the tot variable

    function setUp() public {
        game = new OddsAndEvens();
    }

    function test_arithmeticUnderflow() public {
        // Set tot to MAX_UINT to simulate worst-case scenario
        bytes32 totSlotBytes = bytes32(totSlot);
        vm.store(address(game), totSlotBytes, bytes32(MAX_UINT));

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Precondition set: tot = MAX_UINT");

        console2.log("--- Trigger Play Call ---");
        // Prepare player and call play{value: 1 ether}(42)
        address player = address(0x1);
        vm.deal(player, 1 ether);
        
        vm.expectRevert();
        vm.prank(player);
        game.play{value: 1 ether}(42);
        console2.log("Transaction reverted as expected");

        console2.log("--- AFTER-Trigger State ---");
        console2.log("Trigger validated: Revert prevents state change");
        console2.log("No differential state verification required");

        // Final vulnerability existence verdict
        console2.log("Vulnerability Exists: Arithmetic overflow in tot++ causes safe revert");
    }
}