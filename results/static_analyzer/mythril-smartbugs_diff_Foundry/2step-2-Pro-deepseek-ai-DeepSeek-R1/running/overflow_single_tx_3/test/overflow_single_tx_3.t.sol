// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowSingleTransactionTest is Test {
    IntegerOverflowSingleTransaction public targetContract;
    
    function setUp() public {
        targetContract = new IntegerOverflowSingleTransaction();
    }

    function test_overflowlocalonly_overflow() public {
        console.log("--- BEFORE-Trigger Overflowlocalonly ---");
        uint256 beforeTotal = targetContract.totalOperations();
        uint256 beforeUser = targetContract.userOperations(address(this));
        console.log("Total operations before:", beforeTotal);
        console.log("User operations before:", beforeUser);

        uint256 maxUint = type(uint256).max;
        uint256 startValue = maxUint - 1;
        
        console.log("--- Trigger Overflowlocalonly(2) ---");
        targetContract.overflowlocalonly(2);

        console.log("--- AFTER-Trigger Overflowlocalonly ---");
        uint256 afterTotal = targetContract.totalOperations();
        uint256 afterUser = targetContract.userOperations(address(this));
        console.log("Total operations after:", afterTotal);
        console.log("User operations after:", afterUser);

        bool totalIncreased = (afterTotal == beforeTotal + 1);
        bool userIncreased = (afterUser == beforeUser + 1);
        bool vulnerabilityExists = totalIncreased && userIncreased;

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Counters incremented despite overflow");
        } else {    
            console.log("Vulnerability not Exist: Counter increment violated");
        }
    }
}