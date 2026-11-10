// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FIFADoge.sol";

contract FIFADogePrivilegeTest is Test {
    FIFADoge token;
    address owner = makeAddr("owner");
    address functionalOwner = makeAddr("functionalOwner");
    address attacker = makeAddr("attacker");
    address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        address mockFactory = makeAddr("mockFactory");
        address mockWETH = makeAddr("mockWETH");
        address mockPair = makeAddr("mockPair");

        // Mock router calls
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy contract by owner
        vm.startPrank(owner);
        token = new FIFADoge();
        vm.stopPrank();

        // Transfer functionality to functional owner
        vm.prank(owner);
        token.transferOwnership(functionalOwner);
    }

    function test_functional_owner_can_change_swap_settings() public {
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger SwapEnabled State ---");
        bool swapEnabledBefore = token.swapAndLiquifyEnabled();
        console.log("Initial swapAndLiquifyEnabled:", swapEnabledBefore);
        assertTrue(swapEnabledBefore, "Swap should be enabled initially");

        // Trigger action - Owner changes swap settings
        console.log("--- Trigger: setSwapAndLiquifyEnabled(false) ---");
        vm.prank(functionalOwner);
        token.setSwapAndLiquifyEnabled(false);

        // Post-state snapshot
        console.log("--- AFTER-Trigger SwapEnabled State ---");
        bool swapEnabledAfter = token.swapAndLiquifyEnabled();
        console.log("Final swapAndLiquifyEnabled:", swapEnabledAfter);

        // State change verification
        if (swapEnabledBefore != swapEnabledAfter) {
            console.log("Verdict: State modified correctly, functional owner access works as expected");
            console.log("Vulnerability not Exist: Functional owner can modify settings as designed");
        } else {
            console.log("Verdict: State not changed, functional owner access violation!");
            console.log("Vulnerability Exists: Functional owner cannot modify settings");
        }
    }

    function test_non_functional_owner_cannot_change_settings(address attacker) public {
        vm.assume(attacker != functionalOwner);
        vm.assume(attacker != address(0));
        
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger SwapEnabled State ---");
        bool swapEnabledBefore = token.swapAndLiquifyEnabled();
        console.log("Initial swapAndLiquifyEnabled:", swapEnabledBefore);
        assertTrue(swapEnabledBefore, "Swap should be enabled initially");

        // Trigger action - Non-owner attempts change
        console.log("--- Trigger: Attacker setSwapAndLiquifyEnabled(false) ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapAndLiquifyEnabled(false);

        // Post-state snapshot
        console.log("--- AFTER-Trigger SwapEnabled State ---");
        bool swapEnabledAfter = token.swapAndLiquifyEnabled();
        console.log("Final swapAndLiquifyEnabled:", swapEnabledAfter);

        // State change verification
        if (swapEnabledBefore != swapEnabledAfter) {
            console.log("Verdict: State changed by non-owner! Access violation!");
            console.log("Vulnerability Exists: Non-functional owner can modify swap settings");
        } else {
            console.log("Verdict: State unchanged, access control works correctly");
            console.log("Vulnerability not Exist: Non-functional owners cannot modify settings");
        }
    }
}