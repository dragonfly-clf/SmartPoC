// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

// Mock contract for UniswapV2Factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1); // Return dummy pair address
    }
}

// Mock contract for UniswapV2Router
contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract CoinTokenPrivilegeTest is Test {
    CoinToken token;
    MockFactory mockFactory;
    MockRouter mockRouter;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock Uniswap components
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), WETH_ADDRESS);
        
        // Deploy CoinToken with valid router address
        token = new CoinToken(
            "TestToken", 
            "TT", 
            18, 
            1000000,                // _supply
            0,                      // _txFee
            0,                      // _lpFee
            0,                      // _DexFee
            address(mockRouter),    // Working router address
            address(0),             // feeaddress
            owner,                  // tokenOwner
            address(0)              // service
        );
        vm.stopPrank();
    }

    function test_owner_can_change_router_without_restrictions() public {
        // Deploy new router setup
        MockFactory newMockFactory = new MockFactory();
        MockRouter newMockRouter = new MockRouter(address(newMockFactory), WETH_ADDRESS);
        
        // Pre-trigger state
        console.log("--- BEFORE-Trigger State ---");
        address oldRouter = address(token.uniswapV2Router()); // Fixed: Explicit conversion
        uint256 oldLiquidityThreshold = token.numTokensSellToAddToLiquidity();
        console.log("Old Router Address:", oldRouter);
        console.log("Old Liquidity Threshold:", oldLiquidityThreshold);
        
        // Trigger router change
        console.log("--- Trigger Change: setRouterAddress(newAddress) ---");
        vm.prank(owner);
        token.setRouterAddress(address(newMockRouter));
        
        // Post-trigger state
        console.log("--- AFTER-Trigger State ---");
        address newRouter = address(token.uniswapV2Router()); // Fixed: Explicit conversion
        uint256 newLiquidityThreshold = token.numTokensSellToAddToLiquidity();
        console.log("New Router Address:", newRouter);
        console.log("New Liquidity Threshold:", newLiquidityThreshold);
        
        // Verification
        bool routerChanged = (oldRouter != newRouter);
        bool thresholdUnchanged = (oldLiquidityThreshold == newLiquidityThreshold);
        console.log("Router changed:", routerChanged ? "YES" : "NO");
        console.log("Liquidity threshold unchanged:", thresholdUnchanged ? "YES" : "NO");
        
        // Final verdict
        if (routerChanged) {
            console.log("Vulnerability confirmed: Router address changed arbitrarily");
        } else {
            console.log("Vulnerability not Exist: Router address was not changed");
        }
    }

    function test_owner_can_set_arbitrary_liquidity_threshold() public {
        // Pre-trigger state
        console.log("--- BEFORE-Trigger State ---");
        address oldRouter = address(token.uniswapV2Router()); // Fixed: Explicit conversion
        uint256 oldLiquidityThreshold = token.numTokensSellToAddToLiquidity();
        console.log("Old Router Address:", oldRouter);
        console.log("Old Liquidity Threshold:", oldLiquidityThreshold);
        
        // Trigger threshold modification
        console.log("--- Trigger Change: setNumTokensSellToAddToLiquidity(max) ---");
        vm.prank(owner);
        token.setNumTokensSellToAddToLiquidity(type(uint256).max);
        
        // Post-trigger state
        console.log("--- AFTER-Trigger State ---");
        address newRouter = address(token.uniswapV2Router()); // Fixed: Explicit conversion
        uint256 newLiquidityThreshold = token.numTokensSellToAddToLiquidity();
        console.log("New Router Address:", newRouter);
        console.log("New Liquidity Threshold:", newLiquidityThreshold);
        
        // Verification
        bool thresholdChanged = (oldLiquidityThreshold != newLiquidityThreshold);
        bool routerUnchanged = (oldRouter == newRouter);
        console.log("Liquidity threshold changed:", thresholdChanged ? "YES" : "NO");
        console.log("Router unchanged:", routerUnchanged ? "YES" : "NO");
        
        // Final verdict
        if (thresholdChanged && newLiquidityThreshold == type(uint256).max) {
            console.log("Vulnerability confirmed: Liquidity threshold set to max value arbitrarily");
        } else {
            console.log("Vulnerability not Exist: Liquidity threshold change failed");
        }
    }

    function test_non_owner_cannot_change_router() public {
        address arbitraryRouter = address(0xdead);
        
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setRouterAddress(arbitraryRouter);
    }

    function test_non_owner_cannot_change_liquidity_threshold() public {
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setNumTokensSellToAddToLiquidity(100);
    }
}