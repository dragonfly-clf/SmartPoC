// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract EthRejector {
    fallback() external payable {
        revert("ETH not accepted");
    }
}

contract TokenSenderTest is Test {
    TokenSender tokenSender;
    address owner = address(0x1);
    address attacker = address(0x2);
    address mockToken = address(0x3);
    
    function setUp() public {
        vm.prank(owner);
        tokenSender = new TokenSender(mockToken);
    }

    function testUncheckedCallVulnerability() public {
        // Deploy a contract that will reject ETH transfers
        EthRejector rejector = new EthRejector();
        
        // Send some ETH to the TokenSender contract first
        vm.deal(address(tokenSender), 1 ether);
        
        // Query initial balances
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialTokenSenderBalance = address(tokenSender).balance;
        uint256 initialRejectorBalance = address(rejector).balance;
        console2.log("TokenSender.balance =", initialTokenSenderBalance);
        console2.log("EthRejector.balance =", initialRejectorBalance);
        
        console2.log("--- Trigger Execute ---");
        bytes memory data = abi.encodeWithSignature("fakeFunction()");
        vm.prank(owner);
        tokenSender.execute(address(rejector), 0.5 ether, data);
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalTokenSenderBalance = address(tokenSender).balance;
        uint256 finalRejectorBalance = address(rejector).balance;
        console2.log("TokenSender.balance =", finalTokenSenderBalance);
        console2.log("EthRejector.balance =", finalRejectorBalance);
        
        console2.log("--- Differential Result ---");
        if (finalTokenSenderBalance == initialTokenSenderBalance && 
            finalRejectorBalance == initialRejectorBalance) {
            console2.log("State unchanged: Call succeeded without ETH transfer occurring");
            console2.log("Verdict: Vulnerability Exists: Call fails without revert or state change");
            console2.log("Vulnerability Exists: execute() does not revert on failed external call");
        } else {
            console2.log("State changed: ETH balance updated - call succeeded");
            console2.log("Verdict: Vulnerability not Exist: Expected behavior for successful execution");
            console2.log("Vulnerability not Exist: ETH transferred successfully");
        }
    }
    
    function testSuccessfulCall() public {
        // Send some ETH to the TokenSender contract first
        vm.deal(address(tokenSender), 1 ether);
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialTokenSenderBalance = address(tokenSender).balance;
        address payable receiver = payable(address(0x4));
        uint256 initialReceiverBalance = receiver.balance;
        console2.log("TokenSender.balance =", initialTokenSenderBalance);
        console2.log("Receiver.balance =", initialReceiverBalance);
        
        console2.log("--- Trigger Execute ---");
        bytes memory data = abi.encodeWithSignature("fakeFunction()");
        vm.prank(owner);
        tokenSender.execute(receiver, 0.5 ether, data);
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalTokenSenderBalance = address(tokenSender).balance;
        uint256 finalReceiverBalance = receiver.balance;
        console2.log("TokenSender.balance =", finalTokenSenderBalance);
        console2.log("Receiver.balance =", finalReceiverBalance);
        
        console2.log("--- Differential Result ---");
        if (finalReceiverBalance == initialReceiverBalance + 0.5 ether && 
            finalTokenSenderBalance == initialTokenSenderBalance - 0.5 ether) {
            console2.log("Verdict: Vulnerability not Exist: ETH transferred successfully");
            console2.log("Vulnerability not Exist: Valid ETH transfer occurred");
        } else {
            console2.log("Verdict: Vulnerability exists: ETH transfer failed unexpectedly");
            console2.log("Vulnerability Exists: ETH not transferred when call should succeed");
        }

        // Original assertions remain
        assertEq(finalTokenSenderBalance, initialTokenSenderBalance - 0.5 ether, "ETH balance should be reduced after successful transfer");
        assertEq(receiver.balance, 0.5 ether, "Receiver should have received ETH");
    }
}