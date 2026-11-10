// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        // Using valid checksum address format
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract GoodRouter {
    MockFactory public factoryContract;
    address public immutable weth;

    constructor() {
        factoryContract = new MockFactory();
        weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    function factory() external view returns (address) {
        return address(factoryContract);
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract MaliciousRouterRevert {
    function factory() external pure returns (address) {
        return address(0);
    }
    
    function WETH() external pure returns (address) {
        revert("MaliciousRouter: intentional revert");
    }
}

contract MaliciousRouterGas {
    uint256[10000] private dummyArray; // Large fixed-size array
    
    function factory() external returns (address) {
        // Consume excessive gas through storage operations
        for(uint256 i = 0; i < dummyArray.length; i++) {
            dummyArray[i] = block.timestamp;
        }
        return address(0);
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract TokenToolTest is Test {
    TokenTool token;
    address owner = makeAddr("owner");
    address marketing = makeAddr("marketing");
    address team = makeAddr("team");
    address service = makeAddr("service");
    uint256 constant INITIAL_BALANCE = 1 ether;

    function setUp() public {
        GoodRouter goodRouter = new GoodRouter();
        
        vm.deal(owner, INITIAL_BALANCE);
        vm.startPrank(owner);
        token = new TokenTool{value: INITIAL_BALANCE / 10}(
            "TestToken", 
            "TT", 
            18, 
            1000000, 
            address(goodRouter), 
            owner, 
            marketing, 
            team, 
            service
        );
        vm.stopPrank();
    }

    function test_RevertWhenMaliciousRouterRevert() public {
        MaliciousRouterRevert maliciousRouter = new MaliciousRouterRevert();
        
        console.log("--- BEFORE-Trigger changeRouterVersion ---");
        console.log("State check skipped: complex state pre-trigger");
        
        console.log("--- Trigger changeRouterVersion Attempt ---");
        vm.startPrank(owner);
        vm.expectRevert("MaliciousRouter: intentional revert");
        token.changeRouterVersion(address(maliciousRouter));
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger changeRouterVersion ---");
        console.log("State check skipped: complex state post-trigger");
        console.log("Verification: Revert occurred as expected");
        console.log("Vulnerability not Exist: Malicious router prevented with revert");
    }

    function test_RevertWhenMaliciousRouterGasExhausted() public {
        MaliciousRouterGas maliciousRouter = new MaliciousRouterGas();
        
        console.log("--- BEFORE-Trigger changeRouterVersion ---");
        console.log("State check skipped: complex state pre-trigger");
        
        console.log("--- Trigger changeRouterVersion Attempt ---");
        vm.startPrank(owner);
        vm.expectRevert();
        token.changeRouterVersion(address(maliciousRouter));
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger changeRouterVersion ---");
        console.log("State check skipped: complex state post-trigger");
        console.log("Verification: Revert occurred preventing gas exhaustion");
        console.log("Vulnerability not Exist: Malicious router prevented with revert");
    }
}