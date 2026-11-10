// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MEGADOGE.sol";

// Declare the missing router interface
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract MEGADOGEFeeTest is Test {
    MEGADOGE public token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant DUMMY_FACTORY = address(0x123);
    address constant DUMMY_WETH = address(0x456);
    address constant DUMMY_PAIR = address(0x789);

    function setUp() public {
        // Mock router address responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router.factory.selector),
            abi.encode(DUMMY_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router.WETH.selector),
            abi.encode(DUMMY_WETH)
        );
        vm.mockCall(
            DUMMY_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(DUMMY_PAIR)
        );

        vm.prank(address(this));
        token = new MEGADOGE();
    }

    function testFeeExceeds25Percent() public {
        console.log("--- BEFORE-Trigger Fee Settings ---");
        uint256 marketingFeeBefore = token.marketingFee();
        uint256 rewardsFeeBefore = token.DOGERewardsFee();
        uint256 totalFeesBefore = token.totalFees();
        console.log("Initial Marketing Fee: ", marketingFeeBefore, "%");
        console.log("Initial Rewards Fee: ", rewardsFeeBefore, "%");
        console.log("Initial Total Fees: ", totalFeesBefore, "%");

        address owner = token.owner();
        vm.startPrank(owner);
        
        console.log("--- Trigger ChangeFee (setMarketingFee(15%) & setDOGERewardsFee(16%) ---");
        token.setMarketingFee(15);
        token.setDOGERewardsFee(16);
        
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee Settings ---");
        uint256 marketingFeeAfter = token.marketingFee();
        uint256 rewardsFeeAfter = token.DOGERewardsFee();
        uint256 totalFeesAfter = token.totalFees();
        console.log("Updated Marketing Fee: ", marketingFeeAfter, "%");
        console.log("Updated Rewards Fee: ", rewardsFeeAfter, "%");
        console.log("Updated Total Fees: ", totalFeesAfter, "%");

        bool vulnerabilityExists = totalFeesAfter > 25;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Total fees can be set above 25%% (now %d%%)", totalFeesAfter);
        } else {
            console.log("Vulnerability not Exist: Fees are capped at or below 25%% (now %d%%)", totalFeesAfter);
        }
    }
}