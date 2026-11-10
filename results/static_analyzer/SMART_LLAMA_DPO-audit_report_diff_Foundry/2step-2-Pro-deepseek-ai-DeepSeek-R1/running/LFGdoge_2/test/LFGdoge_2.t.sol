// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LFGdoge.sol";

contract LFGdogeTest is Test {
    LFGdoge token;
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant MARKETING_ADDRESS1 = address(0x123);
    address constant MARKETING_ADDRESS2 = address(0x456);
    
    function setUp() public {
        // Mock Uniswap router
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0xabc)) // Dummy factory address
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0xdef)) // Dummy WETH address
        );
        
        // Mock factory createPair call
        vm.mockCall(
            address(0xabc),
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0x001)) // Dummy pair address
        );
        
        // Deploy token after mocks are set
        token = new LFGdoge();
    }

    // Test redundant setting of marketing wallet address
    function testMarketingWalletRedundantSet() public {
        // Set initial value
        token.setMarketingWalletAddress(MARKETING_ADDRESS1);
        
        console.log("--- BEFORE-Trigger setMarketingWalletAddress(redundant) ---");
        address preState = token.marketingWalletAddress();
        console.log("Pre-state marketing address:", preState);

        console.log("--- Trigger setMarketingWalletAddress(redundant) ---");
        // Set same address again
        token.setMarketingWalletAddress(MARKETING_ADDRESS1);

        console.log("--- AFTER-Trigger setMarketingWalletAddress(redundant) ---");
        address postState = token.marketingWalletAddress();
        console.log("Post-state marketing address:", postState);
        
        // Verify state remains unchanged
        assertEq(preState, MARKETING_ADDRESS1, "First set failed");
        assertEq(postState, MARKETING_ADDRESS1, "Second set changed value");
        assertEq(preState, postState, "State changed after redundant set");
        
        // Differential verdict
        if (preState != postState) {
            console.log("Vulnerability Exists: State changed on redundant set");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged");
        }
    }
    
    // Test redundant setting of swapAndLiquifyEnabled flag
    function testSwapEnabledRedundantSet() public {
        // Enable swap/liquify
        token.setSwapAndLiquifyEnabled(true);
        
        console.log("--- BEFORE-Trigger setSwapAndLiquifyEnabled(redundant) ---");
        bool preState = token.swapAndLiquifyEnabled();
        console.log("Pre-state swap enabled:", preState);
        
        console.log("--- Trigger setSwapAndLiquifyEnabled(redundant) ---");
        // Set same value again
        token.setSwapAndLiquifyEnabled(true);
        
        console.log("--- AFTER-Trigger setSwapAndLiquifyEnabled(redundant) ---");
        bool postState = token.swapAndLiquifyEnabled();
        console.log("Post-state swap enabled:", postState);
        
        // Verify state remains unchanged
        assertTrue(preState, "First set failed");
        assertTrue(postState, "Second set changed value");
        assertEq(preState, postState, "State changed after redundant set");
        
        // Differential verdict
        if (preState != postState) {
            console.log("Vulnerability Exists: State changed on redundant set");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged");
        }
    }
    
    // Added tests to show different values work as expected (unchanged)
    function testMarketingWalletValidChanges() public {
        // Set to address1
        token.setMarketingWalletAddress(MARKETING_ADDRESS1);
        assertEq(token.marketingWalletAddress(), MARKETING_ADDRESS1, "Address1 set failed");
        
        // Change to address2
        token.setMarketingWalletAddress(MARKETING_ADDRESS2);
        assertEq(token.marketingWalletAddress(), MARKETING_ADDRESS2, "Address2 set failed");
    }
    
    function testSwapEnableDisableCycle() public {
        // Enable and verify
        token.setSwapAndLiquifyEnabled(true);
        assertTrue(token.swapAndLiquifyEnabled(), "Enable failed");
        
        // Disable and verify
        token.setSwapAndLiquifyEnabled(false);
        assertFalse(token.swapAndLiquifyEnabled(), "Disable failed");
    }
}