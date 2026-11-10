// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGE1.sol";

contract DOGE1_PrivilegeTest is Test {
    DOGE1 token;
    address owner = address(1);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FIXED_MARKETING_ADDRESS = 0xB935506b02c775cBDC532a708A3218C2f60DFf13;
    
    address mockFactory = address(0xABCD);
    address mockWETH = address(0x1234);
    address mockPair = address(0x5678);

    function setUp() public {
        // Deploy from owner
        vm.startPrank(owner);
        token = new DOGE1();
        vm.stopPrank();

        // Mock Uniswap router and factory
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
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)", address(token), mockWETH),
            abi.encode(mockPair)
        );

        // Initialize contract as owner
        vm.prank(owner);
        token.initContract();
    }

    function test_marketing_address_fixed() public {
        console.log("--- BEFORE-Trigger State ---");
        address marketingBefore = token.marketingAddress();
        console.log("- Marketing Address Before:", marketingBefore);
        
        console.log("--- Trigger ---");
        console.log("No action needed (Static state check)");

        console.log("--- AFTER-Trigger State ---");
        address marketingAfter = token.marketingAddress();
        console.log("- Marketing Address After:", marketingAfter);

        // Final verification and verdict
        if (marketingAfter == FIXED_MARKETING_ADDRESS) {
            console.log("Vulnerability Exists: Marketing address is fixed to attacker controlled address and cannot be changed");
        } else {
            console.log("Vulnerability not Exist: Marketing address is not fixed");
        }
        assertEq(marketingAfter, FIXED_MARKETING_ADDRESS, "Marketing address should be permanently fixed");
    }
}