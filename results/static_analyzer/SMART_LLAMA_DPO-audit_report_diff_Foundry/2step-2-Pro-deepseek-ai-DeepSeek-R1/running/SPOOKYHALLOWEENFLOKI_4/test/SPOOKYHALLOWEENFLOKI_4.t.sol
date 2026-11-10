// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPOOKYHALLOWEENFLOKI.sol";

contract MockWETH {}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract MockRouter {
    address public immutable WETH;
    address public immutable factory;
    
    constructor(address _weth, address _factory) {
        WETH = _weth;
        factory = _factory;
    }
}

contract SPOOKYHALLOWEENFLOKI_PrivilegeTest is Test {
    SPOOKYHALLOWEENFLOKI token;
    address constant owner = address(0x1);
    address constant attacker = address(0x2);

    function setUp() public {
        // Deploy mock dependencies
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockWETH), address(mockFactory));

        // Patch the hardcoded router address to point to our mock
        address ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new SPOOKYHALLOWEENFLOKI();
        vm.stopPrank();
    }

    // Owner should be able to set swap settings
    function test_OwnerCanSetSwapBackSettings() public {
        uint256 supply = token.totalSupply();
        uint256 maxAmount = supply / 10 - 1;  // Valid amount
        
        vm.prank(owner);
        token.setSwapBackSettings(true, maxAmount);

        // If we get here without revert, owner access works correctly
        assertTrue(true);
    }

    // Non-owner should not be able to set swap settings
    function test_NonOwnerCannotSetSwapBackSettings() public {
        uint256 supply = token.totalSupply();
        uint256 maxAmount = supply / 10 - 1;  // Valid amount
        
        console.log("--- BEFORE-Trigger state snapshot ---");
        bool beforeSwapEnabled = token.swapEnabled();
        uint256 beforeSwapThreshold = token.swapThreshold();
        console.log("swapEnabled state: %s", beforeSwapEnabled);
        console.log("swapThreshold value: %d", beforeSwapThreshold);
        
        console.log("--- Trigger: Non-owner attempt to setSwapBackSettings ---");
        vm.prank(attacker);
        vm.expectRevert("!OWNER");
        token.setSwapBackSettings(true, maxAmount);

        console.log("--- AFTER-Trigger state snapshot ---");
        bool afterSwapEnabled = token.swapEnabled();
        uint256 afterSwapThreshold = token.swapThreshold();
        console.log("swapEnabled state: %s", afterSwapEnabled);
        console.log("swapThreshold value: %d", afterSwapThreshold);
        
        // Verify state didn't change
        console.log("--- Differential Result ---");
        if (beforeSwapEnabled == afterSwapEnabled && beforeSwapThreshold == afterSwapThreshold) {
            console.log("State unchanged - Vulnerability not Exist: Non-owner failed to modify swap settings");
        } else {
            console.log("State changed - Vulnerability Exists: Non-owner successfully modified swap settings!");
        }
    }
}