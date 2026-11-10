// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FLOV.sol";

contract FLOVFeeManipulationTest is Test {
    FLOV public token;
    address owner = address(0x1);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xDEAD);
    address constant MOCK_WETH = address(0xC02);
    address constant MOCK_PAIR = address(0x123);

    function setUp() public {
        // Mock Router - factory returns MOCK_FACTORY
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock Router - WETH returns MOCK_WETH
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(MOCK_WETH)
        );
        
        // Mock Factory - any createPair call returns MOCK_PAIR
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(MOCK_PAIR)
        );

        // Deploy token contract (will automatically use our mocks)
        vm.startPrank(owner);
        token = new FLOV();
        vm.stopPrank();
    }
    
    function testMarketingFeeCanExceed25Percent() public {
        vm.startPrank(owner);
        
        emit log("--- BEFORE-Trigger State ---");
        uint256 initialMarketingFee = token.marketingFee();
        uint256 initialTotalFees = token.totalFees();
        emit log_named_uint("marketingFee (pre-trigger)", initialMarketingFee);
        emit log_named_uint("totalFees (pre-trigger)", initialTotalFees);
        
        uint256 excessiveFee = 26;
        emit log("--- Trigger Operation: token.setMarketingFee(26) ---");
        token.setMarketingFee(excessiveFee);
        
        emit log("--- AFTER-Trigger State ---");
        uint256 newMarketingFee = token.marketingFee();
        uint256 newTotalFees = token.totalFees();
        emit log_named_uint("marketingFee (post-trigger)", newMarketingFee);
        emit log_named_uint("totalFees (post-trigger)", newTotalFees);
        
        assertEq(
            newMarketingFee,
            excessiveFee,
            "Marketing fee set beyond 25% limit"
        );
        
        // Final vulnerability verification
        if (newMarketingFee > 25) {
            emit log("Vulnerability Exists: Marketing fee set beyond 25% limit (26%)");
        } else {
            emit log("Vulnerability not Exist: Marketing fee within 25% safety limit");
        }
        
        vm.stopPrank();
    }
    
    function testTotalFeesIncludeExcessiveMarketingFee() public {
        vm.startPrank(owner);
        
        emit log("--- BEFORE-Trigger State ---");
        uint256 initialMarketingFee = token.marketingFee();
        uint256 initialTotalFees = token.totalFees();
        emit log_named_uint("marketingFee (pre-trigger)", initialMarketingFee);
        emit log_named_uint("totalFees (pre-trigger)", initialTotalFees);
        
        uint256 dangerousFee = 40;
        emit log("--- Trigger Operation: token.setMarketingFee(40) ---");
        token.setMarketingFee(dangerousFee);
        
        emit log("--- AFTER-Trigger State ---");
        uint256 newMarketingFee = token.marketingFee();
        uint256 newTotalFees = token.totalFees();
        emit log_named_uint("marketingFee (post-trigger)", newMarketingFee);
        emit log_named_uint("totalFees (post-trigger)", newTotalFees);
        
        uint256 initialBusdFee = token.BUSDRewardsFee();
        uint256 initialLiquidityFee = token.liquidityFee();
        uint256 calculatedTotal = initialBusdFee + initialLiquidityFee + dangerousFee;
        uint256 actualTotal = token.totalFees();
        
        assertEq(
            actualTotal,
            calculatedTotal,
            "Total fees include the dangerous marketing fee"
        );
        
        // Final vulnerability verification
        if (newMarketingFee > 25) {
            emit log("Vulnerability Exists: Marketing fee set beyond 25% limit (40%)");
        } else {
            emit log("Vulnerability not Exist: Marketing fee within 25% safety limit");
        }
        
        vm.stopPrank();
    }
}