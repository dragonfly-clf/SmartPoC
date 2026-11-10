// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MCG.sol";

contract MockRouter {
    address constant FACTORY_ADDR = 0x1111111111111111111111111111111111111111;
    address constant WETH_ADDR = 0x2222222222222222222222222222222222222222;
    
    function factory() external pure returns (address) {
        return FACTORY_ADDR;
    }
    
    function WETH() external pure returns (address) {
        return WETH_ADDR;
    }
}

contract MockFactory {
    address constant PAIR_ADDR = 0x3333333333333333333333333333333333333333;

    function createPair(address, address) external pure returns (address) {
        return PAIR_ADDR;
    }
}

contract MockPair {}

contract MockWETH {}

contract FeeManipulationTest is Test {
    MCG public mcg;
    address owner = address(0x1);
    
    function setUp() public {
        // Deploy and set up mock contracts at fixed addresses
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        
        // Etch mocks to fixed addresses
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        vm.etch(address(0x1111111111111111111111111111111111111111), address(mockFactory).code);
        vm.etch(address(0x2222222222222222222222222222222222222222), address(mockWETH).code);
        vm.etch(address(0x3333333333333333333333333333333333333333), address(mockPair).code);

        // Deploy the MCG contract as the owner
        vm.startPrank(owner);
        mcg = new MCG();
        vm.stopPrank();
    }

    function testFeeLimitExceed() public {
        vm.startPrank(owner);
        
        // Fee parameters for test
        uint256 operationsFee = 20;
        uint256 liquidityFee = 20;
        uint256 buyRewards = 50;
        uint256 sellRewards = 50;
        
        // Differential check: get fee values before vulnerability trigger
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 opsFeeBefore = mcg.operationsFees();
        uint256 liqFeeBefore = mcg.liquidityFee();
        uint256 buyRewardBefore = mcg.MCGRewardsBuyFee();
        uint256 sellRewardBefore = mcg.MCGRewardsSellFee();
        console.log("Operations Fee Before: ", opsFeeBefore);
        console.log("Liquidity Fee Before: ", liqFeeBefore);
        console.log("Buy Reward Fee Before: ", buyRewardBefore);
        console.log("Sell Reward Fee Before: ", sellRewardBefore);

        console.log("--- Trigger updateFees ---");
        mcg.updateFees(operationsFee, liquidityFee, buyRewards, sellRewards);

        // Differential check: get fee values after vulnerability trigger
        console.log("--- AFTER-Trigger Fees ---");
        uint256 opsFeeAfter = mcg.operationsFees();
        uint256 liqFeeAfter = mcg.liquidityFee();
        uint256 buyRewardAfter = mcg.MCGRewardsBuyFee();
        uint256 sellRewardAfter = mcg.MCGRewardsSellFee();
        console.log("Operations Fee After: ", opsFeeAfter);
        console.log("Liquidity Fee After: ", liqFeeAfter);
        console.log("Buy Reward Fee After: ", buyRewardAfter);
        console.log("Sell Reward Fee After: ", sellRewardAfter);

        // Compare fee changes and detect vulnerability
        bool feeChanged = 
            (opsFeeAfter != opsFeeBefore) ||
            (liqFeeAfter != liqFeeBefore) ||
            (buyRewardAfter != buyRewardBefore) ||
            (sellRewardAfter != sellRewardBefore);
            
        bool feesExceedLimit = 
            (opsFeeAfter + liqFeeAfter + buyRewardAfter > 25) ||  // Total buy fees should be <= 25%
            (opsFeeAfter + liqFeeAfter + sellRewardAfter > 25);    // Total sell fees should be <= 25%
        
        if (feeChanged && feesExceedLimit) {
            console.log("Vulnerability Exists: Fees were modified to exceed the 25%% total limit");
        } else {
            console.log("Vulnerability not Exist: Fee changes comply with total limit or fees not changed");
        }
        
        vm.stopPrank();
    }
}