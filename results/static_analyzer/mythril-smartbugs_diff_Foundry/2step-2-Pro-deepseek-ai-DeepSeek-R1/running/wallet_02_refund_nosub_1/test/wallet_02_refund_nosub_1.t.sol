// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet wallet;
    address owner = address(0x1);
    address depositor = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(depositor, 1 ether);
        vm.deal(attacker, 1 ether);
        
        vm.prank(owner);
        wallet = new Wallet();
    }

    function testNonCreatorCanWithdraw() public {
        // Step 1: Depositor funds the contract
        vm.prank(depositor);
        wallet.deposit{value: 1 ether}();

        // Step 2: Attacker deposits to gain withdrawable balance
        vm.startPrank(attacker);
        wallet.deposit{value: 0.1 ether}();

        // Differential snapshot BEFORE withdrawal
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 attackerInternalBefore = wallet.getBalance(attacker);
        
        console.log("Attacker ETH Balance Before:", attackerBalanceBefore);
        console.log("Contract ETH Balance Before:", contractBalanceBefore);
        console.log("Attacker Internal Balance Before:", attackerInternalBefore);

        console.log("--- Trigger Withdraw ---");
        // Step 3: Attacker withdraws their deposited amount
        wallet.withdraw(0.1 ether);

        // Differential snapshot AFTER withdrawal
        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 attackerInternalAfter = wallet.getBalance(attacker);
        
        console.log("Attacker ETH Balance After:", attackerBalanceAfter);
        console.log("Contract ETH Balance After:", contractBalanceAfter);
        console.log("Attacker Internal Balance After:", attackerInternalAfter);

        // Calculate state changes
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 internalChange = attackerInternalBefore - attackerInternalAfter;

        console.log("Attacker ETH Gain:", attackerGain);
        console.log("Contract ETH Loss:", contractLoss);
        console.log("Attacker Internal Change:", internalChange);

        // Existing assertions for test logic
        assertEq(attackerBalanceAfter, attackerBalanceBefore + 0.1 ether, "Attacker should receive their ETH");
        assertEq(contractBalanceAfter, contractBalanceBefore - 0.1 ether, "Contract should lose ETH");
        assertEq(attackerInternalAfter, 0, "Attacker contract balance should be 0");

        // Vulnerability verdict logic
        bool vulnExists = attackerGain == 0.1 ether &&
                        contractLoss == 0.1 ether &&
                        attackerInternalAfter == 0 &&
                        internalChange == 0.1 ether;

        if (vulnExists) {
            console.log("Vulnerability Exists: Non-creator account successfully withdrew funds");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate unauthorized access");
        }
        vm.stopPrank();
    }
}