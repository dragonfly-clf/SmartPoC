// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/StdError.sol"; // Additional import for stdError.arithmeticError
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBankUnderflowTest is Test {
    TokenBank public tokenBank;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function test_WithdrawToken_Underflow() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Attacker native balance: %s", attacker.balance);
        console.log("TokenBank native balance: %s", address(tokenBank).balance);

        console.log("--- Trigger: WithdrawToken call ---");
        bytes memory data = abi.encodeCall(tokenBank.WithdrawToken, (address(0), 0, owner));
        vm.prank(attacker);
        (bool success, bytes memory returnData) = address(tokenBank).call(data);

        console.log("--- AFTER-Trigger State ---");
        if (!success) {
            bytes memory arithmeticError = stdError.arithmeticError;
            if (returnData.length >= arithmeticError.length && 
                keccak256(returnData) == keccak256(arithmeticError)) {
                console.log("WithdrawToken reverted with arithmetic underflow/overflow error");
                console.log("Vulnerability Exists: Arithmetic underflow occurred during token withdrawal");
            } else {
                console.log("WithdrawToken reverted for non-arithmetic reason");
                console.log("Vulnerability not Exist: Requires arithmetic underflow to exist");
            }
        } else {
            console.log("WithdrawToken executed without reverting");
            console.log("Vulnerability not Exist: Arithmetic underflow did not occur");
        }
    }
}