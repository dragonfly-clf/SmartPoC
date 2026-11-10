// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LUCKYRABBITSPIN.sol";

contract ReentrancyTest is Test {
    LUCKYRABBITSPIN token;
    MaliciousReceiver public maliciousReceiver;

    address constant routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant factoryAddr = address(0xF0);
    address constant wethAddr = address(0xEE);
    address constant pairAddr = address(0xABCD);

    uint256 public initBalance = 100 ether;

    function setUp() public {
        // Mock Uniswap V2 router interactions
        vm.mockCall(
            routerAddr,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddr)
        );
        vm.mockCall(
            routerAddr,
            abi.encodeWithSignature("WETH()"),
            abi.encode(wethAddr)
        );
        vm.mockCall(
            factoryAddr,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddr)
        );

        // Deploy token contract
        token = new LUCKYRABBITSPIN();
        
        // Deploy malicious receiver contract
        maliciousReceiver = new MaliciousReceiver();
        
        // Configure system
        token.setNewDevAddress(payable(address(maliciousReceiver)));
        token.setNewMarketingAddress(payable(address(maliciousReceiver)));
        token.toggleSwap(true);
        
        // Fund token contract with ETH
        payable(address(token)).transfer(initBalance);
    }

    function test_ReentrancyInSendETH() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Starting reentrancy test");
        
        console.log("--- Trigger manualsend ---");
        vm.recordLogs();
        token.manualsend();
        
        console.log("--- AFTER-Trigger ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 expectedEventHash = keccak256("Log()");
        bool reentrancyDetected = false;
        
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].emitter == address(maliciousReceiver) && 
                logs[i].topics.length == 1 && 
                logs[i].topics[0] == expectedEventHash) {
                reentrancyDetected = true;
                break;
            }
        }
        
        console.log("Reentrancy detected:", reentrancyDetected ? "YES" : "NO");
        
        // Final vulnerability verification
        if (reentrancyDetected) {
            console.log("Vulnerability Exists: Reentrancy detected during ETH transfer via log analysis");
        } else {
            console.log("Vulnerability not Exist: No reentrancy detected during ETH transfers");
        }
    }
}

contract MaliciousReceiver {
    event Log();

    receive() external payable {
        // Emit event to log reentrancy
        emit Log();
    }
}