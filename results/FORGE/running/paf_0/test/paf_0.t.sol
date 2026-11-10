// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PAFDAO.sol";

contract PAFDAO_FeeManipulationTest is Test {
    PAFDAO token;
    address owner = address(0xABCD);
    address nonOwner = address(0x1234);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        
        // Set up mock router responses
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0xFAC70))
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xDEAD))
        );
        
        // Set up mock factory responses
        vm.mockCall(
            address(0xFAC70),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x1111))
        );
        
        // Deploy token - router calls will use our mocks
        token = new PAFDAO();
        
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        vm.startPrank(owner);
        
        // BEFORE - Query initial fee value
        console.log("--- BEFORE-Trigger CharityFee ---");
        uint256 initialMarketingFee = token._marketingFee();
        console.log("Initial Marketing/Charity Fee Percentage:", initialMarketingFee);
        
        // Trigger - Set fee to unreasonably high value (100%)
        console.log("--- Trigger setChartityFeePercent(100) ---");
        token.setChartityFeePercent(100);
        
        // AFTER - Query updated fee value
        console.log("--- AFTER-Trigger CharityFee ---");
        uint256 updatedMarketingFee = token._marketingFee();
        console.log("Updated Marketing/Charity Fee Percentage:", updatedMarketingFee);
        
        // Vulnerability verdict
        if (updatedMarketingFee == 100) {
            console.log("Vulnerability Exists: Unauthorized 100% fee change allowed");
        } else {
            console.log("Vulnerability not Exist: Fee remained unchanged at %s", initialMarketingFee);
        }
        
        vm.stopPrank();
    }

    function test_NonOwnerCannotManipulateFees() public {
        vm.startPrank(nonOwner);
        
        // Should revert since non-owner tries to set fee
        vm.expectRevert("Ownable: caller is not the owner");
        token.setChartityFeePercent(100);
        
        vm.stopPrank();
    }
}