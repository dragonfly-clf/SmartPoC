// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8c7777c45481dba411450c228cb692ac3d550344.sol";

contract ETHVaultLogStateTest is Test {
    Log public myLog;
    ETH_VAULT public ethVault;
    address payable public user;

    function setUp() public {
        myLog = new Log();
        ethVault = new ETH_VAULT(address(myLog));
        user = payable(makeAddr("user"));
        vm.deal(user, 2 ether);
    }

    function testStateChangeInLog() public {
        console2.log("\n======= NEW TEST RUN =======");
        
        // Pre-deposit log state
        console2.log("--- BEFORE Deposit Trigger ---");
        console2.log("Getting initial LastMsg state:");
        emitLastMsgState();
        uint preDepositTime = block.timestamp;

        // Trigger deposit
        console2.log("--- Trigger Deposit ---");
        vm.prank(user);
        ethVault.Deposit{value: 1 ether}();
        console2.log("Deposit executed: user sent 1 ether");

        // Post-deposit log state
        console2.log("--- AFTER Deposit Trigger ---");
        console2.log("Snapshot after Deposit:");
        emitLastMsgState();
        
        // Deposit verification
        (
            bool depositVerified,
            string memory depositReason
        ) = verifyStateChange(
            user,
            1 ether,
            "Deposit",
            preDepositTime
        );

        // Pre-withdrawal log state
        console2.log("\n--- BEFORE CashOut Trigger ---");
        console2.log("Getting state before withdrawal:");
        emitLastMsgState();
        uint preWithdrawTime = block.timestamp;

        // Trigger withdrawal
        console2.log("--- Trigger CashOut ---");
        vm.prank(user);
        ethVault.CashOut(0.5 ether);
        console2.log("Withdrawal executed: user cashed out 0.5 ether");

        // Post-withdrawal log state
        console2.log("--- AFTER CashOut Trigger ---");
        console2.log("Snapshot after CashOut:");
        emitLastMsgState();

        // Withdrawal verification
        (
            bool withdrawVerified,
            string memory withdrawReason
        ) = verifyStateChange(
            user,
            0.5 ether,
            "CashOut",
            preWithdrawTime
        );

        // Final vulnerability verdict
        console2.log("\n========= VERDICT =========");
        if (depositVerified && withdrawVerified) {
            console2.log("Vulnerability Exists: Log state was modified as expected");
        } else {
            console2.log(
                "Vulnerability not Exist: Log state unchanged (%s / %s)",
                depositReason,
                withdrawReason
            );
        }
    }

    function emitLastMsgState() internal {
        console2.log("State snapshot:");
        console2.log("  Sender: %s", myLog.LastMsg().Sender);
        console2.log("  Value: %s", myLog.LastMsg().Val);
        console2.log("  Data: '%s'", myLog.LastMsg().Data);
        console2.log("  Time: %s", myLog.LastMsg().Time);
    }

    function verifyStateChange(
        address expectedSender,
        uint expectedValue,
        string memory expectedData,
        uint preTime
    ) internal view returns (bool, string memory) {
        address sender = myLog.LastMsg().Sender;
        uint val = myLog.LastMsg().Val;
        string memory data = myLog.LastMsg().Data;
        uint time = myLog.LastMsg().Time;

        bool senderMatch = sender == expectedSender;
        bool valueMatch = val == expectedValue;
        bool dataMatch = keccak256(bytes(data)) == 
                         keccak256(bytes(expectedData));
        bool timeMatch = time == preTime;  // Changed to equality check

        if (!senderMatch) return (false, "INCORRECT_SENDER");
        if (!valueMatch) return (false, "INCORRECT_VALUE");
        if (!dataMatch) return (false, "INCORRECT_OPERATION");
        if (!timeMatch) return (false, "TIMESTAMP_NOT_UPDATED");
        
        return (true, "ALL_CHECKS_PASSED");
    }
}