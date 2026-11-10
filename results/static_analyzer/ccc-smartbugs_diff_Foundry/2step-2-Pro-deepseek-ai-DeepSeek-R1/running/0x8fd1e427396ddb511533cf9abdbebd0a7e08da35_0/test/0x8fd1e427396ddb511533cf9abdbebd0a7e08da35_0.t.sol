// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract MockMaliciousToken {
    bool public transferSuccess;

    function setTransferResult(bool success) external {
        transferSuccess = success;
    }

    function transfer(address, uint256) external returns (bool) {
        return transferSuccess;
    }
}

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MockMaliciousToken public maliciousToken;
    address public constant OWNER = address(0x1);
    address public constant RECIPIENT = address(0x2);

    function setUp() public {
        vm.startPrank(OWNER);
        tokenBank = new TokenBank();
        maliciousToken = new MockMaliciousToken();
        vm.stopPrank();
    }

    function test_withdrawTokenFailsSilently() public {
        vm.startPrank(OWNER);
        
        // Configure token to return false on transfer
        maliciousToken.setTransferResult(false);
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Malicious token transfer configured to FAIL (return false)");
        console.log("WithdrawToken ready to be executed with failing token");

        console.log("--- Trigger WithdrawToken ---");
        // This call should complete without reverting despite failed transfer
        tokenBank.WithdrawToken(
            address(maliciousToken),
            100,
            RECIPIENT
        );
        
        console.log("--- AFTER-Trigger State ---");
        console.log("WithdrawToken execution completed without reverting");
        console.log("Transaction persisted despite token transfer failure");
        vm.stopPrank();

        // Final verdict based on transaction behavior
        console.log("Vulnerability Exists: WithdrawToken does not revert when token transfer fails");
    }
}