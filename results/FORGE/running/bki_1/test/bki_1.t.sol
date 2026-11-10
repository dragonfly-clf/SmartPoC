// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyKabosuInu.sol";

contract MockRouterFactory is Test {
    MockFactory public factory;
    
    constructor() {
        factory = new MockFactory();
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc);
    }
}

contract MockRouter {
    address private immutable _factory;
    
    constructor() {
        _factory = address(new MockFactory());
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract BabyKabosuInuTest is Test {
    BabyKabosuInu token;
    address owner = address(0x1);
    
    // Fee storage structure to reduce stack usage
    struct FeeValues {
        uint256 ecosystem;
        uint256 marketing;
        uint256 reward;
        uint256 liquidity;
        uint256 tax;
    }

    function setUp() public {
        // Setup mocked PancakeSwap router
        MockRouter mockRouter = new MockRouter();
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(router, address(mockRouter).code);
        
        vm.startPrank(owner);
        token = new BabyKabosuInu();
        vm.stopPrank();
    }
    
    function testSetSellFeeAboveLimit() public {
        uint256 ecosystemFee = 8;
        uint256 marketingFee = 6;
        uint256 rewardFee = 7;
        uint256 liquidityFee = 5;
        uint256 taxFee = 5;
        uint256 totalFee = ecosystemFee + marketingFee + rewardFee + liquidityFee + taxFee;
        assertGt(totalFee, 25, "Test fee values must exceed 25%");
        
        console.log("--- BEFORE-Trigger Fee Values ---");
        FeeValues memory preFees;
        preFees.ecosystem = token._ecosystemFee();
        preFees.marketing = token._SellmarketingFee();
        preFees.reward = token._rewardFee();
        preFees.liquidity = token._SelllLiquidityFee();
        preFees.tax = token._SelltaxFee();
        
        console.log("Before Ecosystem Fee:", preFees.ecosystem);
        console.log("Before Marketing Fee:", preFees.marketing);
        console.log("Before Reward Fee:", preFees.reward);
        console.log("Before Liquidity Fee:", preFees.liquidity);
        console.log("Before Tax Fee:", preFees.tax);

        console.log("--- Trigger SetSellFee ---");
        vm.prank(owner);
        token.setSellFee(ecosystemFee, marketingFee, rewardFee, liquidityFee, taxFee);
        
        console.log("--- AFTER-Trigger Fee Values ---");
        FeeValues memory postFees;
        postFees.ecosystem = token._ecosystemFee();
        postFees.marketing = token._SellmarketingFee();
        postFees.reward = token._rewardFee();
        postFees.liquidity = token._SelllLiquidityFee();
        postFees.tax = token._SelltaxFee();
        
        console.log("After Ecosystem Fee:", postFees.ecosystem);
        console.log("After Marketing Fee:", postFees.marketing);
        console.log("After Reward Fee:", postFees.reward);
        console.log("After Liquidity Fee:", postFees.liquidity);
        console.log("After Tax Fee:", postFees.tax);
        
        // Check each fee individually
        bool ecosystemChanged = postFees.ecosystem == ecosystemFee;
        bool marketingChanged = postFees.marketing == marketingFee;
        bool rewardChanged = postFees.reward == rewardFee;
        bool liquidityChanged = postFees.liquidity == liquidityFee;
        bool taxChanged = postFees.tax == taxFee;
        
        console.log("Ecosystem Changed:", ecosystemChanged ? "YES" : "NO");
        console.log("Marketing Changed:", marketingChanged ? "YES" : "NO");
        console.log("Reward Changed:", rewardChanged ? "YES" : "NO");
        console.log("Liquidity Changed:", liquidityChanged ? "YES" : "NO");
        console.log("Tax Changed:", taxChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (ecosystemChanged && marketingChanged && rewardChanged && liquidityChanged && taxChanged) {
            console.log("Vulnerability Exists: Owner can successfully set sell fees above 25%");
        } else {
            console.log("Vulnerability not Exist: Fee restrictions were enforced as expected");
        }
    }
}