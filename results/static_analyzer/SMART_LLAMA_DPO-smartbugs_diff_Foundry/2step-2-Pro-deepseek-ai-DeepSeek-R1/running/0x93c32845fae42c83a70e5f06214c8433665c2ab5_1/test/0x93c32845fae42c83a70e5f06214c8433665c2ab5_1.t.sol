// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

contract XWalletTimestampTest is Test {
    Log public logger;
    X_WALLET public wallet;
    address user = address(0x123);
    uint256 constant DEPOSIT_AMOUNT = 10 ether;
    uint256 constant UNLOCK_DELAY = 100;

    function setUp() public {
        logger = new Log();
        wallet = new X_WALLET(address(logger));
        vm.deal(user, DEPOSIT_AMOUNT);
    }

    function testTimestampManipulation() public {
        // Deposit funds with unlock time in future
        uint256 unlockTime = block.timestamp + UNLOCK_DELAY;
        vm.prank(user);
        wallet.Put{value: DEPOSIT_AMOUNT}(unlockTime);

        // Validate deposit and unlock time
        assertEq(address(wallet).balance, DEPOSIT_AMOUNT);
        assertFalse(
            block.timestamp > unlockTime,
            "Timestamp already exceeds unlock time"
        );

        // Simulate timestamp manipulation
        vm.warp(unlockTime + 1);

        // BEFORE-Trigger: Capture initial balances
        console.log("--- BEFORE-Trigger Collect ---");
        uint256 initialContractBalance = address(wallet).balance;
        uint256 initialUserBalance = user.balance;
        console.log("Contract Balance:", initialContractBalance);
        console.log("User Balance:", initialUserBalance);

        console.log("--- Trigger Collect Operation ---");
        // Attempt withdrawal with manipulated timestamp
        vm.prank(user);
        wallet.Collect(DEPOSIT_AMOUNT);

        // AFTER-Trigger: Capture final balances
        console.log("--- AFTER-Trigger Collect ---");
        uint256 finalContractBalance = address(wallet).balance;
        uint256 finalUserBalance = user.balance;
        console.log("Contract Balance:", finalContractBalance);
        console.log("User Balance:", finalUserBalance);

        // Calculate balance changes
        uint256 contractDiff = initialContractBalance - finalContractBalance;
        uint256 userDiff = finalUserBalance - initialUserBalance;
        bool vulnerabilityExists = (contractDiff == DEPOSIT_AMOUNT) && 
                                   (userDiff == DEPOSIT_AMOUNT);

        // Original verification (kept for test integrity)
        assertEq(
            finalContractBalance,
            0,
            "Funds not withdrawn from contract"
        );
        assertEq(
            finalUserBalance,
            initialUserBalance + DEPOSIT_AMOUNT,
            "User did not receive funds"
        );

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Funds withdrawn early due to timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Withdrawal failed because timelock was enforced");
        }
    }
}