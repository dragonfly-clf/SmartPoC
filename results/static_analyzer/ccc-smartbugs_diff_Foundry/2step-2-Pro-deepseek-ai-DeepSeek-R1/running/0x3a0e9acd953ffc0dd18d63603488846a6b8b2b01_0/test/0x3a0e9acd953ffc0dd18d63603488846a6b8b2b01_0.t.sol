// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract MaliciousToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MaliciousToken public maliciousToken;
    address owner = address(0x1);
    address receiver = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        maliciousToken = new MaliciousToken();
        vm.stopPrank();
    }

    function test_withdrawTokenIgnoresTransferFailure() public {
        console2.log("--- Trigger WithdrawToken ---");
        vm.prank(owner);
        bool isSuccess = true;
        try tokenBank.WithdrawToken(address(maliciousToken), 100 ether, receiver) {
            // Call completed without reverting
        } catch {
            isSuccess = false;
        }

        if (isSuccess) {
            console2.log("Vulnerability Exists: WithdrawToken ignored failed token transfer");
        } else {
            revert("Vulnerability not Exist: WithdrawToken reverts on failed token transfer");
        }
    }
}