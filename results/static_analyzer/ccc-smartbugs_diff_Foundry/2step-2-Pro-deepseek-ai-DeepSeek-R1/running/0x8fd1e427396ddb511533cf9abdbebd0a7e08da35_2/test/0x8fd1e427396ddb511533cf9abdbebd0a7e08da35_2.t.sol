// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract MaliciousHolder {
    receive() external payable {
        revert("ETH transfer rejected");
    }
}

contract TokenBankTest is Test {
    TokenBank public bank;
    MaliciousHolder public malHolder;
    address owner = makeAddr("owner");
    uint256 constant DEPOSIT_AMOUNT = 1 ether;
    uint256 constant BANK_INITIAL_BALANCE = 2 ether;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        bank = new TokenBank();
        malHolder = new MaliciousHolder();
        vm.stopPrank();
    }

    function test__WithdrawToHolder__FailedTransferUpdatesBalance() public {
        // Owner deposits 1 ether
        vm.prank(owner);
        bank.Deposit{value: DEPOSIT_AMOUNT}();
        
        // Malicious holder deposits 1 ether
        vm.deal(address(malHolder), DEPOSIT_AMOUNT);
        vm.prank(address(malHolder));
        bank.Deposit{value: DEPOSIT_AMOUNT}();

        // Verify initial state
        assertEq(bank.Holders(owner), DEPOSIT_AMOUNT);
        assertEq(bank.Holders(address(malHolder)), DEPOSIT_AMOUNT);
        assertEq(address(bank).balance, BANK_INITIAL_BALANCE);

        // Differential validation: PRE-storage snapshot
        console2.log("--- BEFORE-Trigger WithdrawToHolder ---");
        uint256 pre_malHolderBalance = bank.Holders(address(malHolder));
        uint256 pre_bankETHBalance = address(bank).balance;
        console2.log("Pre-malHolder token balance:", pre_malHolderBalance);
        console2.log("Pre-bank ETH balance:       ", pre_bankETHBalance);

        // Trigger vulnerable function
        console2.log("--- Trigger: WithdrawToHolder ---");
        vm.prank(owner);
        bank.WithdrawToHolder(address(malHolder), DEPOSIT_AMOUNT);

        // Differential validation: POST-storage snapshot
        console2.log("--- AFTER-Trigger WithdrawToHolder ---");
        uint256 post_malHolderBalance = bank.Holders(address(malHolder));
        uint256 post_bankETHBalance = address(bank).balance;
        console2.log("Post-malHolder token balance:", post_malHolderBalance);
        console2.log("Post-bank ETH balance:       ", post_bankETHBalance);

        // Verify state changes - both values should be identical to pre-state
        bool holderBalanceChanged = (pre_malHolderBalance != post_malHolderBalance);
        bool bankBalanceChanged = (pre_bankETHBalance != post_bankETHBalance);
        console2.log("Holder balance changed:    ", holderBalanceChanged);
        console2.log("Bank ETH balance changed:  ", bankBalanceChanged);

        // Final vulnerability verdict
        bool vulnerabilityExists = holderBalanceChanged && !bankBalanceChanged;
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: WithdrawToHolder updates holder balance on failed transfer");
        } else {
            console2.log("Vulnerability not Exist: WithdrawToHolder behaves correctly");
        }

        // Original assertions remain
        assertEq(
            bank.Holders(address(malHolder)),
            0,
            "Holder balance updated despite failed ETH transfer"
        );
        assertEq(
            address(bank).balance,
            BANK_INITIAL_BALANCE,
            "Bank ETH balance changed despite failed transfer"
        );
        assertEq(
            address(malHolder).balance,
            0,
            "Malicious holder received ETH despite revert"
        );
    }
}