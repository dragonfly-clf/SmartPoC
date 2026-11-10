// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BNRG.sol";

contract BNRGAuditTest is Test {
    BNRG token;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        token = new BNRG();
        vm.stopPrank();
    }

    function testBotProtectionPermanence() public {
        // Test initial state is Locked (0)
        assertEq(uint256(token.state()), 0, "Initial state should be Locked");

        // Enable bot protection - moves to Restricted (1)
        vm.prank(owner);
        token.setBotProtection(true);
        assertEq(uint256(token.state()), 1, "Should be Restricted after enabling");

        // Disable bot protection - moves to Unlocked (2)
        vm.prank(owner);
        token.setBotProtection(false);
        assertEq(uint256(token.state()), 2, "Should be Unlocked after disabling");

        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 stateBefore = uint256(token.state());
        console.log("Contract state pre-trigger:", stateBefore);
        require(stateBefore == 2, "Pre-condition failed: State should be Unlocked (2)");

        console.log("--- Trigger: Final setBotProtection(true) call ---");
        vm.prank(owner);
        token.setBotProtection(true); // This should be ineffective if vulnerability exists

        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 stateAfter = uint256(token.state());
        console.log("Contract state post-trigger:", stateAfter);

        console.log("--- Differential Comparison Result ---");
        if (stateBefore == stateAfter) {
            console.log("State remains unchanged: Bot protection could not be re-enabled");
            console.log("Vulnerability Exists: Contract permanently loses bot protection functionality");
        } else {
            console.log("State changed: Bot protection was successfully re-enabled");
            console.log("Vulnerability not Exist: Bot protection works as expected");
        }
    }
}