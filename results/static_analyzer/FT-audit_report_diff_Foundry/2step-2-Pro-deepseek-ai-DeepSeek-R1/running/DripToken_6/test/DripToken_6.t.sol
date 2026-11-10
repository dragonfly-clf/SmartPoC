// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DripToken.sol";

contract MockRouter {
    function factory() external view returns (address) {
        return address(this);
    }

    function WETH() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }

    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract DripTokenCentralizationTest is Test {
    DripToken token;
    address owner = address(0xABCD);
    address attacker = address(0x1234);

    function setUp() public {
        // Deploy mock router at hardcoded PancakeSwap address
        MockRouter mock = new MockRouter();
        address pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(pancakeRouter, address(mock).code);
        
        // Deploy token as owner
        vm.prank(owner);
        token = new DripToken();
    }

    function test_CompromisedOwnerCanTakeFullControl() public {
        console.log("--- BEFORE-Trigger ---");
        // Pre-attack state capture
        address preOwner = token.owner();
        bool preSwapEnabled = token.swapAndLiquifyEnabled();
        console.log("Pre-Owner: ", preOwner);
        console.log("Pre-swapEnabled: ", preSwapEnabled);

        console.log("--- Trigger Attack Actions ---");
        // Take over as compromised owner
        vm.startPrank(owner);
        token.transferOwnership(attacker);
        assertEq(token.owner(), attacker, "Ownership transfer failed");
        vm.stopPrank();

        // Attacker disables contract protections
        vm.startPrank(attacker);
        token.setSwapSettings(false, 1);
        assertFalse(token.swapAndLiquifyEnabled(), "Swap protection still active");
        
        // Attacker permanently renounces ownership
        token.renounceOwnership();
        assertEq(token.owner(), address(0), "Ownership renunciation failed");
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        // Post-attack state capture
        address postOwner = token.owner();
        bool postSwapEnabled = token.swapAndLiquifyEnabled();
        console.log("Post-Owner: ", postOwner);
        console.log("Post-swapEnabled: ", postSwapEnabled);

        // Verify state changes
        bool ownershipChanged = (preOwner != postOwner);
        bool swapStateChanged = (preSwapEnabled != postSwapEnabled);
        console.log("Ownership Changed: ", ownershipChanged ? "YES" : "NO");
        console.log("Swap State Changed: ", swapStateChanged ? "YES" : "NO");
        
        // Vulnerability exists if owner became 0 AND protections disabled
        if (postOwner == address(0) && !postSwapEnabled) {
            console.log("Vulnerability Exists: Ownership successfully renounced and swap protections disabled");
        } else {
            console.log("Vulnerability not Exist: Attack did not achieve all desired state changes");
        }

        // Final verification of ownerless state
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapSettings(true, 100);
    }

    function test_NonOwnerCannotChangeSwapSettings() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapSettings(true, 100);
    }

    function test_NonOwnerCannotTransferOwnership() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.transferOwnership(attacker);
    }

    function test_NonOwnerCannotRenounceOwnership() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.renounceOwnership();
    }

    function testRevertWhen_SetZeroSwapThreshold() public {
        vm.prank(owner);
        vm.expectRevert("swap threshold cannot be 0");
        token.setSwapSettings(true, 0);
    }
}