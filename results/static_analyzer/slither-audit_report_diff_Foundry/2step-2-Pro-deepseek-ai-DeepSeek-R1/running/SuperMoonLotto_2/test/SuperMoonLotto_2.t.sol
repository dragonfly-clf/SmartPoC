// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperMoonLotto.sol";

// Mock Uniswap components to satisfy SuperMoonLotto dependencies
contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address _factory) {
        factory = _factory;
    }
}

contract SuperMoonLottoWeakPRNGTest is Test {
    SuperMoonLotto lotto1;
    SuperMoonLotto lotto2;
    MockUniswapV2Factory factory;
    MockUniswapV2Router02 router;
    uint256 constant FIXED_TIMESTAMP = 1000000;
    uint256 constant MODULUS = 100;

    function setUp() public {
        // Set up mock Uniswap components
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router02(address(factory));
        
        // Deploy two instances with same parameters
        lotto1 = new SuperMoonLotto(address(router));
        lotto2 = new SuperMoonLotto(address(router));
    }

    function test_drawResultsRepeatableWithSameInputs() public {
        console.log("--- BEFORE-Trigger ---");
        uint drawNo1Initial = lotto1.drawNo();
        uint drawNo2Initial = lotto2.drawNo();
        uint256[] memory initial1 = lotto1.getDrawnNumber();
        uint256[] memory initial2 = lotto2.getDrawnNumber();
        
        console.log("Initial state: Lotto1 DrawNo=%d, NumbersLength=%d", drawNo1Initial, initial1.length);
        console.log("Initial state: Lotto2 DrawNo=%d, NumbersLength=%d", drawNo2Initial, initial2.length);
        
        // Set fixed block timestamp
        vm.warp(FIXED_TIMESTAMP);
        
        console.log("--- Trigger: First Draw (Lotto1) ---");
        lotto1.draw(MODULUS);
        uint256[] memory result1 = lotto1.getDrawnNumber();
        uint newDrawNo1 = lotto1.drawNo();
        console.log("Lotto1 Draw Complete - New DrawNo: %d, Numbers Drawn: %d", newDrawNo1, result1.length);
        
        // Reset to same timestamp for second draw
        vm.warp(FIXED_TIMESTAMP);
        
        console.log("--- Trigger: Second Draw (Lotto2) ---");
        lotto2.draw(MODULUS);
        uint256[] memory result2 = lotto2.getDrawnNumber();
        uint newDrawNo2 = lotto2.drawNo();
        console.log("Lotto2 Draw Complete - New DrawNo: %d, Numbers Drawn: %d", newDrawNo2, result2.length);
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Lotto1 Numbers: %s", arrayToString(result1));
        console.log("Lotto2 Numbers: %s", arrayToString(result2));
        
        console.log("--- Results Comparison ---");
        bool lengthsMatch = result1.length == result2.length;
        bool contentMatch = true;
        
        if (lengthsMatch) {
            for (uint256 i = 0; i < result1.length; i++) {
                if (result1[i] != result2[i]) {
                    contentMatch = false;
                    console.log("Mismatch at index %d: %d vs %d", i, result1[i], result2[i]);
                    break;
                }
            }
        } else {
            contentMatch = false;
            console.log("Array length difference: %d vs %d", result1.length, result2.length);
        }
        
        if (lengthsMatch && contentMatch) {
            console.log("Verdict: Identical results - Weak PRNG vulnerability confirmed");
            console.log("Vulnerability Exists: PRNG is predictable with fixed inputs");
        } else {
            console.log("Verdict: Different results - Weak PRNG not confirmed");
            console.log("Vulnerability not Exist: Draws produce unique numbers");
        }
    }
    
    // Helper to convert uint256[] to string for logging
    function arrayToString(uint256[] memory arr) internal pure returns (string memory) {
        if (arr.length == 0) return "[]";
        
        string memory buffer = "[";
        for (uint256 i = 0; i < arr.length; i++) {
            if (i != 0) buffer = string(abi.encodePacked(buffer, ", "));
            buffer = string(abi.encodePacked(buffer, vm.toString(arr[i])));
        }
        return string(abi.encodePacked(buffer, "]"));
    }
}