// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankWithdrawTokenTest is Test {
    TokenBank tokenBank;
    MockToken token;

    function setUp() public {
        tokenBank = new TokenBank();
        token = new MockToken(false);
    }

    function test_WithdrawToken_DoesNotRevertOnTransferFailure() public {
        console2.log("--- BEFORE-Trigger Operation ---");
        console2.log("Pre-State: No state change expected since mock token always returns false");

        console2.log("--- Trigger WithdrawToken ---");
        tokenBank.WithdrawToken(address(token), 100, address(this));

        console2.log("--- AFTER-Trigger Operation ---");
        console2.log("Post-State: Function completed without reverting");
        console2.log("Vulnerability Exists: The function WithdrawToken completed execution even though the token transfer returned false");
    }
}

contract MockToken {
    bool public transferResult;

    constructor(bool _transferResult) {
        transferResult = _transferResult;
    }

    function transfer(address, uint256) public returns (bool) {
        return transferResult;
    }
}