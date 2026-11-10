// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract TimestampManipulationTest is Test {
    Log public logFile; // Renamed to avoid conflict
    WALLET public wallet;
    address payable alice = payable(address(0x123));
    uint public constant DEPOSIT_AMOUNT = 10 ether;
    uint public constant COLLECT_AMOUNT = 5 ether;

    // Add receive function to handle ETH transfers
    receive() external payable {}

    function setUp() public {
        // Deploy Log contract
        logFile = new Log();
        // Deploy wallet with Log contract address
        wallet = new WALLET(address(logFile));
        // Fund Alice
        vm.deal(alice, DEPOSIT_AMOUNT);
    }

    function testTimestampManipulation() public {
        uint unlockTime = block.timestamp + 1 days;

        // Alice deposits funds
        vm.prank(alice);
        wallet.Put{value: DEPOSIT_AMOUNT}(unlockTime);

        // Ensure deposit was successful
        assertEq(address(wallet).balance, DEPOSIT_AMOUNT, "Wallet should hold deposited ether");

        // Should fail to collect before unlock time
        vm.prank(alice);
        wallet.Collect(COLLECT_AMOUNT);
        assertEq(alice.balance, 0, "Alice shouldn't receive funds before unlock time");

        console2.log("--- BEFORE-Trigger Timestamp Manipulation ---");
        uint alicePreBalance = alice.balance;
        uint walletPreBalance = address(wallet).balance;
        console2.log("Alice Balance (pre): %s", alicePreBalance);
        console2.log("Wallet Balance (pre): %s", walletPreBalance);

        console2.log("--- Trigger Warp and Collect ---");
        // Fast forward to unlock time + 1 second
        vm.warp(unlockTime + 1);
        // Collect funds after unlocking
        vm.prank(alice);
        wallet.Collect(5 ether);

        console2.log("--- AFTER-Trigger Timestamp Manipulation ---");
        uint alicePostBalance = alice.balance;
        uint walletPostBalance = address(wallet).balance;
        console2.log("Alice Balance (post): %s", alicePostBalance);
        console2.log("Wallet Balance (post): %s", walletPostBalance);

        // Calculate balance changes
        uint aliceDiff = alicePostBalance - alicePreBalance;
        uint walletDiff = walletPreBalance - walletPostBalance;
        console2.log("Alice Balance Change: %s", aliceDiff);
        console2.log("Wallet Balance Change: %s", walletDiff);

        // Final vulnerability check based on state changes
        if (aliceDiff == COLLECT_AMOUNT && walletDiff == COLLECT_AMOUNT) {
            console2.log("Vulnerability Exists: Timestamp manipulation led to unauthorized fund withdrawal");
        } else {
            console2.log("Vulnerability not Exist: Timestamp manipulation did not alter balances as expected");
        }
    }
}