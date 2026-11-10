// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CH.sol";

contract MockERC20 {
    function approve(address, uint256) public pure returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract MockRouter {
    address public immutable factory;

    constructor() {
        factory = address(new MockFactory());
    }
}

contract SwapBackSettingsTest is Test {
    CH public token;
    address public owner = address(0x1);

    // Token's hardcoded dependencies
    address constant BUSD_ADDR = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock dependencies
        MockERC20 mockBUSD = new MockERC20();
        MockRouter mockRouter = new MockRouter();

        // Simulate hardcoded addresses
        vm.etch(BUSD_ADDR, address(mockBUSD).code);
        vm.etch(ROUTER_ADDR, address(mockRouter).code);

        // Deploy token contract
        vm.startPrank(owner);
        token = new CH();
        vm.stopPrank();
    }

    function test_UnprotectedSwapBackSettings() public {
        // --- BEFORE-Trigger swapBackSettings ---
        console2.log("--- BEFORE-Trigger swapBackSettings ---");
        bool enabledBefore = token.swapAndLiquifyEnabled();
        uint256 thresholdBefore = token.swapThreshold();
        console2.log("swapAndLiquifyEnabled:", enabledBefore);
        console2.log("swapThreshold:", thresholdBefore);

        // Verify initial settings (optional)
        assertTrue(enabledBefore, "Swap should be enabled by default");
        assertEq(thresholdBefore, token.totalSupply() / 2000, "Incorrect default threshold");

        // --- Trigger changeSwapBackSettings ---
        console2.log("--- Trigger changeSwapBackSettings ---");
        // Attacker compromises owner account
        vm.prank(owner);
        token.changeSwapBackSettings(false, type(uint256).max);

        // --- AFTER-Trigger swapBackSettings ---
        console2.log("--- AFTER-Trigger swapBackSettings ---");
        bool enabledAfter = token.swapAndLiquifyEnabled();
        uint256 thresholdAfter = token.swapThreshold();
        console2.log("swapAndLiquifyEnabled:", enabledAfter);
        console2.log("swapThreshold:", thresholdAfter);

        // Verify settings were dangerously modified
        assertFalse(enabledAfter, "Swap should be disabled");
        assertEq(thresholdAfter, type(uint256).max, "Threshold should be max value");

        // --- Vulnerability verdict ---
        bool settingsChanged = 
            (enabledBefore != enabledAfter) && 
            (thresholdAfter == type(uint256).max);
        
        if(settingsChanged) {
            console2.log("Vulnerability Exists: Owner could disable swap and set threshold to max");
        } else {
            console2.log("Vulnerability not Exist: Swap back settings unchanged");
        }
    }
}