// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FoundationToken.sol";

contract FoundationTokenTest is Test {
    FoundationToken token;
    address owner = address(0xBEEF);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock router calls
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(address(0xFAC7))
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(address(0xCAFE))
        );
        
        // Mock factory createPair call (fixed invalid address)
        vm.mockCall(
            address(0xFAC7),
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(address(0x1234567890123456789012345678901234567890)) // valid address
        );

        token = new FoundationToken();
        vm.stopPrank();
    }

    function test_SwapTokensAtAmount_ValidBoundaries() public {
        vm.startPrank(owner);
        uint256 supply = token.totalSupply();
        
        uint256 minAllowed = supply / 100000;
        uint256 maxAllowed = supply / 1000;
        
        // Should allow exact minimum
        console.log("--- BEFORE-Trigger minAllowed ---");
        uint256 preStateMin = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before (min):", preStateMin);
        
        console.log("--- Trigger updateSwapTokensAtAmount (min) ---");
        token.updateSwapTokensAtAmount(minAllowed);
        
        console.log("--- AFTER-Trigger minAllowed ---");
        uint256 postStateMin = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after (min):", postStateMin);
        assertEq(postStateMin, minAllowed);
        
        // Should allow exact maximum
        console.log("--- BEFORE-Trigger maxAllowed ---");
        uint256 preStateMax = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before (max):", preStateMax);
        
        console.log("--- Trigger updateSwapTokensAtAmount (max) ---");
        token.updateSwapTokensAtAmount(maxAllowed);
        
        console.log("--- AFTER-Trigger maxAllowed ---");
        uint256 postStateMax = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after (max):", postStateMax);
        assertEq(postStateMax, maxAllowed);
        
        // Diffential validation verdict
        bool minVerified = (postStateMin == minAllowed) && (preStateMin != minAllowed);
        bool maxVerified = (postStateMax == maxAllowed) && (preStateMax != maxAllowed);
        if(minVerified && maxVerified) {
            console.log("Vulnerability not Exist: Valid parameter changes work correctly");
        } else {
            console.log("Vulnerability Exists: Failed to maintain swap threshold limits");
        }
        vm.stopPrank();
    }

    function test_SwapTokensAtAmount_InvalidBelowMinimum() public {
        vm.startPrank(owner);
        uint256 supply = token.totalSupply();
        uint256 minAllowed = supply / 100000;
        
        // Test below minimum (with rounding consideration)
        console.log("--- BEFORE-Trigger BelowMinimum ---");
        uint256 preState = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before:", preState);
        
        uint256 invalidAmount = minAllowed - 1;
        console.log("--- Trigger updateSwapTokensAtAmount (invalid) ---");
        vm.expectRevert("Swap amount cannot be lower than 0.001% total supply.");
        token.updateSwapTokensAtAmount(invalidAmount);
        
        console.log("--- AFTER-Trigger BelowMinimum ---");
        uint256 postState = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after:", postState);
        
        // Diffential validation verdict
        if(preState == postState) {
            console.log("Vulnerability not Exist: State unchanged for invalid min parameter");
        } else {
            console.log("Vulnerability Exists: Allowed invalid threshold value");
        }
        vm.stopPrank();
    }

    function test_SwapTokensAtAmount_InvalidAboveMaximum() public {
        vm.startPrank(owner);
        uint256 supply = token.totalSupply();
        uint256 maxAllowed = supply / 1000;
        
        // Test above maximum
        console.log("--- BEFORE-Trigger AboveMaximum ---");
        uint256 preState = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before:", preState);
        
        uint256 invalidAmount = maxAllowed + 1;
        console.log("--- Trigger updateSwapTokensAtAmount (invalid) ---");
        vm.expectRevert("Swap amount cannot be higher than 0.1% total supply.");
        token.updateSwapTokensAtAmount(invalidAmount);
        
        console.log("--- AFTER-Trigger AboveMaximum ---");
        uint256 postState = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after:", postState);
        
        // Diffential validation verdict
        if(preState == postState) {
            console.log("Vulnerability not Exist: State unchanged for invalid max parameter");
        } else {
            console.log("Vulnerability Exists: Allowed invalid threshold value");
        }
        vm.stopPrank();
    }

    function test_SwapTokensAtAmount_RoundingEdgeCase() public {
        vm.startPrank(owner);
        uint256 supply = token.totalSupply();
        uint256 minAllowed = supply / 100000;
        uint256 maxAllowed = supply / 1000;
        
        // Test value just above minimum
        console.log("--- BEFORE-Trigger minEdgeCase ---");
        uint256 preStateMin = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before (min+1):", preStateMin);
        
        console.log("--- Trigger minEdgeCase ---");
        token.updateSwapTokensAtAmount(minAllowed + 1);
        
        console.log("--- AFTER-Trigger minEdgeCase ---");
        uint256 postStateMin = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after (min+1):", postStateMin);
        assertEq(postStateMin, minAllowed + 1);
        
        // Test value just below maximum
        console.log("--- BEFORE-Trigger maxEdgeCase ---");
        uint256 preStateMax = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount before (max-1):", preStateMax);
        
        console.log("--- Trigger maxEdgeCase ---");
        token.updateSwapTokensAtAmount(maxAllowed - 1);
        
        console.log("--- AFTER-Trigger maxEdgeCase ---");
        uint256 postStateMax = token.swapTokensAtAmount();
        console.log("swapTokensAtAmount after (max-1):", postStateMax);
        assertEq(postStateMax, maxAllowed - 1);
        
        // Diffential validation verdict
        bool minVerified = (preStateMin != minAllowed + 1) && (postStateMin == minAllowed + 1);
        bool maxVerified = (preStateMax != maxAllowed - 1) && (postStateMax == maxAllowed - 1);
        if(minVerified && maxVerified) {
            console.log("Vulnerability not Exist: Edge case parameters work correctly");
        } else {
            console.log("Vulnerability Exists: Failed to handle threshold edge cases");
        }
        vm.stopPrank();
    }
}