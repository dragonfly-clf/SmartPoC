// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x610495793564aed0f9c7fc48dc4c7c9151d34fd6.sol";

contract SimpleWalletTest is Test {
    SimpleWallet wallet;
    address owner = address(0x1);
    address nonPayableContract = address(new NonPayableContract());

    function setUp() public {
        vm.startPrank(owner);
        wallet = new SimpleWallet();
        vm.deal(address(wallet), 10 ether); // Fund the wallet
        vm.stopPrank();
    }

    function testUncheckedSendMoney() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 nonPayableBalanceBefore = address(nonPayableContract).balance;
        console.log("Wallet balance (before):", walletBalanceBefore);
        console.log("Non-payable contract balance (before):", nonPayableBalanceBefore);

        uint256 sendAmount = 1 ether;
        
        console.log("--- Trigger: sendMoney ---");
        vm.expectEmit(true, true, true, true);
        emit SimpleWallet.MoneySent(nonPayableContract, sendAmount);
        vm.prank(owner);
        wallet.sendMoney(nonPayableContract, sendAmount, "");

        console.log("--- AFTER-Trigger State ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 nonPayableBalanceAfter = address(nonPayableContract).balance;
        console.log("Wallet balance (after):", walletBalanceAfter);
        console.log("Non-payable contract balance (after):", nonPayableBalanceAfter);

        bool walletBalanceUnchanged = walletBalanceAfter == walletBalanceBefore;
        bool contractBalanceUnchanged = nonPayableBalanceAfter == nonPayableBalanceBefore;
        console.log("Wallet balance unchanged:", walletBalanceUnchanged);
        console.log("Contract balance unchanged:", contractBalanceUnchanged);

        // Final vulnerability verdict
        if (walletBalanceUnchanged && contractBalanceUnchanged) {
            console.log("Vulnerability Exists: Balances unchanged after transfer, but MoneySent event emitted");
        } else {
            console.log("Vulnerability not Exist: Balances changed during transfer");
        }
    }
}

contract NonPayableContract {
    function dummy() public pure returns (bool) {
        return true;
    }
}