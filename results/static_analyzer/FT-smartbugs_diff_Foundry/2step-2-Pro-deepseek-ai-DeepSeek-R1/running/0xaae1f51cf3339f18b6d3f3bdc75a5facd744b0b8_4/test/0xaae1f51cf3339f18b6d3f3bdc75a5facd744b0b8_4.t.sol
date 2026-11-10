// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract DEPBANKHistoryTest is Test {
    DEP_BANK public depBank;
    uint256 public constant ITERATIONS = 1000;

    function setUp() public {
        depBank = new DEP_BANK();
        depBank.SetLogFile(address(new LogFile()));
        depBank.SetMinSum(0);
    }

    function test_ArrayGrowthPotential() public {
        // Deposit to establish a balance
        vm.deal(address(this), 1 ether);
        depBank.Deposit{value: 1 ether}();
        
        console.log("--- Performing Collect(0) Operations ---");
        bool allIterationsCompleted;
        try this.runLoop() {
            allIterationsCompleted = true;
        } catch {
            allIterationsCompleted = false;
        }

        if (allIterationsCompleted) {
            console.log("Vulnerability Exists: No revert occurred during 1000 Collect(0) calls, indicating potential unbounded array growth");
        } else {
            console.log("Vulnerability not Exist: Operations reverted, suggesting bounds may exist");
        }
    }
    
    function runLoop() public {
        // Perform multiple Collect(0) calls
        for (uint i = 0; i < ITERATIONS; i++) {
            depBank.Collect(0);
        }
    }
}