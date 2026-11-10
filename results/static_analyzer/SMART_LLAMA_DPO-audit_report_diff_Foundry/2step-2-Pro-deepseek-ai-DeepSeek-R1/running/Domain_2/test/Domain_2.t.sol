// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract MockRouter {
    address public factory;
    address public immutable weth;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract MockFactory {
    address public immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract DomainUniquenessTest is Test {
    Domain token;
    address owner = makeAddr("owner");
    address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Create fake addresses
        address fakePair = makeAddr("fakePair");
        address fakeWETH = makeAddr("fakeWETH");
        
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory(fakePair);
        
        // Deploy mock router to get its code
        MockRouter mockRouter = new MockRouter(address(mockFactory), fakeWETH);
        
        // Replace hardcoded router address with mock code
        vm.etch(routerAddr, address(mockRouter).code);
        
        // Configure mock router storage
        bytes32 factorySlot = bytes32(uint256(0));   // Storage slot 0
        bytes32 wethSlot = bytes32(uint256(1));      // Storage slot 1
        
        // Encode values as storage-friendly bytes32
        bytes32 factoryValue = bytes32(uint256(uint160(address(mockFactory))));
        bytes32 wethValue = bytes32(uint256(uint160(fakeWETH)));
        
        // Set mock router's storage
        vm.store(routerAddr, factorySlot, factoryValue);
        vm.store(routerAddr, wethSlot, wethValue);
        
        // Deploy token
        token = new Domain();
        
        // Transfer ownership to test context
        token.transferOwnership(owner);
        
        vm.stopPrank();
    }

    function test_SetAutomatedMarketMakerPair_UniqueEnforcement() public {
        address testPair = makeAddr("testPair");
        
        vm.startPrank(owner);
        token.setAutomatedMarketMakerPair(testPair, true);
        
        console.log("--- BEFORE-Trigger Attempt ---");
        console.log("Activation Attempt: 2nd time for same pair");
        console.log("--- Trigger (Expected Revert) ---");
        
        // Attempt duplicate activation
        vm.expectRevert("Automated market maker pair is already set to that value");
        token.setAutomatedMarketMakerPair(testPair, true);
        
        token.setAutomatedMarketMakerPair(testPair, false);
        
        console.log("--- BEFORE-Trigger Attempt ---");
        console.log("Deactivation Attempt: 2nd time for same pair");
        console.log("--- Trigger (Expected Revert) ---");
        
        // Attempt duplicate deactivation
        vm.expectRevert("Automated market maker pair is already set to that value");
        token.setAutomatedMarketMakerPair(testPair, false);
        
        vm.stopPrank();
        console.log("--- AFTER-Trigger Results ---");
        console.log("Vulnerability not Exist: Reverted on duplicate AMM pair setting");
    }

    function test_ExcludeFromMaxWallet_UniqueEnforcement() public {
        address testUser = makeAddr("testUser");
        
        vm.startPrank(owner);
        token.excludeFromMaxWallet(testUser, true);
        
        console.log("--- BEFORE-Trigger Attempt ---");
        console.log("Exclusion Attempt: 2nd time for same user");
        console.log("--- Trigger (Expected Revert) ---");
        
        // Attempt duplicate exclusion
        vm.expectRevert("_isExcludedFromMaxWallet already set to that value");
        token.excludeFromMaxWallet(testUser, true);
        
        token.excludeFromMaxWallet(testUser, false);
        
        console.log("--- BEFORE-Trigger Attempt ---");
        console.log("Inclusion Attempt: 2nd time for same user");
        console.log("--- Trigger (Expected Revert) ---");
        
        // Attempt duplicate inclusion
        vm.expectRevert("_isExcludedFromMaxWallet already set to that value");
        token.excludeFromMaxWallet(testUser, false);
        
        vm.stopPrank();
        console.log("--- AFTER-Trigger Results ---");
        console.log("Vulnerability not Exist: Reverted on duplicate max wallet exclusion");
    }
}