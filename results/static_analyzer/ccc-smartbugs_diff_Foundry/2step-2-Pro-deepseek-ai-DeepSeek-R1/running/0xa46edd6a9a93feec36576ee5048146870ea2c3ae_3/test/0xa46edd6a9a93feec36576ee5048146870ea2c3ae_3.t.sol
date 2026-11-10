// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract MessagePaddingVulnerabilityTest is Test {
    EBU public vulnContract;
    MockToken public token;
    
    address user = makeAddr("user");
    address constant recipient1 = address(0x01);
    address constant recipient2 = address(0x02);
    
    function setUp() public {
        vulnContract = new EBU();
        token = new MockToken();
        
        // Authorize mock token as approved
        vulnContract.authorizeToken(address(token));
    }

    function test_transferIgnoresCallFailures() public {
        // Set token to fail on second transfer
        token.setFailCondition(2);
        
        address[] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;
        
        uint[] memory amounts = new uint[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint preBal1 = vulnContract.getUserBalance(recipient1);
        uint preBal2 = vulnContract.getUserBalance(recipient2);
        console.log("Recipient1 balance (before): ", preBal1);
        console.log("Recipient2 balance (before): ", preBal2);
        
        console.log("--- Trigger Transfer ---");
        // Execute transfer operation
        vulnContract.transfer(user, address(token), recipients, amounts);
        console.log("Transfer operation executed");
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint postBal1 = vulnContract.getUserBalance(recipient1);
        uint postBal2 = vulnContract.getUserBalance(recipient2);
        console.log("Recipient1 balance (after): ", postBal1);
        console.log("Recipient2 balance (after): ", postBal2);
        
        uint change1 = postBal1 - preBal1;
        uint change2 = postBal2 - preBal2;
        console.log("Balance change for recipient1: ", change1);
        console.log("Balance change for recipient2: ", change2);
        
        // Verdict determination
        if (change2 > 0) {
            console.log("Vulnerability Exists: Contract state updated for recipient2 despite failed token transfer");
        } else {
            console.log("Vulnerability not Exist: Contract state correctly preserved when transfers fail");
        }

        // Assertions
        assertEq(vulnContract.getUserBalance(recipient1), 100, "Recipient 1 balance should be updated");
        assertEq(vulnContract.getUserBalance(recipient2), 200, "Recipient 2 balance updated despite failed token transfer");
    }
}

contract MockToken {
    uint256 private failAfter;
    address public constant NULL_ADDRESS = address(0);

    function setFailCondition(uint256 _callNumber) public {
        failAfter = _callNumber;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        failAfter--;
        return failAfter > 0;
    }
}