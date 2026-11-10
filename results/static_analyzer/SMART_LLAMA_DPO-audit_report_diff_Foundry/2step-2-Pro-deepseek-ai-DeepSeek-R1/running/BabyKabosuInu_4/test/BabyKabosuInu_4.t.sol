// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyKabosuInu.sol";

contract MinimalRouter {
    function factory() external pure returns (address) {
        return address(0x6789);
    }
    function WETH() external pure returns (address) {
        return address(0x678a);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xabc);
    }
}

contract BabyKabosuInuTest is Test {
    BabyKabosuInu public token;
    address owner = address(0x1);

    function setUp() public {
        MinimalRouter minimalRouter = new MinimalRouter();
        MockFactory mockFactory = new MockFactory();
        
        vm.etch(
            0x10ED43C718714eb63d5aA57B78B54704E256024E, 
            address(minimalRouter).code
        );
        vm.etch(address(0x6789), address(mockFactory).code);
        
        vm.startPrank(owner);
        token = new BabyKabosuInu();
        vm.stopPrank();
    }

    function testSetBuyFeeArbitrarily() public {
        uint256 highFee = 100;
        
        console.log("--- BEFORE-Trigger (Buy Fee) ---");
        uint256 initialBuyFee = token._taxFee();
        console.log("Initial buy fee:", initialBuyFee);

        console.log("--- Trigger setBuyFee(0,0,0,0,100) ---");
        vm.prank(owner);
        token.setBuyFee(0, 0, 0, 0, highFee);

        console.log("--- AFTER-Trigger (Buy Fee) ---");
        uint256 updatedBuyFee = token._taxFee();
        console.log("Updated buy fee:", updatedBuyFee);
        assertEq(updatedBuyFee, highFee);

        // Vulnerability verification
        if (updatedBuyFee == highFee) {
            console.log("Vulnerability Exists: Owner can set buy fee to arbitrary value (100%)");
        } else {
            console.log("Vulnerability not Exist: Buy fee was not set to 100%");
        }
    }

    function testSetSellFeeArbitrarily() public {
        uint256 highFee = 100;
        
        console.log("--- BEFORE-Trigger (Sell Fee) ---");
        uint256 initialSellFee = token._SelltaxFee();
        console.log("Initial sell fee:", initialSellFee);

        console.log("--- Trigger setSellFee(0,0,0,0,100) ---");
        vm.prank(owner);
        token.setSellFee(0, 0, 0, 0, highFee);

        console.log("--- AFTER-Trigger (Sell Fee) ---");
        uint256 updatedSellFee = token._SelltaxFee();
        console.log("Updated sell fee:", updatedSellFee);
        assertEq(updatedSellFee, highFee);

        // Vulnerability verification
        if (updatedSellFee == highFee) {
            console.log("Vulnerability Exists: Owner can set sell fee to arbitrary value (100%)");
        } else {
            console.log("Vulnerability not Exist: Sell fee was not set to 100%");
        }
    }
}