// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }

    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract xenoXFeeManipulationTest is Test {
    xenoX public token;
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant FACTORY_ADDRESS = 0x1111111111111111111111111111111111111111;

    function setUp() public {
        // Deploy mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Set up mock router and factory at predefined addresses
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(FACTORY_ADDRESS, address(mockFactory).code);
        
        // Deploy the token contract
        token = new xenoX();
    }

    function testSellDevFeeCanExceedLimit() public {
        console.log("--- BEFORE-Trigger getSellFee ---");
        uint256 beforeFee = token.getSellFee();
        console.log("Original dev fee:", beforeFee, "% (expected safe limit <= 10%)");

        console.log("--- Trigger setSelldevFeePercent(30) ---");
        // Attempt to set dev fee to excessive 30%
        uint256 excessiveFee = 30;
        token.setSelldevFeePercent(excessiveFee);

        console.log("--- AFTER-Trigger getSellFee ---");
        uint256 afterFee = token.getSellFee();
        console.log("Updated dev fee:", afterFee, "%");

        // Final vulnerability verdict
        if (afterFee == excessiveFee) {
            console.log("Vulnerability Exists: Fee control bypassed (set to 30%)");
        } else {
            console.log("Vulnerability not Exist: Fee remains within safe limit");
        }
    }
}