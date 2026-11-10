// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONTICKER.sol";

contract ELONTICKER_ExcessiveSellFeeTest is Test {
    ELONTICKER token;
    address owner = address(0x1);
    
    // Uniswap constants
    address constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0x1234);
    address mockWETH = address(0x5678);
    address mockPair = address(0x9abc);

    function setUp() public {
        // Mock Uniswap setup
        vm.mockCall(
            UNISWAP_ROUTER_ADDRESS,
            abi.encodePacked(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            UNISWAP_ROUTER_ADDRESS,
            abi.encodePacked(bytes4(keccak256("WETH()"))),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodePacked(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new ELONTICKER();
        vm.stopPrank();
    }

    function test_OwnerCanSetExcessiveSellFee() public {
        uint256 MAX_BASE_FEE = 25;   // Maximum allowed base fee %
        uint256 EXCESSIVE_FEE = 10;   // Additional sell fee to exceed limit
        
        // Set base fees to maximum allowed value (25%)
        vm.startPrank(owner);
        token.setLiquidityFee(10);       // 10%
        token.setmarketingFee(10);       // +10%
        token.setrewardFees(5);          // +5% = 25% total
        vm.stopPrank();
        
        // Pre-trigger: Query state before setting extra sell fee
        console.log("--- BEFORE-Trigger State ---");
        uint256 preExtra = token.extraSellFee();
        uint256 preBaseFees = token.liquidityFee() + token.marketingFee() + token.rewardFees();
        uint256 preTotalFees = preBaseFees + preExtra;
        console.log("Extra fee (BEFORE):", preExtra, "%");
        console.log("Base fees (BEFORE):", preBaseFees, "%");
        console.log("Total fees (BEFORE):", preTotalFees, "%");
        
        console.log("--- Trigger: setExtraSellFee(10) ---");
        vm.prank(owner);
        token.setExtraSellFee(EXCESSIVE_FEE);
        
        // Post-trigger: Query state after setting extra sell fee
        console.log("--- AFTER-Trigger State ---");
        uint256 postExtra = token.extraSellFee();
        uint256 postBaseFees = token.liquidityFee() + token.marketingFee() + token.rewardFees();
        uint256 postTotalFees = postBaseFees + postExtra;
        console.log("Extra fee (AFTER):", postExtra, "%");
        console.log("Base fees (AFTER):", postBaseFees, "%");
        console.log("Total fees (AFTER):", postTotalFees, "%");
        
        // Verify fees were set
        assertEq(token.extraSellFee(), EXCESSIVE_FEE, "Extra sell fee not set");
        assertEq(postBaseFees, MAX_BASE_FEE, "Base fees not set correctly");
        assertTrue(postTotalFees > MAX_BASE_FEE, "Total sell fee within limit");
        
        // Final vulnerability verdict
        if (postTotalFees > MAX_BASE_FEE) {
            console.log("Vulnerability Exists: Owner can set fees exceeding 25%% limit (%s%%)", postTotalFees);
        } else {
            console.log("Vulnerability not Exist: Total fees (%s%%) remain below 25%%", postTotalFees);
        }
    }
}