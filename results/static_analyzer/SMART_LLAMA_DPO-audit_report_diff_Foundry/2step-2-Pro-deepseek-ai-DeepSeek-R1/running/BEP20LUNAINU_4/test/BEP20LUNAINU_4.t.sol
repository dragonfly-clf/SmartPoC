// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BEP20LUNAINU.sol";

contract PrivilegeEscalationTest is Test {
    BEP20LUNAINU token;
    address owner;
    address nonOwner = makeAddr("nonOwner");
    
    // Dummy addresses
    address constant DUMMY_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant DUMMY_WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DUMMY_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant DUMMY_PAIR = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;

    function setUp() public {
        owner = address(this);
        vm.startPrank(owner);
        
        // Mock router and factory
        vm.mockCall(DUMMY_ROUTER, abi.encodeWithSelector(0xad5c4648), abi.encode(DUMMY_WBNB));
        vm.mockCall(DUMMY_ROUTER, abi.encodeWithSelector(0xc45a0155), abi.encode(DUMMY_FACTORY));
        vm.mockCall(DUMMY_FACTORY, abi.encodeWithSelector(0xc9c65396), abi.encode(DUMMY_PAIR));
        
        // Deploy token with mocked dependencies
        token = new BEP20LUNAINU();
        vm.stopPrank();
    }

    // Test owner can successfully change settings
    function test_owner_can_set_settings() public {
        vm.prank(owner);
        token.setSwapBackSettings(true, 0); // 0 is safe
        
        // Confirm settings were changed
        assertTrue(token.swapEnabled());
        assertEq(token.swapThreshold(), 0);
    }

    // Test proper threshold validation
    function test_threshold_validation() public {
        uint256 totalSupply = token.totalSupply();
        uint256 maxAllowed = totalSupply / 10;
        
        // Test invalid threshold
        vm.expectRevert("Amount too high");
        vm.prank(owner);
        token.setSwapBackSettings(true, maxAllowed); // Exactly at limit should fail

        // Test valid threshold
        vm.prank(owner);
        token.setSwapBackSettings(true, maxAllowed - 1); // Below limit is valid
        assertEq(token.swapThreshold(), maxAllowed - 1);
    }

    // Test to verify vulnerability existence
    function test_vulnerability_exists() public {
        // Set initial state via owner
        console2.log("--- BEFORE nonOwner call ---");
        vm.prank(owner);
        token.setSwapBackSettings(true, 1000);
        
        // Capture pre-attack state
        bool swapEnabledBefore = token.swapEnabled();
        uint256 swapThresholdBefore = token.swapThreshold();
        console2.log("swapEnabledBefore: ", swapEnabledBefore);
        console2.log("swapThresholdBefore: ", swapThresholdBefore);

        console2.log("--- Trigger nonOwner call ---");
        // Attempt function call as nonOwner
        vm.startPrank(nonOwner);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(token.setSwapBackSettings.selector, false, 500)
        );
        vm.stopPrank();
        console2.log("Call result: ", success ? "Success" : "Reverted");

        console2.log("--- AFTER nonOwner call ---");
        // Capture post-attack state
        bool swapEnabledAfter = token.swapEnabled();
        uint256 swapThresholdAfter = token.swapThreshold();
        console2.log("swapEnabledAfter: ", swapEnabledAfter);
        console2.log("swapThresholdAfter: ", swapThresholdAfter);

        // Determine and log vulnerability status
        if (success) {
            console2.log("Vulnerability Exists: nonOwner changed swap settings");
        } else {
            console2.log("Vulnerability not Exist: nonOwner call reverted");
        }
    }
}