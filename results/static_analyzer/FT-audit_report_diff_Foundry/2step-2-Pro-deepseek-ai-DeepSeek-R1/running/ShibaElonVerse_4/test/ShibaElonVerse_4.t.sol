// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaElonVerse.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory) {
        factory = _factory;
        WETH = address(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    }
}

contract ShibaElonVerseTest is Test {
    ShibaElonVerse public token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint16 constant MAX_ALLOWED_FEE = 250; // 25% in basis points

    function setUp() public {
        // Deploy mock factory and router
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router02 mockRouter = new MockUniswapV2Router02(address(mockFactory));
        
        // Mock router at the contract's hardcoded address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        token = new ShibaElonVerse();
    }

    function test_FeeManipulationOverLimit() public {
        console2.log("--- BEFORE-Trigger FeeState ---");
        // Query initial buy fee state
        (uint16 initialRewardBuy, uint16 initialMarketingBuy, ) = token.buyFee();
        uint16 initialTotalBuy = initialRewardBuy + initialMarketingBuy;
        console2.log("Initial buy fees | reward: %s, marketing: %s, total: %s", 
                    initialRewardBuy, initialMarketingBuy, initialTotalBuy);
        
        // Query initial sell fee state
        (uint16 initialRewardSell, uint16 initialMarketingSell, ) = token.sellFee();
        uint16 initialTotalSell = initialRewardSell + initialMarketingSell;
        console2.log("Initial sell fees | reward: %s, marketing: %s, total: %s", 
                    initialRewardSell, initialMarketingSell, initialTotalSell);

        console2.log("--- Trigger FeeChange (setBuyFees and setSellFees) ---");
        // Attempt to set fees over limit (buy: 26%, sell: 30%)
        token.setBuyFees(130, 130, 0); 
        token.setSellFees(150, 150, 0);

        console2.log("--- AFTER-Trigger FeeState ---");
        // Query new buy fee state
        (uint16 newRewardBuy, uint16 newMarketingBuy, ) = token.buyFee();
        uint16 newTotalBuy = newRewardBuy + newMarketingBuy;
        console2.log("New buy fees | reward: %s, marketing: %s, total: %s", 
                    newRewardBuy, newMarketingBuy, newTotalBuy);
        
        // Query new sell fee state
        (uint16 newRewardSell, uint16 newMarketingSell, ) = token.sellFee();
        uint16 newTotalSell = newRewardSell + newMarketingSell;
        console2.log("New sell fees | reward: %s, marketing: %s, total: %s", 
                    newRewardSell, newMarketingSell, newTotalSell);

        // Compare state changes and determine vulnerability existence
        bool buyFeeExceeded = newTotalBuy > MAX_ALLOWED_FEE;
        bool sellFeeExceeded = newTotalSell > MAX_ALLOWED_FEE;
        
        console2.log("--- State Change Evaluation ---");
        console2.log("Buy fee violation: %s | Sell fee violation: %s", 
                    buyFeeExceeded ? "YES" : "NO",
                    sellFeeExceeded ? "YES" : "NO");

        // Final vulnerability verdict
        if (buyFeeExceeded || sellFeeExceeded) {
            console2.log("Vulnerability Exists: Fees successfully set above 25%% limit (%s/%s)", 
                        MAX_ALLOWED_FEE, newTotalBuy > newTotalSell ? newTotalBuy : newTotalSell);
        } else {
            console2.log("Vulnerability not Exist: All fees were set within 25%% limit");
        }
    }
}