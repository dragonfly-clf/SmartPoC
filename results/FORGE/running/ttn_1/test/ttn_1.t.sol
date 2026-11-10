// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TRITON.sol";

contract MockRouter {
    address public immutable factory;
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x000000000000000000000000000000000000bEEF);
    }
}

contract TRITONTest is Test {
    TRITON token;
    address owner = address(0xABCD);
    
    // Required for mocking Uniswap contracts
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant FACTORY_ADDRESS = address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    
    function setUp() public {
        // Deploy mock contracts and set their code at required addresses
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(FACTORY_ADDRESS);
        
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(FACTORY_ADDRESS, address(mockFactory).code);
        
        // Deploy the TRITON token
        vm.startPrank(owner);
        token = new TRITON();
        vm.stopPrank();
    }

    function test_feeManipulation() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        // Capture initial fee states
        uint256 preBuyDead = token.buyDeadFees();
        uint256 preBuyNonDead = token.totalBuyFees();
        uint256 preSellDead = token.sellDeadFees();
        uint256 preSellNonDead = token.totalSellFees();
        uint256 preTotalBuyFees = preBuyDead + preBuyNonDead;
        uint256 preTotalSellFees = preSellDead + preSellNonDead;
        
        console.log("Initial Buy Dead Fees: ", preBuyDead);
        console.log("Initial Non-Dead Buy Fees: ", preBuyNonDead);
        console.log("Initial Total Buy Fees: ", preTotalBuyFees);
        console.log("Initial Sell Dead Fees: ", preSellDead);
        console.log("Initial Non-Dead Sell Fees: ", preSellNonDead);
        console.log("Initial Total Sell Fees: ", preTotalSellFees);

        console.log("--- Trigger: updateFees ---");
        // Set fees that would result in:
        // - Non-dead Buy Fees: 21% (allowed by contract)
        // - Dead Buy Fees: 5% (not counted in contract's check)
        // Total Buy Fees: 26% (exceeding safe limit)
        uint256 deadBuy = 5;
        uint256 deadSell = 5;
        uint256 marketingBuy = 0;
        uint256 marketingSell = 0;
        uint256 liquidityBuy = 0;
        uint256 liquiditySell = 0;
        uint256 RewardsBuy = 21;
        uint256 RewardsSell = 21;
        uint256 devBuy = 0;
        uint256 devSell = 0;

        // Execute the vulnerable operation
        vm.startPrank(owner);
        token.updateFees(
            deadBuy,
            deadSell,
            marketingBuy,
            marketingSell,
            liquidityBuy,
            liquiditySell,
            RewardsBuy,
            RewardsSell,
            devBuy,
            devSell
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee State ---");
        // Capture updated fee states
        uint256 postBuyDead = token.buyDeadFees();
        uint256 postBuyNonDead = token.totalBuyFees();
        uint256 postSellDead = token.sellDeadFees();
        uint256 postSellNonDead = token.totalSellFees();
        uint256 postTotalBuyFees = postBuyDead + postBuyNonDead;
        uint256 postTotalSellFees = postSellDead + postSellNonDead;
        
        console.log("Updated Buy Dead Fees: ", postBuyDead);
        console.log("Updated Non-Dead Buy Fees: ", postBuyNonDead);
        console.log("Updated Total Buy Fees: ", postTotalBuyFees);
        console.log("Updated Sell Dead Fees: ", postSellDead);
        console.log("Updated Non-Dead Sell Fees: ", postSellNonDead);
        console.log("Updated Total Sell Fees: ", postTotalSellFees);

        // Vulnerability verification
        bool buyFeesExceeded = postTotalBuyFees > 25;
        bool sellFeesExceeded = postTotalSellFees > 25;
        bool vulnerabilityExists = buyFeesExceeded && sellFeesExceeded;
        
        console.log("Validation:");
        console.log("Buy fees >25%%: %s", buyFeesExceeded ? "YES" : "NO");
        console.log("Sell fees >25%%: %s", sellFeesExceeded ? "YES" : "NO");
        console.log("---");

        // Final exploit verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Combined dead+non-dead fees exceed 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fees remain within safety limits");
        }

        // Test assertions (using actual contract state)
        assertGt(postTotalBuyFees, 25, "Combined buy fees should exceed 25%");
        assertGt(postTotalSellFees, 25, "Combined sell fees should exceed 25%");
    }
}