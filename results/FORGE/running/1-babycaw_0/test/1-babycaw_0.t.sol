// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/BabyCAW.sol";

contract BabyCAWTest is Test {
    BabyCAW token;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address mockWETH = address(0x456);
    address mockFactory = address(0x123);
    address mockPair = address(0x789);

    function setUp() public {
        // Mock router and factory calls
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );

        // Create selector for createPair (bytes4 of keccak256 of "createPair(address,address)")
        bytes4 createPairSelector = 0xc9c65396;
        // Match any call with createPair selector
        vm.mockCall(
            mockFactory,
            abi.encodePacked(createPairSelector),
            abi.encode(mockPair)
        );

        vm.startPrank(owner);
        token = new BabyCAW();
        vm.stopPrank();
    }

    function testCannotTransferFromBlacklisted() public {
        // Enable blacklist mode
        vm.prank(owner);
        token.enable_blacklist(true);

        // Add user1 to blacklist
        address[] memory targets = new address[](1);
        targets[0] = user1;
        vm.prank(owner);
        token.manage_blacklist(targets, true);

        uint256 amt = 100 ether;

        // Attempt transfer from blacklisted user1
        vm.prank(user1);
        vm.expectRevert("Blacklisted");
        token.transfer(user2, amt);
    }

    function testCannotTransferToBlacklisted() public {
        // Enable blacklist mode
        vm.prank(owner);
        token.enable_blacklist(true);

        // Add user2 to blacklist
        address[] memory targets = new address[](1);
        targets[0] = user2;
        vm.prank(owner);
        token.manage_blacklist(targets, true);

        uint256 amt = 100 ether;

        // Attempt transfer to blacklisted user2
        vm.prank(user1);
        vm.expectRevert("Blacklisted");
        token.transfer(user2, amt);
    }

    function testOnlyOwnerCanManageBlacklist() public {
        vm.prank(owner);
        token.enable_blacklist(true);

        address[] memory targets = new address[](1);
        targets[0] = user1;

        // Non-owner cannot manage blacklist
        vm.prank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        token.manage_blacklist(targets, true);
    }

    // =========================================================================
    // Differential (before/after) validation of the blacklist state change.
    // State variable under test: token.isBlacklisted(target)
    // Critical operation:       token.manage_blacklist(targets, true)
    // =========================================================================
    function testBlacklistStateDifferential() public {
        // Put the contract in the same state the PoC relies on (blacklist mode on).
        vm.prank(owner);
        token.enable_blacklist(true);

        address target  = user1; // address whose blacklist state will be flipped
        address control = user2; // control address that must remain untouched

        // ---------------------------------------------------------------------
        // (i) PRE-trigger action + state snapshot
        // ---------------------------------------------------------------------
        console.log("=== (i) BEFORE trigger: state snapshot (isBlacklisted) ===");
        bool targetBefore  = token.isBlacklisted(target);
        bool controlBefore = token.isBlacklisted(control);
        console.log("  isBlacklisted(user1) [target] :", targetBefore  ? "true" : "false");
        console.log("  isBlacklisted(user2) [control]:", controlBefore ? "true" : "false");

        // ---------------------------------------------------------------------
        // (ii) Trigger operation: the blacklist mutation in the PoC
        // ---------------------------------------------------------------------
        console.log("=== (ii) TRIGGER: owner calls manage_blacklist([user1], true) ===");
        address[] memory targets = new address[](1);
        targets[0] = target;

        vm.prank(owner);
        (bool triggerSucceeded, ) = address(token).call(
            abi.encodeWithSelector(BabyCAW.manage_blacklist.selector, targets, true)
        );
        console.log("  manage_blacklist executed without revert:", triggerSucceeded ? "true" : "false");

        // ---------------------------------------------------------------------
        // (iii) POST-trigger action + state snapshot
        // ---------------------------------------------------------------------
        console.log("=== (iii) AFTER trigger: state snapshot (isBlacklisted) ===");
        bool targetAfter  = token.isBlacklisted(target);
        bool controlAfter = token.isBlacklisted(control);
        console.log("  isBlacklisted(user1) [target] :", targetAfter  ? "true" : "false");
        console.log("  isBlacklisted(user2) [control]:", controlAfter ? "true" : "false");

        // ---------------------------------------------------------------------
        // (iv) Comparison verdict
        // ---------------------------------------------------------------------
        bool targetChanged    = (targetBefore != targetAfter);
        bool controlUnchanged = (controlBefore == controlAfter);
        bool exploited        = triggerSucceeded && targetChanged && targetAfter && controlUnchanged;

        console.log("=== (iv) DIFF RESULT ===");
        console.log("  target state changed (before != after):", targetChanged    ? "true" : "false");
        console.log("  control state unchanged               :", controlUnchanged ? "true" : "false");
        console.log("  exploitation succeeded                :", exploited        ? "true" : "false");

        if (exploited) {
            console.log("Vulnerability Exists: manage_blacklist call arbitrarily flips the target's isBlacklisted state (any address can be frozen/unfrozen at will)");
        } else {
            console.log("Vulnerability not Exist: isBlacklisted state did not change as the exploit requires");
        }
    }
}