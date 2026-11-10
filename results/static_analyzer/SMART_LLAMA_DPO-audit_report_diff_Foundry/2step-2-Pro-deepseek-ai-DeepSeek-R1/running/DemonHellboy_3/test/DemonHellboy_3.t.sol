// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0);
    }

    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract DemonHellboyTest is Test {
    DemonHellboy private token;
    address private constant owner = address(0x1234);
    address private constant testAddress = address(0x5678);
    uint256 private constant testFee = 1;
    bool private constant testEnable = true;

    function setUp() public {
        // Mock Uniswap router calls
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0))
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0))
        );

        // Mock factory createPair
        vm.mockCall(
            address(0),
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(0))
        );

        // Deploy token
        vm.startPrank(owner);
        token = new DemonHellboy();
        vm.stopPrank();
    }

    function test_SetLiquidityFeePercent_NoEvent() public {
        vm.prank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-trigger state needed for event check");
        
        console.log("--- Trigger setLiquidityFeePercent ---");
        vm.recordLogs();
        token.setLiquidityFeePercent(testFee);
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (entries.length == 0) {
            console.log("Vulnerability Exists: No event emitted");
        } else {
            console.log("Vulnerability not Exist: Event emitted");
        }
        
        assertEq(entries.length, 0, "Event emitted for setLiquidityFeePercent");
    }

    function test_SetTaxFeePercent_NoEvent() public {
        vm.prank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-trigger state needed for event check");
        
        console.log("--- Trigger setTaxFeePercent ---");
        vm.recordLogs();
        token.setTaxFeePercent(testFee);
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (entries.length == 0) {
            console.log("Vulnerability Exists: No event emitted");
        } else {
            console.log("Vulnerability not Exist: Event emitted");
        }
        
        assertEq(entries.length, 0, "Event emitted for setTaxFeePercent");
    }

    function test_SetAddressFee_NoEvent() public {
        vm.prank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-trigger state needed for event check");
        
        console.log("--- Trigger setAddressFee ---");
        vm.recordLogs();
        token.setAddressFee(testAddress, testEnable, testFee, testFee);
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (entries.length == 0) {
            console.log("Vulnerability Exists: No event emitted");
        } else {
            console.log("Vulnerability not Exist: Event emitted");
        }
        
        assertEq(entries.length, 0, "Event emitted for setAddressFee");
    }

    function test_SetBuyAddressFee_NoEvent() public {
        vm.prank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-trigger state needed for event check");
        
        console.log("--- Trigger setBuyAddressFee ---");
        vm.recordLogs();
        token.setBuyAddressFee(testAddress, testEnable, testFee, testFee);
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (entries.length == 0) {
            console.log("Vulnerability Exists: No event emitted");
        } else {
            console.log("Vulnerability not Exist: Event emitted");
        }
        
        assertEq(entries.length, 0, "Event emitted for setBuyAddressFee");
    }

    function test_SetSellAddressFee_NoEvent() public {
        vm.prank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("No pre-trigger state needed for event check");
        
        console.log("--- Trigger setSellAddressFee ---");
        vm.recordLogs();
        token.setSellAddressFee(testAddress, testEnable, testFee, testFee);
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        if (entries.length == 0) {
            console.log("Vulnerability Exists: No event emitted");
        } else {
            console.log("Vulnerability not Exist: Event emitted");
        }
        
        assertEq(entries.length, 0, "Event emitted for setSellAddressFee");
    }
}