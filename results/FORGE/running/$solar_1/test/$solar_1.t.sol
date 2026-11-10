// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SOLIUMRISE.sol";

contract SOLIUMRISEFeeTest is Test {
    SOLIUMRISE token;
    address owner = address(0x1);

    function setUp() public {
        // Mock PancakeSwap router call responses
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        
        // Mock router.facctory() and router.WETH()
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSelector(bytes4(keccak256("factory()"))), 
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))), 
            abi.encode(mockWETH)
        );
        
        // Mock factory.createPair() response
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0x789))
        );

        // Deploy token with mocks in place
        vm.startPrank(owner);
        token = new SOLIUMRISE();
        token.tradingStatus(true);  // Enable trading
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        console.log("=== BEGIN FEE MANIPULATION TEST ===");
        console.log("--- BEFORE-Trigger ---");
        uint256 preTotalFee = token.totalFee();
        uint256 preSellMultiplier = token.sellMultiplier();
        uint256 preLiqFee = token.liquidityFee();
        uint256 preRefFee = token.reflectionFee();
        
        console.log("Initial totalFee:", preTotalFee);
        console.log("Initial sellMultiplier:", preSellMultiplier);
        console.log("Initial liquidityFee:", preLiqFee);
        console.log("Initial reflectionFee:", preRefFee);

        console.log("--- Trigger setFees(49%) + set_sell_multiplier(1000) ---");
        vm.prank(owner);
        token.setFees(10, 10, 10, 10, 5, 4, 100);  // totalFee = 49
        vm.prank(owner);
        token.set_sell_multiplier(1000);

        console.log("--- AFTER-Trigger ---");
        uint256 postTotalFee = token.totalFee();
        uint256 postSellMultiplier = token.sellMultiplier();
        uint256 postLiqFee = token.liquidityFee();
        uint256 postRefFee = token.reflectionFee();
        
        console.log("== STATE CHANGES ==");
        console.log("totalFee:", preTotalFee, "->", postTotalFee);
        console.log("sellMultiplier:", preSellMultiplier, "->", postSellMultiplier);
        console.log("liquidityFee:", preLiqFee, "->", postLiqFee);
        console.log("reflectionFee:", preRefFee, "->", postRefFee);
        console.log("===============================");

        // Vulnerability verification
        if (postTotalFee == 49) {
            console.log("Vulnerability Exists: totalFee set to dangerous level (49%)");
        } else {
            console.log("Vulnerability not Exist: totalFee set to safe level");
        }
    }
    
    function testSetFeesExceeding50Percent() public {
        console.log("\n=== BEGIN FEE LIMIT TEST ===");
        vm.startPrank(owner);
        vm.expectRevert("Fees cannot be more than 50%");
        token.setFees(10, 10, 10, 10, 5, 5, 100); // totalFee = 50 (should revert)
        vm.stopPrank();
        console.log("Test Passed: Reverted when fees exceed 50% as expected");
    }
}