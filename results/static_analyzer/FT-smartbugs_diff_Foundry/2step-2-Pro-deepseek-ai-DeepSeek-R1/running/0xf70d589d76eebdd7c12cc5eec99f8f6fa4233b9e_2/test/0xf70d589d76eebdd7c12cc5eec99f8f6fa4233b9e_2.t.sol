// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

// Malicious contract that always reverts when called
contract MaliciousContract {
    function fail() external payable {
        revert("Call failure");
    }
}

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public whaleGiveaway;
    MaliciousContract public malicious;

    function setUp() public {
        // Deploy contracts
        whaleGiveaway = new WhaleGiveaway2();
        malicious = new MaliciousContract();
    }

    function testUncheckedExternalCall() public {
        // Verify initial contract balance is 0
        assertEq(address(whaleGiveaway).balance, 0, "Initial balance should be zero");

        // Differential state snapshot BEFORE attack
        (uint whaleBalanceBefore, uint maliciousBalanceBefore) = _getBalances();
        console.log("--- BEFORE-Trigger State ---");
        console.log("WhaleGiveaway2 Balance:", whaleBalanceBefore);
        console.log("Malicious Contract Balance:", maliciousBalanceBefore);

        // Prepare malicious call data
        bytes memory data = abi.encodeWithSignature("fail()");
        address maliciousAddr = address(malicious);
        vm.deal(address(this), 1 ether);
        hoax(address(this)); // Sets msg.sender and tx.origin

        console.log("--- Trigger: Call Command with 1 ether ---");
        whaleGiveaway.Command{value: 1 ether}(maliciousAddr, data);

        // Differential state snapshot AFTER attack
        (uint whaleBalanceAfter, uint maliciousBalanceAfter) = _getBalances();
        console.log("--- AFTER-Trigger State ---");
        console.log("WhaleGiveaway2 Balance:", whaleBalanceAfter);
        console.log("Malicious Contract Balance:", maliciousBalanceAfter);

        console.log("--- Balance Changes ---");
        console.log("WhaleGiveaway2 Delta:", whaleBalanceAfter - whaleBalanceBefore);
        console.log("Malicious Contract Delta:", maliciousBalanceAfter - maliciousBalanceBefore);

        // Vulnerability verification - funds remain in WhaleGiveaway2
        bool vulnerabilityExists = (whaleBalanceAfter == whaleBalanceBefore + 1 ether) && 
                                  (maliciousBalanceAfter == maliciousBalanceBefore);
                                  
        // Final verdict with conditional logic
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Funds remained in WhaleGiveaway2 contract after failed external call");
        } else {
            console.log("Vulnerability not Exist: Funds were not trapped in the contract");
        }
    }

    // Helper function to capture both balances
    function _getBalances() private view returns (uint, uint) {
        return (address(whaleGiveaway).balance, address(malicious).balance);
    }
}