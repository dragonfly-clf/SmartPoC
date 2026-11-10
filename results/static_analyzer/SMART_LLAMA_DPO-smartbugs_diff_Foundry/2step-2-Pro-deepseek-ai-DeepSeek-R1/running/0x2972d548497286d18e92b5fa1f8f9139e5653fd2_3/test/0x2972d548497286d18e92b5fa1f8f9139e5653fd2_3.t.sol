// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract OverflowTest is Test {
    demo batchContract;
    MaliciousToken token;
    address victim = address(0x999);
    
    function setUp() public {
        // Deploy the vulnerable contract
        batchContract = new demo();
        
        // Deploy malicious token that always returns success on transfers
        token = new MaliciousToken();
        
        // Approve malicious token so demo contract will accept it
        batchContract.approveToken(address(token));
    }

    function test_IntegerOverflowVulnerability() public {
        uint256 almostMax = type(uint256).max - 1;
        
        // Create transaction parameters
        address[] memory recipient = new address[](1);
        recipient[0] = victim;
        uint256[] memory amounts = new uint256[](1);
        
        // First transfer: set balance to almost max value
        amounts[0] = almostMax;
        batchContract.transfer(address(this), address(token), recipient, amounts);
        assertEq(batchContract.getUserBalance(victim), almostMax);
        
        // Second transfer: add 1 to reach max value
        amounts[0] = 1;
        batchContract.transfer(address(this), address(token), recipient, amounts);
        assertEq(batchContract.getUserBalance(victim), type(uint256).max);
        
        console.log("--- BEFORE-Trigger Overflow Transfer ---");
        uint256 victimBalanceBefore = batchContract.getUserBalance(victim);
        console.log("Victim balance before overflow attempt: %s", victimBalanceBefore);

        console.log("--- Trigger Overflow Transfer ---");
        // Third transfer: attempt to overflow the balance
        amounts[0] = 1;
        vm.expectRevert(stdError.arithmeticError);
        batchContract.transfer(address(this), address(token), recipient, amounts);

        console.log("--- AFTER-Trigger Overflow Transfer ---");
        uint256 victimBalanceAfter = batchContract.getUserBalance(victim);
        console.log("Victim balance after overflow attempt: %s", victimBalanceAfter);
        
        // Verify balance remains unchanged after overflow revert
        assertEq(victimBalanceAfter, victimBalanceBefore, "Balance should not change after overflow attempt");
        assertEq(batchContract.getUserBalance(victim), type(uint256).max, "Balance should be max");

        // Final verdict based on state comparison
        if (victimBalanceAfter == victimBalanceBefore) {
            console.log("Vulnerability not Exist: Overflow reverted correctly and user balance unchanged");
        } else {
            console.log("Vulnerability Exists: Balance changed after overflow attempt indicating successful exploit");
        }
    }
}

contract MaliciousToken {
    function transferFrom(address, address, uint256) public pure returns (bool) {
        return true;
    }
}