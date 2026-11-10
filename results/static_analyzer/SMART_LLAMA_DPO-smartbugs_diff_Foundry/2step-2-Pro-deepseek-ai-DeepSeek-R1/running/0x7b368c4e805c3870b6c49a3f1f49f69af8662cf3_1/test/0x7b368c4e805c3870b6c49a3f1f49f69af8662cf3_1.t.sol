// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol";

contract WalletTimestampTest is Test {
    // Renamed to avoid conflict with Forge's 'log' event
    Log public logContract;
    W_WALLET public wallet;
    
    address user = address(1);
    uint256 constant DEPOSIT_AMOUNT = 1 ether;
    uint256 constant UNLOCK_DELAY = 100 seconds;

    function setUp() public {
        // Deploy required contracts using renamed instance
        logContract = new Log();
        wallet = new W_WALLET(address(logContract));
        
        // Fund user
        vm.deal(user, DEPOSIT_AMOUNT);
    }

    function testTimestampManipulation() public {
        uint256 depositTime = block.timestamp;
        // User deposits funds with 100-second unlock period
        uint256 unlockTime = depositTime + UNLOCK_DELAY;
        vm.prank(user);
        wallet.Put{value: DEPOSIT_AMOUNT}(unlockTime);
        
        // Only 50 seconds pass in real-time
        vm.warp(depositTime + 50 seconds);

        // Attempt early withdrawal (should fail)
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 userBalanceBefore = user.balance;
        vm.prank(user);
        wallet.Collect(DEPOSIT_AMOUNT);
        
        // Verify funds remain locked
        assertEq(
            address(wallet).balance, 
            contractBalanceBefore, 
            "Contract balance changed during early withdrawal attempt"
        );
        assertEq(
            user.balance, 
            userBalanceBefore, 
            "User balance changed during early withdrawal attempt"
        );

        // BEGIN DIFFERENTIAL CHECKS
        console2.log("--- BEFORE-Trigger (Manipulated Withdrawal) ---");
        console2.log("Wallet balance (ETH): %d", address(wallet).balance);
        console2.log("User balance (ETH): %d", user.balance);
        
        console2.log("--- Trigger: Timestamp Manipulation & Withdraw ---");
        // Simulate miner timestamp manipulation (jump to unlockTime+1)
        vm.warp(unlockTime + 1);

        // Execute withdrawal with manipulated timestamp
        contractBalanceBefore = address(wallet).balance;
        userBalanceBefore = user.balance;
        vm.prank(user);
        wallet.Collect(DEPOSIT_AMOUNT);

        console2.log("--- AFTER-Trigger (Manipulated Withdrawal) ---");
        console2.log("Wallet balance (ETH): %d", address(wallet).balance);
        console2.log("User balance (ETH): %d", user.balance);
        // END DIFFERENTIAL CHECKS

        // Verify premature fund withdrawal
        assertEq(
            address(wallet).balance, 
            contractBalanceBefore - DEPOSIT_AMOUNT, 
            "Contract balance not reduced after manipulated withdrawal"
        );
        assertEq(
            user.balance, 
            userBalanceBefore + DEPOSIT_AMOUNT, 
            "User balance not increased after manipulated withdrawal"
        );
        assertLt(
            50 seconds, 
            UNLOCK_DELAY, 
            "Real time elapsed exceeds or equals unlock period"
        );

        // FINAL VERDICT
        if (
            (address(wallet).balance == 0) && 
            (user.balance == DEPOSIT_AMOUNT) && 
            (50 seconds < UNLOCK_DELAY)
        ) {
            console2.log("Vulnerability Exists: Funds were withdrawn after only 50 real seconds via timestamp manipulation");
        } else {
            console2.log("Vulnerability not Exist: Fund balances unchanged or timing condition mismatch");
        }
    }
}