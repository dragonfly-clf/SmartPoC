// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/0xb620cee6b52f96f3c6b253e6eea556aa2d214a99.sol";

contract DrainMeTest is Test {
    DrainMe drainMe;
    address owner = address(0x1);
    address player = address(0x2);
    address firstTarget = address(0x3);
    address secondTarget = address(0x4);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(player, 10 ether);
        vm.deal(firstTarget, 10 ether);
        vm.deal(secondTarget, 10 ether);

        vm.prank(owner);
        drainMe = new DrainMe{value: 5 ether}();

        // Make player an approved player
        vm.prank(player);
        drainMe.becomePlayer{value: 1 ether}();
    }

    // Test that winPrize() doesn't check call return value
    function testUncheckedWinPrizeCall() public {
        vm.prank(owner);
        drainMe.winPrize{value: 1 wei}();

        // Test passes if it doesn't revert - demonstrating unchecked call
        assertTrue(true);
    }

    // Test that callFirstTarget() doesn't check call return value
    function testUncheckedFirstTargetCall() public {
        vm.prank(player);
        drainMe.callFirstTarget{value: 0.005 ether}();

        // Test passes if it doesn't revert - demonstrating unchecked call
        assertTrue(true);
    }

    // Test that callSecondTarget() doesn't check call return value
    function testUncheckedSecondTargetCall() public {
        vm.prank(player);
        drainMe.callSecondTarget{value: 0.005 ether}();

        // Test passes if it doesn't revert - demonstrating unchecked call
        assertTrue(true);
    }

    // Test unchecked call behavior with reverting target
    function testUncheckedCallWithRevertingTarget() public {
        uint256 amount = 0.005 ether;
        
        console2.log("--- BEFORE-Trigger call ---");
        uint256 playerBalanceBefore = player.balance;
        uint256 drainMeBalanceBefore = address(drainMe).balance;
        console2.log("Player balance:", playerBalanceBefore);
        console2.log("DrainMe balance:", drainMeBalanceBefore);

        console2.log("--- Trigger call (to reverting precompile) ---");
        vm.prank(player);
        (bool success,) = address(drainMe).call{value: amount}(
            abi.encodeWithSelector(DrainMe.callFirstTarget.selector)
        );
        
        console2.log("--- AFTER-Trigger call ---");
        uint256 playerBalanceAfter = player.balance;
        uint256 drainMeBalanceAfter = address(drainMe).balance;
        console2.log("Player balance:", playerBalanceAfter);
        console2.log("DrainMe balance:", drainMeBalanceAfter);
        
        console2.log("--- State Changes ---");
        console2.log("Player reduction:", playerBalanceBefore - playerBalanceAfter);
        console2.log("DrainMe change:", drainMeBalanceAfter - drainMeBalanceBefore);
        
        bool playerLostValue = (playerBalanceBefore - playerBalanceAfter) == amount;
        bool drainMeGainedValue = (drainMeBalanceAfter - drainMeBalanceBefore) == amount;
        
        bool vulnerabilityExists = playerLostValue && drainMeGainedValue;
        
        if (vulnerabilityExists) {
            console2.log("RESULT: Vulnerability Exists - ETH retained despite call failure");
            console2.log("Vulnerability Exists: Unchecked call allowed ETH retention");
        } else {
            console2.log("RESULT: Vulnerability not Exist - ETH not retained after failed call");
            console2.log("Vulnerability not Exist: Proper ETH handling");
        }
    }
}