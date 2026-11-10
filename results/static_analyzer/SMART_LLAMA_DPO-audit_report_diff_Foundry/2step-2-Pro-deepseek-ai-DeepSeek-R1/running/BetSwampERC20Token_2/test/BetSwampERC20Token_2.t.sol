// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetSwampERC20Token.sol";

contract MockUniswapV2Router {
    address public factory;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract AutomatedMarketMakerPairTest is Test {
    BetSwampERC20Token token;
    address constant MAINNET_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory;
    address testPair = address(0x1234567890123456789012345678901234567891);
    
    function setUp() public {
        // Deploy mock factory
        mockFactory = address(new MockUniswapV2Factory());
        
        // Mock router calls using cheatcodes
        vm.mockCall(
            MAINNET_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            MAINNET_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))
        );
        
        // Deploy the token
        token = new BetSwampERC20Token();
    }

    function testRemovingInitialPairReverts() public {
        address initialPair = token.uniswapV2Pair();
        vm.expectRevert("The pair cannot be removed from automatedMarketMakerPairs");
        token.setAutomatedMarketMakerPair(initialPair, false);
    }

    function testAllowDuplicatePairRegistration() public {
        console.log("--- BEFORE-First Registration ---");
        bool initialState = token.automatedMarketMakerPairs(testPair);
        console.log("TestPair Initial Registration State:", initialState);

        // First registration
        token.setAutomatedMarketMakerPair(testPair, true);
        console.log("--- AFTER-First Registration ---");
        bool stateAfterFirst = token.automatedMarketMakerPairs(testPair);
        console.log("TestPair State After First Registration:", stateAfterFirst);
        assertTrue(stateAfterFirst);

        console.log("--- BEFORE-Trigger: Duplicate Registration ---");
        console.log("Current TestPair State:", stateAfterFirst);

        console.log("--- Trigger: DUPLICATE Registration ---");
        // Duplicate registration call
        token.setAutomatedMarketMakerPair(testPair, true);

        console.log("--- AFTER-Trigger: Duplicate Registration ---");
        bool stateAfterDuplicate = token.automatedMarketMakerPairs(testPair);
        console.log("TestPair State After Duplicate:", stateAfterDuplicate);
        assertTrue(stateAfterDuplicate);

        // Vulnerability verdict - function didn't revert on duplicate
        console.log("Vulnerability Exists: Duplicate registration call accepted without state change or revert");
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
    }
}