// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperMoonLotto.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0); // Mock return value
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;

    constructor() {
        factory = address(new MockUniswapV2Factory());
        WETH = address(0xdead); // Mock WETH address
    }
}

contract TestWeakPRNG is Test {
    SuperMoonLotto lottery1;
    SuperMoonLotto lottery2;
    MockUniswapV2Router02 mockRouter;
    
    address alice = makeAddr("alice");
    uint constant TEST_TIMESTAMP = 1641070800;
    uint constant modulus = 49;

    function setUp() public {
        vm.warp(TEST_TIMESTAMP);
        
        // Deploy mock router and lottery contracts
        mockRouter = new MockUniswapV2Router02();
        lottery1 = new SuperMoonLotto(address(mockRouter));
        lottery2 = new SuperMoonLotto(address(mockRouter));
    }

    function testPRNGVulnerability() public {
        console.log("--- BEFORE-Trigger PRNG Draw ---");
        console.log("Conditions: Timestamp=%s, Modulus=%s", TEST_TIMESTAMP, modulus);
        console.log("Both lotteries initialized but no draws executed");
        
        console.log("--- Trigger PRNG Draw 1 ---");
        vm.warp(TEST_TIMESTAMP + 1);
        vm.prank(alice);
        lottery1.draw(modulus);
        uint moonSpecialNumber1 = lottery1.getDrawnNumber()[5]; // 6th element
        console.log("First draw moonSpecialNumber:", moonSpecialNumber1);
        
        console.log("--- Trigger PRNG Draw 2 ---");
        vm.warp(TEST_TIMESTAMP + 1); 
        vm.prank(alice);
        lottery2.draw(modulus);
        uint moonSpecialNumber2 = lottery2.getDrawnNumber()[5]; // 6th element
        console.log("Second draw moonSpecialNumber:", moonSpecialNumber2);
        
        console.log("--- AFTER-Trigger Comparison ---");
        console.log("Results: Draw1=%s vs Draw2=%s", moonSpecialNumber1, moonSpecialNumber2);
        
        // Vulnerability verdict logic
        if (moonSpecialNumber1 == moonSpecialNumber2) {
            console.log("Vulnerability Exists: Weak PRNG produces identical output under identical conditions");
        } else {
            console.log("Vulnerability not Exist: PRNG produces different outputs under identical conditions");
        }
    }
}