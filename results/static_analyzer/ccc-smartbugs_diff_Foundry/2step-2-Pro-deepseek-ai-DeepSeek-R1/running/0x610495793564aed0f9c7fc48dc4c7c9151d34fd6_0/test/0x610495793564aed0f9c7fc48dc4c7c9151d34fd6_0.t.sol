// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x610495793564aed0f9c7fc48dc4c7c9151d34fd6.sol";

contract ExpensiveFallback {
    SimpleWallet public wallet;
    uint256 public dummy;

    function deployWallet() public {
        wallet = new SimpleWallet();
    }

    function callWithdraw(uint256 amount) public {
        wallet.withdraw(amount);
    }

    // Fallback function consuming >2300 gas
    receive() external payable {
        dummy = 1; // Storage write operation
    }
}

contract SimpleWalletWithdrawTest is Test {
    ExpensiveFallback public greedy;
    SimpleWallet public wallet;

    function setUp() public {
        greedy = new ExpensiveFallback();
        greedy.deployWallet();
        wallet = greedy.wallet();
    }

    function testWithdrawRevertsDueToGasLimit() public {
        // Fund the wallet contract (not the owner)
        uint256 initialBalance = 1 ether;
        vm.deal(address(wallet), initialBalance);

        console2.log("--- BEFORE-Trigger Withdraw Attempt ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 totalWithdrawnBefore = wallet.totalWithdrawn();
        console2.log("Wallet balance before: %s", walletBalanceBefore);
        console2.log("Total withdrawn before: %s", totalWithdrawnBefore);

        console2.log("--- Trigger Withdraw (Expected to revert) ---");
        // Attempt withdrawal (will fail due to expensive fallback)
        vm.expectRevert();
        greedy.callWithdraw(1 wei);

        console2.log("--- AFTER-Trigger Withdraw Attempt ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 totalWithdrawnAfter = wallet.totalWithdrawn();
        console2.log("Wallet balance after: %s", walletBalanceAfter);
        console2.log("Total withdrawn after: %s", totalWithdrawnAfter);

        bool balanceUnchanged = walletBalanceBefore == walletBalanceAfter;
        bool withdrawnUnchanged = totalWithdrawnBefore == totalWithdrawnAfter;
        bool stateUnchanged = balanceUnchanged && withdrawnUnchanged;
        console2.log("State changed? %s", stateUnchanged ? "NO" : "YES");

        if (stateUnchanged) {
            console2.log("Vulnerability Exists: Fallback function consumes over 2300 gas causing transfer to fail and revert");
        } else {
            console2.log("Vulnerability not Exist: Withdrawal succeeded or state changed unexpectedly");
        }
    }
}