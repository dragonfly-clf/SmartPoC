// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_04_confused_sign.sol";

contract WalletTest is Test {
    Wallet wallet;
    address owner = address(0x1);
    address user1 = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        vm.prank(owner);
        wallet = new Wallet();
        
        // User1 deposits some funds
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        wallet.deposit{value: 5 ether}();
    }

    function testUnauthorizedWithdrawal() public {
        // --- BEFORE-Trigger Snapshot ---
        console.log("--- BEFORE-Trigger Unauthorized Withdrawal ---");
        uint256 initialUserBalance = wallet.getBalance(user1);
        uint256 initialAttackerBalance = attacker.balance;
        uint256 initialContractBalance = address(wallet).balance;
        console.log("user1 balance in wallet:", initialUserBalance);
        console.log("attacker ETH balance:", initialAttackerBalance);
        console.log("contract ETH balance:", initialContractBalance);

        // Trigger: Attempt unauthorized withdrawal
        console.log("--- Trigger Unauthorized Withdrawal ---");
        vm.startPrank(attacker);
        (bool success, ) = address(wallet).call(
            abi.encodeWithSignature("withdraw(uint256)", 5 ether)
        );
        vm.stopPrank();
        console.log("Transaction success? ", success);
        
        // --- AFTER-Trigger Snapshot ---
        console.log("--- AFTER-Trigger Unauthorized Withdrawal ---");
        uint256 userBalanceAfter = wallet.getBalance(user1);
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 contractBalanceAfter = address(wallet).balance;
        console.log("user1 balance in wallet:", userBalanceAfter);
        console.log("attacker ETH balance:", attackerBalanceAfter);
        console.log("contract ETH balance:", contractBalanceAfter);

        // Check for unexpected state changes
        bool balancesChanged = (initialUserBalance != userBalanceAfter) ||
                               (initialAttackerBalance != attackerBalanceAfter) ||
                               (initialContractBalance != contractBalanceAfter);
        
        // --- Vuln verdict ---
        if (success || balancesChanged) {
            console.log("Vulnerability confirmed: Unauthorized withdrawal succeeded or caused state changes");
            console.log("Vulnerability Exists: Attacker bypassed authorization or modified state");
        } else {
            console.log("Vulnerability not confirmed: Unauthorized withdrawal reverted without side-effects");
            console.log("Vulnerability not Exist: Authorization mechanism prevents unauthorized withdrawals");
        }
    }

    function testProperWithdrawal() public {
        // Check initial balances
        uint256 initialUserBalance = wallet.getBalance(user1);
        uint256 initialContractBalance = address(wallet).balance;
        uint256 initialUserEthBalance = user1.balance;
        assertEq(initialUserBalance, 5 ether);
        assertEq(initialContractBalance, 5 ether);

        // User1 withdraws their own funds
        vm.prank(user1);
        wallet.withdraw(5 ether);

        // Verify withdrawal was successful
        assertEq(wallet.getBalance(user1), 0);
        assertEq(address(wallet).balance, 0);
        assertEq(user1.balance, initialUserEthBalance + 5 ether);
    }

    function testCannotWithdrawMoreThanBalance() public {
        // Check initial balance
        assertEq(wallet.getBalance(user1), 5 ether);

        // User1 tries to withdraw more than deposited
        vm.prank(user1);
        vm.expectRevert();
        wallet.withdraw(6 ether);

        // Verify balance remains unchanged
        assertEq(wallet.getBalance(user1), 5 ether);
    }
}